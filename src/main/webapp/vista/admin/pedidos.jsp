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
</head>
<body class="bg-gray-100 min-h-screen">
<div class="flex min-h-screen">

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
            <a href="${pageContext.request.contextPath}/admin/roles"
               class="flex items-center gap-3 px-4 py-2 rounded-lg hover:bg-gray-700 transition">
                <i class="fa-solid fa-shield-halved"></i> Roles
            </a>
            <a href="${pageContext.request.contextPath}/admin/productos"
               class="flex items-center gap-3 px-4 py-2 rounded-lg hover:bg-gray-700 transition">
                <i class="fa-solid fa-bowl-food"></i> Productos
            </a>
            <a href="${pageContext.request.contextPath}/admin/pedidos"
               class="flex items-center gap-3 px-4 py-2 rounded-lg bg-red-600 text-white font-medium">
                <i class="fa-solid fa-receipt"></i> Pedidos
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

        <!-- FILTROS -->
        <div class="bg-white rounded-2xl shadow p-4 mb-6 flex flex-wrap gap-2">
            <a href="${pageContext.request.contextPath}/admin/pedidos"
               class="px-4 py-2 rounded-lg text-sm font-medium transition
                      ${empty filtro ? 'bg-red-600 text-white' : 'bg-gray-100 hover:bg-gray-200 text-gray-700'}">
                Todos
            </a>
            <c:forEach items="${['Pendiente','En cocina','Por despachar','Entregado','Cancelado']}" var="est">
                <a href="${pageContext.request.contextPath}/admin/pedidos?estado=${est}"
                   class="px-4 py-2 rounded-lg text-sm font-medium transition
                          ${filtro == est ? 'bg-red-600 text-white' : 'bg-gray-100 hover:bg-gray-200 text-gray-700'}">
                    ${est}
                </a>
            </c:forEach>
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
                <tbody class="divide-y divide-gray-100">
                    <c:forEach items="${pedidos}" var="p">
                        <tr class="hover:bg-gray-50">
                            <td class="px-4 py-3 text-gray-400">#${p.id}</td>
                            <td class="px-4 py-3 font-medium">${p.usuarioId}</td>
                            <td class="px-4 py-3 font-bold text-red-600">
                                S/<fmt:formatNumber value="${p.total}" pattern="#,##0.00"/>
                            </td>
                            <td class="px-4 py-3">
                                <span class="px-2 py-1 rounded-full text-xs font-semibold
                                    ${p.estado == 'Pendiente' ? 'bg-yellow-100 text-yellow-600' :
                                      p.estado == 'En cocina' ? 'bg-orange-100 text-orange-600' :
                                      p.estado == 'Por despachar' ? 'bg-blue-100 text-blue-600' :
                                      p.estado == 'Entregado' ? 'bg-green-100 text-green-600' :
                                      'bg-red-100 text-red-600'}">
                                    ${p.estado}
                                </span>
                            </td>
                            <td class="px-4 py-3 text-gray-500">${p.fecha}</td>
                            <td class="px-4 py-3 text-center flex items-center justify-center gap-2">
                                <a href="${pageContext.request.contextPath}/admin/pedidos?action=detalle&id=${p.id}"
                                   class="text-blue-500 hover:text-blue-700" title="Ver detalle">
                                    <i class="fa-solid fa-eye"></i>
                                </a>
                                <!-- Cambiar estado -->
                                <form action="${pageContext.request.contextPath}/admin/pedidos" method="post" class="flex items-center gap-1">
                                    <input type="hidden" name="action" value="cambiarEstado">
                                    <input type="hidden" name="id" value="${p.id}">
                                    <select name="estado" class="border rounded px-2 py-1 text-xs focus:outline-none focus:ring-1 focus:ring-red-400">
                                        <option value="Pendiente"      ${p.estado == 'Pendiente'      ? 'selected' : ''}>Pendiente</option>
                                        <option value="En cocina"      ${p.estado == 'En cocina'      ? 'selected' : ''}>En cocina</option>
                                        <option value="Por despachar"  ${p.estado == 'Por despachar'  ? 'selected' : ''}>Por despachar</option>
                                        <option value="Entregado"      ${p.estado == 'Entregado'      ? 'selected' : ''}>Entregado</option>
                                        <option value="Cancelado"      ${p.estado == 'Cancelado'      ? 'selected' : ''}>Cancelado</option>
                                    </select>
                                    <button type="submit" class="bg-red-600 hover:bg-red-700 text-white px-2 py-1 rounded text-xs">
                                        <i class="fa-solid fa-check"></i>
                                    </button>
                                </form>
                            </td>
                        </tr>
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
    </main>
</div>
</body>
</html>