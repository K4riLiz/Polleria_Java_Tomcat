<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<header class="w-full shadow">

    <!-- Barra negra -->
    <div class="w-full bg-black text-white text-center text-sm py-1">
        <p>Envío gratuito por compras mayores a S/150 para Lima Metropolitana</p>
    </div>

    <!-- Contenedor principal -->
    <div class="w-full flex items-center justify-between px-4 md:px-10 py-2 gap-4">

        <!-- LOGO -->
        <a href="${pageContext.request.contextPath}/home" class="flex-shrink-0">
            <img src="${pageContext.request.contextPath}/img/logoheader.png" class="h-14 md:h-20 w-auto object-contain">
        </a>

        <!-- NAV DESKTOP -->
        <nav class="hidden md:flex gap-6 text-base font-medium items-center">
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
                                <a href="${pageContext.request.contextPath}/categoria?id=1" class="hover:text-red-500 py-1">1/4 Pollo</a>
                                <a href="${pageContext.request.contextPath}/categoria?id=1" class="hover:text-red-500 py-1">1/2 Pollo</a>
                                <a href="${pageContext.request.contextPath}/categoria?id=1" class="hover:text-red-500 py-1">1 Pollo entero</a>
                            </div>
                            <div class="flex flex-col">
                                <h2 class="text-lg font-bold text-red-500 mb-2">Ensaladas</h2>
                                <a href="${pageContext.request.contextPath}/categoria?id=2" class="hover:text-red-500 py-1">Fresca</a>
                                <a href="${pageContext.request.contextPath}/categoria?id=2" class="hover:text-red-500 py-1">Cocida</a>
                                <a href="${pageContext.request.contextPath}/categoria?id=2" class="hover:text-red-500 py-1">Especial</a>
                            </div>
                            <div class="flex flex-col">
                                <h2 class="text-lg font-bold text-red-500 mb-2">Bebidas</h2>
                                <a href="${pageContext.request.contextPath}/categoria?id=5" class="hover:text-red-500 py-1">Gaseosas</a>
                                <a href="${pageContext.request.contextPath}/categoria?id=5" class="hover:text-red-500 py-1">Jugos</a>
                            </div>
                            <div class="flex flex-col">
                                <h2 class="text-lg font-bold text-red-500 mb-2">Postres</h2>
                                <a href="${pageContext.request.contextPath}/categoria?id=6" class="hover:text-red-500 py-1">Helados</a>
                                <a href="${pageContext.request.contextPath}/categoria?id=6" class="hover:text-red-500 py-1">Tortas</a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </nav>

        <!-- BUSCADOR DESKTOP -->
        <div class="hidden md:flex items-center border rounded-full px-4 py-1 w-[350px]">
            <input type="text" id="buscadorHeader" class="w-full outline-none text-sm"
                   placeholder="Buscar productos..."
                   onkeydown="if(event.key==='Enter') buscar()">
            <i class="fa-solid fa-magnifying-glass cursor-pointer" onclick="buscar()"></i>
        </div>

        <!-- ICONOS DERECHA -->
        <div class="flex gap-3 text-xl items-center">

            <button class="md:hidden" onclick="toggleBuscadorMovil()">
                <i class="fa-solid fa-magnifying-glass"></i>
            </button>

            <c:choose>
                <c:when test="${not empty sessionScope.usuario}">
                    <span class="hidden md:block text-sm font-medium text-gray-700">
                        Hola, ${sessionScope.usuario.nombre}
                    </span>

                    <%-- ADMIN --%>
                    <c:if test="${sessionScope.rolNombre == 'ADMIN'}">
                        <div class="relative group hidden md:block">
                            <button class="text-sm font-medium text-red-600 hover:underline flex items-center gap-1">
                                Admin <i class="fa-solid fa-chevron-down text-xs"></i>
                            </button>
                            <div class="absolute right-0 top-full w-52 bg-white shadow-lg rounded-xl border border-gray-100 hidden group-hover:block z-50">
                                <a href="${pageContext.request.contextPath}/admin/usuarios"
                                   class="flex items-center gap-2 px-4 py-3 text-sm hover:bg-red-50 hover:text-red-600 transition">
                                    <i class="fa-solid fa-users w-4"></i> Usuarios
                                </a>
                                <a href="${pageContext.request.contextPath}/admin/productos"
                                   class="flex items-center gap-2 px-4 py-3 text-sm hover:bg-red-50 hover:text-red-600 transition">
                                    <i class="fa-solid fa-box w-4"></i> Productos
                                </a>
                                <a href="${pageContext.request.contextPath}/admin/pedidos"
                                   class="flex items-center gap-2 px-4 py-3 text-sm hover:bg-red-50 hover:text-red-600 transition">
                                    <i class="fa-solid fa-receipt w-4"></i> Pedidos
                                </a>
                                <a href="${pageContext.request.contextPath}/admin/reclamaciones"
                                   class="flex items-center gap-2 px-4 py-3 text-sm hover:bg-red-50 hover:text-red-600 transition">
                                    <i class="fa-solid fa-triangle-exclamation w-4"></i> Reclamaciones
                                </a>
                                <div class="border-t border-gray-100"></div>
                                <a href="${pageContext.request.contextPath}/logout"
                                   class="flex items-center gap-2 px-4 py-3 text-sm text-red-500 hover:bg-red-50 transition">
                                    <i class="fa-solid fa-right-from-bracket w-4"></i> Salir
                                </a>
                            </div>
                        </div>
                    </c:if>

                    <%-- CLIENTE --%>
                    <c:if test="${sessionScope.rolNombre == 'CLIENTE'}">
                        <a href="${pageContext.request.contextPath}/historial"
                           class="hidden md:block text-sm hover:text-red-500 transition" title="Mis pedidos">
                            <i class="fa-solid fa-clock-rotate-left"></i>
                        </a>
                        <a href="${pageContext.request.contextPath}/logout"
                           class="text-sm text-red-500 hover:underline">Salir</a>
                    </c:if>

                    <%-- CHEF --%>
                    <c:if test="${sessionScope.rolNombre == 'CHEF'}">
                        <a href="${pageContext.request.contextPath}/chef/pedidos"
                           class="hidden md:block text-sm hover:text-red-500 transition">
                            <i class="fa-solid fa-fire-burner"></i> Cocina
                        </a>
                        <a href="${pageContext.request.contextPath}/logout"
                           class="text-sm text-red-500 hover:underline">Salir</a>
                    </c:if>

                    <%-- DELIVERY --%>
                    <c:if test="${sessionScope.rolNombre == 'DELIVERY'}">
                        <a href="${pageContext.request.contextPath}/delivery/pedidos"
                           class="hidden md:block text-sm hover:text-red-500 transition">
                            <i class="fa-solid fa-motorcycle"></i> Despachos
                        </a>
                        <a href="${pageContext.request.contextPath}/logout"
                           class="text-sm text-red-500 hover:underline">Salir</a>
                    </c:if>

                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/login" class="hover:text-red-500 transition">
                        <ion-icon name="person-outline"></ion-icon>
                    </a>
                </c:otherwise>
            </c:choose>

            <a href="#" class="hover:text-red-500 transition"><ion-icon name="heart-outline"></ion-icon></a>

            <%-- Carrito solo para cliente y no logueado --%>
            <c:if test="${sessionScope.rolNombre == 'CLIENTE' || empty sessionScope.rolNombre}">
                <a href="${pageContext.request.contextPath}/carrito" class="hover:text-red-500 transition">
                    <ion-icon name="bag-outline"></ion-icon>
                </a>
            </c:if>

            <button class="md:hidden text-2xl" onclick="toggleMenu()">
                <ion-icon name="menu-outline" id="iconMenu"></ion-icon>
            </button>
        </div>
    </div>

    <!-- BUSCADOR MÓVIL -->
    <div id="buscadorMovil" class="hidden px-4 pb-3 md:hidden">
        <div class="flex items-center border rounded-full px-4 py-2 bg-gray-50">
            <input type="text" id="buscadorMovilInput" class="w-full outline-none text-sm bg-transparent"
                   placeholder="Buscar productos..."
                   onkeydown="if(event.key==='Enter') buscarMovil()">
            <i class="fa-solid fa-magnifying-glass cursor-pointer text-gray-400" onclick="buscarMovil()"></i>
        </div>
    </div>

    <!-- MENÚ MÓVIL -->
    <div id="menuMovil" class="hidden md:hidden bg-white border-t shadow-lg z-50">
        <nav class="flex flex-col px-4 py-3 gap-1">
            <a href="${pageContext.request.contextPath}/home"
               class="px-4 py-3 rounded-lg hover:bg-red-50 hover:text-red-600 font-medium transition">
                Inicio
            </a>
            <a href="${pageContext.request.contextPath}/promociones"
               class="px-4 py-3 rounded-lg hover:bg-red-50 hover:text-red-600 font-medium transition">
                Promociones
            </a>

            <!-- Categorías móvil -->
            <div>
                <button onclick="toggleCatMovil()"
                        class="w-full text-left px-4 py-3 rounded-lg hover:bg-red-50 hover:text-red-600 font-medium transition flex justify-between items-center">
                    Categoría <ion-icon name="chevron-down-outline" id="iconCat"></ion-icon>
                </button>
                <div id="catMovil" class="hidden flex flex-col pl-4 gap-1">
                    <p class="text-xs font-bold text-red-500 px-4 pt-2">Pollo a la Brasa</p>
                    <a href="${pageContext.request.contextPath}/categoria?id=1" class="px-4 py-2 hover:text-red-500 text-sm">1/4 Pollo</a>
                    <a href="${pageContext.request.contextPath}/categoria?id=1" class="px-4 py-2 hover:text-red-500 text-sm">1/2 Pollo</a>
                    <a href="${pageContext.request.contextPath}/categoria?id=1" class="px-4 py-2 hover:text-red-500 text-sm">1 Pollo entero</a>
                    <p class="text-xs font-bold text-red-500 px-4 pt-2">Ensaladas</p>
                    <a href="${pageContext.request.contextPath}/categoria?id=2" class="px-4 py-2 hover:text-red-500 text-sm">Fresca</a>
                    <a href="${pageContext.request.contextPath}/categoria?id=2" class="px-4 py-2 hover:text-red-500 text-sm">Cocida</a>
                    <p class="text-xs font-bold text-red-500 px-4 pt-2">Bebidas</p>
                    <a href="${pageContext.request.contextPath}/categoria?id=5" class="px-4 py-2 hover:text-red-500 text-sm">Gaseosas</a>
                    <a href="${pageContext.request.contextPath}/categoria?id=5" class="px-4 py-2 hover:text-red-500 text-sm">Jugos</a>
                    <p class="text-xs font-bold text-red-500 px-4 pt-2">Postres</p>
                    <a href="${pageContext.request.contextPath}/categoria?id=6" class="px-4 py-2 hover:text-red-500 text-sm">Helados</a>
                    <a href="${pageContext.request.contextPath}/categoria?id=6" class="px-4 py-2 hover:text-red-500 text-sm">Tortas</a>
                </div>
            </div>

            <%-- ADMIN MÓVIL --%>
            <c:if test="${sessionScope.rolNombre == 'ADMIN'}">
                <p class="text-xs font-bold text-red-500 px-4 pt-3">Administración</p>
                <a href="${pageContext.request.contextPath}/admin/usuarios"
                   class="px-4 py-3 rounded-lg hover:bg-red-50 hover:text-red-600 font-medium transition text-sm">
                    <i class="fa-solid fa-users mr-2"></i> Usuarios
                </a>
                <a href="${pageContext.request.contextPath}/admin/productos"
                   class="px-4 py-3 rounded-lg hover:bg-red-50 hover:text-red-600 font-medium transition text-sm">
                    <i class="fa-solid fa-box mr-2"></i> Productos
                </a>
                <a href="${pageContext.request.contextPath}/admin/pedidos"
                   class="px-4 py-3 rounded-lg hover:bg-red-50 hover:text-red-600 font-medium transition text-sm">
                    <i class="fa-solid fa-receipt mr-2"></i> Pedidos
                </a>
                <a href="${pageContext.request.contextPath}/admin/reclamaciones"
                   class="px-4 py-3 rounded-lg hover:bg-red-50 hover:text-red-600 font-medium transition text-sm">
                    <i class="fa-solid fa-triangle-exclamation mr-2"></i> Reclamaciones
                </a>
            </c:if>

            <%-- CLIENTE MÓVIL --%>
            <c:if test="${sessionScope.rolNombre == 'CLIENTE'}">
                <a href="${pageContext.request.contextPath}/historial"
                   class="px-4 py-3 rounded-lg hover:bg-red-50 hover:text-red-600 font-medium transition">
                    <i class="fa-solid fa-clock-rotate-left mr-2"></i> Mis pedidos
                </a>
            </c:if>

            <%-- CHEF MÓVIL --%>
            <c:if test="${sessionScope.rolNombre == 'CHEF'}">
                <a href="${pageContext.request.contextPath}/chef/pedidos"
                   class="px-4 py-3 rounded-lg hover:bg-red-50 hover:text-red-600 font-medium transition">
                    <i class="fa-solid fa-fire-burner mr-2"></i> Cocina
                </a>
            </c:if>

            <%-- DELIVERY MÓVIL --%>
            <c:if test="${sessionScope.rolNombre == 'DELIVERY'}">
                <a href="${pageContext.request.contextPath}/delivery/pedidos"
                   class="px-4 py-3 rounded-lg hover:bg-red-50 hover:text-red-600 font-medium transition">
                    <i class="fa-solid fa-motorcycle mr-2"></i> Despachos
                </a>
            </c:if>

            <%-- CERRAR SESIÓN --%>
            <c:if test="${not empty sessionScope.usuario}">
                <a href="${pageContext.request.contextPath}/logout"
                   class="px-4 py-3 rounded-lg hover:bg-red-50 text-red-500 font-medium transition">
                    <i class="fa-solid fa-right-from-bracket mr-2"></i>
                    Cerrar sesión (${sessionScope.usuario.nombre})
                </a>
            </c:if>
            <c:if test="${empty sessionScope.usuario}">
                <a href="${pageContext.request.contextPath}/login"
                   class="px-4 py-3 rounded-lg hover:bg-red-50 hover:text-red-600 font-medium transition">
                    Iniciar sesión
                </a>
            </c:if>

        </nav>
    </div>

    <script src="https://cdn.tailwindcss.com"></script>
    <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
    <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>

    <script>
        function buscar() {
            const texto = document.getElementById('buscadorHeader').value.trim();
            if (texto) window.location.href = '${pageContext.request.contextPath}/buscar?q=' + encodeURIComponent(texto);
        }

        function buscarMovil() {
            const texto = document.getElementById('buscadorMovilInput').value.trim();
            if (texto) window.location.href = '${pageContext.request.contextPath}/buscar?q=' + encodeURIComponent(texto);
        }

        function toggleMenu() {
            const menu = document.getElementById('menuMovil');
            menu.classList.toggle('hidden');
        }

        function toggleBuscadorMovil() {
            const b = document.getElementById('buscadorMovil');
            b.classList.toggle('hidden');
            if (!b.classList.contains('hidden')) {
                document.getElementById('buscadorMovilInput').focus();
            }
        }

        function toggleCatMovil() {
            document.getElementById('catMovil').classList.toggle('hidden');
        }
    </script>

</header>