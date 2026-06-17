<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <script src="https://cdn.tailwindcss.com"></script>
    <title>${categoria.nombre} - Pollería</title>
</head>
<body>

    <jsp:include page="/components/header.jsp"/>

    <%-- BANNER CATEGORÍA --%>
    <div class="relative w-full h-[200px] overflow-hidden">
        <img src="${pageContext.request.contextPath}/img/${categoria.imagen}"
             class="w-full h-full object-cover">
        <div class="absolute inset-0 bg-black/50 flex items-center justify-center">
            <h1 class="text-white text-4xl font-bold">${categoria.nombre}</h1>
        </div>
    </div>

    <%-- BREADCRUMB --%>
    <div class="max-w-7xl mx-auto px-6 py-4 text-sm text-gray-500">
        <a href="${pageContext.request.contextPath}/home" class="hover:text-red-500">Inicio</a>
        <span class="mx-2">/</span>
        <span class="text-gray-800 font-medium">${categoria.nombre}</span>
    </div>

    <%-- GRID PRODUCTOS --%>
    <section class="max-w-7xl mx-auto px-6 pb-16">
        <h2 class="text-2xl font-bold mb-8">${categoria.nombre}</h2>


        <c:choose>
            <c:when test="${empty productos}">
                <div class="text-center py-20 text-gray-400">
                    <i class="fa-solid fa-bowl-food text-6xl mb-4"></i>
                    <p class="text-xl">No hay productos disponibles en esta categoría.</p>
                    <p class="text-sm mt-2">Es posible que el stock del día se haya agotado.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-6" id="grid-productos">
                    <c:forEach items="${productos}" var="prod">
                        <a href="${pageContext.request.contextPath}/producto?id=${prod.id}"
                           class="bg-white rounded-2xl shadow-md overflow-hidden border border-gray-100 flex flex-col group hover:shadow-xl transition">
                            <div class="overflow-hidden">
                                <img src="${prod.imagen}"
                                     class="w-full h-[160px] object-cover group-hover:scale-105 transition duration-400"
                                     onerror="this.src='${pageContext.request.contextPath}/img/pollobrasa.webp'">
                            </div>
                            <div class="p-4 flex flex-col flex-1">
                                <h3 class="font-semibold text-sm mb-1">${prod.nombre}</h3>
                                <p class="text-xs text-gray-500 leading-tight flex-1 line-clamp-2">${prod.descripcion}</p>
                                <div class="mt-3 flex items-center justify-between">
                                    <span class="text-base font-bold text-gray-800">
                                        S/<fmt:formatNumber value="${prod.precio}" pattern="#,##0.00"/>
                                    </span>
                                    <span class="bg-orange-600 text-white text-xs font-semibold px-3 py-1.5 rounded-lg">
                                        Ver detalle
                                    </span>
                                </div>
                                <p class="text-xs text-green-600 mt-2 font-medium">${prod.stock} disponible(s)</p>
                            </div>
                        </a>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </section>

    <jsp:include page="/components/footer.jsp"/>

    <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
    <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>



</body>
</html>
