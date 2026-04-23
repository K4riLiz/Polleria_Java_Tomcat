<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://kit.fontawesome.com/887a835504.js" crossorigin="anonymous"></script>
    <title>Inicio - Pollería</title>
</head>
<body>

    <%-- HEADER --%>
    <jsp:include page="/components/header.jsp"/>

    <%-- CARRUSEL --%>
    <div class="relative w-full overflow-hidden">
        <div id="carousel" class="flex transition-transform duration-500 ease-in-out">
            <img src="${pageContext.request.contextPath}/img/carrusel1.png" class="w-full flex-shrink-0 object-cover h-[250px] sm:h-[350px] md:h-[450px] lg:h-[500px]">
            <img src="${pageContext.request.contextPath}/img/carrusel2.png" class="w-full flex-shrink-0 object-cover h-[250px] sm:h-[350px] md:h-[450px] lg:h-[500px]">
            <img src="${pageContext.request.contextPath}/img/carrusel3.png" class="w-full flex-shrink-0 object-cover h-[250px] sm:h-[350px] md:h-[450px] lg:h-[500px]">
        </div>
        <button id="prev" class="absolute top-1/2 left-2 md:left-4 -translate-y-1/2 bg-black/50 text-white px-2 py-1 md:px-3 md:py-2 rounded-full hover:bg-black">❮</button>
        <button id="next" class="absolute top-1/2 right-2 md:right-4 -translate-y-1/2 bg-black/50 text-white px-2 py-1 md:px-3 md:py-2 rounded-full hover:bg-black">❯</button>
        <div class="absolute bottom-4 left-1/2 transform -translate-x-1/2 flex gap-3">
            <span class="dot w-3 h-3 bg-white/50 rounded-full cursor-pointer"></span>
            <span class="dot w-3 h-3 bg-white/50 rounded-full cursor-pointer"></span>
            <span class="dot w-3 h-3 bg-white/50 rounded-full cursor-pointer"></span>
        </div>
    </div>

    <%-- NUESTRA CARTA - dinámico desde BD --%>
    <section class="max-w-7xl mx-auto px-6 py-12">
        <h2 class="text-3xl font-bold text-center mb-10">Nuestra Carta</h2>

        <div class="grid gap-6">
            <%-- Filas de 3 columnas, alterna grande-pequeño --%>
            <c:set var="index" value="0"/>
            <c:forEach items="${categorias}" var="cat" varStatus="loop">
                <c:if test="${loop.index % 2 == 0}">
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                </c:if>

                <c:choose>
                    <c:when test="${loop.index % 2 == 0}">
                        <%-- Imagen GRANDE --%>
                        <a href="${pageContext.request.contextPath}/categoria?id=${cat.id}"
                           class="md:col-span-2 relative group overflow-hidden rounded-xl">
                            <img src="${pageContext.request.contextPath}/img/${cat.imagen}"
                                 class="w-full h-[180px] sm:h-[220px] md:h-[250px] object-cover group-hover:scale-110 transition duration-500">
                            <div class="absolute inset-0 bg-black/30 group-hover:bg-black/40 transition"></div>
                            <p class="absolute bottom-4 left-4 text-white text-lg md:text-xl font-semibold transform translate-y-4 group-hover:translate-y-0 transition">
                                ${cat.nombre}
                            </p>
                        </a>
                    </c:when>
                    <c:otherwise>
                        <%-- Imagen PEQUEÑA --%>
                        <a href="${pageContext.request.contextPath}/categoria?id=${cat.id}"
                           class="relative group overflow-hidden rounded-xl">
                            <img src="${pageContext.request.contextPath}/img/${cat.imagen}"
                                 class="w-full h-[180px] sm:h-[220px] md:h-[250px] object-cover group-hover:scale-110 transition duration-500">
                            <div class="absolute inset-0 bg-black/30 group-hover:bg-black/40 transition"></div>
                            <p class="absolute bottom-4 left-4 text-white text-lg md:text-xl font-semibold transform translate-y-4 group-hover:translate-y-0 transition">
                                ${cat.nombre}
                            </p>
                        </a>
                    </c:otherwise>
                </c:choose>

                <c:if test="${loop.index % 2 == 1 or loop.last}">
                    </div>
                </c:if>
            </c:forEach>
        </div>
    </section>

    <%-- CARDS INFORME --%>
    <section class="flex flex-col md:flex-row gap-6 px-6 md:px-12 py-16 bg-white">
        <div class="w-full md:w-1/3 p-6 border rounded-xl text-center border-gray-300 rounded-[15px] p-8 shadow-[0_0_15px_5px_rgb(165,67,42)]">
            <div class="flex justify-center">
                <i class="fa-solid fa-hand-sparkles text-3xl md:text-4xl p-4 rounded-full bg-[rgba(201,91,9,0.2)] text-[#A5432A]"></i>
            </div>
            <h1 class="mt-6 text-xl font-semibold leading-[50px]">Higiene Garantizada</h1>
            <p class="leading-[25px] text-base">Cumplimos con los más altos estándares de calidad y seguridad en cada preparación.</p>
        </div>
        <div class="w-full md:w-1/3 p-6 border rounded-xl text-center border-gray-300 rounded-[15px] p-8 shadow-[0_0_15px_5px_rgb(241,83,83)]">
            <div class="flex justify-center">
                <i class="fa-solid fa-truck text-3xl md:text-4xl p-4 rounded-full bg-[rgba(245,188,188,0.2)] text-red-500"></i>
            </div>
            <h1 class="mt-6 text-xl font-semibold leading-[50px]">Delivery</h1>
            <p class="leading-[25px] text-base">Llevamos tu pedido en tiempo récord para que disfrutes de tu pollo como recién salido del horno.</p>
        </div>
        <div class="w-full md:w-1/3 p-6 border rounded-xl text-center border-gray-300 rounded-[15px] p-8 shadow-[0_0px_15px_5px_rgba(202,104,24,0.5)]">
            <div class="flex justify-center">
                <i class="fa-solid fa-drumstick-bite text-3xl md:text-4xl p-4 rounded-full bg-[rgba(202,104,24,0.2)] text-yellow-600"></i>
            </div>
            <h1 class="mt-6 text-xl font-semibold leading-[50px]">Sabor Inigualable</h1>
            <p class="leading-[25px] text-base">El auténtico sabor del pollo a la brasa, preparado con nuestra receta secreta.</p>
        </div>
    </section>

    <%-- FOOTER --%>
    <jsp:include page="/components/footer.jsp"/>

    <script src="${pageContext.request.contextPath}/js/carrusel.js"></script>
    <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
    <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
</body>
</html>
