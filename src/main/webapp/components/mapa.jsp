<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Parámetros:
     modo      = "editar" (cliente ingresa dirección) | "ver" (delivery ve dirección)
     latitud   = coordenada (solo modo ver)
     longitud  = coordenada (solo modo ver)
     direccion = texto (solo modo ver)
--%>

<c:set var="modo"      value="${param.modo}"/>
<c:set var="latParam"  value="${param.latitud}"/>
<c:set var="lngParam"  value="${param.longitud}"/>
<c:set var="dirParam"  value="${param.direccion}"/>

<!-- Leaflet CSS -->
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
<!-- Leaflet JS -->
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

<div class="w-full flex flex-col gap-3">

    <c:if test="${modo == 'editar'}">
        <!-- Buscador de dirección -->
        <div class="relative">
            <input type="text" id="mapaBuscador"
                   placeholder="Busca tu dirección..."
                   autocomplete="off"
                   class="w-full border border-gray-200 rounded-xl px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-300 pr-10">
            <i class="fa-solid fa-magnifying-glass absolute right-3 top-2.5 text-gray-400 text-sm"></i>
            <!-- Sugerencias -->
            <div id="mapaSugerencias"
                 class="hidden absolute top-full left-0 right-0 bg-white border border-gray-200 rounded-xl shadow-lg z-30 max-h-48 overflow-y-auto mt-1">
            </div>
        </div>

        <!-- Campos ocultos para el form del checkout -->
        <input type="hidden" name="direccion" id="mapaDir">
        <input type="hidden" name="latitud"   id="mapaLat">
        <input type="hidden" name="longitud"  id="mapaLng">

        <!-- Dirección seleccionada -->
        <div id="mapaDirTexto" class="hidden text-xs text-gray-500 flex items-center gap-2 px-1">
            <i class="fa-solid fa-location-dot text-red-500"></i>
            <span id="mapaDirSpan"></span>
        </div>
    </c:if>

    <c:if test="${modo == 'ver' && not empty dirParam}">
        <div class="text-xs text-gray-500 flex items-center gap-2 px-1">
            <i class="fa-solid fa-location-dot text-red-500"></i>
            <span>${dirParam}</span>
        </div>
    </c:if>

    <!-- Mapa -->
    <div id="mapaLeaflet" class="w-full rounded-xl overflow-hidden border border-gray-200"
         style="height: 280px; z-index: 1;"></div>

    <c:if test="${modo == 'editar'}">
        <p class="text-xs text-gray-400 text-center">
            <i class="fa-solid fa-hand-pointer mr-1"></i>
            Haz clic en el mapa o arrastra el pin para ajustar tu ubicación
        </p>
    </c:if>

</div>

<script>
(function() {
    const modo = '${modo}';

    // Coordenadas iniciales
    let lat = -12.0464;
    let lng = -77.0428;
    let zoom = 13;

    <c:if test="${not empty latParam && not empty lngParam}">
        lat  = parseFloat('${latParam}');
        lng  = parseFloat('${lngParam}');
        zoom = 16;
    </c:if>

    // Inicializar mapa
    const mapa = L.map('mapaLeaflet').setView([lat, lng], zoom);

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap'
    }).addTo(mapa);

    // Marker
    const marker = L.marker([lat, lng], {
        draggable: modo === 'editar'
    }).addTo(mapa);

    if (modo === 'editar') {

        // Al arrastrar el pin
        marker.on('dragend', function() {
            const pos = marker.getLatLng();
            geocodificarInverso(pos.lat, pos.lng);
        });

        // Al hacer clic en el mapa
        mapa.on('click', function(e) {
            marker.setLatLng(e.latlng);
            geocodificarInverso(e.latlng.lat, e.latlng.lng);
        });

        // Buscador con Nominatim
        let timeoutBusqueda;
        document.getElementById('mapaBuscador').addEventListener('input', function() {
            clearTimeout(timeoutBusqueda);
            const texto = this.value.trim();
            if (texto.length < 3) {
                document.getElementById('mapaSugerencias').classList.add('hidden');
                return;
            }
            timeoutBusqueda = setTimeout(() => buscarDireccion(texto), 400);
        });

        // Cerrar sugerencias al hacer clic fuera
        document.addEventListener('click', function(e) {
            if (!e.target.closest('#mapaBuscador') && !e.target.closest('#mapaSugerencias')) {
                document.getElementById('mapaSugerencias').classList.add('hidden');
            }
        });
    }

    function buscarDireccion(texto) {
        const url = `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(texto)}&countrycodes=pe&limit=5&addressdetails=1`;
        fetch(url, { headers: { 'Accept-Language': 'es' } })
            .then(r => r.json())
            .then(resultados => {
                const lista = document.getElementById('mapaSugerencias');
                lista.innerHTML = '';
                if (resultados.length === 0) {
                    lista.innerHTML = '<div class="px-4 py-3 text-sm text-gray-400">Sin resultados</div>';
                    lista.classList.remove('hidden');
                    return;
                }
                resultados.forEach(r => {
                    const div = document.createElement('div');
                    div.className = 'px-4 py-3 text-sm text-gray-700 hover:bg-red-50 hover:text-red-600 cursor-pointer border-b border-gray-50 last:border-0';
                    div.innerHTML = `<i class="fa-solid fa-location-dot mr-2 text-red-400 text-xs"></i>${r.display_name}`;
                    div.addEventListener('click', () => {
                        const la = parseFloat(r.lat);
                        const ln = parseFloat(r.lon);
                        mapa.setView([la, ln], 17);
                        marker.setLatLng([la, ln]);
                        guardarUbicacion(la, ln, r.display_name);
                        document.getElementById('mapaBuscador').value = r.display_name;
                        lista.classList.add('hidden');
                    });
                    lista.appendChild(div);
                });
                lista.classList.remove('hidden');
            })
            .catch(() => {});
    }

    function geocodificarInverso(la, ln) {
        const url = `https://nominatim.openstreetmap.org/reverse?format=json&lat=${la}&lon=${ln}&accept-language=es`;
        fetch(url)
            .then(r => r.json())
            .then(data => {
                const dir = data.display_name || `${la.toFixed(6)}, ${ln.toFixed(6)}`;
                guardarUbicacion(la, ln, dir);
                document.getElementById('mapaBuscador').value = dir;
            })
            .catch(() => guardarUbicacion(la, ln, `${la.toFixed(6)}, ${ln.toFixed(6)}`));
    }

    function guardarUbicacion(la, ln, dir) {
        document.getElementById('mapaLat').value = la;
        document.getElementById('mapaLng').value = ln;
        document.getElementById('mapaDir').value = dir;
        const span = document.getElementById('mapaDirSpan');
        const divTexto = document.getElementById('mapaDirTexto');
        if (span) span.textContent = dir;
        if (divTexto) divTexto.classList.remove('hidden');
    }

})();
</script>