<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<header class="w-full shadow">

    <!-- Barra negra -->
    <div class="w-full bg-black text-white text-center text-md py-1">
        <p class="slide-text">Envío gratuito por compras mayores a S/150 para Lima Metropolitana</p>
    </div>

    <!-- Contenedor principal -->
    <div class="w-full flex items-center justify-between px-10 py-1 gap-6">

        <a href="${pageContext.request.contextPath}/home">
            <img src="${pageContext.request.contextPath}/img/logoheader.png" class="h-20 w-auto object-contain">
        </a>

        <nav class="flex gap-6 text-base md:text-lg font-medium items-center">

            <a href="${pageContext.request.contextPath}/home"
               class="px-3 py-2 rounded hover:bg-red-500 hover:text-white transition">Inicio</a>

            <a href="${pageContext.request.contextPath}/promociones"
               class="px-3 py-2 rounded hover:bg-red-500 hover:text-white transition">Promociones</a>

            <!-- MENÚ CATEGORÍAS -->
            <div class="relative group">
                <a href="#" class="px-3 py-2 rounded hover:bg-red-500 hover:text-white transition">Categoría</a>

                <div class="absolute left-0 top-full w-screen bg-white shadow-lg hidden group-hover:block z-50">
                    <div class="max-w-7xl mx-auto flex gap-10 p-10">
                        <div class="w-[250px]">
                            <img src="${pageContext.request.contextPath}/img/megamenu.png" class="w-full rounded-lg object-cover">
                        </div>
                        <div class="flex gap-12">
                            <div class="flex flex-col">
                                <h2 class="text-lg font-bold text-red-500 mb-2">Pollo a la brasa</h2>
                                <a href="${pageContext.request.contextPath}/categoria?id=1" class="hover:text-red-500">1/4 Pollo</a>
                                <a href="${pageContext.request.contextPath}/categoria?id=1" class="hover:text-red-500">1/2 Pollo</a>
                                <a href="${pageContext.request.contextPath}/categoria?id=1" class="hover:text-red-500">1 Pollo entero</a>
                            </div>
                            <div class="flex flex-col">
                                <h2 class="text-lg font-bold text-red-500 mb-2">Ensaladas</h2>
                                <a href="${pageContext.request.contextPath}/categoria?id=2" class="hover:text-red-500">Fresca</a>
                                <a href="${pageContext.request.contextPath}/categoria?id=2" class="hover:text-red-500">Cocida</a>
                                <a href="${pageContext.request.contextPath}/categoria?id=2" class="hover:text-red-500">Especial</a>
                            </div>
                            <div class="flex flex-col">
                                <h2 class="text-lg font-bold text-red-500 mb-2">Bebidas</h2>
                                <a href="${pageContext.request.contextPath}/categoria?id=5" class="hover:text-red-500">Gaseosas</a>
                                <a href="${pageContext.request.contextPath}/categoria?id=5" class="hover:text-red-500">Jugos</a>
                            </div>
                            <div class="flex flex-col">
                                <h2 class="text-lg font-bold text-red-500 mb-2">Postres</h2>
                                <a href="${pageContext.request.contextPath}/categoria?id=6" class="hover:text-red-500">Helados</a>
                                <a href="${pageContext.request.contextPath}/categoria?id=6" class="hover:text-red-500">Tortas</a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

        </nav>

        <!-- BUSCADOR -->
        <div class="flex items-center border rounded-full px-4 py-1 w-[450px]">
            <input type="text" class="w-full outline-none text-sm" placeholder="Buscar...">
            <i class="fa-solid fa-magnifying-glass"></i>
        </div>

        <!-- ICONOS USUARIO -->
        <div class="flex gap-4 text-xl items-center">
            <c:choose>
                <c:when test="${not empty sessionScope.usuario}">
                    <span class="text-sm font-medium text-gray-700">Hola, ${sessionScope.usuario.nombre}</span>
                    <a href="${pageContext.request.contextPath}/logout" class="text-sm text-red-500 hover:underline">Salir</a>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/login" class="hover:text-red-500 transition">
                        <ion-icon name="person-outline"></ion-icon>
                    </a>
                </c:otherwise>
            </c:choose>
            <a href="#" class="hover:text-red-500 transition"><ion-icon name="heart-outline"></ion-icon></a>
            <a href="${pageContext.request.contextPath}/carrito" class="hover:text-red-500 transition relative">
                <ion-icon name="bag-outline"></ion-icon>
            </a>
        </div>

    </div>

    <script src="https://cdn.tailwindcss.com"></script>
    <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
    <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
</header>
