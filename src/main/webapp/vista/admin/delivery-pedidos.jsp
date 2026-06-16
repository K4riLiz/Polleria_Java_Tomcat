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
    <title>Delivery - Pedidos</title>
    <style>
        .slide-panel { transform: translateX(-100%); transition: transform 0.3s ease; }
        .slide-panel.abierto { transform: translateX(0); }
        .mapa-delivery { height: 200px; width: 100%; border-radius: 12px; z-index: 1; }
    </style>
</head>
<body class="bg-gray-100 min-h-screen">

<!-- OVERLAY MÓVIL -->
<div id="overlay" class="fixed inset-0 bg-black/40 z-30 hidden md:hidden" onclick="cerrarMenu()"></div>

<!-- SIDEBAR MÓVIL -->
<div id="sidebarMovil"
     class="slide-panel fixed top-0 left-0 h-full w-64 bg-gray-900 text-white z-40 flex flex-col md:hidden">
    <div class="p-6 border-b border-gray-700 flex items-center justify-between">
        <div>
            <h1 class="text-xl font-bold text-blue-400">Hola, Delivery</h1>
            <p class="text-xs text-gray-400 mt-1">${sessionScope.usuario.nombre}</p>
        </div>
        <button onclick="cerrarMenu()" class="text-gray-400 hover:text-white">
            <i class="fa-solid fa-xmark text-xl"></i>
        </button>
    </div>
    <nav class="flex flex-col p-4 gap-2 flex-1">
        <a href="${pageContext.request.contextPath}/delivery/pedidos"
           class="flex items-center gap-3 px-4 py-2 rounded-lg bg-blue-500 text-white font-medium">
            <i class="fa-solid fa-motorcycle"></i> Pedidos por despachar
        </a>
        <a href="${pageContext.request.contextPath}/logout"
           class="flex items-center gap-3 px-4 py-2 rounded-lg hover:bg-red-700 transition text-red-400 mt-auto">
            <i class="fa-solid fa-right-from-bracket"></i> Cerrar sesión
        </a>
    </nav>
</div>

