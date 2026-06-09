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
    <title>Delivery - Pedidos</title>
</head>
<body class="bg-gray-100 min-h-screen">
<div class="flex min-h-screen">

    <!-- SIDEBAR -->
    <aside class="w-64 bg-gray-900 text-white flex flex-col">
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

    <main class="flex-1 p-8 overflow-auto">
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
                    <p class="text-sm text-gray-500"><i class="fa-regular fa-clock mr-1"></i>${p.fecha}</p>
                    <p class="text-sm text-gray-500"><i class="fa-solid fa-location-dot mr-1"></i>${p.direccion}</p>
                    <p class="font-bold text-red-600">S/<fmt:formatNumber value="${p.total}" pattern="#,##0.00"/></p>

                    <div class="flex gap-2 mt-auto">
                        <a href="${pageContext.request.contextPath}/delivery/pedidos?action=detalle&id=${p.id}"
                           class="flex-1 text-center bg-gray-100 hover:bg-gray-200 text-gray-700 px-3 py-2 rounded-lg text-xs font-semibold transition">
                            <i class="fa-solid fa-eye mr-1"></i> Ver detalle
                        </a>
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
            </c:forEach>
            <c:if test="${empty pedidos}">
                <div class="col-span-3 bg-white rounded-2xl shadow p-10 text-center text-gray-400">
                    <i class="fa-solid fa-check-circle text-4xl text-green-400 mb-3"></i>
                    <p class="font-medium">No hay pedidos por despachar</p>
                </div>
            </c:if>
        </div>
    </main>
</div>
</body>
</html>