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
    <title>Buscar: ${query} - El Dorado</title>
</head>
<body class="bg-gray-50 min-h-screen">

    <jsp:include page="/components/header.jsp"/>

    <div class="max-w-7xl mx-auto px-4 py-10">

        <!-- TÍTULO -->
        <div class="mb-8">
            <h1 class="text-2xl font-bold text-gray-800">
                Resultados para: <span class="text-red-600">"${query}"</span>
            </h1>
            <p class="text-sm text-gray-400 mt-1">
                ${productos.size() + promociones.size()} resultado(s) encontrado(s)
            </p>
        </div>

        <c:if test="${not empty error}">
            <div class="bg-red-100 text-red-700 px-4 py-3 rounded-xl mb-6">${error}</div>
        </c:if>

        <!-- SIN RESULTADOS -->
        <c:if test="${empty productos and empty promociones}">
            <div class="bg-white rounded-2xl shadow-sm p-16 text-center">
                <i class="fa-solid fa-magnifying-glass text-6xl text-gray-200 mb-4"></i>
                <h2 class="text-xl font-semibold text-gray-400 mb-2">No encontramos resultados</h2>
                <p class="text-gray-400 text-sm mb-6">Intenta con otro término de búsqueda</p>
                <a href="${pageContext.request.contextPath}/home"
                   class="bg-red-600 hover:bg-red-700 text-white font-semibold px-6 py-2 rounded-xl transition">
                    Ver todo el menú
                </a>
            </div>
        </c:if>

        <!-- PRODUCTOS -->
        <c:if test="${not empty productos}">
            <h2 class="text-lg font-bold text-gray-700 mb-4">
                <i class="fa-solid fa-bowl-food text-red-600 mr-2"></i>Productos
            </h2>
            <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4 mb-10">
                <c:forEach items="${productos}" var="prod">
                    <a href="${pageContext.request.contextPath}/producto?id=${prod.id}"
                       class="bg-white rounded-2xl shadow-md overflow-hidden border border-gray-100 flex flex-col group hover:shadow-xl transition">
                        <div class="overflow-hidden">
                            <img src="${pageContext.request.contextPath}/img/${prod.imagen}"
                                 class="w-full h-[160px] object-cover group-hover:scale-105 transition duration-400"
                                 onerror="this.src='${pageContext.request.contextPath}/img/pollobrasa.png'">
                        </div>
                        <div class="p-4 flex flex-col flex-1">
                            <span class="text-xs text-orange-500 font-semibold mb-1">${prod.categoriaNombre}</span>
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
                        </div>
                    </a>
                </c:forEach>
            </div>
        </c:if>

        <!-- PROMOCIONES -->
        <c:if test="${not empty promociones}">
            <h2 class="text-lg font-bold text-gray-700 mb-4">
                <i class="fa-solid fa-tag text-red-600 mr-2"></i>Promociones
            </h2>
            <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4">
                <c:forEach items="${promociones}" var="promo">
                    <a href="${pageContext.request.contextPath}/promocion?id=${promo.id}"
                       class="bg-white rounded-2xl shadow-md overflow-hidden border border-gray-100 flex flex-col group hover:shadow-xl transition">
                        <div class="overflow-hidden relative">
                            <img src="${pageContext.request.contextPath}/img/${promo.imagen}"
                                 class="w-full h-[160px] object-cover group-hover:scale-105 transition duration-400">
                            <div class="absolute top-2 left-2 bg-red-600 text-white text-[10px] font-bold px-2 py-0.5 rounded-full">
                                PROMO
                            </div>
                        </div>
                        <div class="p-4 flex flex-col flex-1">
                            <h3 class="font-semibold text-sm mb-1">${promo.nombre}</h3>
                            <p class="text-xs text-gray-500 leading-tight flex-1 line-clamp-2">${promo.descripcion}</p>
                            <div class="mt-3 flex items-center justify-between">
                                <span class="text-base font-bold text-gray-800">
                                    S/<fmt:formatNumber value="${promo.precio}" pattern="#,##0.00"/>
                                </span>
                                <span class="bg-orange-600 text-white text-xs font-semibold px-3 py-1.5 rounded-lg">
                                    Ver detalle
                                </span>
                            </div>
                        </div>
                    </a>
                </c:forEach>
            </div>
        </c:if>

    </div>

    <jsp:include page="/components/footer.jsp"/>

    <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
    <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
</body>
</html>
