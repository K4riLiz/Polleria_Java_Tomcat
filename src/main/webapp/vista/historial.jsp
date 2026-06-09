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
</head>
<body class="bg-gray-50 min-h-screen">

    <jsp:include page="/components/header.jsp"/>

    <div class="max-w-4xl mx-auto px-4 py-8">
        <h2 class="text-2xl font-bold text-gray-800 mb-6">Mis Pedidos</h2>

        <c:choose>
            <c:when test="${empty pedidos}">
                <div class="bg-white rounded-2xl shadow p-12 text-center text-gray-400">
                    <i class="fa-solid fa-bag-shopping text-5xl mb-4 text-gray-300"></i>
                    <p class="text-lg font-medium mb-2">Aún no tienes pedidos entregados</p>
                    <p class="text-sm mb-6">Cuando tus pedidos sean entregados aparecerán aquí</p>
                    <a href="${pageContext.request.contextPath}/home"
                       class="bg-red-600 hover:bg-red-700 text-white px-6 py-2 rounded-xl text-sm font-semibold transition">
                        Ir al menú
                    </a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="flex flex-col gap-4">
                    <c:forEach items="${pedidos}" var="p">
                        <div class="bg-white rounded-2xl shadow p-5 flex flex-col md:flex-row md:items-center justify-between gap-4">
                            <div class="flex flex-col gap-1">
                                <div class="flex items-center gap-3">
                                    <span class="font-bold text-gray-800 text-lg">#${p.id}</span>
                                    <span class="px-2 py-1 rounded-full text-xs font-semibold bg-green-100 text-green-600">
                                        ${p.estado}
                                    </span>
                                </div>
                                <p class="text-sm text-gray-500"><i class="fa-regular fa-clock mr-1"></i>${p.fecha}</p>
                                <p class="text-sm text-gray-500"><i class="fa-solid fa-location-dot mr-1"></i>${p.direccion}</p>
                            </div>
                            <div class="flex items-center gap-4">
                                <p class="font-bold text-red-600 text-xl">
                                    S/<fmt:formatNumber value="${p.total}" pattern="#,##0.00"/>
                                </p>
                                <a href="${pageContext.request.contextPath}/historial?action=detalle&id=${p.id}"
                                   class="bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-xl text-sm font-semibold transition">
                                    Ver detalle
                                </a>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <jsp:include page="/components/footer.jsp"/>
</body>
</html>