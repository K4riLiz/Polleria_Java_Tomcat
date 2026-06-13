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
    <title>Admin - Pedidos</title>
    <style>
        .tab-btn { border-bottom: 3px solid transparent; transition: all 0.2s; }
        .tab-btn.activo { border-bottom-color: #dc2626; color: #dc2626; font-weight: 700; }
        .subtab-btn { transition: all 0.2s; }
        .subtab-btn.activo { background: #dc2626; color: white; }
    </style>
</head>
<body class="bg-gray-100 min-h-screen">
<div class="flex min-h-screen">

    <!-- SIDEBAR -->
    <!-- SIDEBAR -->
    <aside class="w-64 bg-gray-900 text-white flex flex-col">
        <div class="p-6 border-b border-gray-700">
            <h1 class="text-xl font-bold text-red-400">Hola, admin</h1>
            <p class="text-xs text-gray-400 mt-1">${sessionScope.usuario.nombre}</p>
        </div>
        <nav class="flex flex-col p-4 gap-2 flex-1">
            <a href="${pageContext.request.contextPath}/admin/usuarios"
               class="flex items-center gap-3 px-4 py-2 rounded-lg hover:bg-gray-700 transition">
                <i class="fa-solid fa-users"></i> Usuarios
            </a>
            <!-- Roles: fa-shield-halved puede no cargar, usar fa-shield -->
            <a href="${pageContext.request.contextPath}/admin/roles"
               class="flex items-center gap-3 px-4 py-2 rounded-lg hover:bg-gray-700 transition">
                <i class="fa-solid fa-shield"></i> Roles
            </a>
            <!-- Productos: fa-bowl-food puede no cargar, usar fa-utensils -->
            <a href="${pageContext.request.contextPath}/admin/productos"
               class="flex items-center gap-3 px-4 py-2 rounded-lg hover:bg-gray-700 transition">
                <i class="fa-solid fa-utensils"></i> Productos
            </a>
            <a href="${pageContext.request.contextPath}/admin/pedidos"
               class="flex items-center gap-3 px-4 py-2 rounded-lg hover:bg-gray-700 transition">
                <i class="fa-solid fa-receipt"></i> Pedidos
            </a>
            <a href="${pageContext.request.contextPath}/admin/opciones"
               class="flex items-center gap-3 px-4 py-2 rounded-lg bg-red-600 text-white font-medium">
                <i class="fa-solid fa-sliders"></i> Opciones
            </a>
            <a href="${pageContext.request.contextPath}/admin/reclamaciones"
               class="flex items-center gap-3 px-4 py-2 rounded-lg hover:bg-gray-700 transition">
                <i class="fa-solid fa-book-open"></i> Reclamaciones
            </a>
            <a href="${pageContext.request.contextPath}/logout"
               class="flex items-center gap-3 px-4 py-2 rounded-lg hover:bg-red-700 transition text-red-400">
                <i class="fa-solid fa-right-from-bracket"></i> Cerrar sesión
            </a>
        </nav>
    </aside>

    <!-- CONTENIDO -->
    <main class="flex-1 p-8 overflow-auto">
        <h2 class="text-2xl font-bold text-gray-800 mb-6">Gestión de Pedidos</h2>

        <!-- ALERTAS -->
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

        <!-- TABS PRINCIPALES -->
        <div class="flex border-b border-gray-200 mb-4 gap-6">
            <button class="tab-btn activo pb-3 text-sm whitespace-nowrap"
                    onclick="cambiarTab('proceso', this)">En proceso
            </button>
            <button class="tab-btn pb-3 text-sm text-gray-500 whitespace-nowrap"
                    onclick="cambiarTab('entregado', this)">Entregados
            </button>
            <button class="tab-btn pb-3 text-sm text-gray-500 whitespace-nowrap"
                    onclick="cambiarTab('cancelado', this)">Cancelados
            </button>
        </div>

        <!-- SUBTABS (solo visibles en "proceso") -->
        <div id="subtabs" class="flex gap-2 mb-4 flex-wrap">
            <button class="subtab-btn activo px-3 py-1.5 rounded-lg text-xs font-semibold border border-gray-200"
                    onclick="filtrarEstado('todos', this)">
                Todos
            </button>
            <button class="subtab-btn px-3 py-1.5 rounded-lg text-xs font-semibold border border-gray-200 text-gray-600"
                    onclick="filtrarEstado('Pendiente', this)">
                Pendiente
            </button>
            <button class="subtab-btn px-3 py-1.5 rounded-lg text-xs font-semibold border border-gray-200 text-gray-600"
                    onclick="filtrarEstado('En cocina', this)">
                En cocina
            </button>
            <button class="subtab-btn px-3 py-1.5 rounded-lg text-xs font-semibold border border-gray-200 text-gray-600"
                    onclick="filtrarEstado('Por despachar', this)">
                Por despachar
            </button>
        </div>

        <!-- TABLA -->
        <div class="bg-white rounded-2xl shadow overflow-hidden">
            <table class="w-full text-sm">
                <thead class="bg-gray-50 text-gray-600 uppercase text-xs">
                    <tr>
                        <th class="px-4 py-3 text-left">#</th>
                        <th class="px-4 py-3 text-left">Cliente</th>
                        <th class="px-4 py-3 text-left">Total</th>
                        <th class="px-4 py-3 text-left">Estado</th>
                        <th class="px-4 py-3 text-left">Fecha</th>
                        <th class="px-4 py-3 text-center">Acciones</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-100" id="tablaPedidos">
                    <c:forEach items="${pedidos}" var="p">
                        <c:set var="grupo"
                               value="${p.estado == 'Entregado' ? 'entregado' :
                                       p.estado == 'Cancelado'  ? 'cancelado' : 'proceso'}"/>
                        <tr class="pedido-row hover:bg-gray-50"
                            data-grupo="${grupo}"
                            data-estado="${p.estado}"
                            style="${grupo != 'proceso' ? 'display:none' : ''}">
                            
                            <td class="px-4 py-3 text-gray-400">#${p.id}</td>
                            <td class="px-4 py-3">
                                <c:if test="${not empty p.usuarioNombre}">
                                    <p class="font-medium text-gray-800">${p.usuarioNombre}</p>
                                </c:if>
                                <p class="text-xs text-gray-400">ID: ${p.usuarioId}</p>
                            </td>
                            
                            <td class="px-4 py-3 font-bold text-red-600">
                                S/<fmt:formatNumber value="${p.total}" pattern="#,##0.00"/>
                            </td>
                            <td class="px-4 py-3">
                                <span class="px-2 py-1 rounded-full text-xs font-semibold
                                    ${p.estado == 'Pendiente'     ? 'bg-yellow-100 text-yellow-600' :
                                      p.estado == 'En cocina'     ? 'bg-orange-100 text-orange-600' :
                                      p.estado == 'Por despachar' ? 'bg-blue-100 text-blue-600' :
                                      p.estado == 'Entregado'     ? 'bg-green-100 text-green-600' :
                                                                     'bg-red-100 text-red-600'}">
                                    ${p.estado}
                                </span>
                            </td>
                            <td class="px-4 py-3 text-gray-500">${p.fecha}</td>
                            <td class="px-4 py-3">
                                <div class="flex items-center justify-center gap-2">
                                    <!-- Ver detalle → modal -->
                                    <button onclick="abrirModal('modal-${p.id}')"
                                            class="bg-red-600 hover:bg-red-700 text-white px-3 py-1.5 rounded-lg transition flex items-center gap-1 text-xs">
                                        <i class="fa-solid fa-eye"></i>
                                    </button>
                                    <!-- Cambiar estado -->
                                    <form action="${pageContext.request.contextPath}/admin/pedidos"
                                          method="post" class="flex items-center gap-1">
                                        <input type="hidden" name="action" value="cambiarEstado">
                                        <input type="hidden" name="id" value="${p.id}">
                                        <select name="estado"
                                                class="border rounded px-2 py-1 text-xs focus:outline-none focus:ring-1 focus:ring-red-400">
                                            <option value="Pendiente"     ${p.estado == 'Pendiente'     ? 'selected' : ''}>Pendiente</option>
                                            <option value="En cocina"     ${p.estado == 'En cocina'     ? 'selected' : ''}>En cocina</option>
                                            <option value="Por despachar" ${p.estado == 'Por despachar' ? 'selected' : ''}>Por despachar</option>
                                            <option value="Entregado"     ${p.estado == 'Entregado'     ? 'selected' : ''}>Entregado</option>
                                            <option value="Cancelado"     ${p.estado == 'Cancelado'     ? 'selected' : ''}>Cancelado</option>
                                        </select>
                                        <button type="submit"
                                                class="bg-gray-700 hover:bg-gray-800 text-white px-2 py-1 rounded text-xs transition">
                                            <i class="fa-solid fa-check"></i>
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>

                        <!-- MODAL DETALLE -->
                        <div id="modal-${p.id}"
                             class="fixed inset-0 bg-black/50 z-50 hidden flex items-center justify-center p-4">
                            <div class="bg-white rounded-2xl shadow-xl w-full max-w-lg max-h-[85vh] overflow-y-auto">
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
                                    <button onclick="cerrarModal('modal-${p.id}')"
                                            class="text-gray-400 hover:text-gray-600 text-xl">
                                        <i class="fa-solid fa-xmark"></i>
                                    </button>
                                </div>

                                <!-- Info -->
                                <div class="px-6 py-4 border-b border-gray-100 grid grid-cols-2 gap-3 text-sm">
                                    <div>
                                        <p class="text-xs text-gray-400 font-semibold uppercase mb-1">Cliente ID</p>
                                        <p class="text-gray-700">${p.usuarioId}</p>
                                    </div>
                                    <div>
                                        <p class="text-xs text-gray-400 font-semibold uppercase mb-1">Total</p>
                                        <p class="font-bold text-red-600">S/<fmt:formatNumber value="${p.total}" pattern="#,##0.00"/></p>
                                    </div>
                                    <div>
                                        <p class="text-xs text-gray-400 font-semibold uppercase mb-1">Fecha</p>
                                        <p class="text-gray-700">${p.fecha}</p>
                                    </div>
                                    <div>
                                        <p class="text-xs text-gray-400 font-semibold uppercase mb-1">Dirección</p>
                                        <p class="text-gray-700">${p.direccion}</p>
                                    </div>
                                </div>

                                <!-- Cambiar estado desde modal -->
                                <div class="px-6 py-4 border-b border-gray-100">
                                    <p class="text-xs text-gray-400 font-semibold uppercase mb-2">Cambiar estado</p>
                                    <form action="${pageContext.request.contextPath}/admin/pedidos"
                                          method="post" class="flex items-center gap-2">
                                        <input type="hidden" name="action" value="cambiarEstado">
                                        <input type="hidden" name="id" value="${p.id}">
                                        <select name="estado"
                                                class="flex-1 border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-400">
                                            <option value="Pendiente"     ${p.estado == 'Pendiente'     ? 'selected' : ''}>Pendiente</option>
                                            <option value="En cocina"     ${p.estado == 'En cocina'     ? 'selected' : ''}>En cocina</option>
                                            <option value="Por despachar" ${p.estado == 'Por despachar' ? 'selected' : ''}>Por despachar</option>
                                            <option value="Entregado"     ${p.estado == 'Entregado'     ? 'selected' : ''}>Entregado</option>
                                            <option value="Cancelado"     ${p.estado == 'Cancelado'     ? 'selected' : ''}>Cancelado</option>
                                        </select>
                                        <button type="submit"
                                                class="bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-lg text-sm font-semibold transition">
                                            <i class="fa-solid fa-check mr-1"></i> Actualizar
                                        </button>
                                    </form>
                                </div>

                                <!-- Productos -->
                                <div class="px-6 py-4">
                                    <p class="text-sm font-semibold text-gray-700 mb-3">Productos:</p>
                                    <div class="flex flex-col gap-2">
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
                                        <c:if test="${empty p.detalles}">
                                            <p class="text-sm text-gray-400 text-center py-2">Sin detalles cargados</p>
                                        </c:if>
                                    </div>
                                </div>

                                <div class="px-6 py-4 border-t border-gray-100 flex justify-end">
                                    <button onclick="cerrarModal('modal-${p.id}')"
                                            class="bg-gray-200 hover:bg-gray-300 text-gray-700 px-4 py-2 rounded-lg text-sm font-semibold transition">
                                        Cerrar
                                    </button>
                                </div>
                            </div>
                        </div>

                    </c:forEach>

                    <c:if test="${empty pedidos}">
                        <tr>
                            <td colspan="6" class="px-4 py-8 text-center text-gray-400">
                                <i class="fa-solid fa-inbox text-3xl mb-2"></i>
                                <p>No hay pedidos</p>
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>

        <!-- Mensaje vacío por tab -->
        <div id="msgVacio" class="hidden bg-white rounded-2xl shadow p-10 text-center text-gray-400 mt-4">
            <i class="fa-solid fa-inbox text-4xl mb-3 text-gray-300"></i>
            <p class="font-medium">No hay pedidos en esta sección</p>
        </div>
    </main>
</div>

<script>
    // Tab principal
    function cambiarTab(grupo, btn) {
        document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('activo'));
        btn.classList.add('activo');

        // Mostrar/ocultar subtabs
        document.getElementById('subtabs').style.display = grupo === 'proceso' ? 'flex' : 'none';

        // Filtrar filas
        let visible = 0;
        document.querySelectorAll('.pedido-row').forEach(row => {
            if (row.dataset.grupo === grupo) {
                row.style.display = '';
                visible++;
            } else {
                row.style.display = 'none';
            }
        });

        document.getElementById('msgVacio').classList.toggle('hidden', visible > 0);

        // Resetear subtabs
        if (grupo === 'proceso') {
            document.querySelectorAll('.subtab-btn').forEach(b => b.classList.remove('activo'));
            document.querySelector('.subtab-btn').classList.add('activo');
        }
    }

    // Subtab de estados dentro de "proceso"
    function filtrarEstado(estado, btn) {
        document.querySelectorAll('.subtab-btn').forEach(b => b.classList.remove('activo'));
        btn.classList.add('activo');

        let visible = 0;
        document.querySelectorAll('.pedido-row').forEach(row => {
            if (row.dataset.grupo !== 'proceso') return;
            if (estado === 'todos' || row.dataset.estado === estado) {
                row.style.display = '';
                visible++;
            } else {
                row.style.display = 'none';
            }
        });

        document.getElementById('msgVacio').classList.toggle('hidden', visible > 0);
    }

    // Modal
    function abrirModal(id) {
        document.getElementById(id).classList.remove('hidden');
        document.body.style.overflow = 'hidden';
    }
    function cerrarModal(id) {
        document.getElementById(id).classList.add('hidden');
        document.body.style.overflow = '';
    }
    document.querySelectorAll('[id^="modal-"]').forEach(modal => {
        modal.addEventListener('click', function(e) {
            if (e.target === this) cerrarModal(this.id);
        });
    });

    // Inicializar: mostrar mensaje vacío si no hay pedidos en proceso
    window.addEventListener('load', () => {
        const filasProceso = document.querySelectorAll('.pedido-row[data-grupo="proceso"]');
        document.getElementById('msgVacio').classList.toggle('hidden', filasProceso.length > 0);
    });
</script>
</body>
</html>