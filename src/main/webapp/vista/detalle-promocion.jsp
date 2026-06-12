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
    <title>${promocion.nombre} - El Dorado</title>
    <style>
        .opcion-item input[type="radio"] { display: none; }
        .opcion-item input[type="radio"]:checked + label {
            border-color: #c0392b; background-color: #fff5f5;
            color: #c0392b; font-weight: 600;
        }
        .opcion-item label {
            cursor: pointer; transition: all 0.2s; display: block;
            border: 2px solid #e5e7eb; border-radius: 10px;
            padding: 10px 16px; font-size: 14px;
        }
        .opcion-item label:hover { border-color: #f87171; }
        .chevron { transition: transform 0.3s; }
        .chevron.abierto { transform: rotate(180deg); }
        .contenido-opcion { overflow: hidden; transition: max-height 0.35s ease; }
        .btn-cantidad {
            width: 36px; height: 36px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 20px; font-weight: bold; cursor: pointer;
            border: 2px solid #c0392b; color: #c0392b; background: white;
            transition: all 0.2s;
        }
        .btn-cantidad:hover { background: #c0392b; color: white; }
    </style>
</head>
<body class="bg-gray-50 min-h-screen">

    <jsp:include page="/components/header.jsp"/>

    <!-- BREADCRUMB -->
    <div class="max-w-5xl mx-auto px-4 py-3 text-sm text-gray-400 flex items-center gap-2">
        <a href="${pageContext.request.contextPath}/home" class="hover:text-red-600">Inicio</a>
        <span>/</span>
        <a href="${pageContext.request.contextPath}/promociones" class="hover:text-red-600">Promociones</a>
        <span>/</span>
        <span class="text-gray-700 font-medium">${promocion.nombre}</span>
    </div>

    <!-- VOLVER -->
    <div class="max-w-5xl mx-auto px-4 mb-3">
        <a href="${pageContext.request.contextPath}/promociones"
           class="inline-flex items-center gap-2 text-sm text-gray-500 hover:text-red-600 transition font-medium">
            <i class="fa-solid fa-arrow-left text-xs"></i> Volver a Promociones
        </a>
    </div>

    <!-- CONTENIDO -->
    <div class="max-w-5xl mx-auto px-4 pb-20">
        <div class="bg-white rounded-2xl shadow-sm overflow-hidden flex flex-col md:flex-row">

            <!-- IMAGEN -->
            <div class="md:w-1/2 relative min-h-[280px]">
                <img src="${pageContext.request.contextPath}/img/${promocion.imagen}"
                     alt="${promocion.nombre}"
                     class="w-full h-full object-cover min-h-[280px]">
                <span class="absolute top-4 left-4 bg-red-600 text-white text-xs font-bold px-3 py-1 rounded-full uppercase">
                     Promoción
                </span>
            </div>

            <!-- INFO -->
            <div class="md:w-1/2 p-6 md:p-8 flex flex-col gap-5">

                <div>
                    <h1 class="text-2xl font-bold text-gray-800 mb-1">${promocion.nombre}</h1>
                    <p class="text-gray-500 text-sm leading-relaxed mb-3">${promocion.descripcion}</p>
                    <p class="text-3xl font-bold text-red-600">
                        S/ <fmt:formatNumber value="${promocion.precio}" pattern="#,##0.00"/>
                    </p>
                </div>

                <p class="text-xs text-gray-400 italic">
                    Por favor, elige tus opciones para continuar con tu pedido.
                </p>

                <!-- OPCIONES -->
                <div class="border border-gray-100 rounded-xl overflow-hidden divide-y divide-gray-100">

                    <!-- Pollo — siempre fijo -->
                    <div>
                        <div class="flex items-center justify-between px-4 py-3 bg-red-600 text-white cursor-pointer select-none" onclick="toggle(this)">
                            <div class="flex items-center gap-2 text-sm font-semibold">
                                <i class="fa-solid fa-drumstick-bite"></i> Pollo
                                <span class="text-xs bg-white/20 px-2 py-0.5 rounded-full">Obligatorio</span>
                            </div>
                            <i class="fa-solid fa-chevron-down chevron abierto text-sm"></i>
                        </div>
                        <div class="contenido-opcion" style="max-height:200px">
                            <div class="p-4 flex flex-col gap-2">
                                <div class="opcion-item"><input type="radio" name="pollo" id="pierna" value="Pierna"><label for="pierna"> Pierna</label></div>
                                <div class="opcion-item"><input type="radio" name="pollo" id="pecho" value="Pecho"><label for="pecho"> Pecho</label></div>
                            </div>
                        </div>
                    </div>

                    <%-- Guarnición dinámica --%>
                    <c:set var="tieneGuarnicion" value="false"/>
                    <c:forEach var="op" items="${opciones}">
                        <c:if test="${op.grupo == 'Guarnición'}"><c:set var="tieneGuarnicion" value="true"/></c:if>
                    </c:forEach>

                    <c:if test="${tieneGuarnicion}">
                        <div>
                            <div class="flex items-center justify-between px-4 py-3 bg-yellow-500 text-white cursor-pointer select-none" onclick="toggle(this)">
                                <div class="flex items-center gap-2 text-sm font-semibold">
                                    <i class="fa-solid fa-leaf"></i> Guarnición
                                </div>
                                <i class="fa-solid fa-chevron-down chevron abierto text-sm"></i>
                            </div>
                            <div class="contenido-opcion" style="max-height:300px">
                                <div class="p-4 flex flex-col gap-2">
                                    <c:forEach var="op" items="${opciones}">
                                        <c:if test="${op.grupo == 'Guarnición'}">
                                            <div class="opcion-item">
                                                <input type="radio" name="guarnicion"
                                                       id="guar${op.id}"
                                                       value="${op.nombre}"
                                                       data-precio="${op.precioAdicional}">
                                                <label for="guar${op.id}">
                                                    ${op.nombre}
                                                    <c:if test="${op.precioAdicional > 0}">
                                                        <span class="text-red-500 text-xs ml-1">+S/ <fmt:formatNumber value="${op.precioAdicional}" pattern="#,##0.00"/></span>
                                                    </c:if>
                                                </label>
                                            </div>
                                        </c:if>
                                    </c:forEach>
                                </div>
                            </div>
                        </div>
                    </c:if>

                    <%-- Bebida dinámica --%>
                    <c:set var="tieneBebida" value="false"/>
                    <c:forEach var="op" items="${opciones}">
                        <c:if test="${op.grupo == 'Bebida'}"><c:set var="tieneBebida" value="true"/></c:if>
                    </c:forEach>

                    <c:if test="${tieneBebida}">
                        <div>
                            <div class="flex items-center justify-between px-4 py-3 bg-blue-500 text-white cursor-pointer select-none" onclick="toggle(this)">
                                <div class="flex items-center gap-2 text-sm font-semibold">
                                    <i class="fa-solid fa-bottle-water"></i> Bebida
                                    <span class="text-xs bg-white/20 px-2 py-0.5 rounded-full">Obligatorio</span>
                                </div>
                                <i class="fa-solid fa-chevron-down chevron abierto text-sm"></i>
                            </div>
                            <div class="contenido-opcion" style="max-height:300px">
                                <div class="p-4 flex flex-col gap-2">
                                    <c:forEach var="op" items="${opciones}">
                                        <c:if test="${op.grupo == 'Bebida'}">
                                            <div class="opcion-item">
                                                <input type="radio" name="bebida"
                                                       id="beb${op.id}"
                                                       value="${op.nombre}">
                                                <label for="beb${op.id}">${op.nombre}</label>
                                            </div>
                                        </c:if>
                                    </c:forEach>
                                </div>
                            </div>
                        </div>
                    </c:if>

                </div>

                <!-- COMENTARIO -->
                <div>
                    <label class="block text-sm font-medium text-gray-600 mb-1">
                        <i class="fa-regular fa-comment mr-1"></i> Comentario
                    </label>
                    <textarea rows="2" placeholder="¿Alguna indicación especial?"
                              class="w-full border border-gray-200 rounded-xl px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-300 resize-none"></textarea>
                </div>

                <!-- CANTIDAD + BOTÓN -->
                <div class="flex items-center gap-4 mt-auto">
                    <div class="flex items-center gap-3">
                        <button class="btn-cantidad" onclick="cambiarCantidad(-1)">−</button>
                        <span id="cantidad" class="text-xl font-bold w-8 text-center">1</span>
                        <button class="btn-cantidad" onclick="cambiarCantidad(1)">+</button>
                    </div>

                    <button onclick="agregarAlPedido()"
                            class="flex-1 bg-red-600 hover:bg-red-700 active:scale-95 text-white font-bold py-3 px-4 rounded-xl transition-all flex items-center justify-center gap-2 text-sm">
                        <i class="fa-solid fa-cart-plus"></i>
                        Añadir a mi pedido — S/ <span id="precioTotal"><fmt:formatNumber value="${promocion.precio}" pattern="#,##0.00"/></span>
                    </button>
                </div>

            </div>
        </div>
    </div>

    <jsp:include page="/components/footer.jsp"/>

    <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
    <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>

    <!-- FORM OCULTO -->
    <form id="formCarrito" action="${pageContext.request.contextPath}/carrito" method="post" style="display:none">
        <input type="hidden" name="action" value="agregar">
        <input type="hidden" name="productoId" value="${promocion.id}">
        <input type="hidden" name="nombre" value="${promocion.nombre}">
        <input type="hidden" name="precio" value="${promocion.precio}">
        <input type="hidden" name="imagen" value="${promocion.imagen}">
        <input type="hidden" name="tipo" value="promocion">
        <input type="hidden" name="cantidad" id="cantidadInput" value="1">
        <input type="hidden" name="opciones" id="opcionesInput" value="">
    </form>

    <script>
        const precioBase = ${promocion.precio};

        function agregarAlPedido() {
            let precioExtra = 0;

            const pollo = document.querySelector('input[name="pollo"]:checked');
            if (!pollo) { alert('Por favor selecciona el tipo de pollo.'); return; }

            const bebida = document.querySelector('input[name="bebida"]:checked');
            if (!bebida) { alert('Por favor selecciona una bebida.'); return; }

            const guarnicion = document.querySelector('input[name="guarnicion"]:checked');
            if (guarnicion) precioExtra += parseFloat(guarnicion.dataset.precio || 0);

            const opciones = [
                pollo.value,
                guarnicion ? guarnicion.value : null,
                bebida.value
            ].filter(Boolean).join(', ');

            const cantidad = parseInt(document.getElementById('cantidad').textContent);
            const precioFinal = (precioBase + precioExtra) * cantidad;
            document.getElementById('precioTotal').textContent = precioFinal.toFixed(2);
            document.getElementById('opcionesInput').value = opciones;
            document.querySelector('input[name="precio"]').value = (precioBase + precioExtra).toFixed(2);
            document.getElementById('formCarrito').submit();
        }

        function cambiarCantidad(delta) {
            const el = document.getElementById('cantidad');
            let v = parseInt(el.textContent) + delta;
            if (v < 1) v = 1;
            if (v > 20) v = 20;
            el.textContent = v;

            let precioExtra = 0;
            const guarnicion = document.querySelector('input[name="guarnicion"]:checked');
            if (guarnicion) precioExtra += parseFloat(guarnicion.dataset.precio || 0);

            document.getElementById('precioTotal').textContent = ((precioBase + precioExtra) * v).toFixed(2);
            document.getElementById('cantidadInput').value = v;
        }

        function toggle(header) {
            const content = header.nextElementSibling;
            const chevron = header.querySelector('.chevron');
            if (chevron.classList.contains('abierto')) {
                content.style.maxHeight = '0px';
                chevron.classList.remove('abierto');
            } else {
                content.style.maxHeight = '200px';
                chevron.classList.add('abierto');
            }
        }
    </script>
</body>
</html>