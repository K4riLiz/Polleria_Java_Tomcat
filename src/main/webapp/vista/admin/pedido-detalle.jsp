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
    <title>Detalle Pedido #${pedido.id}</title>
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

    <main class="flex-1 p-8 overflow-auto">
        <div class="mb-6">
            <a href="${pageContext.request.contextPath}/admin/pedidos"
               class="inline-flex items-center gap-2 text-sm text-gray-500 hover:text-red-600 transition font-medium">
                <i class="fa-solid fa-arrow-left text-xs"></i> Volver a Pedidos
            </a>
        </div>

        <h2 class="text-2xl font-bold text-gray-800 mb-6">Detalle Pedido #${pedido.id}</h2>

        <!-- INFO PEDIDO -->
        <div class="bg-white rounded-2xl shadow p-6 mb-6 grid grid-cols-2 md:grid-cols-4 gap-4">
            <div>
                <p class="text-xs text-gray-400 uppercase font-semibold mb-1">Estado</p>
                <span class="px-3 py-1 rounded-full text-sm font-semibold
                    ${pedido.estado == 'Pendiente' ? 'bg-yellow-100 text-yellow-600' :
                      pedido.estado == 'En cocina' ? 'bg-orange-100 text-orange-600' :
                      pedido.estado == 'Por despachar' ? 'bg-blue-100 text-blue-600' :
                      pedido.estado == 'Entregado' ? 'bg-green-100 text-green-600' :
                      'bg-red-100 text-red-600'}">
                    ${pedido.estado}
                </span>
            </div>
            <div>
                <p class="text-xs text-gray-400 uppercase font-semibold mb-1">Total</p>
                <p class="text-xl font-bold text-red-600">S/<fmt:formatNumber value="${pedido.total}" pattern="#,##0.00"/></p>
            </div>
            <div>
                <p class="text-xs text-gray-400 uppercase font-semibold mb-1">Fecha</p>
                <p class="text-sm text-gray-700">${pedido.fecha}</p>
            </div>
            <div>
                <p class="text-xs text-gray-400 uppercase font-semibold mb-1">Dirección</p>
                <p class="text-sm text-gray-700">${pedido.direccion}</p>
            </div>
        </div>

        <!-- CAMBIAR ESTADO -->
        <div class="bg-white rounded-2xl shadow p-6 mb-6">
            <h3 class="text-lg font-semibold mb-4">Cambiar Estado</h3>
            <form action="${pageContext.request.contextPath}/admin/pedidos" method="post" class="flex items-center gap-3">
                <input type="hidden" name="action" value="cambiarEstado">
                <input type="hidden" name="id" value="${pedido.id}">
                <select name="estado" class="border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-400">
                    <option value="Pendiente"     ${pedido.estado == 'Pendiente'     ? 'selected' : ''}>Pendiente</option>
                    <option value="En cocina"     ${pedido.estado == 'En cocina'     ? 'selected' : ''}>En cocina</option>
                    <option value="Por despachar" ${pedido.estado == 'Por despachar' ? 'selected' : ''}>Por despachar</option>
                    <option value="Entregado"     ${pedido.estado == 'Entregado'     ? 'selected' : ''}>Entregado</option>
                    <option value="Cancelado"     ${pedido.estado == 'Cancelado'     ? 'selected' : ''}>Cancelado</option>
                </select>
                <button type="submit" class="bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-lg text-sm font-semibold transition">
                    <i class="fa-solid fa-check mr-1"></i> Actualizar
                </button>
            </form>
        </div>

        <!-- DETALLES -->
        <div class="bg-white rounded-2xl shadow overflow-hidden">
            <div class="px-6 py-4 border-b border-gray-100">
                <h3 class="text-lg font-semibold">Productos del pedido</h3>
            </div>
            <table class="w-full text-sm">
                <thead class="bg-gray-50 text-gray-600 uppercase text-xs">
                    <tr>
                        <th class="px-4 py-3 text-left">Producto</th>
                        <th class="px-4 py-3 text-left">Tipo</th>
                        <th class="px-4 py-3 text-left">Opciones</th>
                        <th class="px-4 py-3 text-center">Cantidad</th>
                        <th class="px-4 py-3 text-right">Precio</th>
                        <th class="px-4 py-3 text-right">Subtotal</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-100">
                    <c:forEach items="${detalles}" var="d">
                        <tr class="hover:bg-gray-50">
                            <td class="px-4 py-3 font-medium">${d.productoNombre}</td>
                            <td class="px-4 py-3">
                                <span class="px-2 py-1 rounded-full text-xs font-semibold
                                    ${d.tipo == 'promocion' ? 'bg-purple-100 text-purple-600' : 'bg-orange-100 text-orange-600'}">
                                    ${d.tipo}
                                </span>
                            </td>
                            <td class="px-4 py-3 text-gray-500 text-xs">${d.opciones}</td>
                            <td class="px-4 py-3 text-center">${d.cantidad}</td>
                            <td class="px-4 py-3 text-right">S/<fmt:formatNumber value="${d.precio}" pattern="#,##0.00"/></td>
                            <td class="px-4 py-3 text-right font-bold text-red-600">S/<fmt:formatNumber value="${d.subtotal}" pattern="#,##0.00"/></td>
                        </tr>
                    </c:forEach>
                </tbody>
                <tfoot class="bg-gray-50">
                    <tr>
                        <td colspan="5" class="px-4 py-3 text-right font-bold text-gray-700">Total:</td>
                        <td class="px-4 py-3 text-right font-bold text-red-600 text-lg">
                            S/<fmt:formatNumber value="${pedido.total}" pattern="#,##0.00"/>
                        </td>
                    </tr>
                </tfoot>
            </table>
        </div>
    </main>
</div>
</body>
</html>