<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/leaflet.css"/>
    <script src="https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/leaflet.js"></script>
    <script src="https://checkout.culqi.com/js/v4"></script>
    <title>Checkout - El Dorado</title>
    <style>
        .metodo-card input[type="radio"] { display: none; }
        .metodo-card input[type="radio"]:checked + label {
            border-color: #c0392b;
            background-color: #fff5f5;
        }
        .metodo-card label {
            cursor: pointer;
            transition: all 0.2s;
            border: 2px solid #e5e7eb;
            border-radius: 12px;
            padding: 16px;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .metodo-card label:hover { border-color: #f87171; }
        #mapaLeaflet {
            height: 280px;
            width: 100%;
            border-radius: 12px;
            border: 1px solid #e5e7eb;
            z-index: 1;
        }
        #mapaSugerencias { z-index: 999; }
    </style>
</head>
<body class="bg-gray-50 min-h-screen">

    <jsp:include page="/components/header.jsp"/>

    <div class="max-w-5xl mx-auto px-4 py-10">
        <h1 class="text-2xl font-bold text-gray-800 mb-8 flex items-center gap-3">
            <i class="fa-solid fa-credit-card text-red-600"></i> Finalizar Pedido
        </h1>

        <c:if test="${not empty error}">
            <div class="bg-red-100 text-red-700 px-4 py-3 rounded-xl mb-6">
                <i class="fa-solid fa-circle-exclamation mr-2"></i>${error}
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/checkout"
              method="post" id="formCheckout">

            <!-- Campos hidden -->
            <input type="hidden" name="culqiToken"    id="culqiToken">
            <input type="hidden" name="culqiEmail"    id="culqiEmail">
            <input type="hidden" name="yapeNumero"    id="yapeNumerHidden">
            <input type="hidden" name="yapeOtp"       id="yapeOtpHidden">
            <input type="hidden" name="metodo"        id="metodoHidden">
            <input type="hidden" name="direccion"     id="mapaDir">
            <input type="hidden" name="latitud"       id="mapaLat">
            <input type="hidden" name="longitud"      id="mapaLng">
            <input type="hidden" name="guardarDireccion" id="guardarDirHidden">

            <div class="flex flex-col lg:flex-row gap-6">

                <!-- IZQUIERDA -->
                <div class="flex-1 flex flex-col gap-6">

                    <!-- DIRECCIÓN -->
                    <div class="bg-white rounded-2xl shadow-sm p-6">
                        <h2 class="text-lg font-semibold mb-4">
                            <i class="fa-solid fa-location-dot text-red-600 mr-2"></i>
                            Dirección de entrega
                        </h2>

                        <!-- Dirección guardada -->
                        <c:if test="${not empty clientePerfil.direccion}">
                            <div class="bg-red-50 border border-red-100 rounded-xl p-4 mb-3 flex items-start gap-3">
                                <i class="fa-solid fa-location-dot text-red-500 mt-0.5"></i>
                                <div class="flex-1">
                                    <p class="text-sm font-semibold text-gray-700 mb-0.5">
                                        ¿Usar tu dirección guardada?
                                    </p>
                                    <p class="text-xs text-gray-500 mb-2">${clientePerfil.direccion}</p>
                                    <button type="button" onclick="usarDireccionGuardada()"
                                            class="text-xs bg-red-600 hover:bg-red-700 text-white px-3 py-1.5 rounded-lg font-semibold transition">
                                        <i class="fa-solid fa-check mr-1"></i> Usar esta dirección
                                    </button>
                                </div>
                            </div>
                        </c:if>

                        <!-- Buscador -->
                        <div class="relative mb-3">
                            <input type="text" id="mapaBuscador"
                                   placeholder="Busca tu dirección en Lima..."
                                   autocomplete="off"
                                   class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-red-300 pr-10">
                            <i class="fa-solid fa-magnifying-glass absolute right-3 top-3 text-gray-400 text-sm"></i>
                            <div id="mapaSugerencias"
                                 class="hidden absolute top-full left-0 right-0 bg-white border border-gray-200 rounded-xl shadow-lg max-h-48 overflow-y-auto mt-1 z-50">
                            </div>
                        </div>

                        <!-- Mapa -->
                        <div id="mapaLeaflet" class="mb-3"></div>

                        <!-- Dirección seleccionada -->
                        <div id="mapaDirTexto" class="hidden text-xs text-gray-500 flex items-start gap-2 px-1 mb-2">
                            <i class="fa-solid fa-location-dot text-red-500 mt-0.5"></i>
                            <span id="mapaDirSpan" class="leading-relaxed"></span>
                        </div>

                        <!-- Guardar dirección (solo si no tiene) -->
                        <c:if test="${sinDireccion}">
                            <div id="seccionGuardarDir" class="hidden mt-3 bg-amber-50 border border-amber-200 rounded-xl p-3 flex items-center gap-3">
                                <input type="checkbox" id="chkGuardarDir"
                                       class="w-4 h-4 accent-red-600 cursor-pointer"
                                       onchange="document.getElementById('guardarDirHidden').value = this.checked ? 'true' : ''">
                                <label for="chkGuardarDir" class="text-sm text-gray-700 cursor-pointer">
                                    <span class="font-semibold">Guardar esta dirección en mi perfil</span>
                                    <span class="text-gray-500 text-xs block">Para no tener que ingresarla la próxima vez</span>
                                </label>
                            </div>
                        </c:if>

                        <p class="text-xs text-gray-400 text-center mt-2">
                            <i class="fa-solid fa-hand-pointer mr-1"></i>
                            Haz clic en el mapa o arrastra el pin para ajustar
                        </p>
                    </div>

                    <!-- MÉTODO DE PAGO -->
                    <div class="bg-white rounded-2xl shadow-sm p-6">
                        <h2 class="text-lg font-semibold mb-4">
                            <i class="fa-solid fa-wallet text-red-600 mr-2"></i>Método de pago
                        </h2>

                        <div class="flex flex-col gap-3">

                            <!-- Tarjeta -->
                            <div class="metodo-card">
                                <input type="radio" name="metodoPago" id="opTarjeta"
                                       value="Tarjeta"
                                       onchange="seleccionarMetodo('Tarjeta')">
                                <label for="opTarjeta">
                                    <div class="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
                                        <i class="fa-solid fa-credit-card text-blue-600"></i>
                                    </div>
                                    <div>
                                        <p class="font-semibold text-sm">Tarjeta de crédito/débito</p>
                                        <p class="text-xs text-gray-400">Visa, Mastercard — powered by Culqi</p>
                                    </div>
                                </label>
                            </div>

                            <!-- Yape -->
                            <div class="metodo-card">
                                <input type="radio" name="metodoPago" id="opYape"
                                       value="Yape"
                                       onchange="seleccionarMetodo('Yape')">
                                <label for="opYape">
                                    <div class="w-10 h-10 bg-purple-100 rounded-lg flex items-center justify-center">
                                        <span class="text-purple-600 font-bold text-sm">Y</span>
                                    </div>
                                    <div>
                                        <p class="font-semibold text-sm">Yape</p>
                                        <p class="text-xs text-gray-400">Paga con tu número Yape + OTP</p>
                                    </div>
                                </label>
                            </div>

                        </div>
                    </div>
                </div>

                <!-- DERECHA: RESUMEN -->
                <div class="lg:w-80 flex-shrink-0">
                    <div class="bg-white rounded-2xl shadow-sm p-6 sticky top-4">
                        <h2 class="text-lg font-bold text-gray-800 mb-4">Resumen del pedido</h2>

                        <div class="flex flex-col gap-2 mb-4 max-h-48 overflow-y-auto">
                            <c:set var="total" value="0"/>
                            <c:forEach items="${sessionScope.carrito}" var="item">
                                <c:set var="total" value="${total + item.subtotal}"/>
                                <div class="flex justify-between text-sm text-gray-500">
                                    <span>${item.nombre} x${item.cantidad}</span>
                                    <span>S/<fmt:formatNumber value="${item.subtotal}" pattern="#,##0.00"/></span>
                                </div>
                            </c:forEach>
                        </div>

                        <div class="border-t pt-4 mb-6">
                            <div class="flex justify-between text-sm text-gray-500 mb-2">
                                <span>Subtotal</span>
                                <span>S/<fmt:formatNumber value="${total}" pattern="#,##0.00"/></span>
                            </div>
                            <div class="flex justify-between text-sm text-gray-500 mb-2">
                                <span>Delivery</span>
                                <span class="text-green-600 font-medium">Gratis</span>
                            </div>
                            <div class="flex justify-between font-bold text-gray-800 text-lg mt-3">
                                <span>Total</span>
                                <span class="text-red-600">
                                    S/<fmt:formatNumber value="${total}" pattern="#,##0.00"/>
                                </span>
                            </div>
                        </div>

                        <button type="button" onclick="procesarPago()"
                                class="w-full bg-red-600 hover:bg-red-700 text-white font-bold py-3 rounded-xl transition flex items-center justify-center gap-2">
                            <i class="fa-solid fa-lock"></i> Confirmar y pagar
                        </button>

                        <a href="${pageContext.request.contextPath}/carrito"
                           class="w-full mt-3 border border-gray-200 hover:bg-gray-50 text-gray-600 font-semibold py-2 rounded-xl transition flex items-center justify-center gap-2 text-sm">
                            <i class="fa-solid fa-arrow-left"></i> Volver al carrito
                        </a>

                        <p class="text-xs text-gray-400 text-center mt-4">
                            <i class="fa-solid fa-shield-halved text-green-500 mr-1"></i>
                            Pago seguro · Datos encriptados por Culqi
                        </p>
                    </div>
                </div>

            </div>
        </form>
    </div>

    <jsp:include page="/components/footer.jsp"/>

    <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
    <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>

    
    
    <script>
        // ── VARIABLES ─────────────────────────────────────────────────────────────
var mapa, marker;
var latPerfil          = '${clientePerfil.latitud}';
var lngPerfil          = '${clientePerfil.longitud}';
var dirPerfil          = '${clientePerfil.direccion}';
var sinDireccion       = ${sinDireccion != null ? sinDireccion : false};
var totalMonto         = ${total};
var metodoSeleccionado = '';

// ── CULQI ─────────────────────────────────────────────────────────────────────
Culqi.publicKey = 'pk_test_RoSdgHZ8UBOYu0Gb';

// Culqi llama esta función al completar el pago (tarjeta o Yape)
function culqi() {
    if (Culqi.token) {
        var token = Culqi.token;
        Culqi.close();

        document.getElementById('culqiToken').value  = token.id;
        document.getElementById('culqiEmail').value  = token.email || '';
        document.getElementById('metodoHidden').value = metodoSeleccionado;
        document.getElementById('formCheckout').submit();

    } else {
        var err = Culqi.error;
        alert('Error en el pago: ' + (err && err.user_message ? err.user_message : 'Intenta de nuevo.'));
    }
}

// ── MAPA ──────────────────────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', function () {
    mapa = L.map('mapaLeaflet').setView([-12.0464, -77.0428], 13);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap'
    }).addTo(mapa);

    marker = L.marker([-12.0464, -77.0428], { draggable: true }).addTo(mapa);

    marker.on('dragend', function () {
        var pos = marker.getLatLng();
        geocodificarInverso(pos.lat, pos.lng);
    });
    mapa.on('click', function (e) {
        marker.setLatLng(e.latlng);
        geocodificarInverso(e.latlng.lat, e.latlng.lng);
    });

    if (latPerfil && lngPerfil) {
        var la = parseFloat(latPerfil);
        var ln = parseFloat(lngPerfil);
        mapa.setView([la, ln], 16);
        marker.setLatLng([la, ln]);
    }

    var timeout;
    document.getElementById('mapaBuscador').addEventListener('input', function () {
        clearTimeout(timeout);
        var texto = this.value.trim();
        if (texto.length < 3) {
            document.getElementById('mapaSugerencias').classList.add('hidden');
            return;
        }
        timeout = setTimeout(function () { buscarDireccion(texto); }, 400);
    });

    document.addEventListener('click', function (e) {
        if (!e.target.closest('#mapaBuscador') && !e.target.closest('#mapaSugerencias')) {
            document.getElementById('mapaSugerencias').classList.add('hidden');
        }
    });
});

