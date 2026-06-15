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

    <div class="max-w-2xl mx-auto px-4 py-12">

        <!-- ÉXITO -->
        <div class="bg-white rounded-2xl shadow-sm p-8 text-center mb-6">
            <div class="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <i class="fa-solid fa-circle-check text-5xl text-green-500"></i>
            </div>
            <h1 class="text-2xl font-bold text-gray-800 mb-2">¡Pedido confirmado!</h1>
            <p class="text-gray-500 text-sm mb-4">Tu pedido ha sido recibido y está siendo procesado.</p>
            <div class="bg-gray-50 rounded-xl px-6 py-3 inline-block">
                <p class="text-xs text-gray-400">Número de pedido</p>
                <p class="text-2xl font-bold text-red-600">#${pedido.id}</p>
            </div>
        </div>

        <!-- DETALLES DEL PEDIDO -->
        <div class="bg-white rounded-2xl shadow-sm p-6 mb-6">
            <h2 class="text-lg font-semibold mb-4">
                <i class="fa-solid fa-receipt text-red-600 mr-2"></i>Detalle del pedido
            </h2>
            <div class="flex flex-col gap-3 mb-4">
                <c:forEach items="${detalles}" var="d">
                    <div class="flex justify-between items-start py-2 border-b border-gray-50">
                        <div>
                            <p class="font-medium text-sm">${d.productoNombre} x${d.cantidad}</p>
                            <c:if test="${not empty d.opciones}">
                                <p class="text-xs text-gray-400">${d.opciones}</p>
                            </c:if>
                        </div>
                        <span class="font-bold text-sm text-gray-700">
                            S/<fmt:formatNumber value="${d.subtotal}" pattern="#,##0.00"/>
                        </span>
                    </div>
                </c:forEach>
            </div>
            <div class="flex justify-between font-bold text-lg text-gray-800 pt-2">
                <span>Total pagado</span>
                <span class="text-red-600">S/<fmt:formatNumber value="${pedido.total}" pattern="#,##0.00"/></span>
            </div>
        </div>

        <!-- INFO PAGO -->
        <div class="bg-white rounded-2xl shadow-sm p-6 mb-6">
            <h2 class="text-lg font-semibold mb-4">
                <i class="fa-solid fa-wallet text-red-600 mr-2"></i>Información del pago
            </h2>
            <div class="grid grid-cols-2 gap-4 text-sm">
                <div>
                    <p class="text-gray-400">Método</p>
                    <p class="font-semibold">${pago.metodo}</p>
                </div>
                <div>
                    <p class="text-gray-400">Estado</p>
                    <span class="bg-green-100 text-green-600 text-xs font-bold px-2 py-1 rounded-full">
                        ${pago.estado}
                    </span>
                </div>
                <div>
                    <p class="text-gray-400">Referencia</p>
                    <p class="font-semibold">${pago.referencia}</p>
                </div>
                <div>
                    <p class="text-gray-400">Estado del pedido</p>
                    <span class="bg-yellow-100 text-yellow-600 text-xs font-bold px-2 py-1 rounded-full">
                        ${pedido.estado}
                    </span>
                </div>
            </div>
        </div>

        <!-- SEGUIMIENTO -->
        <div class="bg-white rounded-2xl shadow-sm p-6 mb-6">
            <h2 class="text-lg font-semibold mb-6">
                <i class="fa-solid fa-timeline text-red-600 mr-2"></i>Seguimiento del pedido
            </h2>
            <div class="relative flex items-center justify-between">
                <!-- Línea base -->
                <div class="absolute top-4 left-0 right-0 h-1 bg-gray-200 z-0"></div>
                <!-- Línea progreso -->
                <div class="absolute top-4 left-0 h-1 bg-red-500 z-0 transition-all"
                     style="width:
                     ${pedido.estado == 'Pendiente'     ? '0%'   :
                        pedido.estado == 'En cocina'     ? '33%'  :
                        pedido.estado == 'Por despachar' ? '66%'  :
                        pedido.estado == 'Entregado'     ? '100%' : '0%'}">
                </div>

                <%-- Paso 1: Pendiente --%>
                <div class="flex flex-col items-center gap-2 z-10">
                    <div class="w-10 h-10 rounded-full flex items-center justify-center
                         ${pedido.estado == 'Pendiente' || pedido.estado == 'En cocina' || pedido.estado == 'Por despachar' || pedido.estado == 'Entregado'
                          ? 'bg-red-600 text-white shadow-lg shadow-red-200' : 'bg-gray-200 text-gray-400'}">
                        <i class="fa-solid fa-clock text-sm"></i>
                    </div>
                    <p class="text-xs text-gray-500 text-center w-16">Pendiente</p>
                </div>

                <%-- Paso 2: En cocina --%>
                <div class="flex flex-col items-center gap-2 z-10">
                    <div class="w-10 h-10 rounded-full flex items-center justify-center
                         ${pedido.estado == 'En cocina' || pedido.estado == 'Por despachar' || pedido.estado == 'Entregado'
                         ? 'bg-red-600 text-white shadow-lg shadow-red-200' : 'bg-gray-200 text-gray-400'}">
                        <i class="fa-solid fa-fire text-sm"></i>
                    </div>
                    <p class="text-xs text-gray-500 text-center w-16">En cocina</p>
                </div>

                <%-- Paso 3: Despachando --%>
                <div class="flex flex-col items-center gap-2 z-10">
                    <div class="w-10 h-10 rounded-full flex items-center justify-center
                         ${pedido.estado == 'Por despachar' || pedido.estado == 'Entregado'
                         ? 'bg-red-600 text-white shadow-lg shadow-red-200' : 'bg-gray-200 text-gray-400'}">
                        <i class="fa-solid fa-motorcycle text-sm"></i>
                    </div>
                    <p class="text-xs text-gray-500 text-center w-16">Despachando</p>
                </div>

                <%-- Paso 4: Entregado --%>
                <div class="flex flex-col items-center gap-2 z-10">
                    <div class="w-10 h-10 rounded-full flex items-center justify-center
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
            <!-- Volver al inicio -->
            <a href="${pageContext.request.contextPath}/home"
               class="flex-1 bg-red-600 hover:bg-red-700 text-white font-bold py-3 rounded-xl transition text-center">
                <i class="fa-solid fa-home mr-2"></i>Volver al inicio
            </a>

            <!-- Descargar boleta (de danna) -->
            <a href="${pageContext.request.contextPath}/boleta?pedidoId=${pedido.id}"
               class="flex-1 bg-green-600 hover:bg-green-700 text-white font-bold py-3 rounded-xl transition text-center flex items-center justify-center gap-2">
                <i class="fa-solid fa-file-pdf"></i> Descargar Boleta
            </a>

            <!-- Mis pedidos (tu ruta /historial) -->
            <a href="${pageContext.request.contextPath}/historial"
               class="flex-1 border border-gray-200 hover:bg-gray-50 text-gray-600 font-semibold py-3 rounded-xl transition text-center text-sm flex items-center justify-center gap-2">
                <i class="fa-solid fa-list"></i> Mis pedidos
            </a>
        </div>

    </div>

    <jsp:include page="/components/footer.jsp"/>

    <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
    <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
</body>
</html>