<div class="flex min-h-screen">

    <!-- SIDEBAR DESKTOP -->
    <aside class="w-64 bg-gray-900 text-white flex-col hidden md:flex">
        <div class="p-6 border-b border-gray-700">
            <h1 class="text-xl font-bold text-blue-400">Hola, Delivery</h1>
            <p class="text-xs text-gray-400 mt-1">${sessionScope.usuario.nombre}</p>
        </div>
        <nav class="flex flex-col p-4 gap-2 flex-1">
            <a href="${pageContext.request.contextPath}/delivery/pedidos"
               class="flex items-center gap-3 px-4 py-2 rounded-lg bg-blue-500 text-white font-medium">
                <i class="fa-solid fa-motorcycle"></i> Pedidos por despachar
            </a>
            <a href="${pageContext.request.contextPath}/logout"
               class="flex items-center gap-3 px-4 py-2 rounded-lg hover:bg-red-700 transition text-red-400">
                <i class="fa-solid fa-right-from-bracket"></i> Cerrar sesión
            </a>
        </nav>
    </aside>

    <main class="flex-1 overflow-auto">

        <!-- TOPBAR MÓVIL -->
        <div class="md:hidden flex items-center justify-between bg-gray-900 text-white px-4 py-3">
            <button onclick="abrirMenu()" class="text-white text-xl">
                <i class="fa-solid fa-bars"></i>
            </button>
            <span class="font-bold text-blue-400">Delivery</span>
            <span class="text-xs text-gray-400">${sessionScope.usuario.nombre}</span>
        </div>

        <div class="p-4 md:p-8">
            <h2 class="text-2xl font-bold text-gray-800 mb-6">Pedidos por Despachar</h2>

            <c:if test="${not empty sessionScope.exito}">
                <div class="bg-green-100 text-green-700 px-4 py-3 rounded-lg mb-4">
                    ${sessionScope.exito} <c:remove var="exito" scope="session"/>
                </div>
            </c:if>
            <c:if test="${not empty sessionScope.error}">
                <div class="bg-red-100 text-red-700 px-4 py-3 rounded-lg mb-4">
                    ${sessionScope.error} <c:remove var="error" scope="session"/>
                </div>
            </c:if>

            <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
                <c:forEach items="${pedidos}" var="p">
                    <div class="bg-white rounded-2xl shadow p-5 flex flex-col gap-3">
                        <div class="flex items-center justify-between">
                            <span class="font-bold text-lg text-gray-800">#${p.id}</span>
                            <span class="px-2 py-1 rounded-full text-xs font-semibold bg-blue-100 text-blue-600">
                                ${p.estado}
                            </span>
                        </div>
                        <p class="text-sm text-gray-500">
                            <i class="fa-regular fa-clock mr-1"></i>${p.fecha}
                        </p>
                        <p class="text-sm font-semibold text-gray-700">
                            <i class="fa-solid fa-user mr-1 text-gray-400"></i>${p.usuarioNombre}
                        </p>
                        <p class="text-sm text-gray-500">
                            <i class="fa-solid fa-location-dot mr-1"></i>${p.direccion}
                        </p>
                        <p class="font-bold text-red-600">
                            S/<fmt:formatNumber value="${p.total}" pattern="#,##0.00"/>
                        </p>

                        <div class="flex gap-2 mt-auto">
                            <button onclick="abrirDetalle('detalle-${p.id}')"
                                    class="flex-1 text-center bg-gray-100 hover:bg-gray-200 text-gray-700 px-3 py-2 rounded-lg text-xs font-semibold transition">
                                <i class="fa-solid fa-eye mr-1"></i> Ver detalle
                            </button>
                            <form action="${pageContext.request.contextPath}/delivery/pedidos" method="post" class="flex-1">
                                <input type="hidden" name="id" value="${p.id}">
                                <input type="hidden" name="estado" value="Entregado">
                                <button type="submit"
                                        class="w-full bg-green-500 hover:bg-green-600 text-white px-3 py-2 rounded-lg text-xs font-semibold transition">
                                    <i class="fa-solid fa-check mr-1"></i> Entregado
                                </button>
                            </form>
                        </div>
                    </div>

                    <!-- MODAL DETALLE CON MAPA -->
                    <div id="detalle-${p.id}"
                         class="fixed inset-0 bg-black/50 z-50 hidden flex items-center justify-center p-4">
                        <div class="bg-white rounded-2xl shadow-xl w-full max-w-lg max-h-[90vh] overflow-y-auto">

                            <!-- Header -->
                            <div class="flex items-center justify-between px-6 py-4 border-b border-gray-100">
                                <h3 class="text-lg font-bold text-gray-800">Pedido #${p.id}</h3>
                                <button onclick="cerrarDetalle('detalle-${p.id}')"
                                        class="text-gray-400 hover:text-gray-600 text-xl">
                                    <i class="fa-solid fa-xmark"></i>
                                </button>
                            </div>

                            <!-- Info básica -->
                            <div class="px-6 py-4 border-b border-gray-100 grid grid-cols-2 gap-3 text-sm">
                                <div class="col-span-2">
                                <p class="text-xs text-gray-400 font-semibold uppercase mb-1">Cliente</p>
                                <p class="text-gray-700 font-semibold">${p.usuarioNombre}</p>
                                </div>
                                <div>
                                    <p class="text-xs text-gray-400 font-semibold uppercase mb-1">Fecha</p>
                                    <p class="text-gray-700">${p.fecha}</p>
                                </div>
                                <div>
                                    <p class="text-xs text-gray-400 font-semibold uppercase mb-1">Total</p>
                                    <p class="font-bold text-red-600">
                                        S/<fmt:formatNumber value="${p.total}" pattern="#,##0.00"/>
                                    </p>
                                </div>
                                <div class="col-span-2">
                                    <p class="text-xs text-gray-400 font-semibold uppercase mb-1">Dirección</p>
                                    <p class="text-gray-700">${p.direccion}</p>
                                </div>
                            </div>

                            <!-- MAPA -->
                            <div class="px-6 py-4 border-b border-gray-100">
                                <p class="text-xs text-gray-400 font-semibold uppercase mb-2">
                                    <i class="fa-solid fa-map-location-dot mr-1 text-blue-500"></i>Ubicación del cliente
                                </p>
                                <c:choose>
                                    <c:when test="${not empty p.latitud && not empty p.longitud}">
                                        <div id="mapa-${p.id}" class="mapa-delivery"></div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="bg-gray-50 rounded-xl p-4 text-center text-gray-400 text-sm">
                                            <i class="fa-solid fa-map-location-dot text-2xl mb-1 text-gray-300"></i>
                                            <p>Ubicación no disponible</p>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <!-- Productos -->
                            <div class="px-6 py-4">
                                <p class="text-sm font-semibold text-gray-700 mb-3">Productos:</p>
                                <div class="flex flex-col gap-3">
                                    <c:forEach items="${p.detalles}" var="d">
                                        <div class="bg-gray-50 rounded-xl p-3">
                                            <div class="flex items-center justify-between mb-1">
                                                <span class="font-semibold text-sm text-gray-800">${d.productoNombre}</span>
                                                <span class="text-xs bg-gray-200 text-gray-600 px-2 py-0.5 rounded-full">x${d.cantidad}</span>
                                            </div>
                                            <c:if test="${not empty d.opciones}">
                                                <div class="flex flex-wrap gap-1 mt-1">
                                                    <c:forEach items="${d.opciones}" var="op">
                                                        <span class="text-xs bg-blue-100 text-blue-600 px-2 py-0.5 rounded-full">
                                                            ${op.nombreOpcion}
                                                        </span>
                                                    </c:forEach>
                                                </div>
                                            </c:if>
                                            <p class="text-xs text-red-600 font-semibold mt-1">
                                                S/<fmt:formatNumber value="${d.subtotal}" pattern="#,##0.00"/>
                                            </p>
                                        </div>
                                    </c:forEach>
                                </div>
                            </div>

                            <!-- Footer -->
                            <div class="px-6 py-4 border-t border-gray-100 flex justify-between items-center">
                                <form action="${pageContext.request.contextPath}/delivery/pedidos" method="post">
                                    <input type="hidden" name="id" value="${p.id}">
                                    <input type="hidden" name="estado" value="Entregado">
                                    <button type="submit"
                                            class="bg-green-500 hover:bg-green-600 text-white px-4 py-2 rounded-lg text-sm font-semibold transition">
                                        <i class="fa-solid fa-check mr-1"></i> Marcar entregado
                                    </button>
                                </form>
                                <button onclick="cerrarDetalle('detalle-${p.id}')"
                                        class="bg-gray-200 hover:bg-gray-300 text-gray-700 px-4 py-2 rounded-lg text-sm font-semibold transition">
                                    Cerrar
                                </button>
                            </div>
                        </div>
                    </div>

                </c:forEach>

                <c:if test="${empty pedidos}">
                    <div class="col-span-3 bg-white rounded-2xl shadow p-10 text-center text-gray-400">
                        <i class="fa-solid fa-check-circle text-4xl text-green-400 mb-3"></i>
                        <p class="font-medium">No hay pedidos por despachar</p>
                    </div>
                </c:if>
            </div>
        </div>
    </main>