function buscarDireccion(texto) {
    fetch('https://nominatim.openstreetmap.org/search?format=json&q='
          + encodeURIComponent(texto) + '&countrycodes=pe&limit=5',
          { headers: { 'Accept-Language': 'es' } })
    .then(function(r) { return r.json(); })
    .then(function(resultados) {
        var lista = document.getElementById('mapaSugerencias');
        lista.innerHTML = '';
        if (!resultados.length) {
            lista.innerHTML = '<div class="px-4 py-3 text-sm text-gray-400">Sin resultados</div>';
            lista.classList.remove('hidden');
            return;
        }
        resultados.forEach(function(r) {
            var div = document.createElement('div');
            div.className = 'px-4 py-3 text-sm text-gray-700 hover:bg-red-50 hover:text-red-600 cursor-pointer border-b border-gray-50';
            div.innerHTML = '<i class="fa-solid fa-location-dot mr-2 text-red-400 text-xs"></i>' + r.display_name;
            div.addEventListener('click', function() {
                var la = parseFloat(r.lat), ln = parseFloat(r.lon);
                mapa.setView([la, ln], 17);
                marker.setLatLng([la, ln]);
                guardarUbicacion(la, ln, r.display_name);
                document.getElementById('mapaBuscador').value = r.display_name;
                lista.classList.add('hidden');
            });
            lista.appendChild(div);
        });
        lista.classList.remove('hidden');
    }).catch(function(){});
}

