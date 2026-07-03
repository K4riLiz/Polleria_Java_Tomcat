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
        .opciones-scroll {
            max-height: 320px; overflow-y: auto;
            scrollbar-width: thin; scrollbar-color: #f87171 #f3f4f6;
        }
        .opciones-scroll::-webkit-scrollbar { width: 4px; }
        .opciones-scroll::-webkit-scrollbar-track { background: #f3f4f6; border-radius: 4px; }
        .opciones-scroll::-webkit-scrollbar-thumb { background: #f87171; border-radius: 4px; }
    </style>
</head>
<body class="bg-gray-50 min-h-screen">

    <jsp:include page="/components/header.jsp"/>

    <div class="max-w-5xl mx-auto px-4 py-3 text-sm text-gray-400 flex items-center gap-2">
        <a href="${pageContext.request.contextPath}/home" class="hover:text-red-600">Inicio</a>
        <span>/</span>
        <a href="${pageContext.request.contextPath}/promociones" class="hover:text-red-600">Promociones</a>
        <span>/</span>
        <span class="text-gray-700 font-medium">${promocion.nombre}</span>
    </div>

    <div class="max-w-5xl mx-auto px-4 mb-3">
        <a href="${pageContext.request.contextPath}/promociones"
           class="inline-flex items-center gap-2 text-sm text-gray-500 hover:text-red-600 transition font-medium">
            <i class="fa-solid fa-arrow-left text-xs"></i> Volver a Promociones
        </a>
    </div>

    <div class="max-w-5xl mx-auto px-4 pb-20">
        <div class="bg-white rounded-2xl shadow-sm overflow-hidden flex flex-col md:flex-row">

            <div class="md:w-1/2 relative min-h-[280px]">
                <img src="${promocion.imagen}" alt="${promocion.nombre}"
                     class="w-full h-full object-cover min-h-[280px]"
                     onerror="this.src='${pageContext.request.contextPath}/img/pollobrasa.png'">
                <span class="absolute top-4 left-4 bg-red-600 text-white text-xs font-bold px-3 py-1 rounded-full uppercase">
                    Promoción
                </span>
            </div>

            <div class="md:w-1/2 p-6 md:p-8 flex flex-col gap-4">
                <div>
                    <h1 class="text-2xl font-bold text-gray-800 mb-1">${promocion.nombre}</h1>
                    <p class="text-gray-500 text-sm leading-relaxed mb-3">${promocion.descripcion}</p>
                    <p class="text-3xl font-bold text-red-600">
                        S/ <fmt:formatNumber value="${promocion.precio}" pattern="#,##0.00"/>
                    </p>
                    <p class="text-sm text-gray-500 mt-1">
                        <i class="fa-solid fa-box-open mr-1"></i>
                        ${promocion.stock} disponible(s)
                    </p>
                </div>

                <c:if test="${not empty opcionesPorGrupo}">
                    <p class="text-xs text-gray-400 italic">Por favor, elige tus opciones para continuar.</p>
                </c:if>

                <div class="border border-gray-100 rounded-xl overflow-hidden">
                    <c:choose>
                        <c:when test="${not empty opcionesPorGrupo}">
                            <div class="opciones-scroll divide-y divide-gray-100">
                                <c:forEach var="entrada" items="${opcionesPorGrupo}">
                                    <c:set var="grupo" value="${entrada.key}"/>
                                    <c:set var="listaOpciones" value="${entrada.value}"/>
                                    <c:set var="color" value="${coloresPorGrupo[grupo] != null ? coloresPorGrupo[grupo] : 'bg-gray-500'}"/>
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
                                                               name="${grupo}"
                                                               id="op${op.id}"
                                                               value="${op.nombre}"
                                                               data-precio="${op.precioAdicional}">
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

                <div>
                    <label class="block text-sm font-medium text-gray-600 mb-1">
                        <i class="fa-regular fa-comment mr-1"></i> Comentario
                    </label>
                    <textarea rows="2" placeholder="¿Alguna indicación especial?"
                              class="w-full border border-gray-200 rounded-xl px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-300 resize-none"></textarea>
                </div>

                <div class="flex items-center gap-4 mt-auto">
                    <div class="flex items-center gap-3">
                        <button type="button" class="btn-cantidad" onclick="cambiarCantidad(-1)">−</button>
                        <span id="cantidad" class="text-xl font-bold w-8 text-center">1</span>
                        <button type="button" class="btn-cantidad" id="btnMas" onclick="cambiarCantidad(1)">+</button>
                    </div>
                    <button type="button" id="btnAgregar" onclick="agregarAlPedido()"
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
        var precioBase  = ${promocion.precio};
        var stockMax    = ${promocion.stock};
        var yaEnCarrito = false;

        // ── Recalcular precio ─────────────────────────────────────────────────
        function recalcularPrecio() {
            var cantidad    = parseInt(document.getElementById('cantidad').textContent);
            var precioExtra = 0;
            document.querySelectorAll('input[type="radio"]:checked').forEach(function(i) {
                precioExtra += parseFloat(i.dataset.precio || 0);
            });
            var total = (precioBase + precioExtra) * cantidad;
            document.getElementById('precioTotal').textContent = total.toFixed(2);
            document.getElementById('cantidadInput').value = cantidad;
            document.querySelector('input[name="precio"]').value = (precioBase + precioExtra).toFixed(2);
        }

        // Actualizar precio al seleccionar opción
        document.querySelectorAll('input[type="radio"]').forEach(function(radio) {
            radio.addEventListener('change', function() {
                recalcularPrecio();
                if (yaEnCarrito) {
                    yaEnCarrito = false;
                    restaurarBtn();
                }
            });
        });

        // ── Cantidad ──────────────────────────────────────────────────────────
        function cambiarCantidad(delta) {
            var el = document.getElementById('cantidad');
            var v  = parseInt(el.textContent) + delta;
            if (v < 1) v = 1;
            if (v > stockMax) v = stockMax;
            el.textContent = v;
            recalcularPrecio();
            if (yaEnCarrito) {
                yaEnCarrito = false;
                restaurarBtn();
            }
        }

        // ── Estados del botón ─────────────────────────────────────────────────
        function setBtnExito() {
            var btn = document.getElementById('btnAgregar');
            btn.onclick = null;
            btn.className = 'flex-1 bg-green-600 text-white font-bold py-3 px-4 rounded-xl flex items-center justify-center gap-2 text-sm';
            btn.innerHTML = '<i class="fa-solid fa-circle-check"></i> ¡Añadido al pedido!';
            yaEnCarrito = true;
        }

        function restaurarBtn() {
            var btn = document.getElementById('btnAgregar');
            btn.onclick = agregarAlPedido;
            btn.className = 'flex-1 bg-red-600 hover:bg-red-700 active:scale-95 text-white font-bold py-3 px-4 rounded-xl transition-all flex items-center justify-center gap-2 text-sm';
            btn.innerHTML = '<i class="fa-solid fa-cart-plus"></i> Añadir a mi pedido — S/ <span id="precioTotal">0.00</span>';
            recalcularPrecio();
        }

        // ── Agregar al carrito ────────────────────────────────────────────────
        function agregarAlPedido() {
            // Recoger grupos únicos por name
            var radios = document.querySelectorAll('input[type="radio"]');
            var grupos = [];
            radios.forEach(function(r) {
                if (grupos.indexOf(r.name) === -1) grupos.push(r.name);
            });

            var opcionesSeleccionadas = [];
            var precioExtra = 0;

            for (var i = 0; i < grupos.length; i++) {
                var checked = document.querySelector('input[name="' + grupos[i] + '"]:checked');
                if (!checked) {
                    alert('Por favor selecciona una opción de: ' + grupos[i]);
                    return;
                }
                precioExtra += parseFloat(checked.dataset.precio || 0);
                opcionesSeleccionadas.push(checked.value);
            }

            var cantidad = parseInt(document.getElementById('cantidad').textContent);
            if (cantidad > stockMax) {
                alert('Solo puedes pedir ' + stockMax + ' unidad(es).');
                return;
            }

            document.querySelector('input[name="precio"]').value = (precioBase + precioExtra).toFixed(2);
            document.getElementById('opcionesInput').value       = opcionesSeleccionadas.join(', ');
            document.getElementById('cantidadInput').value       = cantidad;

            setBtnExito();
            document.getElementById('formCarrito').submit();
        }

        function toggle(header) {
            var content = header.nextElementSibling;
            var chevron = header.querySelector('.chevron');
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