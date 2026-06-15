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
    <title>Pedido Confirmado - El Dorado</title>
</head>
<body class="bg-gray-50 min-h-screen">

    <jsp:include page="/components/header.jsp"/>

    <div class="max-w-5xl mx-auto px-4 py-6">

        <!-- FILA SUPERIOR: éxito + detalle del pedido -->
        <div class="flex flex-col lg:flex-row gap-4 mb-4">

            <!-- ÉXITO + NÚMERO -->
            <div class="bg-white rounded-2xl shadow-sm p-6 flex flex-col items-center justify-center text-center lg:w-64 flex-shrink-0">
                <div class="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mb-3">
                    <i class="fa-solid fa-circle-check text-4xl text-green-500"></i>
                </div>
                <h1 class="text-xl font-bold text-gray-800 mb-1">¡Pedido confirmado!</h1>
                <p class="text-gray-400 text-xs mb-3">Tu pedido está siendo procesado.</p>
                <div class="bg-gray-50 rounded-xl px-5 py-2">
                    <p class="text-xs text-gray-400">Número de pedido</p>
                    <p class="text-2xl font-bold text-red-600">#${pedido.id}</p>
                </div>
            </div>

            <!-- DETALLE DEL PEDIDO -->
            <div class="bg-white rounded-2xl shadow-sm p-6 flex-1">
                <h2 class="text-base font-semibold mb-3">
                    <i class="fa-solid fa-receipt text-red-600 mr-2"></i>Detalle del pedido
                </h2>
                <div class="flex flex-col gap-1 mb-3 max-h-36 overflow-y-auto pr-1">
                    <c:forEach items="${detalles}" var="d">
                        <div class="flex justify-between items-start py-1.5 border-b border-gray-50">
                            <div>
                                <p class="font-medium text-sm">${d.productoNombre} x${d.cantidad}</p>
                                <c:if test="${not empty d.opciones}">
                                    <p class="text-xs text-gray-400">${d.opciones}</p>
                                </c:if>
                            </div>
                            <span class="font-bold text-sm text-gray-700 ml-4">
                                S/<fmt:formatNumber value="${d.subtotal}" pattern="#,##0.00"/>
                            </span>
                        </div>
                    </c:forEach>
                </div>
                <div class="flex justify-between font-bold text-base text-gray-800 pt-1">
                    <span>Total pagado</span>
                    <span class="text-red-600">S/<fmt:formatNumber value="${pedido.total}" pattern="#,##0.00"/></span>
                </div>
            </div>
        </div>

        <!-- FILA MEDIA: info pago + dirección -->
        <div class="flex flex-col lg:flex-row gap-4 mb-4">

            <!-- INFO PAGO -->
            <div class="bg-white rounded-2xl shadow-sm p-6 flex-1">
                <h2 class="text-base font-semibold mb-3">
                    <i class="fa-solid fa-wallet text-red-600 mr-2"></i>Información del pago
                </h2>
                <div class="grid grid-cols-2 gap-3 text-sm">
                    <div>
                        <p class="text-gray-400 text-xs">Método</p>
                        <p class="font-semibold">${pago.metodo}</p>
                    </div>
                    <div>
                        <p class="text-gray-400 text-xs">Estado pago</p>
                        <span class="bg-green-100 text-green-600 text-xs font-bold px-2 py-0.5 rounded-full">
                            ${pago.estado}
                        </span>
                    </div>
                    <div>
                        <p class="text-gray-400 text-xs">Referencia</p>
                        <p class="font-semibold">${pago.referencia}</p>
                    </div>
                    <div>
                        <p class="text-gray-400 text-xs">Estado del pedido</p>
                        <span id="badgeEstado" class="text-xs font-bold px-2 py-0.5 rounded-full
                            ${pedido.estado == 'Pendiente'     ? 'bg-yellow-100 text-yellow-600' :
                              pedido.estado == 'En cocina'     ? 'bg-orange-100 text-orange-600' :
                              pedido.estado == 'Por despachar' ? 'bg-blue-100 text-blue-600'     :
                              pedido.estado == 'Entregado'     ? 'bg-green-100 text-green-600'   :
                                                                 'bg-red-100 text-red-600'}">
                            ${pedido.estado}
                        </span>
                    </div>
                </div>
            </div>

            <!-- DIRECCIÓN DE ENTREGA -->
            <div class="bg-white rounded-2xl shadow-sm p-6 flex-1">
                <h2 class="text-base font-semibold mb-3">
                    <i class="fa-solid fa-location-dot text-red-600 mr-2"></i>Dirección de entrega
                </h2>
                <c:choose>
                    <c:when test="${not empty pedido.direccion}">
                        <div class="bg-red-50 border border-red-100 rounded-xl p-3 flex items-start gap-3">
                            <i class="fa-solid fa-map-pin text-red-400 mt-0.5"></i>
                            <p class="text-sm text-gray-700 leading-relaxed">${pedido.direccion}</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <p class="text-sm text-gray-400 italic">No se registró dirección para este pedido.</p>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- SEGUIMIENTO -->
        <div class="bg-white rounded-2xl shadow-sm p-6 mb-4">
            <h2 class="text-base font-semibold mb-5">
                <i class="fa-solid fa-timeline text-red-600 mr-2"></i>Seguimiento del pedido
            </h2>
            <div class="relative flex items-center justify-between">
                <div class="absolute top-4 left-0 right-0 h-1 bg-gray-200 z-0"></div>
                <div id="barraProgreso" class="absolute top-4 left-0 h-1 bg-red-500 z-0 transition-all duration-500"
                     style="width: ${pedido.estado == 'Pendiente' ? '0%' :
                                     pedido.estado == 'En cocina' ? '33%' :
                                     pedido.estado == 'Por despachar' ? '66%' :
                                     pedido.estado == 'Entregado' ? '100%' : '0%'}">
                </div>

                <div class="flex flex-col items-center gap-2 z-10">
                    <div id="paso1" class="w-10 h-10 rounded-full flex items-center justify-center bg-red-600 text-white shadow-lg shadow-red-200">
                        <i class="fa-solid fa-clock text-sm"></i>
                    </div>
                    <p class="text-xs text-gray-500 text-center w-16">Pendiente</p>
                </div>

                <div class="flex flex-col items-center gap-2 z-10">
                    <div id="paso2" class="w-10 h-10 rounded-full flex items-center justify-center
                         ${pedido.estado == 'En cocina' || pedido.estado == 'Por despachar' || pedido.estado == 'Entregado'
                         ? 'bg-red-600 text-white shadow-lg shadow-red-200' : 'bg-gray-200 text-gray-400'}">
                        <i class="fa-solid fa-fire text-sm"></i>
                    </div>
                    <p class="text-xs text-gray-500 text-center w-16">En cocina</p>
                </div>

                <div class="flex flex-col items-center gap-2 z-10">
                    <div id="paso3" class="w-10 h-10 rounded-full flex items-center justify-center
                         ${pedido.estado == 'Por despachar' || pedido.estado == 'Entregado'
                         ? 'bg-red-600 text-white shadow-lg shadow-red-200' : 'bg-gray-200 text-gray-400'}">
                        <i class="fa-solid fa-motorcycle text-sm"></i>
                    </div>
                    <p class="text-xs text-gray-500 text-center w-16">Despachando</p>
                </div>

                <div class="flex flex-col items-center gap-2 z-10">
                    <div id="paso4" class="w-10 h-10 rounded-full flex items-center justify-center
                         ${pedido.estado == 'Entregado'
                        ? 'bg-green-500 text-white shadow-lg shadow-green-200' : 'bg-gray-200 text-gray-400'}">
                        <i class="fa-solid fa-check text-sm"></i>
                    </div>
                    <p class="text-xs text-gray-500 text-center w-16">Entregado</p>
                </div>
            </div>
        </div>

        <!-- BOTONES -->
        <div class="flex gap-3 flex-wrap">
            <a href="${pageContext.request.contextPath}/home"
               class="flex-1 bg-red-600 hover:bg-red-700 text-white font-bold py-3 rounded-xl transition text-center">
                <i class="fa-solid fa-home mr-2"></i>Volver al inicio
            </a>
            <a href="${pageContext.request.contextPath}/historial"
               class="flex-1 border border-gray-200 hover:bg-gray-50 text-gray-600 font-semibold py-3 rounded-xl transition text-center text-sm flex items-center justify-center gap-2">
                <i class="fa-solid fa-list"></i> Mis pedidos
            </a>
        </div>

    </div>

    <!-- MODAL PEDIDO ENTREGADO -->
    <div id="modalEntregado"
         class="fixed inset-0 bg-black/50 z-50 hidden items-center justify-center p-4">
        <div class="bg-white rounded-2xl shadow-2xl w-full max-w-md overflow-hidden">
            <div class="bg-green-500 px-6 py-5 text-center">
                <div class="w-16 h-16 bg-white rounded-full flex items-center justify-center mx-auto mb-3">
                    <i class="fa-solid fa-circle-check text-4xl text-green-500"></i>
                </div>
                <h2 class="text-xl font-bold text-white">¡Pedido entregado!</h2>
                <p class="text-green-100 text-sm mt-1">Pedido <strong>#${pedido.id}</strong></p>
            </div>
            <div class="px-6 py-5 text-center">
                <p class="text-gray-700 text-sm mb-2">Tu pedido ha sido entregado exitosamente. ¡Que lo disfrutes!</p>
                <div class="bg-blue-50 border border-blue-100 rounded-xl px-4 py-3 mb-5 flex items-start gap-3 text-left">
                    <i class="fa-solid fa-envelope text-blue-500 mt-0.5"></i>
                    <p class="text-xs text-blue-700">
                        Tu boleta en PDF ha sido enviada a tu correo electrónico.
                        También puedes descargarla directamente aquí.
                    </p>
                </div>
                <div class="flex flex-col gap-2">
                    <a href="${pageContext.request.contextPath}/boleta?pedidoId=${pedido.id}"
                       class="w-full bg-green-600 hover:bg-green-700 text-white font-bold py-2.5 rounded-xl transition flex items-center justify-center gap-2 text-sm">
                        <i class="fa-solid fa-file-pdf"></i> Descargar boleta PDF
                    </a>
                    <a href="${pageContext.request.contextPath}/historial"
                       class="w-full border border-gray-200 hover:bg-gray-50 text-gray-600 font-semibold py-2.5 rounded-xl transition flex items-center justify-center gap-2 text-sm">
                        <i class="fa-solid fa-list"></i> Ver mis pedidos
                    </a>
                    <button onclick="cerrarModal()"
                            class="w-full text-gray-400 hover:text-gray-600 text-xs py-1 transition">
                        Cerrar
                    </button>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="/components/footer.jsp"/>

    <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
    <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>

    <script>
        var pedidoId     = ${pedido.id};
        var contextPath  = '${pageContext.request.contextPath}';
        var estadoActual = '${pedido.estado}';
        var modalMostrado = false;
        var intervalo;
        var storageKey = 'modal_pedido_' + pedidoId;

        if (estadoActual === 'Entregado' && !localStorage.getItem(storageKey)) {
            mostrarModal();
        } else if (estadoActual !== 'Entregado') {
            intervalo = setInterval(consultarEstado, 5000);
        }

        function consultarEstado() {
            fetch(contextPath + '/api/estadoPedido?pedidoId=' + pedidoId)
                .then(function(r) { return r.json(); })
                .then(function(data) {
                    if (!data.estado) return;
                    actualizarBadge(data.estado);
                    actualizarSeguimiento(data.estado);
                    if (data.estado === 'Entregado' && !modalMostrado && !localStorage.getItem(storageKey)) {
                        clearInterval(intervalo);
                        mostrarModal();
                    }
                })
                .catch(function() {});
        }

        function actualizarBadge(estado) {
            var badge = document.getElementById('badgeEstado');
            badge.textContent = estado;
            badge.className = 'text-xs font-bold px-2 py-0.5 rounded-full ';
            if      (estado === 'Pendiente')     badge.className += 'bg-yellow-100 text-yellow-600';
            else if (estado === 'En cocina')     badge.className += 'bg-orange-100 text-orange-600';
            else if (estado === 'Por despachar') badge.className += 'bg-blue-100 text-blue-600';
            else if (estado === 'Entregado')     badge.className += 'bg-green-100 text-green-600';
            else                                 badge.className += 'bg-red-100 text-red-600';
        }

        function actualizarSeguimiento(estado) {
            var activo   = 'bg-red-600 text-white shadow-lg shadow-red-200';
            var inactivo = 'bg-gray-200 text-gray-400';
            var verde    = 'bg-green-500 text-white shadow-lg shadow-green-200';
            var base     = 'w-10 h-10 rounded-full flex items-center justify-center ';

            document.getElementById('paso1').className = base + activo;

            if (estado === 'Pendiente') {
                document.getElementById('paso2').className = base + inactivo;
                document.getElementById('paso3').className = base + inactivo;
                document.getElementById('paso4').className = base + inactivo;
                document.getElementById('barraProgreso').style.width = '0%';
            } else if (estado === 'En cocina') {
                document.getElementById('paso2').className = base + activo;
                document.getElementById('paso3').className = base + inactivo;
                document.getElementById('paso4').className = base + inactivo;
                document.getElementById('barraProgreso').style.width = '33%';
            } else if (estado === 'Por despachar') {
                document.getElementById('paso2').className = base + activo;
                document.getElementById('paso3').className = base + activo;
                document.getElementById('paso4').className = base + inactivo;
                document.getElementById('barraProgreso').style.width = '66%';
            } else if (estado === 'Entregado') {
                document.getElementById('paso2').className = base + activo;
                document.getElementById('paso3').className = base + activo;
                document.getElementById('paso4').className = base + verde;
                document.getElementById('barraProgreso').style.width = '100%';
            }
        }

        function mostrarModal() {
            modalMostrado = true;
            localStorage.setItem(storageKey, 'visto');
            var modal = document.getElementById('modalEntregado');
            modal.classList.remove('hidden');
            modal.classList.add('flex');
        }

        function cerrarModal() {
            var modal = document.getElementById('modalEntregado');
            modal.classList.add('hidden');
            modal.classList.remove('flex');
        }

        window.addEventListener('beforeunload', function() {
            clearInterval(intervalo);
        });
    </script>
</body>
</html>