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
    <title>Chef - Pedidos</title>
    <style>
        /* Scroll horizontal táctil */
        .scroll-row {
            display: flex;
            gap: 16px;
            overflow-x: auto;
            padding-bottom: 12px;
            scroll-snap-type: x mandatory;
            -webkit-overflow-scrolling: touch;
            cursor: grab;
        }
        .scroll-row:active { cursor: grabbing; }
        .scroll-row::-webkit-scrollbar { height: 6px; }
        .scroll-row::-webkit-scrollbar-track { background: #f1f1f1; border-radius: 4px; }
        .scroll-row::-webkit-scrollbar-thumb { background: #d1d5db; border-radius: 4px; }

        /* Tarjeta fija ancho */
        .card-pedido {
            min-width: 280px;
            max-width: 280px;
            scroll-snap-align: start;
            flex-shrink: 0;
        }

        /* Animación nueva tarjeta */
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        .card-pedido { animation: fadeIn 0.3s ease; }

        /* Touch drag scroll */
        .scroll-row { user-select: none; }
    </style>
</head>
<body class="bg-gray-100 min-h-screen">
<div class="flex min-h-screen">

    <!-- SIDEBAR -->
    <aside class="w-56 bg-gray-900 text-white flex flex-col flex-shrink-0">
        <div class="p-5 border-b border-gray-700">
            <h1 class="text-lg font-bold text-orange-400">
                <i class="fa-solid fa-hat-chef mr-1"></i> Cocina
            </h1>
            <p class="text-xs text-gray-400 mt-1">${sessionScope.usuario.nombre}</p>
        </div>
        <nav class="flex flex-col p-4 gap-2 flex-1">
            <a href="${pageContext.request.contextPath}/chef/pedidos"
               class="flex items-center gap-3 px-4 py-2 rounded-lg bg-orange-500 text-white font-medium text-sm">
                <i class="fa-solid fa-fire-burner"></i> Pedidos
            </a>
            <a href="${pageContext.request.contextPath}/logout"
               class="flex items-center gap-3 px-4 py-2 rounded-lg hover:bg-red-700 transition text-red-400 text-sm mt-auto">
                <i class="fa-solid fa-right-from-bracket"></i> Salir
            </a>
        </nav>
    </aside>

    <!-- CONTENIDO -->
    <main class="flex-1 p-6 overflow-auto flex flex-col gap-8">

        <!-- Título + última actualización -->
        <div class="flex items-center justify-between">
            <h2 class="text-2xl font-bold text-gray-800">
                <i class="fa-solid fa-fire-burner text-orange-500 mr-2"></i>Pedidos
            </h2>
            <span class="text-xs text-gray-400" id="ultimaActualizacion"></span>
        </div>

        <!-- ALERTAS -->
        <c:if test="${not empty sessionScope.exito}">
            <div class="bg-green-100 text-green-700 px-4 py-3 rounded-lg">
                ${sessionScope.exito} <c:remove var="exito" scope="session"/>
            </div>
        </c:if>
        <c:if test="${not empty sessionScope.error}">
            <div class="bg-red-100 text-red-700 px-4 py-3 rounded-lg">
                ${sessionScope.error} <c:remove var="error" scope="session"/>
            </div>
        </c:if>

        <!-- ===== FILA 1: PENDIENTES ===== -->
        <div>
            <div class="flex items-center gap-3 mb-3">
                <span class="w-3 h-3 rounded-full bg-yellow-400 inline-block"></span>
                <h3 class="text-base font-bold text-gray-700 uppercase tracking-wide">
                    Pendientes
                </h3>
                <span class="bg-yellow-100 text-yellow-700 text-xs font-bold px-2 py-0.5 rounded-full">
                    <%-- Contar pendientes --%>
                    <c:set var="countPendiente" value="0"/>
                    <c:forEach items="${pedidos}" var="p">
                        <c:if test="${p.estado == 'Pendiente'}">
                            <c:set var="countPendiente" value="${countPendiente + 1}"/>
                        </c:if>
                    </c:forEach>
                    ${countPendiente}
                </span>
            </div>

            <div class="scroll-row" id="rowPendiente">
                <c:set var="hayPendiente" value="false"/>
                <c:forEach items="${pedidos}" var="p">
                    <c:if test="${p.estado == 'Pendiente'}">
                        <c:set var="hayPendiente" value="true"/>
                        <div class="card-pedido bg-white rounded-2xl shadow border-l-4 border-yellow-400 p-4 flex flex-col gap-3">

                            <!-- Header tarjeta -->
                            <div class="flex items-center justify-between">
                                <span class="font-bold text-gray-800 text-base">#${p.id}</span>
                                <div class="flex items-center gap-1">
                                    <c:choose>
                                        <c:when test="${empty p.direccion}">
                                            <span class="text-xs bg-green-100 text-green-700 px-2 py-0.5 rounded-full font-semibold">
                                                <i class="fa-solid fa-store"></i> Local
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-xs bg-blue-100 text-blue-700 px-2 py-0.5 rounded-full font-semibold">
                                                <i class="fa-solid fa-motorcycle"></i> Delivery
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <!-- Fecha y cliente -->
                            <div class="flex flex-col gap-0.5">
                                <p class="text-xs text-gray-400">
                                    <i class="fa-regular fa-clock mr-1"></i>${p.fecha}
                                </p>
                                <c:if test="${not empty p.usuarioNombre and not empty p.direccion}">
                                    <p class="text-xs text-gray-600 font-medium">
                                        <i class="fa-solid fa-user mr-1 text-gray-400"></i>${p.usuarioNombre}
                                    </p>
                                </c:if>
                            </div>

                            <!-- Divisor -->
                            <div class="border-t border-gray-100"></div>

                            <!-- Productos y opciones -->
                            <div class="flex flex-col gap-2 flex-1">
                                <c:forEach items="${p.detalles}" var="d">
                                    <div>
                                        <p class="text-sm font-semibold text-gray-800">
                                            <i class="fa-solid fa-drumstick-bite text-orange-400 mr-1"></i>
                                            ${d.productoNombre}
                                            <span class="text-xs text-gray-400 font-normal ml-1">x${d.cantidad}</span>
                                        </p>
                                        <c:if test="${not empty d.opciones}">
                                            <ul class="ml-4 mt-0.5 flex flex-col gap-0.5">
                                                <c:forEach items="${d.opciones}" var="op">
                                                    <li class="text-xs text-gray-500">
                                                        <i class="fa-solid fa-circle text-gray-300 text-[6px] mr-1 align-middle"></i>
                                                        ${op.nombreOpcion}
                                                    </li>
                                                </c:forEach>
                                            </ul>
                                        </c:if>
                                    </div>
                                </c:forEach>
                            </div>

                            <!-- Divisor -->
                            <div class="border-t border-gray-100"></div>

                            <!-- Botón acción -->
                            <form action="${pageContext.request.contextPath}/chef/pedidos" method="post">
                                <input type="hidden" name="id" value="${p.id}">
                                <input type="hidden" name="estado" value="En cocina">
                                <button type="submit"
                                        class="w-full bg-orange-500 hover:bg-orange-600 active:scale-95 text-white px-3 py-2 rounded-xl text-sm font-bold transition-all">
                                    <i class="fa-solid fa-fire mr-1"></i> Iniciar a cocinar
                                </button>
                            </form>

                        </div>
                    </c:if>
                </c:forEach>

                <!-- Sin pendientes -->
                <c:if test="${!hayPendiente}">
                    <div class="bg-white rounded-2xl shadow px-8 py-6 text-center text-gray-400 w-full">
                        <i class="fa-solid fa-check-circle text-3xl text-green-400 mb-2"></i>
                        <p class="text-sm">Sin pedidos pendientes</p>
                    </div>
                </c:if>
            </div>
        </div>

        <!-- ===== FILA 2: EN COCINA ===== -->
        <div>
            <div class="flex items-center gap-3 mb-3">
                <span class="w-3 h-3 rounded-full bg-orange-500 inline-block"></span>
                <h3 class="text-base font-bold text-gray-700 uppercase tracking-wide">
                    En Cocina
                </h3>
                <span class="bg-orange-100 text-orange-700 text-xs font-bold px-2 py-0.5 rounded-full">
                    <c:set var="countCocina" value="0"/>
                    <c:forEach items="${pedidos}" var="p">
                        <c:if test="${p.estado == 'En cocina'}">
                            <c:set var="countCocina" value="${countCocina + 1}"/>
                        </c:if>
                    </c:forEach>
                    ${countCocina}
                </span>
            </div>

            <div class="scroll-row" id="rowCocina">
                <c:set var="hayCocina" value="false"/>
                <c:forEach items="${pedidos}" var="p">
                    <c:if test="${p.estado == 'En cocina'}">
                        <c:set var="hayCocina" value="true"/>
                        <div class="card-pedido bg-white rounded-2xl shadow border-l-4 border-orange-500 p-4 flex flex-col gap-3">

                            <!-- Header tarjeta -->
                            <div class="flex items-center justify-between">
                                <span class="font-bold text-gray-800 text-base">#${p.id}</span>
                                <div class="flex items-center gap-1">
                                    <c:choose>
                                        <c:when test="${empty p.direccion}">
                                            <span class="text-xs bg-green-100 text-green-700 px-2 py-0.5 rounded-full font-semibold">
                                                <i class="fa-solid fa-store"></i> Local
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-xs bg-blue-100 text-blue-700 px-2 py-0.5 rounded-full font-semibold">
                                                <i class="fa-solid fa-motorcycle"></i> Delivery
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <!-- Fecha y cliente -->
                            <div class="flex flex-col gap-0.5">
                                <p class="text-xs text-gray-400">
                                    <i class="fa-regular fa-clock mr-1"></i>${p.fecha}
                                </p>
                                <c:if test="${not empty p.usuarioNombre and not empty p.direccion}">
                                    <p class="text-xs text-gray-600 font-medium">
                                        <i class="fa-solid fa-user mr-1 text-gray-400"></i>${p.usuarioNombre}
                                    </p>
                                </c:if>
                            </div>

                            <!-- Divisor -->
                            <div class="border-t border-gray-100"></div>

                            <!-- Productos y opciones -->
                            <div class="flex flex-col gap-2 flex-1">
                                <c:forEach items="${p.detalles}" var="d">
                                    <div>
                                        <p class="text-sm font-semibold text-gray-800">
                                            <i class="fa-solid fa-drumstick-bite text-orange-400 mr-1"></i>
                                            ${d.productoNombre}
                                            <span class="text-xs text-gray-400 font-normal ml-1">x${d.cantidad}</span>
                                        </p>
                                        <c:if test="${not empty d.opciones}">
                                            <ul class="ml-4 mt-0.5 flex flex-col gap-0.5">
                                                <c:forEach items="${d.opciones}" var="op">
                                                    <li class="text-xs text-gray-500">
                                                        <i class="fa-solid fa-circle text-gray-300 text-[6px] mr-1 align-middle"></i>
                                                        ${op.nombreOpcion}
                                                    </li>
                                                </c:forEach>
                                            </ul>
                                        </c:if>
                                    </div>
                                </c:forEach>
                            </div>

                            <!-- Divisor -->
                            <div class="border-t border-gray-100"></div>

                            <!-- Botón acción -->
                            <form action="${pageContext.request.contextPath}/chef/pedidos" method="post">
                                <input type="hidden" name="id" value="${p.id}">
                                <input type="hidden" name="estado" value="Por despachar">
                                <button type="submit"
                                        class="w-full bg-blue-500 hover:bg-blue-600 active:scale-95 text-white px-3 py-2 rounded-xl text-sm font-bold transition-all">
                                    <i class="fa-solid fa-box mr-1"></i> Listo para despachar
                                </button>
                            </form>

                        </div>
                    </c:if>
                </c:forEach>

                <!-- Sin pedidos en cocina -->
                <c:if test="${!hayCocina}">
                    <div class="bg-white rounded-2xl shadow px-8 py-6 text-center text-gray-400 w-full">
                        <i class="fa-solid fa-fire text-3xl text-orange-300 mb-2"></i>
                        <p class="text-sm">Sin pedidos en cocina</p>
                    </div>
                </c:if>
            </div>
        </div>

    </main>
</div>

<script>
    // Mostrar hora de última actualización
    document.getElementById('ultimaActualizacion').textContent =
        'Actualizado: ' + new Date().toLocaleTimeString('es-PE');

    // Drag scroll táctil en desktop
    document.querySelectorAll('.scroll-row').forEach(row => {
        let isDown = false, startX, scrollLeft;

        row.addEventListener('mousedown', e => {
            isDown = true;
            startX = e.pageX - row.offsetLeft;
            scrollLeft = row.scrollLeft;
        });
        row.addEventListener('mouseleave', () => isDown = false);
        row.addEventListener('mouseup', () => isDown = false);
        row.addEventListener('mousemove', e => {
            if (!isDown) return;
            e.preventDefault();
            const x = e.pageX - row.offsetLeft;
            row.scrollLeft = scrollLeft - (x - startX) * 1.5;
        });
    });
</script>

</body>
</html>