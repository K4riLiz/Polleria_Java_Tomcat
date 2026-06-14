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
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.js"></script>
    <title>Admin - Dashboard</title>
    <style>
        body { background: #f8fafc; }
    </style>
</head>
<body class="min-h-screen">
<div class="flex min-h-screen">

    <!-- SIDEBAR -->
    <aside class="w-64 bg-gray-900 text-white flex flex-col">
        <div class="p-6 border-b border-gray-700">
            <h1 class="text-xl font-bold text-red-400">El Dorado</h1>
            <p class="text-xs text-gray-400 mt-1">${sessionScope.usuario.nombre}</p>
        </div>
        <nav class="flex flex-col p-4 gap-2 flex-1">
            <a href="${pageContext.request.contextPath}/admin/dashboard"
                   class="flex items-center gap-3 px-4 py-2 rounded-lg bg-red-600 text-white font-medium">
                    <i class="fa-solid fa-chart-line"></i> Dashboard
                </a>
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
                   class="flex items-center gap-3 px-4 py-2 rounded-lg hover:bg-gray-700 transition">
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

        <!-- TOPBAR -->
        <div class="flex items-center justify-between mb-6">
            <h2 class="text-2xl font-bold text-gray-800">Dashboard</h2>
            <button onclick="exportarPDF()"
                    class="flex items-center gap-2 bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-xl text-sm font-semibold transition">
                <i class="fa-solid fa-file-pdf"></i> Exportar PDF
            </button>
        </div>

        <!-- ALERTA -->
        <c:if test="${pedidosViejos > 0}">
            <div class="bg-amber-50 border border-amber-300 rounded-xl px-4 py-3 mb-6 flex items-start gap-3">
                <i class="fa-solid fa-triangle-exclamation text-amber-500 mt-0.5"></i>
                <div>
                    <p class="text-sm font-semibold text-amber-800">
                        ${pedidosViejos} pedido(s) sin atender hace más de 25 minutos
                    </p>
                    <p class="text-xs text-amber-600 mt-0.5">${idsViejos} — Revisa la cola de cocina</p>
                </div>
                <a href="${pageContext.request.contextPath}/admin/pedidos"
                   class="ml-auto text-xs bg-amber-500 hover:bg-amber-600 text-white px-3 py-1.5 rounded-lg font-semibold transition">
                    Ver pedidos
                </a>
            </div>
        </c:if>

        <!-- CARDS -->
        <div class="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
                <div class="flex items-center justify-between mb-3">
                    <span class="text-xs text-gray-400 uppercase tracking-wide font-medium">Pedidos hoy</span>
                    <div class="w-9 h-9 bg-red-50 rounded-xl flex items-center justify-center">
                        <i class="fa-solid fa-receipt text-red-500"></i>
                    </div>
                </div>
                <p class="text-3xl font-bold text-gray-800">${pedidosHoy}</p>
                <p class="text-xs mt-1 ${varPedidos.startsWith('↑') ? 'text-green-600' : 'text-red-500'}">${varPedidos}</p>
            </div>
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
                <div class="flex items-center justify-between mb-3">
                    <span class="text-xs text-gray-400 uppercase tracking-wide font-medium">Ingresos hoy</span>
                    <div class="w-9 h-9 bg-green-50 rounded-xl flex items-center justify-center">
                        <i class="fa-solid fa-wallet text-green-500"></i>
                    </div>
                </div>
                <p class="text-2xl font-bold text-gray-800">S/<fmt:formatNumber value="${ingresosHoy}" pattern="#,##0.00"/></p>
                <p class="text-xs mt-1 ${varIngresos.startsWith('↑') ? 'text-green-600' : 'text-red-500'}">${varIngresos}</p>
            </div>
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
                <div class="flex items-center justify-between mb-3">
                    <span class="text-xs text-gray-400 uppercase tracking-wide font-medium">En proceso</span>
                    <div class="w-9 h-9 bg-amber-50 rounded-xl flex items-center justify-center">
                        <i class="fa-solid fa-fire text-amber-500"></i>
                    </div>
                </div>
                <p class="text-3xl font-bold text-gray-800">${enProceso}</p>
                <p class="text-xs text-amber-600 mt-1">pedidos activos</p>
            </div>
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
                <div class="flex items-center justify-between mb-3">
                    <span class="text-xs text-gray-400 uppercase tracking-wide font-medium">Reclamaciones</span>
                    <div class="w-9 h-9 bg-purple-50 rounded-xl flex items-center justify-center">
                        <i class="fa-solid fa-book-open text-purple-500"></i>
                    </div>
                </div>
                <p class="text-3xl font-bold text-gray-800">${reclamaciones}</p>
                <p class="text-xs text-purple-600 mt-1">sin resolver</p>
            </div>
        </div>

        <!-- GRÁFICOS BARRAS -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-4 mb-6">

            <!-- Productos más vendidos -->
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
                <h3 class="text-sm font-semibold text-gray-700 mb-4">Productos más vendidos</h3>
                <c:set var="maxProd" value="1"/>
                <c:forEach var="e" items="${productosMasVendidos}">
                    <c:if test="${e.value > maxProd}"><c:set var="maxProd" value="${e.value}"/></c:if>
                </c:forEach>
                <c:forEach var="e" items="${productosMasVendidos}">
                    <div class="flex items-center gap-3 mb-3">
                        <span class="text-xs text-gray-500 w-32 truncate">${e.key}</span>
                        <div class="flex-1 bg-gray-100 rounded-full h-2">
                            <div class="bg-red-500 h-2 rounded-full"
                                 style="width: ${(e.value * 100) / maxProd}%"></div>
                        </div>
                        <span class="text-xs font-semibold text-gray-700 w-6 text-right">${e.value}</span>
                    </div>
                </c:forEach>
                <c:if test="${empty productosMasVendidos}">
                    <p class="text-sm text-gray-400 text-center py-4">Sin datos aún</p>
                </c:if>
            </div>

            <!-- Promociones más vendidas -->
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
                <h3 class="text-sm font-semibold text-gray-700 mb-4">Promociones más vendidas</h3>
                <c:set var="maxProm" value="1"/>
                <c:forEach var="e" items="${promocionesMasVendidas}">
                    <c:if test="${e.value > maxProm}"><c:set var="maxProm" value="${e.value}"/></c:if>
                </c:forEach>
                <c:forEach var="e" items="${promocionesMasVendidas}">
                    <div class="flex items-center gap-3 mb-3">
                        <span class="text-xs text-gray-500 w-32 truncate">${e.key}</span>
                        <div class="flex-1 bg-gray-100 rounded-full h-2">
                            <div class="bg-purple-500 h-2 rounded-full"
                                 style="width: ${(e.value * 100) / maxProm}%"></div>
                        </div>
                        <span class="text-xs font-semibold text-gray-700 w-6 text-right">${e.value}</span>
                    </div>
                </c:forEach>
                <c:if test="${empty promocionesMasVendidas}">
                    <p class="text-sm text-gray-400 text-center py-4">Sin datos aún</p>
                </c:if>
            </div>
        </div>

        <!-- VENTAS + ESTADOS -->
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-4 mb-6">

            <!-- Ventas 7 días -->
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5 lg:col-span-2">
                <h3 class="text-sm font-semibold text-gray-700 mb-4">Ventas últimos 7 días (S/)</h3>
                <div style="position:relative;height:200px;">
                    <canvas id="lineChart" role="img" aria-label="Ventas de los últimos 7 días"></canvas>
                </div>
            </div>

            <!-- Pedidos por estado -->
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5">
                <h3 class="text-sm font-semibold text-gray-700 mb-4">Pedidos por estado</h3>
                <div style="position:relative;height:160px;">
                    <canvas id="pieChart" role="img" aria-label="Pedidos por estado"></canvas>
                </div>
                <div class="flex flex-col gap-1 mt-3">
                    <div class="flex items-center gap-2 text-xs text-gray-500">
                        <span class="w-3 h-3 rounded-sm bg-yellow-400"></span> Pendiente: ${pedidosPorEstado['Pendiente']}
                    </div>
                    <div class="flex items-center gap-2 text-xs text-gray-500">
                        <span class="w-3 h-3 rounded-sm bg-orange-400"></span> En cocina: ${pedidosPorEstado['En cocina']}
                    </div>
                    <div class="flex items-center gap-2 text-xs text-gray-500">
                        <span class="w-3 h-3 rounded-sm bg-blue-400"></span> Por despachar: ${pedidosPorEstado['Por despachar']}
                    </div>
                    <div class="flex items-center gap-2 text-xs text-gray-500">
                        <span class="w-3 h-3 rounded-sm bg-green-500"></span> Entregado: ${pedidosPorEstado['Entregado']}
                    </div>
                    <div class="flex items-center gap-2 text-xs text-gray-500">
                        <span class="w-3 h-3 rounded-sm bg-red-400"></span> Cancelado: ${pedidosPorEstado['Cancelado']}
                    </div>
                </div>
            </div>
        </div>

        <!-- TABLA ÚLTIMOS PEDIDOS -->
        <div class="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
            <div class="flex items-center justify-between px-6 py-4 border-b border-gray-100">
                <h3 class="text-sm font-semibold text-gray-700">Últimos pedidos</h3>
                <a href="${pageContext.request.contextPath}/admin/pedidos"
                   class="text-xs text-red-600 hover:underline">Ver todos →</a>
            </div>
            <table class="w-full text-sm">
                <thead class="bg-gray-50 text-gray-500 uppercase text-xs">
                    <tr>
                        <th class="px-6 py-3 text-left">#</th>
                        <th class="px-6 py-3 text-left">Cliente</th>
                        <th class="px-6 py-3 text-left">Total</th>
                        <th class="px-6 py-3 text-left">Estado</th>
                        <th class="px-6 py-3 text-center">Acción rápida</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-50">
                    <c:forEach items="${ultimosPedidos}" var="p">
                        <tr class="hover:bg-gray-50">
                            <td class="px-6 py-3 text-gray-400">#${p['id']}</td>
                            <td class="px-6 py-3 font-medium text-gray-800">${p['cliente']}</td>
                            <td class="px-6 py-3 font-semibold text-red-600">S/${p['total']}</td>
                            <td class="px-6 py-3">
                                <span class="px-2 py-1 rounded-full text-xs font-semibold
                                    ${p['estado'] == 'Pendiente'     ? 'bg-yellow-100 text-yellow-700' :
                                      p['estado'] == 'En cocina'     ? 'bg-orange-100 text-orange-700' :
                                      p['estado'] == 'Por despachar' ? 'bg-blue-100 text-blue-700' :
                                      p['estado'] == 'Entregado'     ? 'bg-green-100 text-green-700' :
                                                                        'bg-red-100 text-red-700'}">
                                    ${p['estado']}
                                </span>
                            </td>
                            <td class="px-6 py-3 text-center">
                                <c:if test="${p['estado'] == 'Pendiente'}">
                                    <form action="${pageContext.request.contextPath}/admin/pedidos" method="post" class="inline">
                                        <input type="hidden" name="action" value="cambiarEstado">
                                        <input type="hidden" name="id" value="${p['id']}">
                                        <input type="hidden" name="estado" value="En cocina">
                                        <button type="submit" class="text-xs bg-gray-100 hover:bg-gray-200 text-gray-600 px-3 py-1.5 rounded-lg transition">
                                            → En cocina
                                        </button>
                                    </form>
                                </c:if>
                                <c:if test="${p['estado'] == 'En cocina'}">
                                    <form action="${pageContext.request.contextPath}/admin/pedidos" method="post" class="inline">
                                        <input type="hidden" name="action" value="cambiarEstado">
                                        <input type="hidden" name="id" value="${p['id']}">
                                        <input type="hidden" name="estado" value="Por despachar">
                                        <button type="submit" class="text-xs bg-gray-100 hover:bg-gray-200 text-gray-600 px-3 py-1.5 rounded-lg transition">
                                            → Despachar
                                        </button>
                                    </form>
                                </c:if>
                                <c:if test="${p['estado'] == 'Por despachar'}">
                                    <form action="${pageContext.request.contextPath}/admin/pedidos" method="post" class="inline">
                                        <input type="hidden" name="action" value="cambiarEstado">
                                        <input type="hidden" name="id" value="${p['id']}">
                                        <input type="hidden" name="estado" value="Entregado">
                                        <button type="submit" class="text-xs bg-gray-100 hover:bg-gray-200 text-gray-600 px-3 py-1.5 rounded-lg transition">
                                            → Entregado
                                        </button>
                                    </form>
                                </c:if>
                                <c:if test="${p['estado'] == 'Entregado' || p['estado'] == 'Cancelado'}">
                                    <span class="text-xs text-gray-300">—</span>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty ultimosPedidos}">
                        <tr>
                            <td colspan="5" class="px-6 py-8 text-center text-gray-400 text-sm">
                                No hay pedidos aún
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>

    </main>
