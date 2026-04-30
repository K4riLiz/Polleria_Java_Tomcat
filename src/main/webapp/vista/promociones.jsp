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
    <title>Promociones - El Dorado</title>
    <style>
        .card-promo:hover .card-img { transform: scale(1.05); }
        .card-img { transition: transform 0.4s ease; }
    </style>
</head>
<body class="bg-gray-50">

    <jsp:include page="/components/header.jsp"/>

    <!-- BANNER -->
    <div class="w-full bg-red-600 py-10 text-center text-white">
        <h1 class="text-4xl font-bold mb-2"> Promociones</h1>
        <p class="text-red-100 text-sm">Aprovecha las mejores ofertas en pollería "El Dorado"</p>
    </div>

    <!-- GRID PROMOCIONES -->
    <section class="max-w-7xl mx-auto px-4 py-12">

        <c:if test="${not empty error}">
            <div class="bg-red-100 text-red-700 px-4 py-3 rounded-lg mb-6">${error}</div>
        </c:if>

        <c:choose>
            <c:when test="${empty promociones}">
                <div class="text-center py-20 text-gray-400">
                    <i class="fa-solid fa-tag text-6xl mb-4"></i>
                    <p class="text-xl">No hay promociones disponibles por el momento.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4">
                    <c:forEach items="${promociones}" var="promo">
                        <a href="${pageContext.request.contextPath}/promocion?id=${promo.id}"
                           class="card-promo bg-white rounded-2xl shadow-md overflow-hidden border border-gray-100 flex flex-col hover:shadow-xl transition">
                            <div class="overflow-hidden relative">
                                <img src="${pageContext.request.contextPath}/img/${promo.imagen}"
                                     class="card-img w-full h-[160px] object-cover">
                                <div class="absolute top-2 left-2 bg-red-600 text-white text-[10px] font-bold px-2 py-0.5 rounded-full">
                                    PROMO
                                </div>
                            </div>
                            <div class="p-3 flex flex-col flex-1">
                                <h3 class="font-semibold text-sm mb-1">${promo.nombre}</h3>
                                <p class="text-xs text-gray-500 leading-tight flex-1">${promo.descripcion}</p>
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
            </c:otherwise>
        </c:choose>
    </section>

    <jsp:include page="/components/footer.jsp"/>

    <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
    <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
</body>
</html>
