<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- Cargar categorías dinámicamente si no vienen ya en el request --%>
<%
    java.util.List categorias = (java.util.List) request.getAttribute("categorias");
    if (categorias == null) {
        categorias = (java.util.List) session.getAttribute("categoriasNav");
        if (categorias == null) {
            try {
                com.polleria.dao.CategoriaDAO catDao = new com.polleria.dao.CategoriaDAO();
                categorias = catDao.listarTodas();
                session.setAttribute("categoriasNav", categorias);
            } catch (Exception e) {
                categorias = new java.util.ArrayList();
            }
        }
    }
    request.setAttribute("categoriasNav", categorias);
%>

<header class="w-full shadow">

    <div class="w-full bg-black text-white text-center text-sm py-1">
        <p>Envío gratuito por compras mayores a S/150 para Lima Metropolitana</p>
    </div>

    <div class="w-full flex items-center justify-between px-4 md:px-10 py-2 gap-4">

        <a href="${pageContext.request.contextPath}/home" class="flex-shrink-0">
            <img src="${pageContext.request.contextPath}/img/logoheader.webp" class="h-14 md:h-20 w-auto object-contain">
        </a>

        <nav class="hidden md:flex gap-6 text-base font-medium items-center">
            <a href="${pageContext.request.contextPath}/home"
               class="px-3 py-2 rounded hover:bg-red-500 hover:text-white transition">Inicio</a>
            <a href="${pageContext.request.contextPath}/promociones"
               class="px-3 py-2 rounded hover:bg-red-500 hover:text-white transition">Promociones</a>

            <!-- MENÚ CATEGORÍAS DINÁMICO -->
            <div class="relative group">
                <a href="#" class="px-3 py-2 rounded hover:bg-red-500 hover:text-white transition">Categoría</a>
                <div class="absolute left-0 top-full bg-white shadow-lg hidden group-hover:block z-50">
                    <div class="flex gap-8 p-8 min-w-[500px] items-center">

                        <!-- Imagen -->
                        <div class="w-[220px] flex-shrink-0">
                            <img src="${pageContext.request.contextPath}/img/megamenu.webp"
                                 class="w-full rounded-lg object-cover">
                        </div>

                        <!-- Categorías -->
                        <div class="flex flex-col gap-3 min-w-[200px]">
                            <c:forEach items="${categoriasNav}" var="cat">
                                <a href="${pageContext.request.contextPath}/categoria?id=${cat.id}"
                                   class="text-base font-semibold text-gray-700 hover:text-red-500 hover:translate-x-1 transition-all">
                                    ${cat.nombre}
                                </a>
                            </c:forEach>
                        </div>

                    </div>
                </div>
            </div>
        </nav>

        <div class="hidden md:flex items-center border rounded-full px-4 py-1 w-[350px]">
            <input type="text" id="buscadorHeader" class="w-full outline-none text-sm"
                   placeholder="Buscar productos..."
                   onkeydown="if(event.key==='Enter') buscar()">
            <i class="fa-solid fa-magnifying-glass cursor-pointer" onclick="buscar()"></i>
        </div>

        <div class="flex gap-3 text-xl items-center">
            <button class="md:hidden" onclick="toggleBuscadorMovil()">
                <i class="fa-solid fa-magnifying-glass"></i>
            </button>

            <c:choose>
                <c:when test="${not empty sessionScope.usuario}">
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
                                <a href="${pageContext.request.contextPath}/perfil"
                                   class="flex items-center gap-3 px-4 py-3 text-sm text-gray-700 hover:bg-red-50 hover:text-red-600 transition">
                                    <i class="fa-solid fa-user"></i> Mi perfil
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
            <button class="md:hidden text-2xl" onclick="toggleMenu()">
                <ion-icon name="menu-outline" id="iconMenu"></ion-icon>
            </button>
        </div>
    </div>

    <div id="buscadorMovil" class="hidden px-4 pb-3 md:hidden">
        <div class="flex items-center border rounded-full px-4 py-2 bg-gray-50">
            <input type="text" id="buscadorMovilInput" class="w-full outline-none text-sm bg-transparent"
                   placeholder="Buscar productos..."
                   onkeydown="if(event.key==='Enter') buscarMovil()">
            <i class="fa-solid fa-magnifying-glass cursor-pointer text-gray-400" onclick="buscarMovil()"></i>
        </div>
    </div>

    <!-- MENÚ MÓVIL con categorías dinámicas -->
    <div id="menuMovil" class="hidden md:hidden bg-white border-t shadow-lg z-50">
        <nav class="flex flex-col px-4 py-3 gap-1">
            <a href="${pageContext.request.contextPath}/home"
               class="px-4 py-3 rounded-lg hover:bg-red-50 hover:text-red-600 font-medium transition">Inicio</a>
            <a href="${pageContext.request.contextPath}/promociones"
               class="px-4 py-3 rounded-lg hover:bg-red-50 hover:text-red-600 font-medium transition">Promociones</a>
            <div>
                <button onclick="toggleCatMovil()"
                        class="w-full text-left px-4 py-3 rounded-lg hover:bg-red-50 hover:text-red-600 font-medium transition flex justify-between items-center">
                    Categoría <ion-icon name="chevron-down-outline" id="iconCat"></ion-icon>
                </button>
                <div id="catMovil" class="hidden flex flex-col pl-4 gap-1">
                    <c:forEach items="${categoriasNav}" var="cat">
                        <a href="${pageContext.request.contextPath}/categoria?id=${cat.id}"
                           class="px-4 py-2 text-sm font-semibold text-black hover:text-red-500 transition">
                            ${cat.nombre}
                        </a>
                    </c:forEach>
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

    <%-- MODAL GLOBAL — solo para clientes logueados --%>
    <c:if test="${sessionScope.rolNombre == 'CLIENTE' and not empty sessionScope.usuario}">
    <div id="modalEntregadoGlobal"
         class="fixed inset-0 bg-black/50 z-[9999] hidden items-center justify-center p-4">
        <div class="bg-white rounded-2xl shadow-2xl w-full max-w-md overflow-hidden">
            <div class="bg-green-500 px-6 py-5 text-center">
                <div class="w-16 h-16 bg-white rounded-full flex items-center justify-center mx-auto mb-3">
                    <i class="fa-solid fa-circle-check text-4xl text-green-500"></i>
                </div>
                <h2 class="text-xl font-bold text-white">¡Pedido entregado!</h2>
                <p class="text-green-100 text-sm mt-1">Pedido <strong>#<span id="modalPedidoIdGlobal">-</span></strong></p>
            </div>
            <div class="px-6 py-5 text-center">
                <p class="text-gray-700 text-sm mb-2">Tu pedido ha sido entregado exitosamente. ¡Que lo disfrutes!</p>
                <div class="bg-blue-50 border border-blue-100 rounded-xl px-4 py-3 mb-5 flex items-start gap-3 text-left">
                    <i class="fa-solid fa-envelope text-blue-500 mt-0.5"></i>
                    <p class="text-xs text-blue-700">Tu boleta en PDF ha sido enviada a tu correo. También puedes descargarla aquí.</p>
                </div>
                <div class="flex flex-col gap-2">
                    <a id="btnBoletaGlobal" href="#"
                       class="w-full bg-green-600 hover:bg-green-700 text-white font-bold py-2.5 rounded-xl transition flex items-center justify-center gap-2 text-sm">
                        <i class="fa-solid fa-file-pdf"></i> Descargar boleta PDF
                    </a>
                    <a href="${pageContext.request.contextPath}/historial"
                       class="w-full border border-gray-200 hover:bg-gray-50 text-gray-600 font-semibold py-2.5 rounded-xl transition flex items-center justify-center gap-2 text-sm">
                        <i class="fa-solid fa-list"></i> Ver mis pedidos
                    </a>
                    <button onclick="cerrarModalGlobal()"
                            class="w-full text-gray-400 hover:text-gray-600 text-xs py-1 transition">Cerrar</button>
                </div>
            </div>
        </div>
    </div>
    </c:if>

    <script src="https://cdn.tailwindcss.com"></script>
    <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
    <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>

    <script>
        function buscar() {
            var texto = document.getElementById('buscadorHeader').value.trim();
            if (texto) window.location.href = '${pageContext.request.contextPath}/buscar?q=' + encodeURIComponent(texto);
        }
        function buscarMovil() {
            var texto = document.getElementById('buscadorMovilInput').value.trim();
            if (texto) window.location.href = '${pageContext.request.contextPath}/buscar?q=' + encodeURIComponent(texto);
        }
        function toggleMenu() { document.getElementById('menuMovil').classList.toggle('hidden'); }
        function toggleBuscadorMovil() {
            var b = document.getElementById('buscadorMovil');
            b.classList.toggle('hidden');
            if (!b.classList.contains('hidden')) document.getElementById('buscadorMovilInput').focus();
        }
        function toggleCatMovil() { document.getElementById('catMovil').classList.toggle('hidden'); }
        function toggleClienteMenu() {
            document.getElementById('dropdownCliente').classList.toggle('hidden');
            document.getElementById('iconClienteMenu').classList.toggle('rotate-180');
        }
        document.addEventListener('click', function(e) {
            var menu = document.getElementById('clienteMenu');
            if (menu && !menu.contains(e.target)) {
                document.getElementById('dropdownCliente').classList.add('hidden');
                document.getElementById('iconClienteMenu').classList.remove('rotate-180');
            }
        });

        // ── POLLING GLOBAL ────────────────────────────────────────────────────
        <c:if test="${sessionScope.rolNombre == 'CLIENTE' and not empty sessionScope.usuario}">
        (function() {
            var contextPath = '${pageContext.request.contextPath}';
            var pedidoActivoId = localStorage.getItem('pedido_activo_id');
            if (!pedidoActivoId) return;
            var storageKey = 'modal_pedido_' + pedidoActivoId;
            if (localStorage.getItem(storageKey)) return;

            var intervaloGlobal = setInterval(function() {
                fetch(contextPath + '/api/estadoPedido?pedidoId=' + pedidoActivoId)
                    .then(function(r) { return r.json(); })
                    .then(function(data) {
                        if (!data.estado) return;
                        if (data.estado === 'Entregado' && !localStorage.getItem(storageKey)) {
                            clearInterval(intervaloGlobal);
                            localStorage.removeItem('pedido_activo_id');
                            mostrarModalGlobal(pedidoActivoId);
                        } else if (data.estado === 'Cancelado') {
                            clearInterval(intervaloGlobal);
                            localStorage.removeItem('pedido_activo_id');
                        }
                    })
                    .catch(function() {});
            }, 5000);
        })();

        function mostrarModalGlobal(pedidoId) {
            localStorage.setItem('modal_pedido_' + pedidoId, 'visto');
            document.getElementById('modalPedidoIdGlobal').textContent = pedidoId;
            document.getElementById('btnBoletaGlobal').href =
                '${pageContext.request.contextPath}/boleta?pedidoId=' + pedidoId;
            var modal = document.getElementById('modalEntregadoGlobal');
            modal.classList.remove('hidden');
            modal.classList.add('flex');
        }
        function cerrarModalGlobal() {
            var modal = document.getElementById('modalEntregadoGlobal');
            modal.classList.add('hidden');
            modal.classList.remove('flex');
        }
        </c:if>
    </script>
</header>
