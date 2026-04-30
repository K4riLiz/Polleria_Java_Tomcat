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
            <div class="md:w-1/2 p-6 md:p-8 flex flex-col gap-5 overflow-y-auto max-h-[90vh]">

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

                    <!-- Pollo -->
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
                                <div class="opcion-item"><input type="radio" name="pollo" id="pierna" value="pierna"><label for="pierna"> Pierna</label></div>
                                <div class="opcion-item"><input type="radio" name="pollo" id="pecho" value="pecho"><label for="pecho"> Pecho</label></div>
                            </div>
                        </div>
                    </div>

                    <!-- Complemento -->
                    <div>
                        <div class="flex items-center justify-between px-4 py-3 bg-orange-500 text-white cursor-pointer select-none" onclick="toggle(this)">
                            <div class="flex items-center gap-2 text-sm font-semibold">
                                <i class="fa-solid fa-bowl-food"></i> Complemento
                            </div>
                            <i class="fa-solid fa-chevron-down chevron abierto text-sm"></i>
                        </div>
                        <div class="contenido-opcion" style="max-height:200px">
                            <div class="p-4 flex flex-col gap-2">
                                <div class="opcion-item"><input type="radio" name="complemento" id="papas" value="papas"><label for="papas"> Papas Fritas</label></div>
                                <div class="opcion-item"><input type="radio" name="complemento" id="arroz" value="arroz"><label for="arroz"> Arroz</label></div>
                            </div>
                        </div>
                    </div>

                    <!-- Guarnición -->
                    <div>
                        <div class="flex items-center justify-between px-4 py-3 bg-yellow-500 text-white cursor-pointer select-none" onclick="toggle(this)">
                            <div class="flex items-center gap-2 text-sm font-semibold">
                                <i class="fa-solid fa-leaf"></i> Guarnición
                            </div>
                            <i class="fa-solid fa-chevron-down chevron abierto text-sm"></i>
                        </div>
                        <div class="contenido-opcion" style="max-height:200px">
                            <div class="p-4 flex flex-col gap-2">
                                <div class="opcion-item"><input type="radio" name="guarnicion" id="ef" value="fresca"><label for="ef"> Ensalada Fresca</label></div>
                                <div class="opcion-item"><input type="radio" name="guarnicion" id="ec" value="cocida"><label for="ec"> Ensalada Cocida</label></div>
                            </div>
                        </div>
                    </div>

                    <!-- Bebida -->
                    <div>
                        <div class="flex items-center justify-between px-4 py-3 bg-blue-500 text-white cursor-pointer select-none" onclick="toggle(this)">
                            <div class="flex items-center gap-2 text-sm font-semibold">
                                <i class="fa-solid fa-bottle-water"></i> Bebida
                                <span class="text-xs bg-white/20 px-2 py-0.5 rounded-full">Obligatorio</span>
                            </div>
                            <i class="fa-solid fa-chevron-down chevron abierto text-sm"></i>
                        </div>
                        <div class="contenido-opcion" style="max-height:200px">
                            <div class="p-4 flex flex-col gap-2">
                                <div class="opcion-item"><input type="radio" name="bebida" id="inca" value="inca"><label for="inca"> Inca Kola 500ml</label></div>
                                <div class="opcion-item"><input type="radio" name="bebida" id="gaseosa15" value="gaseosa"><label for="gaseosa15"> Gaseosa 1.5L</label></div>
                                <div class="opcion-item"><input type="radio" name="bebida" id="jugo" value="jugo"><label for="jugo"> Jugo Natural</label></div>
                            </div>
                        </div>
                    </div>

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

    function cambiarCantidad(delta) {
        const el = document.getElementById('cantidad');
        let v = parseInt(el.textContent) + delta;
        if (v < 1) v = 1;
        if (v > 20) v = 20;
        el.textContent = v;
        document.getElementById('precioTotal').textContent = (precioBase * v).toFixed(2);
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

        function agregarAlPedido() {
        const pollo = document.querySelector('input[name="pollo"]:checked');
        const bebida = document.querySelector('input[name="bebida"]:checked');
        if (!pollo) { alert('Por favor selecciona el tipo de pollo.'); return; }
        if (!bebida) { alert('Por favor selecciona una bebida.'); return; }

        const complemento = document.querySelector('input[name="complemento"]:checked');
        const guarnicion = document.querySelector('input[name="guarnicion"]:checked');

        const opciones = [
            '🍗 ' + pollo.value,
            complemento ? '🍽️ ' + complemento.value : null,
            guarnicion ? '🥗 ' + guarnicion.value : null,
            '🥤 ' + bebida.value
        ].filter(Boolean).join(', ');

        // Agregar campo opciones al form
        const input = document.getElementById('opcionesInput');
        if (input) input.value = opciones;

        document.getElementById('formCarrito').submit();
    }
</script>
</body>
</html>
