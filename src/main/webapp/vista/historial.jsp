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
        .slide-panel {
            transform: translateX(100%);
            transition: transform 0.35s cubic-bezier(.4,0,.2,1);
        }
        .slide-panel.abierto {
            transform: translateX(0);
        }
        .tab-btn.activo {
            border-bottom: 3px solid #dc2626;
            color: #dc2626;
            font-weight: 700;
        }
    </style>
</head>
<body class="bg-gray-50 min-h-screen">

    <jsp:include page="/components/header.jsp"/>

    <div class="max-w-4xl mx-auto px-4 py-8">

        <!-- CABECERA con nombre y dropdown -->
        <div class="flex items-center justify-between mb-6">
            <h2 class="text-2xl font-bold text-gray-800">Mis Pedidos</h2>

            <!-- Dropdown del cliente -->
            <div class="relative">
                <button onclick="toggleDropdown()"
                        class="flex items-center gap-2 bg-white border border-gray-200 shadow-sm px-4 py-2 rounded-xl text-sm font-medium text-gray-700 hover:border-red-400 hover:text-red-600 transition">
                    <i class="fa-solid fa-circle-user text-red-500 text-lg"></i>
                    ${sessionScope.usuario.nombre}
                    <i class="fa-solid fa-chevron-down text-xs text-gray-400" id="iconDropdown"></i>
                </button>

                <!-- Menú dropdown -->
                <div id="dropdown"
                     class="hidden absolute right-0 top-full mt-2 w-56 bg-white rounded-2xl shadow-lg border border-gray-100 z-30 overflow-hidden">
                    <div class="px-4 py-3 border-b border-gray-100 bg-red-50">
                        <p class="text-sm font-semibold text-gray-800">${sessionScope.usuario.nombre}</p>
                        <p class="text-xs text-gray-500">${sessionScope.usuario.email}</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/home"
                       class="flex items-center gap-3 px-4 py-3 text-sm text-gray-700 hover:bg-red-50 hover:text-red-600 transition">
                        <i class="fa-solid fa-house w-4"></i> Inicio
                    </a>
                    <a href="${pageContext.request.contextPath}/historial"
                       class="flex items-center gap-3 px-4 py-3 text-sm text-red-600 bg-red-50 font-medium">
                        <i class="fa-solid fa-clock-rotate-left w-4"></i> Mis pedidos
                    </a>
                    <a href="${pageContext.request.contextPath}/carrito"
                       class="flex items-center gap-3 px-4 py-3 text-sm text-gray-700 hover:bg-red-50 hover:text-red-600 transition">
                        <i class="fa-solid fa-bag-shopping w-4"></i> Mi carrito
                    </a>
                    <a href="${pageContext.request.contextPath}/libro-reclamaciones"
                       class="flex items-center gap-3 px-4 py-3 text-sm text-gray-700 hover:bg-red-50 hover:text-red-600 transition">
                        <i class="fa-solid fa-book-open w-4"></i> Reclamaciones
                    </a>
                    <div class="border-t border-gray-100"></div>
                    <a href="${pageContext.request.contextPath}/logout"
                       class="flex items-center gap-3 px-4 py-3 text-sm text-red-500 hover:bg-red-50 transition">
                        <i class="fa-solid fa-right-from-bracket w-4"></i> Cerrar sesión
                    </a>
                </div>
            </div>
        </div>

        <!-- TABS -->
        <div class="flex border-b border-gray-200 mb-6 gap-4 overflow-x-auto">
            <button class="tab-btn activo pb-3 text-sm transition whitespace-nowrap" onclick="filtrar('todos', this)">
                Todos
            </button>
            <button class="tab-btn pb-3 text-sm text-gray-500 transition whitespace-nowrap" onclick="filtrar('Pendiente', this)">
                Pendientes
            </button>
            <button class="tab-btn pb-3 text-sm text-gray-500 transition whitespace-nowrap" onclick="filtrar('En cocina', this)">
                En cocina
            </button>
            <button class="tab-btn pb-3 text-sm text-gray-500 transition whitespace-nowrap" onclick="filtrar('Por despachar', this)">
                Por despachar
            </button>
            <button class="tab-btn pb-3 text-sm text-gray-500 transition whitespace-nowrap" onclick="filtrar('Entregado', this)">
                Entregados
            </button>
            <button class="tab-btn pb-3 text-sm text-gray-500 transition whitespace-nowrap" onclick="filtrar('Cancelado', this)">
                Cancelados
            </button>
        </div>

        <!-- LISTA PEDIDOS -->
        <div id="listaPedidos" class="flex flex-col gap-4">
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
                        <div class="pedido-card bg-white rounded-2xl shadow p-5"
                             data-estado="${p.estado}">
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

                        <!-- MODAL DETALLE -->
                        <div id="detalle-${p.id}"
                             class="fixed inset-0 bg-black/50 z-50 hidden flex items-center justify-center p-4">
                            <div class="bg-white rounded-2xl shadow-xl w-full max-w-lg max-h-[80vh] overflow-y-auto">
                                <div class="flex items-center justify-between px-6 py-4 border-b border-gray-100">
                                    <h3 class="text-lg font-bold text-gray-800">
                                        Pedido #${p.id}
                                        <span class="ml-2 px-2 py-1 rounded-full text-xs font-semibold
                                            ${p.estado == 'Pendiente'     ? 'bg-yellow-100 text-yellow-600' :
                                              p.estado == 'En cocina'     ? 'bg-orange-100 text-orange-600' :
                                              p.estado == 'Por despachar' ? 'bg-blue-100 text-blue-600' :
                                              p.estado == 'Entregado'     ? 'bg-green-100 text-green-600' :
                                                                            'bg-red-100 text-red-600'}">
                                            ${p.estado}
                                        </span>
                                    </h3>
                                    <button onclick="cerrarDetalle('detalle-${p.id}')"
                                            class="text-gray-400 hover:text-gray-600 text-xl">
                                        <i class="fa-solid fa-xmark"></i>
                                    </button>
                                </div>
                                <div class="px-6 py-4 border-b border-gray-100 grid grid-cols-2 gap-3 text-sm">
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
                                                            <span class="text-xs bg-red-100 text-red-600 px-2 py-0.5 rounded-full">
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
        </div>
    </div>

    <jsp:include page="/components/footer.jsp"/>

    <script>
        // Dropdown
        function toggleDropdown() {
            const dd = document.getElementById('dropdown');
            const icon = document.getElementById('iconDropdown');
            dd.classList.toggle('hidden');
            icon.classList.toggle('rotate-180');
        }
        // Cerrar dropdown al hacer clic fuera
        document.addEventListener('click', function(e) {
            const dd = document.getElementById('dropdown');
            if (!e.target.closest('.relative')) {
                dd.classList.add('hidden');
                document.getElementById('iconDropdown').classList.remove('rotate-180');
            }
        });

        // Modal detalle
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

        // Tabs filtro
        function filtrar(estado, btn) {
            document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('activo'));
            btn.classList.add('activo');
            document.querySelectorAll('.pedido-card').forEach(card => {
                if (estado === 'todos' || card.dataset.estado === estado) {
                    card.style.display = '';
                } else {
                    card.style.display = 'none';
                }
            });
        }
    </script>
</body>
</html>