function geocodificarInverso(la, ln) {
    fetch('https://nominatim.openstreetmap.org/reverse?format=json&lat=' + la + '&lon=' + ln + '&accept-language=es')
    .then(function(r) { return r.json(); })
    .then(function(data) {
        var dir = data.display_name || (la.toFixed(6) + ', ' + ln.toFixed(6));
        guardarUbicacion(la, ln, dir);
        document.getElementById('mapaBuscador').value = dir;
    }).catch(function() {
        guardarUbicacion(la, ln, la.toFixed(6) + ', ' + ln.toFixed(6));
    });
}

function guardarUbicacion(la, ln, dir) {
    document.getElementById('mapaLat').value = la;
    document.getElementById('mapaLng').value = ln;
    document.getElementById('mapaDir').value = dir;
    document.getElementById('mapaDirSpan').textContent = dir;
    document.getElementById('mapaDirTexto').classList.remove('hidden');
    if (sinDireccion) {
        var sec = document.getElementById('seccionGuardarDir');
        if (sec) sec.classList.remove('hidden');
    }
}

function usarDireccionGuardada() {
    if (!latPerfil || !lngPerfil) return;
    var la = parseFloat(latPerfil), ln = parseFloat(lngPerfil);
    mapa.setView([la, ln], 17);
    marker.setLatLng([la, ln]);
    guardarUbicacion(la, ln, dirPerfil);
    document.getElementById('mapaBuscador').value = dirPerfil;
}

// ── MÉTODO DE PAGO ────────────────────────────────────────────────────────────
function seleccionarMetodo(metodo) {
    metodoSeleccionado = metodo;
}

// ── PROCESAR PAGO ─────────────────────────────────────────────────────────────
function procesarPago() {
    if (!document.getElementById('mapaDir').value) {
        alert('Por favor selecciona tu dirección de entrega en el mapa.');
        return;
    }
    if (!metodoSeleccionado) {
        alert('Por favor selecciona un método de pago.');
        return;
    }

    var montoCentavos = Math.round(totalMonto * 100);

    // Culqi abre su modal — el cliente elige tarjeta o Yape dentro del modal
    Culqi.settings({
        title:       'Pollería El Dorado',
        currency:    'PEN',
        description: metodoSeleccionado === 'Yape' ? 'Pago con Yape' : 'Pago con tarjeta',
        amount:      montoCentavos,
        // Habilitar Yape en el modal si seleccionó Yape
        paymentMethods: {
            tarjeta: metodoSeleccionado === 'Tarjeta',
            yape:    metodoSeleccionado === 'Yape',
            cuotas:  false,
            billetera: false
        }
    });
    Culqi.open();
}
    </script>

</body>
</html>