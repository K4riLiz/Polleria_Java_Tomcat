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
    <title>Mis Pedidos - El Dorado</title>
    <style>
        .tab-btn { border-bottom: 3px solid transparent; transition: all 0.2s; }
        .tab-btn.activo { border-bottom-color: #dc2626; color: #dc2626; font-weight: 700; }
    </style>
</head>
<body class="bg-gray-50 min-h-screen">

    <jsp:include page="/components/header.jsp"/>

    <div class="max-w-4xl mx-auto px-4 py-8">
        <h2 class="text-2xl font-bold text-gray-800 mb-6">Mis Pedidos</h2>

        <!-- TABS: 3 secciones -->
        <div class="flex border-b border-gray-200 mb-6 gap-6">
            <button class="tab-btn activo pb-3 text-sm whitespace-nowrap" onclick="filtrar('proceso', this)">En proceso
            </button>
            <button class="tab-btn pb-3 text-sm text-gray-500 whitespace-nowrap" onclick="filtrar('entregado', this)">Entregados
            </button>
            <button class="tab-btn pb-3 text-sm text-gray-500 whitespace-nowrap" onclick="filtrar('cancelado', this)">Cancelados
            </button>
        </div>

        <!-- LISTA -->
        <div class="flex flex-col gap-4">
            <c:choose>
                <c:when test="${empty pedidos}">
                    <div class="bg-white rounded-2xl shadow p-12 text-center text-gray-400">
                        <i class="fa-solid fa-bag-shopping text-5xl mb-4 text-gray-300"></i>
                        <p class="text-lg font-medium mb-2">Aún no tienes pedidos</p>
                        <a href="${pageContext.request.contextPath}/home"
                           class="bg-red-600 hover:bg-red-700 text-white px-6 py-2 rounded-xl text-sm font-semibold transition">
                            Ir al menú
                        </a>
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach items="${pedidos}" var="p">
                        <%-- Clasificar el pedido --%>
                        <c:set var="grupo"
                               value="${p.estado == 'Entregado' ? 'entregado' :
                                       p.estado == 'Cancelado'  ? 'cancelado' : 'proceso'}"/>

                        <div class="pedido-card bg-white rounded-2xl shadow p-5"
                             data-grupo="${grupo}"
                             style="${grupo != 'proceso' ? 'display:none' : ''}">
                            <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
                                <div class="flex flex-col gap-1">
                                    <div class="flex items-center gap-3">
                                        <span class="font-bold text-gray-800 text-lg">#${p.id}</span>
                                        <span class="px-2 py-1 rounded-full text-xs font-semibold
                                            ${p.estado == 'Pendiente'     ? 'bg-yellow-100 text-yellow-600' :
                                              p.estado == 'En cocina'     ? 'bg-orange-100 text-orange-600' :
                                              p.estado == 'Por despachar' ? 'bg-blue-100 text-blue-600' :
                                              p.estado == 'Entregado'     ? 'bg-green-100 text-green-600' :
                                                                            'bg-red-100 text-red-600'}">
                                            ${p.estado}
                                        </span>
                                    </div>
                                    <p class="text-sm text-gray-500">
                                        <i class="fa-regular fa-clock mr-1"></i>${p.fecha}
                                    </p>
                                    <p class="text-sm text-gray-500">
                                        <i class="fa-solid fa-location-dot mr-1"></i>${p.direccion}
                                    </p>
                                </div>
                                <div class="flex items-center gap-4">
                                    <p class="font-bold text-red-600 text-xl">
                                        S/<fmt:formatNumber value="${p.total}" pattern="#,##0.00"/>
                                    </p>
                                    <button onclick="abrirDetalle('detalle-${p.id}')"
                                            class="bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-xl text-sm font-semibold transition">
                                        Ver detalle
                                    </button>
                                </div>
                            </div>
                        </div>

                        <!-- MODAL DETALLE estilo confirmación -->
                        <div id="detalle-${p.id}"
                             class="fixed inset-0 bg-black/50 z-50 hidden flex items-center justify-center p-4">
                            <div class="bg-white rounded-2xl shadow-xl w-full max-w-lg max-h-[90vh] overflow-y-auto">

                                <!-- Header modal -->
                                <div class="flex items-center justify-between px-6 py-4 border-b border-gray-100">
                                    <h3 class="text-lg font-bold text-gray-800">Pedido #${p.id}</h3>
                                    <button onclick="cerrarDetalle('detalle-${p.id}')"
                                            class="text-gray-400 hover:text-gray-600 text-xl">
                                        <i class="fa-solid fa-xmark"></i>
                                    </button>
                                </div>

                                <div class="p-6 flex flex-col gap-5">

                                    <!-- SEGUIMIENTO -->
                                    <div>
                                        <p class="text-sm font-semibold text-gray-700 mb-4">
                                            <i class="fa-solid fa-timeline text-red-600 mr-2"></i>Seguimiento
                                        </p>
                                        <div class="relative flex items-center justify-between">
                                            <!-- Línea base -->
                                            <div class="absolute top-4 left-0 right-0 h-1 bg-gray-200 z-0"></div>
                                            <!-- Línea progreso -->
                                            <div class="absolute top-4 left-0 h-1 bg-red-500 z-0 transition-all"
                                                 style="width:
                                                    ${p.estado == 'Pendiente'     ? '0%'   :
                                                      p.estado == 'En cocina'     ? '33%'  :
                                                      p.estado == 'Por despachar' ? '66%'  :
                                                      p.estado == 'Entregado'     ? '100%' : '0%'}">
                                            </div>

                                            <%-- Paso 1: Pendiente --%>
                                            <div class="flex flex-col items-center gap-2 z-10">
                                                <div class="w-8 h-8 rounded-full flex items-center justify-center text-xs
                                                    ${p.estado == 'Pendiente' || p.estado == 'En cocina' || p.estado == 'Por despachar' || p.estado == 'Entregado'
                                                      ? 'bg-red-600 text-white' : 'bg-gray-200 text-gray-400'}">
                                                    <i class="fa-solid fa-clock"></i>
                                                </div>
                                                <p class="text-xs text-gray-500 text-center w-16">Pendiente</p>
                                            </div>

                                            <%-- Paso 2: En cocina --%>
                                            <div class="flex flex-col items-center gap-2 z-10">
                                                <div class="w-8 h-8 rounded-full flex items-center justify-center text-xs
                                                    ${p.estado == 'En cocina' || p.estado == 'Por despachar' || p.estado == 'Entregado'
                                                      ? 'bg-red-600 text-white' : 'bg-gray-200 text-gray-400'}">
                                                    <i class="fa-solid fa-fire"></i>
                                                </div>
                                                <p class="text-xs text-gray-500 text-center w-16">En cocina</p>
                                            </div>

                                            <%-- Paso 3: Por despachar --%>
                                            <div class="flex flex-col items-center gap-2 z-10">
                                                <div class="w-8 h-8 rounded-full flex items-center justify-center text-xs
                                                    ${p.estado == 'Por despachar' || p.estado == 'Entregado'
                                                      ? 'bg-red-600 text-white' : 'bg-gray-200 text-gray-400'}">
                                                    <i class="fa-solid fa-motorcycle"></i>
                                                </div>
                                                <p class="text-xs text-gray-500 text-center w-16">Despachando</p>
                                            </div>

                                            <%-- Paso 4: Entregado --%>
                                            <div class="flex flex-col items-center gap-2 z-10">
                                                <div class="w-8 h-8 rounded-full flex items-center justify-center text-xs
                                                    ${p.estado == 'Entregado'
                                                      ? 'bg-green-500 text-white' : 'bg-gray-200 text-gray-400'}">
                                                    <i class="fa-solid fa-check"></i>
                                                </div>
                                                <p class="text-xs text-gray-500 text-center w-16">Entregado</p>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- PRODUCTOS -->
                                    <div>
                                        <p class="text-sm font-semibold text-gray-700 mb-3">
                                            <i class="fa-solid fa-receipt text-red-600 mr-2"></i>Productos
                                        </p>
                                        <div class="flex flex-col gap-2">
                                            <c:forEach items="${p.detalles}" var="d">
                                                <div class="flex justify-between items-start py-2 border-b border-gray-50">
                                                    <div>
                                                        <p class="font-medium text-sm">${d.productoNombre} x${d.cantidad}</p>
                                                        <c:if test="${not empty d.opciones}">
                                                            <div class="flex flex-wrap gap-1 mt-1">
                                                                <c:forEach items="${d.opciones}" var="op">
                                                                    <span class="text-xs bg-red-100 text-red-600 px-2 py-0.5 rounded-full">
                                                                        ${op.nombreOpcion}
                                                                    </span>
                                                                </c:forEach>
                                                            </div>
                                                        </c:if>
                                                    </div>
                                                    <span class="font-bold text-sm text-gray-700">
                                                        S/<fmt:formatNumber value="${d.subtotal}" pattern="#,##0.00"/>
                                                    </span>
                                                </div>
                                            </c:forEach>
                                        </div>
                                        <div class="flex justify-between font-bold text-base text-gray-800 pt-3">
                                            <span>Total</span>
                                            <span class="text-red-600">S/<fmt:formatNumber value="${p.total}" pattern="#,##0.00"/></span>
                                        </div>
                                    </div>

                                    <!-- INFO -->
                                    <div class="bg-gray-50 rounded-xl p-4 text-sm grid grid-cols-2 gap-3">
                                        <div>
                                            <p class="text-xs text-gray-400 mb-1">Fecha</p>
                                            <p class="font-medium text-gray-700">${p.fecha}</p>
                                        </div>
                                        <div>
                                            <p class="text-xs text-gray-400 mb-1">Estado</p>
                                            <span class="px-2 py-1 rounded-full text-xs font-semibold
                                                ${p.estado == 'Pendiente'     ? 'bg-yellow-100 text-yellow-600' :
                                                  p.estado == 'En cocina'     ? 'bg-orange-100 text-orange-600' :
                                                  p.estado == 'Por despachar' ? 'bg-blue-100 text-blue-600' :
                                                  p.estado == 'Entregado'     ? 'bg-green-100 text-green-600' :
                                                                                'bg-red-100 text-red-600'}">
                                                ${p.estado}
                                            </span>
                                        </div>
                                        <div class="col-span-2">
                                            <p class="text-xs text-gray-400 mb-1">Dirección</p>
                                            <p class="font-medium text-gray-700">${p.direccion}</p>
                                        </div>
                                    </div>
                                </div>

                                <div class="px-6 py-4 border-t border-gray-100 flex justify-end">
                                    <button onclick="cerrarDetalle('detalle-${p.id}')"
                                            class="bg-gray-200 hover:bg-gray-300 text-gray-700 px-4 py-2 rounded-lg text-sm font-semibold transition">
                                        Cerrar
                                    </button>
                                </div>
                            </div>
                        </div>

                    </c:forEach>
                </c:otherwise>
            </c:choose>

            <!-- Mensaje vacío por tab -->
            <div id="msgVacio" class="hidden bg-white rounded-2xl shadow p-10 text-center text-gray-400">
                <i class="fa-solid fa-inbox text-4xl mb-3 text-gray-300"></i>
                <p class="font-medium">No hay pedidos en esta sección</p>
            </div>
        </div>
    </div>

    <jsp:include page="/components/footer.jsp"/>

    <script>
        function filtrar(grupo, btn) {
            document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('activo'));
            btn.classList.add('activo');

            let visible = 0;
            document.querySelectorAll('.pedido-card').forEach(card => {
                if (card.dataset.grupo === grupo) {
                    card.style.display = '';
                    visible++;
                } else {
                    card.style.display = 'none';
                }
            });

            document.getElementById('msgVacio').classList.toggle('hidden', visible > 0);
        }

        function abrirDetalle(id) {
            document.getElementById(id).classList.remove('hidden');
            document.body.style.overflow = 'hidden';
        }
        function cerrarDetalle(id) {
            document.getElementById(id).classList.add('hidden');
            document.body.style.overflow = '';
        }
        document.querySelectorAll('[id^="detalle-"]').forEach(modal => {
            modal.addEventListener('click', function(e) {
                if (e.target === this) cerrarDetalle(this.id);
            });
        });

        // Mostrar mensaje vacío al cargar si no hay pedidos en proceso
        window.addEventListener('load', () => {
            const cards = document.querySelectorAll('.pedido-card[data-grupo="proceso"]');
            document.getElementById('msgVacio').classList.toggle('hidden', cards.length > 0);
        });
    </script>
</body>
</html>