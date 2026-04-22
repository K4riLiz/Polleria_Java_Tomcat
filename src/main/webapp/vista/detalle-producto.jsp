<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <script src="https://cdn.tailwindcss.com"></script>
    <title>${producto.nombre} - Pollería</title>
</head>
<body>

    <jsp:include page="/components/header.jsp"/>

    <%-- BREADCRUMB --%>
    <div class="max-w-7xl mx-auto px-6 py-4 text-sm text-gray-500">
        <a href="${pageContext.request.contextPath}/home" class="hover:text-red-500">Inicio</a>
        <span class="mx-2">/</span>
        <a href="${pageContext.request.contextPath}/categoria?id=${producto.categoriaId}" class="hover:text-red-500">
            ${producto.categoriaNombre}
        </a>
        <span class="mx-2">/</span>
        <span class="text-gray-800 font-medium">${producto.nombre}</span>
    </div>

    <%-- DETALLE PRODUCTO --%>
    <section class="max-w-5xl mx-auto px-6 py-10">
        <div class="bg-white rounded-2xl shadow-lg overflow-hidden flex flex-col md:flex-row">

            <%-- IMAGEN --%>
            <div class="md:w-1/2">
                <img src="${pageContext.request.contextPath}/img/${producto.imagen}"
                     class="w-full h-[300px] md:h-full object-cover">
            </div>

            <%-- INFO --%>
            <div class="md:w-1/2 p-8 flex flex-col justify-center gap-4">

                <span class="text-sm text-orange-600 font-semibold uppercase tracking-wide">
                    ${producto.categoriaNombre}
                </span>

                <h1 class="text-3xl font-bold text-gray-800">${producto.nombre}</h1>

                <p class="text-gray-500 leading-relaxed">${producto.descripcion}</p>

                <div class="text-4xl font-bold text-red-600">
                    S/<fmt:formatNumber value="${producto.precio}" pattern="#,##0.00"/>
                </div>

                <%-- Solo mostrar botón agregar si hay sesión --%>
                <c:choose>
                    <c:when test="${not empty sessionScope.usuario}">
                        <button class="bg-red-600 hover:bg-red-700 text-white font-semibold py-3 px-8 rounded-xl transition text-lg">
                            <i class="fa-solid fa-cart-plus mr-2"></i> Agregar al carrito
                        </button>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/login"
                           class="bg-red-600 hover:bg-red-700 text-white font-semibold py-3 px-8 rounded-xl transition text-lg text-center">
                            <i class="fa-solid fa-user mr-2"></i> Inicia sesión para comprar
                        </a>
                    </c:otherwise>
                </c:choose>

                <a href="${pageContext.request.contextPath}/categoria?id=${producto.categoriaId}"
                   class="text-sm text-gray-400 hover:text-red-500 transition mt-2">
                    ← Volver a ${producto.categoriaNombre}
                </a>

            </div>
        </div>
    </section>

    <jsp:include page="/components/footer.jsp"/>

    <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
    <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
</body>
</html>