</div>

<!-- DATOS PARA CHARTS inyectados desde servidor -->
<script>
    var ventasLabels = [<c:forEach var="e" items="${ventasSemana}" varStatus="vs">'${e.key}'<c:if test="${!vs.last}">,</c:if></c:forEach>];
    var ventasData   = [<c:forEach var="e" items="${ventasSemana}" varStatus="vs">${e.value}<c:if test="${!vs.last}">,</c:if></c:forEach>];

    var estadoLabels = ['Pendiente','En cocina','Por despachar','Entregado','Cancelado'];
    var estadoData   = [
        ${pedidosPorEstado['Pendiente']},
        ${pedidosPorEstado['En cocina']},
        ${pedidosPorEstado['Por despachar']},
        ${pedidosPorEstado['Entregado']},
        ${pedidosPorEstado['Cancelado']}
    ];
</script>

<script>
    // Gráfico línea — ventas 7 días
    new Chart(document.getElementById('lineChart'), {
        type: 'line',
        data: {
            labels: ventasLabels,
            datasets: [{
                label: 'Ventas S/',
                data: ventasData,
                borderColor: '#dc2626',
                backgroundColor: 'rgba(220,38,38,0.08)',
                borderWidth: 2,
                pointRadius: 4,
                pointBackgroundColor: '#dc2626',
                fill: true,
                tension: 0.4
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: {
                x: { ticks: { font: { size: 10 }, color: '#9ca3af' }, grid: { display: false } },
                y: { ticks: { font: { size: 10 }, color: '#9ca3af', callback: function(v) { return 'S/' + v; } }, grid: { color: 'rgba(0,0,0,0.04)' } }
            }
        }
    });

    // Gráfico pastel — pedidos por estado
    new Chart(document.getElementById('pieChart'), {
        type: 'doughnut',
        data: {
            labels: estadoLabels,
            datasets: [{
                data: estadoData,
                backgroundColor: ['#facc15','#f97316','#60a5fa','#4ade80','#f87171'],
                borderWidth: 2,
                borderColor: '#ffffff'
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            cutout: '60%'
        }
    });

    // Exportar PDF
    function exportarPDF() {
        window.print();
    }
</script>
</body>
</html>