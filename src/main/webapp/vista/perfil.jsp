<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/leaflet.css"/>
    <script src="https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/leaflet.js"></script>
    <title>Mi Perfil - El Dorado</title>
    <style>
        #mapaPerfilVer, #mapaPerfilEditar {
            height: 220px;
            width: 100%;
            border-radius: 12px;
            border: 1px solid #e5e7eb;
        }
        #mapaSugerenciasPerfil { z-index: 999; }
    </style>
</head>
<body class="bg-gray-50 min-h-screen">

    <jsp:include page="/components/header.jsp"/>

    <div class="max-w-3xl mx-auto px-4 py-10">

        <h1 class="text-2xl font-bold text-gray-800 mb-6 flex items-center gap-3">
            <i class="fa-solid fa-user-circle text-red-600"></i> Mi Perfil
        </h1>

        <!-- ALERTAS -->
        <c:if test="${not empty sessionScope.exito}">
            <div class="bg-green-100 text-green-700 px-4 py-3 rounded-xl mb-4">
                ${sessionScope.exito} <c:remove var="exito" scope="session"/>
            </div>
        </c:if>
        <c:if test="${not empty sessionScope.error}">
            <div class="bg-red-100 text-red-700 px-4 py-3 rounded-xl mb-4">
                ${sessionScope.error} <c:remove var="error" scope="session"/>
            </div>
        </c:if>

        <!-- TABS -->
        <div class="flex gap-2 mb-6 border-b border-gray-200">
            <button id="tabVerBtn"
                    onclick="cambiarTab('ver')"
                    class="tab-btn px-5 py-2.5 text-sm font-semibold border-b-2 border-red-600 text-red-600">
                <i class="fa-solid fa-eye mr-1"></i> Ver perfil
            </button>
            <button id="tabEditarBtn"
                    onclick="cambiarTab('editar')"
                    class="tab-btn px-5 py-2.5 text-sm font-semibold border-b-2 border-transparent text-gray-500 hover:text-red-600 transition">
                <i class="fa-solid fa-pen mr-1"></i> Editar perfil
            </button>
        </div>

        <!-- ── TAB VER ── -->
        <div id="tabVer">
            <div class="bg-white rounded-2xl shadow-sm p-6 flex flex-col gap-5">

                <!-- Avatar y nombre -->
                <div class="flex items-center gap-4">
                    <div class="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center text-3xl text-red-600">
                        <i class="fa-solid fa-user-circle"></i>
                    </div>
                    <div>
                        <p class="text-xl font-bold text-gray-800">
                            ${usuario.nombre}
                            <c:if test="${not empty cliente.apellido}"> ${cliente.apellido}</c:if>
                        </p>
                        <p class="text-sm text-gray-400">${usuario.email}</p>
                    </div>
                </div>

                <div class="border-t border-gray-100"></div>

                <!-- Datos -->
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                        <p class="text-xs text-gray-400 font-semibold uppercase mb-1">Nombre</p>
                        <p class="text-sm text-gray-700 font-medium">${usuario.nombre}</p>
                    </div>
                    <div>
                        <p class="text-xs text-gray-400 font-semibold uppercase mb-1">Apellido</p>
                        <p class="text-sm text-gray-700 font-medium">
                            <c:choose>
                                <c:when test="${not empty cliente.apellido}">${cliente.apellido}</c:when>
                                <c:otherwise><span class="text-gray-300 italic">No registrado</span></c:otherwise>
                            </c:choose>
                        </p>
                    </div>
                    <div>
                        <p class="text-xs text-gray-400 font-semibold uppercase mb-1">Correo</p>
                        <p class="text-sm text-gray-700 font-medium">${usuario.email}</p>
                    </div>
                    <div>
                        <p class="text-xs text-gray-400 font-semibold uppercase mb-1">Teléfono</p>
                        <p class="text-sm text-gray-700 font-medium">
                            <c:choose>
                                <c:when test="${not empty cliente.telefono}">${cliente.telefono}</c:when>
                                <c:otherwise><span class="text-gray-300 italic">No registrado</span></c:otherwise>
                            </c:choose>
                        </p>
                    </div>
                </div>

                <!-- Ubicación guardada -->
                <div class="border-t border-gray-100 pt-4">
                    <p class="text-xs text-gray-400 font-semibold uppercase mb-2">
                        <i class="fa-solid fa-location-dot text-red-500 mr-1"></i> Dirección guardada
                    </p>
                    <c:choose>
                        <c:when test="${not empty cliente.direccion}">
                            <p class="text-sm text-gray-700 mb-3">${cliente.direccion}</p>
                            <c:if test="${not empty cliente.latitud and not empty cliente.longitud}">
                                <div id="mapaPerfilVer"></div>
                            </c:if>
                        </c:when>
                        <c:otherwise>
                            <p class="text-sm text-gray-400 italic">No tienes una dirección guardada aún.</p>
                            <button onclick="cambiarTab('editar')"
                                    class="mt-2 text-sm text-red-600 hover:underline font-medium">
                                <i class="fa-solid fa-plus mr-1"></i> Agregar dirección
                            </button>
                        </c:otherwise>
                    </c:choose>
                </div>

            </div>
        </div>

        <!-- ── TAB EDITAR ── -->
        <div id="tabEditar" class="hidden">
            <form action="${pageContext.request.contextPath}/perfil" method="post">

                <div class="bg-white rounded-2xl shadow-sm p-6 flex flex-col gap-5">
                    <h3 class="font-semibold text-gray-700">Datos personales</h3>

                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <div>
                            <label class="block text-xs font-medium text-gray-600 mb-1">Nombre</label>
                            <input type="text" name="nombre" required
                                   value="${usuario.nombre}"
                                   class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-red-300">
                        </div>
                        <div>
                            <label class="block text-xs font-medium text-gray-600 mb-1">Apellido</label>
                            <input type="text" name="apellido"
                                   value="${cliente.apellido}"
                                   class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-red-300">
                        </div>
                        <div>
                            <label class="block text-xs font-medium text-gray-600 mb-1">Correo</label>
                            <input type="email" value="${usuario.email}" disabled
                                   class="w-full border border-gray-100 rounded-xl px-4 py-2.5 text-sm bg-gray-50 text-gray-400 cursor-not-allowed">
                            <p class="text-xs text-gray-400 mt-1">El correo no se puede cambiar</p>
                        </div>
                        <div>
                            <label class="block text-xs font-medium text-gray-600 mb-1">Teléfono</label>
                            <input type="text" name="telefono" maxlength="9"
                                   value="${cliente.telefono}"
                                   class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-red-300">
                        </div>
                    </div>
                </div>

                <!-- Ubicación -->
                <div class="bg-white rounded-2xl shadow-sm p-6 flex flex-col gap-4 mt-4">
                    <h3 class="font-semibold text-gray-700">
                        <i class="fa-solid fa-location-dot text-red-600 mr-1"></i> Dirección guardada
                    </h3>
                    <p class="text-xs text-gray-400">Esta dirección se usará por defecto en el checkout.</p>

                    <!-- Buscador -->
                    <div class="relative">
                        <input type="text" id="mapaBuscadorPerfil"
                               placeholder="Busca tu dirección..."
                               autocomplete="off"
                               class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-red-300 pr-10">
                        <i class="fa-solid fa-magnifying-glass absolute right-3 top-3 text-gray-400 text-sm"></i>
                        <div id="mapaSugerenciasPerfil"
                             class="hidden absolute top-full left-0 right-0 bg-white border border-gray-200 rounded-xl shadow-lg max-h-48 overflow-y-auto mt-1 z-50">
                        </div>
                    </div>

                    <!-- Mapa editar -->
                    <div id="mapaPerfilEditar"></div>

                    <!-- Dirección actual -->
                    <div id="perfilDirTexto" class="${empty cliente.direccion ? 'hidden' : ''} text-xs text-gray-500 flex items-start gap-2">
                        <i class="fa-solid fa-location-dot text-red-500 mt-0.5"></i>
                        <span id="perfilDirSpan">${cliente.direccion}</span>
                    </div>

                    <p class="text-xs text-gray-400 text-center">
                        <i class="fa-solid fa-hand-pointer mr-1"></i>
                        Haz clic en el mapa o arrastra el pin para ajustar
                    </p>

                    <!-- Inputs hidden -->
                    <input type="hidden" name="direccion" id="perfilDir" value="${cliente.direccion}">
                    <input type="hidden" name="latitud"   id="perfilLat" value="${cliente.latitud}">
                    <input type="hidden" name="longitud"  id="perfilLng" value="${cliente.longitud}">
                </div>

                <div class="flex gap-3 mt-4">
                    <button type="submit"
                            class="flex-1 bg-red-600 hover:bg-red-700 text-white font-bold py-3 rounded-xl transition flex items-center justify-center gap-2">
                        <i class="fa-solid fa-floppy-disk"></i> Guardar cambios
                    </button>
                    <button type="button" onclick="cambiarTab('ver')"
                            class="flex-1 border border-gray-200 hover:bg-gray-50 text-gray-600 font-semibold py-3 rounded-xl transition">
                        Cancelar
                    </button>
                </div>
            </form>
        </div>

    </div>

    <jsp:include page="/components/footer.jsp"/>

    <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
    <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>

    <script>
        // ── TABS ──────────────────────────────────────────────
        let mapaVerIniciado    = false;
        let mapaEditarIniciado = false;

        function cambiarTab(tab) {
            document.getElementById('tabVer').classList.toggle('hidden', tab !== 'ver');
            document.getElementById('tabEditar').classList.toggle('hidden', tab !== 'editar');
            document.getElementById('tabVerBtn').classList.toggle('border-red-600', tab === 'ver');
            document.getElementById('tabVerBtn').classList.toggle('text-red-600', tab === 'ver');
            document.getElementById('tabVerBtn').classList.toggle('border-transparent', tab !== 'ver');
            document.getElementById('tabVerBtn').classList.toggle('text-gray-500', tab !== 'ver');
            document.getElementById('tabEditarBtn').classList.toggle('border-red-600', tab === 'editar');
            document.getElementById('tabEditarBtn').classList.toggle('text-red-600', tab === 'editar');
            document.getElementById('tabEditarBtn').classList.toggle('border-transparent', tab !== 'editar');
            document.getElementById('tabEditarBtn').classList.toggle('text-gray-500', tab !== 'editar');

            if (tab === 'ver' && !mapaVerIniciado)    iniciarMapaVer();
            if (tab === 'editar' && !mapaEditarIniciado) iniciarMapaEditar();
        }

        // ── MAPA VER ──────────────────────────────────────────
        <c:if test="${not empty cliente.latitud and not empty cliente.longitud}">
        function iniciarMapaVer() {
            var lat = ${cliente.latitud};
            var lng = ${cliente.longitud};
            var m = L.map('mapaPerfilVer').setView([lat, lng], 16);
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '© OpenStreetMap'
            }).addTo(m);
            L.marker([lat, lng]).addTo(m)
             .bindPopup('${cliente.direccion}').openPopup();
            mapaVerIniciado = true;
        }
        // Iniciar mapa de ver al cargar
        document.addEventListener('DOMContentLoaded', function() {
            setTimeout(iniciarMapaVer, 100);
        });
        </c:if>
        <c:if test="${empty cliente.latitud or empty cliente.longitud}">
        function iniciarMapaVer() { mapaVerIniciado = true; }
        </c:if>

        // ── MAPA EDITAR ───────────────────────────────────────
        function iniciarMapaEditar() {
            var latInicial = ${not empty cliente.latitud ? cliente.latitud : -12.0464};
            var lngInicial = ${not empty cliente.longitud ? cliente.longitud : -77.0428};
            var zoom = ${not empty cliente.latitud ? 16 : 13};

            var mapa = L.map('mapaPerfilEditar').setView([latInicial, lngInicial], zoom);
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '© OpenStreetMap'
            }).addTo(mapa);

            var marker = L.marker([latInicial, lngInicial], { draggable: true }).addTo(mapa);

            marker.on('dragend', function() {
                var pos = marker.getLatLng();
                geocodificarInverso(pos.lat, pos.lng, marker);
            });

            mapa.on('click', function(e) {
                marker.setLatLng(e.latlng);
                geocodificarInverso(e.latlng.lat, e.latlng.lng, marker);
            });

            // Buscador
            var timeout;
            document.getElementById('mapaBuscadorPerfil').addEventListener('input', function() {
                clearTimeout(timeout);
                var texto = this.value.trim();
                if (texto.length < 3) {
                    document.getElementById('mapaSugerenciasPerfil').classList.add('hidden');
                    return;
                }
                timeout = setTimeout(function() { buscarDireccion(texto, mapa, marker); }, 400);
            });

            document.addEventListener('click', function(e) {
                if (!e.target.closest('#mapaBuscadorPerfil') && !e.target.closest('#mapaSugerenciasPerfil')) {
                    document.getElementById('mapaSugerenciasPerfil').classList.add('hidden');
                }
            });

            mapaEditarIniciado = true;
        }

        function buscarDireccion(texto, mapa, marker) {
            fetch('https://nominatim.openstreetmap.org/search?format=json&q=' + encodeURIComponent(texto) + '&countrycodes=pe&limit=5', {
                headers: { 'Accept-Language': 'es' }
            })
            .then(function(r) { return r.json(); })
            .then(function(resultados) {
                var lista = document.getElementById('mapaSugerenciasPerfil');
                lista.innerHTML = '';
                if (resultados.length === 0) {
                    lista.innerHTML = '<div class="px-4 py-3 text-sm text-gray-400">Sin resultados</div>';
                    lista.classList.remove('hidden');
                    return;
                }
                resultados.forEach(function(r) {
                    var div = document.createElement('div');
                    div.className = 'px-4 py-3 text-sm text-gray-700 hover:bg-red-50 hover:text-red-600 cursor-pointer border-b border-gray-50';
                    div.innerHTML = '<i class="fa-solid fa-location-dot mr-2 text-red-400 text-xs"></i>' + r.display_name;
                    div.addEventListener('click', function() {
                        var la = parseFloat(r.lat);
                        var ln = parseFloat(r.lon);
                        mapa.setView([la, ln], 17);
                        marker.setLatLng([la, ln]);
                        guardarUbicacion(la, ln, r.display_name);
                        document.getElementById('mapaBuscadorPerfil').value = r.display_name;
                        lista.classList.add('hidden');
                    });
                    lista.appendChild(div);
                });
                lista.classList.remove('hidden');
            })
            .catch(function() {});
        }

        function geocodificarInverso(la, ln, marker) {
            fetch('https://nominatim.openstreetmap.org/reverse?format=json&lat=' + la + '&lon=' + ln + '&accept-language=es')
            .then(function(r) { return r.json(); })
            .then(function(data) {
                var dir = data.display_name || (la.toFixed(6) + ', ' + ln.toFixed(6));
                guardarUbicacion(la, ln, dir);
                document.getElementById('mapaBuscadorPerfil').value = dir;
            })
            .catch(function() {
                guardarUbicacion(la, ln, la.toFixed(6) + ', ' + ln.toFixed(6));
            });
        }

        function guardarUbicacion(la, ln, dir) {
            document.getElementById('perfilLat').value = la;
            document.getElementById('perfilLng').value = ln;
            document.getElementById('perfilDir').value = dir;
            document.getElementById('perfilDirSpan').textContent = dir;
            document.getElementById('perfilDirTexto').classList.remove('hidden');
        }
    </script>
</body>
</html>