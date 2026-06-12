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
                                <a href="${pageContext.request.contextPath}/categoria?id=1" class="text-lg font-bold text-red-500 mb-2 hover:underline">Pollo a la brasa</a>
                                <a href="${pageContext.request.contextPath}/categoria?id=1" class="hover:text-red-500 py-1">1/4 Pollo</a>
                                <a href="${pageContext.request.contextPath}/categoria?id=1" class="hover:text-red-500 py-1">1/2 Pollo</a>
                                <a href="${pageContext.request.contextPath}/categoria?id=1" class="hover:text-red-500 py-1">1 Pollo entero</a>
                            </div>
                            <div class="flex flex-col">
                                <a href="${pageContext.request.contextPath}/categoria?id=2" class="text-lg font-bold text-red-500 mb-2 hover:underline">Ensaladas</a>
                                <a href="${pageContext.request.contextPath}/categoria?id=2" class="hover:text-red-500 py-1">Fresca</a>
                                <a href="${pageContext.request.contextPath}/categoria?id=2" class="hover:text-red-500 py-1">Cocida</a>
                                <a href="${pageContext.request.contextPath}/categoria?id=2" class="hover:text-red-500 py-1">Especial</a>
                            </div>
                            <div class="flex flex-col">
                                <a href="${pageContext.request.contextPath}/categoria?id=5" class="text-lg font-bold text-red-500 mb-2 hover:underline">Bebidas</a>
                                <a href="${pageContext.request.contextPath}/categoria?id=5" class="hover:text-red-500 py-1">Gaseosas</a>
                                <a href="${pageContext.request.contextPath}/categoria?id=5" class="hover:text-red-500 py-1">Jugos</a>
                            </div>
                            <div class="flex flex-col">
                                <a href="${pageContext.request.contextPath}/categoria?id=6" class="text-lg font-bold text-red-500 mb-2 hover:underline">Postres</a>
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

            <!-- Buscador móvil -->
            <button class="md:hidden" onclick="toggleBuscadorMovil()">
                <i class="fa-solid fa-magnifying-glass"></i>
            </button>

            <c:choose>
                <c:when test="${not empty sessionScope.usuario}">
                    <%-- Dropdown solo para CLIENTE --%>
                    <c:if test="${sessionScope.rolNombre == 'CLIENTE'}">
                        <div class="relative hidden md:block" id="clienteMenu">
                            <button onclick="toggleClienteMenu()"
                                    class="flex items-center gap-2 bg-white border border-gray-200 shadow-sm px-3 py-1.5 rounded-xl text-sm font-medium text-gray-700 hover:border-red-400 hover:text-red-600 transition">
                                <i class="fa-solid fa-circle-user text-red-500 text-base"></i>
                                ${sessionScope.usuario.nombre}
                                <i class="fa-solid fa-chevron-down text-xs text-gray-400" id="iconClienteMenu"></i>
                            </button>
                            <div id="dropdownCliente"
                                 class="hidden absolute right-0 top-full mt-2 w-56 bg-white rounded-2xl shadow-lg border border-gray-100 z-50 overflow-hidden">
                                <div class="px-4 py-3 border-b border-gray-100 bg-red-50">
                                    <p class="text-sm font-semibold text-gray-800">${sessionScope.usuario.nombre}</p>
                                    <p class="text-xs text-gray-500">${sessionScope.usuario.email}</p>
                                </div>
                                <a href="${pageContext.request.contextPath}/home"
                                   class="flex items-center gap-3 px-4 py-3 text-sm text-gray-700 hover:bg-red-50 hover:text-red-600 transition">
                                    <i class="fa-solid fa-house w-4"></i> Inicio
                                </a>
                                <a href="${pageContext.request.contextPath}/historial"
                                   class="flex items-center gap-3 px-4 py-3 text-sm text-gray-700 hover:bg-red-50 hover:text-red-600 transition">
                                    <i class="fa-solid fa-clock-rotate-left w-4"></i> Mis pedidos
                                </a>
                                <a href="${pageContext.request.contextPath}/carrito"
                                   class="flex items-center gap-3 px-4 py-3 text-sm text-gray-700 hover:bg-red-50 hover:text-red-600 transition">
                                    <i class="fa-solid fa-bag-shopping w-4"></i> Mi carrito
                                </a>
                                <a href="${pageContext.request.contextPath}/libro-reclamaciones"
                                   class="flex items-center gap-3 px-4 py-3 text-sm text-gray-700 hover:bg-red-50 hover:text-red-600 transition">
                                    <i class="fa-solid fa-book-open w-4"></i> Reclamaciones
                                </a>
                                <div class="border-t border-gray-100"></div>
                                <a href="${pageContext.request.contextPath}/logout"
                                   class="flex items-center gap-3 px-4 py-3 text-sm text-red-500 hover:bg-red-50 transition">
                                    <i class="fa-solid fa-right-from-bracket w-4"></i> Cerrar sesión
                                </a>
                            </div>
                        </div>
                    </c:if>

                    <%-- Para otros roles mantenemos el saludo simple --%>
                    <c:if test="${sessionScope.rolNombre != 'CLIENTE'}">
                        <span class="hidden md:block text-sm font-medium text-gray-700">
                            Hola, ${sessionScope.usuario.nombre}
                        </span>
                    </c:if>
                </c:when>
                
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/login" class="hover:text-red-500 transition">
                        <ion-icon name="person-outline"></ion-icon>
                    </a>
                </c:otherwise>
            </c:choose>

            <a href="#" class="hover:text-red-500 transition"><ion-icon name="heart-outline"></ion-icon></a>
            <a href="${pageContext.request.contextPath}/carrito" class="hover:text-red-500 transition">
                <ion-icon name="bag-outline"></ion-icon>
            </a>

            <!-- Hamburguesa móvil -->
            <button class="md:hidden text-2xl" onclick="toggleMenu()">
                <ion-icon name="menu-outline" id="iconMenu"></ion-icon>
            </button>
        </div>
    </div>

    <!-- BUSCADOR MÓVIL (oculto por defecto) -->
    <div id="buscadorMovil" class="hidden px-4 pb-3 md:hidden">
        <div class="flex items-center border rounded-full px-4 py-2 bg-gray-50">
            <input type="text" id="buscadorMovilInput" class="w-full outline-none text-sm bg-transparent"
                   placeholder="Buscar productos..."
                   onkeydown="if(event.key==='Enter') buscarMovil()">
            <i class="fa-solid fa-magnifying-glass cursor-pointer text-gray-400" onclick="buscarMovil()"></i>
        </div>
    </div>

    <!-- MENÚ MÓVIL (oculto por defecto) -->
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

            <!-- Categorías en móvil -->
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

            <c:if test="${not empty sessionScope.usuario}">
                <a href="${pageContext.request.contextPath}/logout"
                   class="px-4 py-3 rounded-lg hover:bg-red-50 text-red-500 font-medium transition">
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
        
        //box
        function toggleClienteMenu() {
            const dd = document.getElementById('dropdownCliente');
            const icon = document.getElementById('iconClienteMenu');
            dd.classList.toggle('hidden');
            icon.classList.toggle('rotate-180');
        }
        document.addEventListener('click', function(e) {
            const menu = document.getElementById('clienteMenu');
            if (menu && !menu.contains(e.target)) {
                document.getElementById('dropdownCliente').classList.add('hidden');
                document.getElementById('iconClienteMenu').classList.remove('rotate-180');
            }
        });
    </script>
    

</header>
