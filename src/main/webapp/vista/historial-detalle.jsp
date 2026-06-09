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
    <title>Detalle Pedido #${pedido.id} - El Dorado</title>
</head>
<body class="bg-gray-50 min-h-screen">

    <jsp:include page="/components/header.jsp"/>

    <div class="max-w-4xl mx-auto px-4 py-8">
        <div class="mb-6">
            <a href="${pageContext.request.contextPath}/historial"
               class="inline-flex items-center gap-2 text-sm text-gray-500 hover:text-red-600 transition font-medium">
                <i class="fa-solid fa-arrow-left text-xs"></i> Volver a mis pedidos
            </a>
        </div>

        <h2 class="text-2xl font-bold text-gray-800 mb-6">Pedido #${pedido.id}</h2>

        <!-- INFO -->
        <div class="bg-white rounded-2xl shadow p-6 mb-6 grid grid-cols-2 md:grid-cols-3 gap-4">
            <div>
                <p class="text-xs text-gray-400 uppercase font-semibold mb-1">Estado</p>
                <span class="px-3 py-1 rounded-full text-sm font-semibold bg-green-100 text-green-600">
                    ${pedido.estado}
                </span>
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

        <!-- DETALLES -->
        <div class="bg-white rounded-2xl shadow overflow-hidden">
            <div class="px-6 py-4 border-b border-gray-100">
                <h3 class="text-lg font-semibold">Productos</h3>
            </div>
            <table class="w-full text-sm">
                <thead class="bg-gray-50 text-gray-600 uppercase text-xs">
                    <tr>
                        <th class="px-4 py-3 text-left">Producto</th>
                        <th class="px-4 py-3 text-left">Opciones</th>
                        <th class="px-4 py-3 text-center">Cantidad</th>
                        <th class="px-4 py-3 text-right">Subtotal</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-100">
                    <c:forEach items="${detalles}" var="d">
                        <tr>
                            <td class="px-4 py-3 font-medium">${d.productoNombre}</td>
                            <td class="px-4 py-3 text-gray-500 text-xs">${d.opciones}</td>
                            <td class="px-4 py-3 text-center">${d.cantidad}</td>
                            <td class="px-4 py-3 text-right font-bold text-red-600">
                                S/<fmt:formatNumber value="${d.subtotal}" pattern="#,##0.00"/>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
                <tfoot class="bg-gray-50">
                    <tr>
                        <td colspan="3" class="px-4 py-3 text-right font-bold text-gray-700">Total:</td>
                        <td class="px-4 py-3 text-right font-bold text-red-600 text-lg">
                            S/<fmt:formatNumber value="${pedido.total}" pattern="#,##0.00"/>
                        </td>
                    </tr>
                </tfoot>
            </table>
        </div>
    </div>

    <jsp:include page="/components/footer.jsp"/>
</body>
</html>