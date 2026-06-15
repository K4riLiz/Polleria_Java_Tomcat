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
        #seccion-tarjeta, #seccion-yape, #seccion-plin { display: none; }
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
            <div class="bg-red-100 text-red-700 px-4 py-3 rounded-xl mb-6">${error}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/checkout" method="post" id="formCheckout">
            <div class="flex flex-col lg:flex-row gap-6">

                <!-- IZQUIERDA -->
                <div class="flex-1 flex flex-col gap-6">

                    <!-- DIRECCIÓN CON MAPA -->
                    <div class="bg-white rounded-2xl shadow-sm p-6">
                        <h2 class="text-lg font-semibold mb-4">
                            <i class="fa-solid fa-location-dot text-red-600 mr-2"></i>Dirección de entrega
                        </h2>

                        <%-- Opción de usar ubicación guardada --%>
                        <c:if test="${not empty sessionScope.usuario}">
                            <%
                                com.polleria.dao.ClienteDAO cDao = new com.polleria.dao.ClienteDAO();
                                com.polleria.model.Usuario uSes = (com.polleria.model.Usuario) session.getAttribute("usuario");
                                com.polleria.model.Cliente cSes = null;
                                try {
                                    cSes = cDao.obtenerPorUsuarioId(uSes.getId());
                                } catch (Exception ignored) {
                                }
                                request.setAttribute("clientePerfil", cSes);
                            %>
                            <c:if test="${not empty clientePerfil.direccion}">
                                <div class="bg-red-50 border border-red-100 rounded-xl p-4 mb-3 flex items-start gap-3">
                                    <i class="fa-solid fa-location-dot text-red-500 mt-0.5"></i>
                                    <div class="flex-1">
                                        <p class="text-sm font-semibold text-gray-700 mb-0.5">¿Usar tu dirección guardada?</p>
                                        <p class="text-xs text-gray-500 mb-2">${clientePerfil.direccion}</p>
                                        <button type="button" onclick="usarDireccionGuardada()"
                                                class="text-xs bg-red-600 hover:bg-red-700 text-white px-3 py-1.5 rounded-lg font-semibold transition">
                                            <i class="fa-solid fa-check mr-1"></i> Usar esta dirección
                                        </button>
                                    </div>
                                </div>
                            </c:if>
                        </c:if>
                        
                        <!-- Buscador -->
                        <div class="relative mb-3">
                            <input type="text" id="mapaBuscador"
                                   placeholder="Busca tu dirección en Lima..."
                                   autocomplete="off"
                                   class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-red-300 pr-10">
                            <i class="fa-solid fa-magnifying-glass absolute right-3 top-3 text-gray-400 text-sm"></i>
                            <div id="mapaSugerencias"
                                 class="hidden absolute top-full left-0 right-0 bg-white border border-gray-200 rounded-xl shadow-lg max-h-48 overflow-y-auto mt-1">
                            </div>
                        </div>

                        <!-- Mapa -->
                        <div id="mapaLeaflet" class="mb-3"></div>

                        <!-- Dirección seleccionada -->
                        <div id="mapaDirTexto" class="hidden text-xs text-gray-500 flex items-start gap-2 px-1 mb-2">
                            <i class="fa-solid fa-location-dot text-red-500 mt-0.5"></i>
                            <span id="mapaDirSpan" class="leading-relaxed"></span>
                        </div>

                        <p class="text-xs text-gray-400 text-center">
                            <i class="fa-solid fa-hand-pointer mr-1"></i>
                            Haz clic en el mapa o arrastra el pin para ajustar tu ubicación
                        </p>

                        <!-- Inputs hidden -->
                        <input type="hidden" name="direccion" id="mapaDir">
                        <input type="hidden" name="latitud"   id="mapaLat">
                        <input type="hidden" name="longitud"  id="mapaLng">
                    </div>

                    <!-- MÉTODO DE PAGO -->
                    <div class="bg-white rounded-2xl shadow-sm p-6">
                        <h2 class="text-lg font-semibold mb-4">
                            <i class="fa-solid fa-wallet text-red-600 mr-2"></i>Método de pago
                        </h2>

                        <div class="flex flex-col gap-3">

                            <!-- Tarjeta -->
                            <div class="metodo-card">
                                <input type="radio" name="metodo" id="tarjeta" value="Tarjeta" onchange="mostrarSeccion('tarjeta')">
                                <label for="tarjeta">
                                    <div class="w-10 h-10 bg-blue-100 rounded-lg flex items-center justify-center">
                                        <i class="fa-solid fa-credit-card text-blue-600"></i>
                                    </div>
                                    <div>
                                        <p class="font-semibold text-sm">Tarjeta de crédito/débito</p>
                                        <p class="text-xs text-gray-400">Visa, Mastercard, American Express</p>
                                    </div>
                                </label>
                            </div>

                            <div id="seccion-tarjeta" class="bg-gray-50 rounded-xl p-4 flex flex-col gap-3">
                                <div>
                                    <label class="block text-xs font-medium text-gray-600 mb-1">Número de tarjeta</label>
                                    <input type="text" placeholder="0000 0000 0000 0000" maxlength="19"
                                           oninput="formatarTarjeta(this)"
                                           class="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-300">
                                </div>
                                <div class="grid grid-cols-2 gap-3">
                                    <div>
                                        <label class="block text-xs font-medium text-gray-600 mb-1">Vencimiento</label>
                                        <input type="text" placeholder="MM/AA" maxlength="5"
                                               class="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-300">
                                    </div>
                                    <div>
                                        <label class="block text-xs font-medium text-gray-600 mb-1">CVV</label>
                                        <input type="text" placeholder="123" maxlength="3"
                                               class="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-300">
                                    </div>
                                </div>
                                <div>
                                    <label class="block text-xs font-medium text-gray-600 mb-1">Nombre en la tarjeta</label>
                                    <input type="text" placeholder="NOMBRE APELLIDO"
                                           class="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-300">
                                </div>
                            </div>

                            <!-- Yape -->
                            <div class="metodo-card">
                                <input type="radio" name="metodo" id="yape" value="Yape" onchange="mostrarSeccion('yape')">
                                <label for="yape">
                                    <div class="w-10 h-10 bg-purple-100 rounded-lg flex items-center justify-center">
                                        <span class="text-purple-600 font-bold text-sm">Y</span>
                                    </div>
                                    <div>
                                        <p class="font-semibold text-sm">Yape</p>
                                        <p class="text-xs text-gray-400">Pago con código QR o número</p>
                                    </div>
                                </label>
                            </div>

                            <div id="seccion-yape" class="bg-purple-50 rounded-xl p-4 flex flex-col items-center gap-3">
                                <p class="text-sm font-semibold text-purple-700">Escanea el código QR con Yape</p>
                                <div class="w-40 h-40 bg-white rounded-xl flex items-center justify-center border-2 border-purple-200">
                                    <div class="text-center">
                                        <i class="fa-solid fa-qrcode text-5xl text-purple-400"></i>
                                        <p class="text-xs text-gray-400 mt-2">QR simulado</p>
                                    </div>
                                </div>
                                <p class="text-xs text-gray-500">O paga al número: <span class="font-bold text-purple-700">+51 999 888 777</span></p>
                            </div>

                            <!-- Plin -->
                            <div class="metodo-card">
                                <input type="radio" name="metodo" id="plin" value="Plin" onchange="mostrarSeccion('plin')">
                                <label for="plin">
                                    <div class="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center">
                                        <span class="text-green-600 font-bold text-sm">P</span>
                                    </div>
                                    <div>
                                        <p class="font-semibold text-sm">Plin</p>
                                        <p class="text-xs text-gray-400">Pago con código QR o número</p>
                                    </div>
                                </label>
                            </div>

                            <div id="seccion-plin" class="bg-green-50 rounded-xl p-4 flex flex-col items-center gap-3">
                                <p class="text-sm font-semibold text-green-700">Escanea el código QR con Plin</p>
                                <div class="w-40 h-40 bg-white rounded-xl flex items-center justify-center border-2 border-green-200">
                                    <div class="text-center">
                                        <i class="fa-solid fa-qrcode text-5xl text-green-400"></i>
                                        <p class="text-xs text-gray-400 mt-2">QR simulado</p>
                                    </div>
                                </div>
                                <p class="text-xs text-gray-500">O paga al número: <span class="font-bold text-green-700">+51 999 888 777</span></p>
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
                                <span class="text-red-600">S/<fmt:formatNumber value="${total}" pattern="#,##0.00"/></span>
                            </div>
                        </div>

                        <button type="submit" onclick="return validarFormulario()"
                                class="w-full bg-red-600 hover:bg-red-700 text-white font-bold py-3 rounded-xl transition flex items-center justify-center gap-2">
                            <i class="fa-solid fa-lock"></i> Confirmar y pagar
                        </button>

                        <a href="${pageContext.request.contextPath}/carrito"
                           class="w-full mt-3 border border-gray-200 hover:bg-gray-50 text-gray-600 font-semibold py-2 rounded-xl transition flex items-center justify-center gap-2 text-sm">
                            <i class="fa-solid fa-arrow-left"></i> Volver al carrito
                        </a>
                    </div>
                </div>

            </div>
        </form>
    </div>

    <jsp:include page="/components/footer.jsp"/>

    <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
    <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>

    <script>
    // ── Variables globales del mapa ──────────────────────────
    var mapa, marker;

    var latPerfil = '${clientePerfil.latitud}';
    var lngPerfil = '${clientePerfil.longitud}';
    var dirPerfil = '${clientePerfil.direccion}';

    document.addEventListener('DOMContentLoaded', function () {

        // ── MAPA ──────────────────────────────────────────────
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

        var timeoutBusqueda;
        document.getElementById('mapaBuscador').addEventListener('input', function () {
            clearTimeout(timeoutBusqueda);
            var texto = this.value.trim();
            if (texto.length < 3) {
                document.getElementById('mapaSugerencias').classList.add('hidden');
                return;
            }
            timeoutBusqueda = setTimeout(function () { buscarDireccion(texto); }, 400);
        });

        document.addEventListener('click', function (e) {
            if (!e.target.closest('#mapaBuscador') && !e.target.closest('#mapaSugerencias')) {
                document.getElementById('mapaSugerencias').classList.add('hidden');
            }
        });

        // Si hay dirección de perfil, pre-cargar el mapa al inicio
        if (latPerfil && lngPerfil) {
            var la = parseFloat(latPerfil);
            var ln = parseFloat(lngPerfil);
            mapa.setView([la, ln], 16);
            marker.setLatLng([la, ln]);
        }
    });

    // ── Funciones globales (accesibles desde onclick) ─────────

    function buscarDireccion(texto) {
        var url = 'https://nominatim.openstreetmap.org/search?format=json&q='
                + encodeURIComponent(texto) + '&countrycodes=pe&limit=5';
        fetch(url, { headers: { 'Accept-Language': 'es' } })
            .then(function (r) { return r.json(); })
            .then(function (resultados) {
                var lista = document.getElementById('mapaSugerencias');
                lista.innerHTML = '';
                if (resultados.length === 0) {
                    lista.innerHTML = '<div class="px-4 py-3 text-sm text-gray-400">Sin resultados</div>';
                    lista.classList.remove('hidden');
                    return;
                }
                resultados.forEach(function (r) {
                    var div = document.createElement('div');
                    div.className = 'px-4 py-3 text-sm text-gray-700 hover:bg-red-50 hover:text-red-600 cursor-pointer border-b border-gray-50 last:border-0';
                    div.innerHTML = '<i class="fa-solid fa-location-dot mr-2 text-red-400 text-xs"></i>' + r.display_name;
                    div.addEventListener('click', function () {
                        var la = parseFloat(r.lat);
                        var ln = parseFloat(r.lon);
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
            .catch(function () {});
    }

    function geocodificarInverso(la, ln) {
        var url = 'https://nominatim.openstreetmap.org/reverse?format=json&lat='
                + la + '&lon=' + ln + '&accept-language=es';
        fetch(url)
            .then(function (r) { return r.json(); })
            .then(function (data) {
                var dir = data.display_name || (la.toFixed(6) + ', ' + ln.toFixed(6));
                guardarUbicacion(la, ln, dir);
                document.getElementById('mapaBuscador').value = dir;
            })
            .catch(function () {
                guardarUbicacion(la, ln, la.toFixed(6) + ', ' + ln.toFixed(6));
            });
    }

    function guardarUbicacion(la, ln, dir) {
        document.getElementById('mapaLat').value = la;
        document.getElementById('mapaLng').value = ln;
        document.getElementById('mapaDir').value = dir;
        document.getElementById('mapaDirSpan').textContent = dir;
        document.getElementById('mapaDirTexto').classList.remove('hidden');
    }

    function usarDireccionGuardada() {
        if (!latPerfil || !lngPerfil) return;
        var la = parseFloat(latPerfil);
        var ln = parseFloat(lngPerfil);
        mapa.setView([la, ln], 17);
        marker.setLatLng([la, ln]);
        guardarUbicacion(la, ln, dirPerfil);
        document.getElementById('mapaBuscador').value = dirPerfil;
    }

    function validarFormulario() {
        var dir = document.getElementById('mapaDir').value;
        if (!dir) {
            alert('Por favor selecciona tu dirección de entrega en el mapa.');
            return false;
        }
        var metodo = document.querySelector('input[name="metodo"]:checked');
        if (!metodo) {
            alert('Por favor selecciona un método de pago.');
            return false;
        }
        return true;
    }

    function mostrarSeccion(metodo) {
        document.getElementById('seccion-tarjeta').style.display = 'none';
        document.getElementById('seccion-yape').style.display = 'none';
        document.getElementById('seccion-plin').style.display = 'none';
        document.getElementById('seccion-' + metodo).style.display = 'flex';
        document.getElementById('seccion-' + metodo).style.flexDirection = 'column';
    }

    function formatarTarjeta(input) {
        var val = input.value.replace(/\s/g, '').replace(/[^0-9]/gi, '');
        var match = (val.match(/\d{4,16}/g) || [''])[0];
        var parts = [];
        for (var i = 0; i < match.length; i += 4) {
            parts.push(match.substring(i, i + 4));
        }
        input.value = parts.length ? parts.join(' ') : val;
    }
    </script>
    
</body>
</html>