</div>

<script>
    // ── MENÚ MÓVIL ────────────────────────────────────────
    function abrirMenu() {
        document.getElementById('sidebarMovil').classList.add('abierto');
        document.getElementById('overlay').classList.remove('hidden');
        document.body.style.overflow = 'hidden';
    }
    function cerrarMenu() {
        document.getElementById('sidebarMovil').classList.remove('abierto');
        document.getElementById('overlay').classList.add('hidden');
        document.body.style.overflow = '';
    }

    // ── MAPAS: datos desde servidor ───────────────────────
    var mapasCargados = {};

    // Coordenadas de cada pedido inyectadas desde JSP
    var coordenadasPedidos = {
        <c:forEach items="${pedidos}" var="p" varStatus="vs">
            <c:if test="${not empty p.latitud && not empty p.longitud}">
                '${p.id}': { lat: ${p.latitud}, lng: ${p.longitud} }<c:if test="${!vs.last}">,</c:if>
            </c:if>
        </c:forEach>
    };

    // ── MODAL ─────────────────────────────────────────────
    function abrirDetalle(id) {
        document.getElementById(id).classList.remove('hidden');
        document.body.style.overflow = 'hidden';

        // Extraer ID del pedido del string "detalle-123"
        var pedidoId = id.replace('detalle-', '');

        // Inicializar mapa solo si tiene coordenadas y no fue cargado antes
        if (coordenadasPedidos[pedidoId] && !mapasCargados[pedidoId]) {
            setTimeout(function() {
                var coords = coordenadasPedidos[pedidoId];
                var mapaDiv = document.getElementById('mapa-' + pedidoId);
                if (!mapaDiv) return;

                var mapa = L.map('mapa-' + pedidoId).setView([coords.lat, coords.lng], 16);

                L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                    attribution: '© OpenStreetMap'
                }).addTo(mapa);

                // Fijar íconos
                delete L.Icon.Default.prototype._getIconUrl;
                L.Icon.Default.mergeOptions({
                    iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
                    iconRetinaUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png',
                    shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
                });

                L.marker([coords.lat, coords.lng]).addTo(mapa);

                mapasCargados[pedidoId] = true;
            }, 100);
        }
    }

    function cerrarDetalle(id) {
        document.getElementById(id).classList.add('hidden');
        document.body.style.overflow = '';
    }

    document.querySelectorAll('[id^="detalle-"]').forEach(function(modal) {
        modal.addEventListener('click', function(e) {
            if (e.target === this) cerrarDetalle(this.id);
        });
    });
</script>
</body>
</html>