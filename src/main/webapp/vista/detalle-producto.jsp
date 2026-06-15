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
    <title>${producto.nombre} - El Dorado</title>
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
        .opciones-scroll {
            max-height: 320px;
            overflow-y: auto;
            scrollbar-width: thin;
            scrollbar-color: #f87171 #f3f4f6;
        }
        .opciones-scroll::-webkit-scrollbar { width: 4px; }
        .opciones-scroll::-webkit-scrollbar-track { background: #f3f4f6; border-radius: 4px; }
        .opciones-scroll::-webkit-scrollbar-thumb { background: #f87171; border-radius: 4px; }
    </style>
</head>
<body class="bg-gray-50 min-h-screen">

    <jsp:include page="/components/header.jsp"/>

    <!-- BREADCRUMB -->
    <div class="max-w-5xl mx-auto px-4 py-3 text-sm text-gray-400 flex items-center gap-2">
        <a href="${pageContext.request.contextPath}/home" class="hover:text-red-600">Inicio</a>
        <span>/</span>
        <a href="${pageContext.request.contextPath}/categoria?id=${producto.categoriaId}" class="hover:text-red-600">${producto.categoriaNombre}</a>
        <span>/</span>
        <span class="text-gray-700 font-medium">${producto.nombre}</span>
    </div>

    <!-- VOLVER -->
    <div class="max-w-5xl mx-auto px-4 mb-3">
        <a href="${pageContext.request.contextPath}/categoria?id=${producto.categoriaId}"
           class="inline-flex items-center gap-2 text-sm text-gray-500 hover:text-red-600 transition font-medium">
            <i class="fa-solid fa-arrow-left text-xs"></i> Volver
        </a>
    </div>

    <!-- CONTENIDO -->
    <div class="max-w-5xl mx-auto px-4 pb-20">

        <c:if test="${not empty sessionScope.carritoError}">
            <div class="bg-red-100 text-red-700 px-4 py-3 rounded-xl mb-4 text-sm">
                ${sessionScope.carritoError}
                <c:remove var="carritoError" scope="session"/>
            </div>
        </c:if>

        <div class="bg-white rounded-2xl shadow-sm overflow-hidden flex flex-col md:flex-row">

            <!-- IMAGEN -->
            <div class="md:w-1/2 relative min-h-[280px]">
                <img src="${pageContext.request.contextPath}/img/${producto.imagen}"
                     alt="${producto.nombre}"
                     class="w-full h-full object-cover min-h-[280px]">
                <span class="absolute top-4 left-4 bg-red-600 text-white text-xs font-bold px-3 py-1 rounded-full uppercase">
                    ${producto.categoriaNombre}
                </span>
            </div>

            <!-- INFO -->
            <div class="md:w-1/2 p-6 md:p-8 flex flex-col gap-4">

                <div>
                    <h1 class="text-2xl font-bold text-gray-800 mb-1">${producto.nombre}</h1>
                    <p class="text-gray-500 text-sm leading-relaxed mb-3">${producto.descripcion}</p>
                    <p class="text-3xl font-bold text-red-600">
                        S/ <fmt:formatNumber value="${producto.precio}" pattern="#,##0.00"/>
                    </p>
                    <p class="text-sm mt-2 ${producto.stock <= 5 ? 'text-orange-600' : 'text-green-600'} font-medium">
                        <i class="fa-solid fa-box-open mr-1"></i>
                        ${producto.stock} plato(s) disponible(s) hoy
                    </p>
                </div>

                <p class="text-xs text-gray-400 italic">
                    Por favor, elige tus opciones para continuar con tu pedido.
                </p>

                <!-- OPCIONES con scroll interno -->
                <div class="border border-gray-100 rounded-xl overflow-hidden">
                    <c:choose>
                        <c:when test="${not empty opcionesPorGrupo}">
                            <div class="opciones-scroll divide-y divide-gray-100">
                                <c:forEach var="entrada" items="${opcionesPorGrupo}">
                                    <c:set var="grupo" value="${entrada.key}"/>
                                    <c:set var="listaOpciones" value="${entrada.value}"/>
                                    <c:set var="color" value="${coloresPorGrupo[grupo] != null ? coloresPorGrupo[grupo] : 'bg-gray-500'}"/>
                                    <c:set var="inputName" value="${grupo}"/>

                                    <div>
                                        <div class="flex items-center justify-between px-4 py-3 ${color} text-white cursor-pointer select-none" onclick="toggle(this)">
                                            <div class="flex items-center gap-2 text-sm font-semibold">
                                                <i class="fa-solid fa-circle-dot"></i> ${grupo}
                                            </div>
                                            <i class="fa-solid fa-chevron-down chevron abierto text-sm"></i>
                                        </div>
                                        <div class="contenido-opcion" style="max-height:300px">
                                            <div class="p-4 flex flex-col gap-2">
                                                <c:forEach var="op" items="${listaOpciones}">
                                                    <div class="opcion-item">
                                                        <input type="radio"
                                                               name="${inputName}"
                                                               id="op${op.id}"
                                                               value="${op.nombre}"
                                                               data-precio="${op.precioAdicional}"
                                                               data-grupo="${grupo}">
                                                        <label for="op${op.id}">
                                                            ${op.nombre}
                                                            <c:if test="${op.precioAdicional > 0}">
                                                                <span class="text-red-500 text-xs ml-1">
                                                                    +S/ <fmt:formatNumber value="${op.precioAdicional}" pattern="#,##0.00"/>
                                                                </span>
                                                            </c:if>
                                                        </label>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="p-4 text-center text-gray-400 text-sm">
                                <i class="fa-solid fa-circle-check text-green-500 text-2xl mb-2"></i>
                                <p>Solo selecciona la cantidad y agrega al carrito</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- COMENTARIO -->
                <div>
                    <label class="block text-sm font-medium text-gray-600 mb-1">
                        <i class="fa-regular fa-comment mr-1"></i> Comentario
                    </label>
                    <textarea id="comentario" rows="2"
                              placeholder="¿Alguna indicación especial?"
                              class="w-full border border-gray-200 rounded-xl px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-300 resize-none"></textarea>
                </div>

                <!-- CANTIDAD + BOTÓN -->
                <div class="flex items-center gap-4 mt-auto">
                    <div class="flex items-center gap-3">
                        <button type="button" class="btn-cantidad" onclick="cambiarCantidad(-1)">−</button>
                        <span id="cantidad" class="text-xl font-bold w-8 text-center">1</span>
                        <button type="button" class="btn-cantidad" id="btnMas" onclick="cambiarCantidad(1)">+</button>
                    </div>
                    <button type="button" id="btnAgregar" onclick="agregarAlPedido()"
                            class="flex-1 bg-red-600 hover:bg-red-700 active:scale-95 text-white font-bold py-3 px-4 rounded-xl transition-all flex items-center justify-center gap-2 text-sm">
                        <i class="fa-solid fa-cart-plus"></i>
                        Añadir a mi pedido — S/ <span id="precioTotal"><fmt:formatNumber value="${producto.precio}" pattern="#,##0.00"/></span>
                    </button>
                </div>

            </div>
        </div>
    </div>

    <jsp:include page="/components/footer.jsp"/>

    <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
    <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>

    <form id="formCarrito" action="${pageContext.request.contextPath}/carrito" method="post" style="display:none">
        <input type="hidden" name="action" value="agregar">
        <input type="hidden" name="productoId" value="${producto.id}">
        <input type="hidden" name="nombre" value="${producto.nombre}">
        <input type="hidden" name="precio" value="${producto.precio}">
        <input type="hidden" name="imagen" value="${producto.imagen}">
        <input type="hidden" name="tipo" value="producto">
        <input type="hidden" name="cantidad" id="cantidadInput" value="1">
        <input type="hidden" name="opciones" id="opcionesInput" value="">
    </form>

    <script>
        const precioBase = ${producto.precio};
        const stockMax = ${producto.stock};
        const enCarrito = ${not empty cantidadEnCarrito ? cantidadEnCarrito : 0};
        const stockDisponible = Math.max(0, stockMax - enCarrito);

        function agregarAlPedido() {
            if (stockDisponible <= 0) {
                alert('Este producto está agotado.');
                return;
            }
            let precioExtra = 0;
            const opcionesSeleccionadas = [];

            const todosInputs = document.querySelectorAll('input[type="radio"][data-grupo]');
            const gruposUnicos = [...new Set([...todosInputs].map(i => i.name))];

            for (const nombre of gruposUnicos) {
                const checked = document.querySelector(`input[name="${CSS.escape(nombre)}"]:checked`);
                const hayInputs = document.querySelector(`input[name="${CSS.escape(nombre)}"]`);
                if (hayInputs && !checked) {
                    alert(`Por favor selecciona una opción de: ${nombre}`);
                    return;
                }
                if (checked) {
                    precioExtra += parseFloat(checked.dataset.precio || 0);
                    opcionesSeleccionadas.push(checked.value);
                }
            }

            const cantidad = parseInt(document.getElementById('cantidad').textContent);
            if (cantidad > stockDisponible) {
                alert('Solo puedes pedir ' + stockDisponible + ' unidad(es).');
                return;
            }
            const precioFinal = (precioBase + precioExtra) * cantidad;
            document.getElementById('precioTotal').textContent = precioFinal.toFixed(2);
            document.getElementById('opcionesInput').value = opcionesSeleccionadas.join(', ');
            document.querySelector('input[name="precio"]').value = (precioBase + precioExtra).toFixed(2);
            document.getElementById('formCarrito').submit();
        }

        function cambiarCantidad(delta) {
            const el = document.getElementById('cantidad');
            let v = parseInt(el.textContent) + delta;
            if (v < 1) v = 1;
            if (v > stockDisponible) v = stockDisponible;
            el.textContent = v;

            let precioExtra = 0;
            document.querySelectorAll('input[type="radio"]:checked').forEach(i => {
                precioExtra += parseFloat(i.dataset.precio || 0);
            });

            document.getElementById('precioTotal').textContent = ((precioBase + precioExtra) * v).toFixed(2);
            document.getElementById('cantidadInput').value = v;
            document.getElementById('btnMas').disabled = (v >= stockDisponible);
        }

        if (stockDisponible <= 0) {
            document.getElementById('btnAgregar').disabled = true;
            document.getElementById('btnAgregar').classList.add('opacity-50', 'cursor-not-allowed');
            document.getElementById('btnMas').disabled = true;
        } else if (stockDisponible < 20) {
            document.getElementById('btnMas').disabled = (parseInt(document.getElementById('cantidad').textContent) >= stockDisponible);
        }

        function toggle(header) {
            const content = header.nextElementSibling;
            const chevron = header.querySelector('.chevron');
            if (chevron.classList.contains('abierto')) {
                content.style.maxHeight = '0px';
                chevron.classList.remove('abierto');
            } else {
                content.style.maxHeight = '300px';
                chevron.classList.add('abierto');
            }
        }
    </script>
</body>
</html>