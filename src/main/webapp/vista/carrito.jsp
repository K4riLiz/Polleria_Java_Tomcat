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
    <title>Mi Carrito - El Dorado</title>
</head>
<body class="bg-gray-50 min-h-screen">

    <jsp:include page="/components/header.jsp"/>

    <div class="max-w-5xl mx-auto px-4 py-10">

        <h1 class="text-2xl font-bold text-gray-800 mb-8 flex items-center gap-3">
            <i class="fa-solid fa-cart-shopping text-red-600"></i> Mi Carrito
        </h1>

        <c:choose>
            <c:when test="${empty sessionScope.carrito}">
                <!-- CARRITO VACÍO -->
                <div class="bg-white rounded-2xl shadow-sm p-16 text-center">
                    <i class="fa-solid fa-cart-shopping text-7xl text-gray-200 mb-6"></i>
                    <h2 class="text-xl font-semibold text-gray-400 mb-2">Tu carrito está vacío</h2>
                    <p class="text-gray-400 text-sm mb-8">Agrega productos desde nuestro menú</p>
                    <a href="${pageContext.request.contextPath}/home"
                       class="bg-red-600 hover:bg-red-700 text-white font-semibold px-8 py-3 rounded-xl transition inline-block">
                        Ver menú
                    </a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="flex flex-col lg:flex-row gap-6">

                    <!-- LISTA DE ITEMS -->
                    <div class="flex-1 flex flex-col gap-4">

                        <c:forEach items="${sessionScope.carrito}" var="item">
                            <div class="bg-white rounded-2xl shadow-sm overflow-hidden flex items-center gap-4 p-4">

                                <!-- Imagen -->
                                <img src="${pageContext.request.contextPath}/img/${item.imagen}"
                                     class="w-20 h-20 object-cover rounded-xl flex-shrink-0"
                                     onerror="this.src='${pageContext.request.contextPath}/img/pollobrasa.png'">

                                <!-- Info -->
                                <div class="flex-1">
                                    <h3 class="font-semibold text-gray-800">${item.nombre}</h3>
                                    <c:if test="${not empty item.opciones}">
                                        <p class="text-xs text-gray-400 mt-1">${item.opciones}</p>
                                    </c:if>
                                    <p class="text-xs text-gray-400 capitalize">${item.tipo}</p>
                                    <p class="text-red-600 font-bold mt-1">
                                        S/<fmt:formatNumber value="${item.precio}" pattern="#,##0.00"/>
                                    </p>
                                </div>

                                <!-- Cantidad -->
                                <form action="${pageContext.request.contextPath}/carrito"
                                      method="post" class="flex items-center gap-2">
                                    <input type="hidden" name="action" value="actualizar">
                                    <input type="hidden" name="productoId" value="${item.productoId}">
                                    <input type="hidden" name="tipo" value="${item.tipo}">
                                    <button type="submit" name="cantidad" value="${item.cantidad - 1}"
                                            class="w-8 h-8 rounded-full border-2 border-red-500 text-red-500 hover:bg-red-500 hover:text-white font-bold transition flex items-center justify-center">
                                        −
                                    </button>
                                    <span class="w-8 text-center font-bold text-gray-800">${item.cantidad}</span>
                                    <button type="submit" name="cantidad" value="${item.cantidad + 1}"
                                            class="w-8 h-8 rounded-full border-2 border-red-500 text-red-500 hover:bg-red-500 hover:text-white font-bold transition flex items-center justify-center">
                                        +
                                    </button>
                                </form>

                                <!-- Subtotal -->
                                <div class="text-right min-w-[80px]">
                                    <p class="text-xs text-gray-400">Subtotal</p>
                                    <p class="font-bold text-gray-800">
                                        S/<fmt:formatNumber value="${item.subtotal}" pattern="#,##0.00"/>
                                    </p>
                                </div>

                                <!-- Eliminar -->
                                <a href="${pageContext.request.contextPath}/carrito?action=eliminar&productoId=${item.productoId}&tipo=${item.tipo}"
                                   class="text-gray-300 hover:text-red-500 transition ml-2"
                                   title="Eliminar">
                                    <i class="fa-solid fa-xmark text-lg"></i>
                                </a>

                            </div>
                        </c:forEach>

                        <!-- VACIAR CARRITO -->
                        <div class="flex justify-end">
                            <a href="${pageContext.request.contextPath}/carrito?action=vaciar"
                               class="text-sm text-gray-400 hover:text-red-500 transition"
                               onclick="return confirm('¿Vaciar el carrito?')">
                                <i class="fa-solid fa-trash mr-1"></i> Vaciar carrito
                            </a>
                        </div>
                    </div>

                    <!-- RESUMEN -->
                    <div class="lg:w-80 flex-shrink-0">
                        <div class="bg-white rounded-2xl shadow-sm p-6 sticky top-4">
                            <h2 class="text-lg font-bold text-gray-800 mb-4">Resumen del pedido</h2>

                            <div class="flex flex-col gap-2 mb-4">
                                <c:set var="total" value="0"/>
                                <c:forEach items="${sessionScope.carrito}" var="item">
                                    <c:set var="total" value="${total + item.subtotal}"/>
                                    <div class="flex justify-between text-sm text-gray-500">
                                        <span>${item.nombre} x${item.cantidad}</span>
                                        <span>S/<fmt:formatNumber value="${item.subtotal}" pattern="#,##0.00"/></span>
                                    </div>
                                </c:forEach>
                            </div>

                            <div class="border-t pt-4 mb-6">
                                <div class="flex justify-between font-bold text-gray-800 text-lg">
                                    <span>Total</span>
                                    <span class="text-red-600">
                                        S/<fmt:formatNumber value="${total}" pattern="#,##0.00"/>
                                    </span>
                                </div>
                            </div>

                            <c:choose>
                                <c:when test="${not empty sessionScope.usuario}">
                                    <a href="${pageContext.request.contextPath}/checkout"
                                        class="w-full bg-red-600 hover:bg-red-700 text-white font-bold py-3 rounded-xl transition flex items-center justify-center gap-2">
                                        <i class="fa-solid fa-lock"></i> Realizar pedido
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <a href="${pageContext.request.contextPath}/login"
                                       class="w-full bg-red-600 hover:bg-red-700 text-white font-bold py-3 rounded-xl transition flex items-center justify-center gap-2 text-center block">
                                        <i class="fa-solid fa-user"></i> Inicia sesión para pedir
                                    </a>
                                </c:otherwise>
                            </c:choose>

                            <a href="${pageContext.request.contextPath}/home"
                               class="w-full mt-3 border border-gray-200 hover:bg-gray-50 text-gray-600 font-semibold py-3 rounded-xl transition flex items-center justify-center gap-2 text-sm">
                                <i class="fa-solid fa-arrow-left"></i> Seguir comprando
                            </a>
                        </div>
                    </div>

                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <jsp:include page="/components/footer.jsp"/>

    <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
    <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
</body>
</html>
