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
    <title>Admin - Productos</title>
    <style>
        .preview-img { width: 80px; height: 80px; object-fit: cover; border-radius: 10px; }
        .drop-zone {
            border: 2px dashed #d1d5db; border-radius: 12px;
            padding: 20px; text-align: center; cursor: pointer; transition: border-color 0.2s;
        }
        .drop-zone:hover { border-color: #ef4444; }
        .drop-zone.dragover { border-color: #ef4444; background: #fff5f5; }
        .tab-btn { border-bottom: 3px solid transparent; transition: all 0.2s; }
        .tab-btn.activo { border-bottom-color: #dc2626; color: #dc2626; font-weight: 700; }
    </style>
</head>
<body class="bg-gray-100 min-h-screen">
<div class="flex min-h-screen">

    <!-- SIDEBAR -->
    <aside class="w-64 bg-gray-900 text-white flex flex-col">
        <div class="p-6 border-b border-gray-700">
            <h1 class="text-xl font-bold text-red-400">Hola, admin</h1>
            <p class="text-xs text-gray-400 mt-1">${sessionScope.usuario.nombre}</p>
        </div>
        <nav class="flex flex-col p-4 gap-2 flex-1">
            <a href="${pageContext.request.contextPath}/admin/dashboard"
               class="flex items-center gap-3 px-4 py-2 rounded-lg hover:bg-gray-700 transition">
                <i class="fa-solid fa-chart-line"></i> Dashboard
            </a>
            <a href="${pageContext.request.contextPath}/admin/usuarios"
               class="flex items-center gap-3 px-4 py-2 rounded-lg hover:bg-gray-700 transition">
                <i class="fa-solid fa-users"></i> Usuarios
            </a>
            <a href="${pageContext.request.contextPath}/admin/roles"
               class="flex items-center gap-3 px-4 py-2 rounded-lg hover:bg-gray-700 transition">
                <i class="fa-solid fa-shield"></i> Roles
            </a>
            <a href="${pageContext.request.contextPath}/admin/productos"
               class="flex items-center gap-3 px-4 py-2 rounded-lg bg-red-600 text-white font-medium">
                <i class="fa-solid fa-utensils"></i> Productos
            </a>
            <a href="${pageContext.request.contextPath}/admin/pedidos"
               class="flex items-center gap-3 px-4 py-2 rounded-lg hover:bg-gray-700 transition">
                <i class="fa-solid fa-receipt"></i> Pedidos
            </a>
            <a href="${pageContext.request.contextPath}/admin/opciones"
               class="flex items-center gap-3 px-4 py-2 rounded-lg hover:bg-gray-700 transition">
                <i class="fa-solid fa-sliders"></i> Opciones
            </a>
            <a href="${pageContext.request.contextPath}/admin/reclamaciones"
               class="flex items-center gap-3 px-4 py-2 rounded-lg hover:bg-gray-700 transition">
                <i class="fa-solid fa-book-open"></i> Reclamaciones
            </a>
            <a href="${pageContext.request.contextPath}/logout"
               class="flex items-center gap-3 px-4 py-2 rounded-lg hover:bg-red-700 transition text-red-400">
                <i class="fa-solid fa-right-from-bracket"></i> Cerrar sesión
            </a>
        </nav>
    </aside>

    <!-- CONTENIDO -->
    <main class="flex-1 p-8 overflow-auto">
        <h2 class="text-2xl font-bold text-gray-800 mb-2">Gestión de Productos</h2>

        <!-- ALERTAS -->
        <c:if test="${not empty sessionScope.exito}">
            <div class="bg-green-100 text-green-700 px-4 py-3 rounded-lg mb-4">
                ${sessionScope.exito} <c:remove var="exito" scope="session"/>
            </div>
        </c:if>
        <c:if test="${not empty sessionScope.error}">
            <div class="bg-red-100 text-red-700 px-4 py-3 rounded-lg mb-4">
                ${sessionScope.error} <c:remove var="error" scope="session"/>
            </div>
        </c:if>

        <!-- TABS -->
        <div class="flex border-b border-gray-200 mb-6 gap-6">
            <button id="tabProductosBtn" onclick="cambiarTab('productos')"
                    class="tab-btn activo pb-3 text-sm whitespace-nowrap">
                <i class="fa-solid fa-utensils mr-1"></i> Productos
            </button>
            <button id="tabCategoriasBtn" onclick="cambiarTab('categorias')"
                    class="tab-btn pb-3 text-sm text-gray-500 whitespace-nowrap">
                <i class="fa-solid fa-tags mr-1"></i> Categorías
            </button>
        </div>

        <!-- ══════════════════════════════════════════════════════ -->
        <!-- TAB PRODUCTOS                                          -->
        <!-- ══════════════════════════════════════════════════════ -->
        <div id="tabProductos">

            <p class="text-sm text-gray-500 mb-4">
                <i class="fa-solid fa-boxes-stacked mr-1"></i>
                Actualiza el <strong>stock del día</strong> de cada plato.
            </p>

            <!-- FORMULARIO PRODUCTO -->
            <div class="bg-white rounded-2xl shadow p-6 mb-8">
                <h3 class="text-lg font-semibold mb-4">
                    <c:choose>
                        <c:when test="${not empty productoEditar}">✏️ Editar Producto</c:when>
                        <c:otherwise>➕ Nuevo Producto</c:otherwise>
                    </c:choose>
                </h3>
                <form action="${pageContext.request.contextPath}/admin/productos"
                      method="post" enctype="multipart/form-data"
                      class="grid grid-cols-1 md:grid-cols-3 gap-4">

                    <c:choose>
                        <c:when test="${not empty productoEditar}">
                            <input type="hidden" name="action" value="actualizar">
                            <input type="hidden" name="id" value="${productoEditar.id}">
                            <input type="hidden" name="imagenActual" value="${productoEditar.imagen}">
                        </c:when>
                        <c:otherwise>
                            <input type="hidden" name="action" value="crear">
                        </c:otherwise>
                    </c:choose>

                    <div>
                        <label class="block text-sm font-medium text-gray-600 mb-1">Nombre</label>
                        <input type="text" name="nombre" required value="${productoEditar.nombre}"
                               class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-400">
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-600 mb-1">Precio (S/)</label>
                        <input type="number" name="precio" step="0.01" min="0" required value="${productoEditar.precio}"
                               class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-400">
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-600 mb-1">Categoría</label>
                        <select name="categoriaId" class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-400">
                            <c:forEach items="${categorias}" var="cat">
                                <option value="${cat.id}" <c:if test="${cat.id == productoEditar.categoriaId}">selected</c:if>>
                                    ${cat.nombre}
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-600 mb-1">Stock del día</label>
                        <input type="number" name="stock" min="0" required
                               value="${empty productoEditar ? 0 : productoEditar.stock}"
                               class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-400">
                    </div>
                    <div class="md:col-span-2">
                        <label class="block text-sm font-medium text-gray-600 mb-1">Descripción</label>
                        <textarea name="descripcion" rows="2"
                                  class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-400">${productoEditar.descripcion}</textarea>
                    </div>
                    <c:if test="${not empty productoEditar}">
                    <div>
                        <label class="block text-sm font-medium text-gray-600 mb-1">Estado</label>
                        <select name="activo" class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-400">
                            <option value="1" <c:if test="${productoEditar.activo}">selected</c:if>>Activo</option>
                            <option value="0" <c:if test="${!productoEditar.activo}">selected</c:if>>Inactivo</option>
                        </select>
                    </div>
                    </c:if>
                    <div class="md:col-span-3">
                        <label class="block text-sm font-medium text-gray-600 mb-2">Imagen del producto</label>
                        <div class="flex items-start gap-4">
                            <c:if test="${not empty productoEditar.imagen}">
                                <div class="flex-shrink-0">
                                    <p class="text-xs text-gray-400 mb-1">Imagen actual:</p>
                                    <img src="${productoEditar.imagen}" 
                                         id="previewActual" class="preview-img border"
                                         onerror="this.src='${pageContext.request.contextPath}/img/pollobrasa.webp'">
                                </div>
                            </c:if>
                            <div class="flex-1">
                                <div class="drop-zone" id="dropZone" onclick="document.getElementById('imagenFile').click()">
                                    <i class="fa-solid fa-cloud-arrow-up text-3xl text-gray-300 mb-2"></i>
                                    <p class="text-sm text-gray-500">Arrastra una imagen o <span class="text-red-500 font-medium">haz clic</span></p>
                                    <p class="text-xs text-gray-400 mt-1">PNG, JPG — máx. 5MB</p>
                                    <p id="fileName" class="text-xs text-green-600 mt-2 font-medium"></p>
                                </div>
                                <input type="file" name="imagenFile" id="imagenFile" accept="image/*" class="hidden" onchange="mostrarPreview(this)">
                                <div id="previewNueva" class="mt-3 hidden">
                                    <p class="text-xs text-gray-400 mb-1">Nueva imagen:</p>
                                    <img id="imgPreview" class="preview-img border">
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="md:col-span-3 flex gap-3">
                        <button type="submit"
                                class="bg-red-600 hover:bg-red-700 text-white px-6 py-2 rounded-lg text-sm font-semibold transition">
                            <c:choose>
                                <c:when test="${not empty productoEditar}"><i class="fa-solid fa-floppy-disk mr-1"></i> Actualizar</c:when>
                                <c:otherwise><i class="fa-solid fa-plus mr-1"></i> Crear Producto</c:otherwise>
                            </c:choose>
                        </button>
                        <c:if test="${not empty productoEditar}">
                            <a href="${pageContext.request.contextPath}/admin/productos"
                               class="bg-gray-200 hover:bg-gray-300 text-gray-700 px-6 py-2 rounded-lg text-sm font-semibold transition">
                                Cancelar
                            </a>
                        </c:if>
                    </div>
                </form>
            </div>

            <!-- TABLA PRODUCTOS -->
            <div class="bg-white rounded-2xl shadow overflow-hidden">
                <table class="w-full text-sm">
                    <thead class="bg-gray-50 text-gray-600 uppercase text-xs">
                        <tr>
                            <th class="px-4 py-3 text-left">#</th>
                            <th class="px-4 py-3 text-left">Imagen</th>
                            <th class="px-4 py-3 text-left">Nombre</th>
                            <th class="px-4 py-3 text-left">Categoría</th>
                            <th class="px-4 py-3 text-left">Precio</th>
                            <th class="px-4 py-3 text-left">Stock</th>
                            <th class="px-4 py-3 text-left">Estado</th>
                            <th class="px-4 py-3 text-center">Acciones</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100">
                        <c:forEach items="${productos}" var="p">
                            <tr class="hover:bg-gray-50">
                                <td class="px-4 py-3 text-gray-400">${p.id}</td>
                                <td class="px-4 py-3">
                                    <img src="${p.imagen}"
                                         class="w-12 h-12 object-cover rounded-lg"
                                         onerror="this.src='${pageContext.request.contextPath}/img/pollobrasa.png'">
                                </td>
                                <td class="px-4 py-3 font-medium">${p.nombre}</td>
                                <td class="px-4 py-3">
                                    <span class="bg-orange-100 text-orange-600 text-xs font-semibold px-2 py-1 rounded-full">
                                        ${p.categoriaNombre}
                                    </span>
                                </td>
                                <td class="px-4 py-3 font-bold text-red-600">
                                    S/<fmt:formatNumber value="${p.precio}" pattern="#,##0.00"/>
                                </td>
                                <td class="px-4 py-3">
                                    <form action="${pageContext.request.contextPath}/admin/productos"
                                          method="post" class="flex items-center gap-2">
                                        <input type="hidden" name="action" value="actualizarStock">
                                        <input type="hidden" name="id" value="${p.id}">
                                        <input type="number" name="stock" min="0" value="${p.stock}"
                                               class="w-16 border rounded px-2 py-1 text-sm text-center
                                               ${p.stock == 0 ? 'border-red-400 bg-red-50' : 'border-gray-300'}">
                                        <button type="submit" class="text-green-600 hover:text-green-800">
                                            <i class="fa-solid fa-floppy-disk"></i>
                                        </button>
                                    </form>
                                    <c:if test="${p.stock == 0}">
                                        <span class="text-xs text-red-500 font-semibold">Agotado</span>
                                    </c:if>
                                </td>
                                <td class="px-4 py-3">
                                    <span class="px-2 py-1 rounded-full text-xs font-semibold
                                        ${p.activo ? 'bg-green-100 text-green-600' : 'bg-gray-100 text-gray-500'}">
                                        ${p.activo ? 'Activo' : 'Inactivo'}
                                    </span>
                                </td>
                                <td class="px-4 py-3 text-center">
                                    <a href="${pageContext.request.contextPath}/admin/productos?action=editar&id=${p.id}"
                                       class="text-blue-500 hover:text-blue-700 mr-3">
                                        <i class="fa-solid fa-pen-to-square"></i>
                                    </a>
                                    <form action="${pageContext.request.contextPath}/admin/productos"
                                          method="post" enctype="multipart/form-data" class="inline"
                                          onsubmit="return confirm('¿Eliminar este producto?')">
                                        <input type="hidden" name="action" value="eliminar">
                                        <input type="hidden" name="id" value="${p.id}">
                                        <button type="submit" class="text-red-500 hover:text-red-700">
                                            <i class="fa-solid fa-trash"></i>
                                        </button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- ══════════════════════════════════════════════════════ -->
        <!-- TAB CATEGORÍAS                                         -->
        <!-- ══════════════════════════════════════════════════════ -->
        <div id="tabCategorias" class="hidden">

            <!-- FORMULARIO CATEGORÍA -->
            <div class="bg-white rounded-2xl shadow p-6 mb-8">
                <h3 class="text-lg font-semibold mb-4">
                    <c:choose>
                        <c:when test="${not empty categoriaEditar}">✏️ Editar Categoría</c:when>
                        <c:otherwise>➕ Nueva Categoría</c:otherwise>
                    </c:choose>
                </h3>
                <form action="${pageContext.request.contextPath}/admin/productos"
                      method="post" class="grid grid-cols-1 md:grid-cols-2 gap-4">

                    <c:choose>
                        <c:when test="${not empty categoriaEditar}">
                            <input type="hidden" name="action" value="actualizarCategoria">
                            <input type="hidden" name="catId" value="${categoriaEditar.id}">
                            <input type="hidden" name="catImagenActual" value="${categoriaEditar.imagen}">
                        </c:when>
                        <c:otherwise>
                            <input type="hidden" name="action" value="crearCategoria">
                        </c:otherwise>
                    </c:choose>

                    <div>
                        <label class="block text-sm font-medium text-gray-600 mb-1">Nombre de la categoría</label>
                        <input type="text" name="catNombre" required value="${categoriaEditar.nombre}"
                               placeholder="Ej: Pollo a la brasa"
                               class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-400">
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-600 mb-1">Descripción (opcional)</label>
                        <input type="text" name="catDescripcion" value="${categoriaEditar.descripcion}"
                               placeholder="Breve descripción..."
                               class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-400">
                    </div>
                    <div class="md:col-span-2 flex gap-3">
                        <button type="submit"
                                class="bg-red-600 hover:bg-red-700 text-white px-6 py-2 rounded-lg text-sm font-semibold transition">
                            <c:choose>
                                <c:when test="${not empty categoriaEditar}"><i class="fa-solid fa-floppy-disk mr-1"></i> Actualizar</c:when>
                                <c:otherwise><i class="fa-solid fa-plus mr-1"></i> Crear Categoría</c:otherwise>
                            </c:choose>
                        </button>
                        <c:if test="${not empty categoriaEditar}">
                            <a href="${pageContext.request.contextPath}/admin/productos?tab=categorias"
                               class="bg-gray-200 hover:bg-gray-300 text-gray-700 px-6 py-2 rounded-lg text-sm font-semibold transition">
                                Cancelar
                            </a>
                        </c:if>
                    </div>
                </form>
            </div>

            <!-- TABLA CATEGORÍAS -->
            <div class="bg-white rounded-2xl shadow overflow-hidden">
                <table class="w-full text-sm">
                    <thead class="bg-gray-50 text-gray-600 uppercase text-xs">
                        <tr>
                            <th class="px-4 py-3 text-left">#</th>
                            <th class="px-4 py-3 text-left">Nombre</th>
                            <th class="px-4 py-3 text-left">Descripción</th>
                            <th class="px-4 py-3 text-center">Acciones</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100">
                        <c:forEach items="${categorias}" var="cat">
                            <tr class="hover:bg-gray-50">
                                <td class="px-4 py-3 text-gray-400">${cat.id}</td>
                                <td class="px-4 py-3 font-medium">
                                    <span class="bg-orange-100 text-orange-600 text-xs font-semibold px-2 py-1 rounded-full">
                                        ${cat.nombre}
                                    </span>
                                </td>
                                <td class="px-4 py-3 text-gray-500 text-xs">${cat.descripcion}</td>
                                <td class="px-4 py-3 text-center">
                                    <a href="${pageContext.request.contextPath}/admin/productos?action=editarCategoria&id=${cat.id}"
                                       class="text-blue-500 hover:text-blue-700 mr-3">
                                        <i class="fa-solid fa-pen-to-square"></i>
                                    </a>
                                    <form action="${pageContext.request.contextPath}/admin/productos"
                                          method="post" class="inline"
                                          onsubmit="return confirm('¿Eliminar esta categoría? Solo se puede si no tiene productos.')">
                                        <input type="hidden" name="action" value="eliminarCategoria">
                                        <input type="hidden" name="catId" value="${cat.id}">
                                        <button type="submit" class="text-red-500 hover:text-red-700">
                                            <i class="fa-solid fa-trash"></i>
                                        </button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>

    </main>
</div>

<script>
    // ── TABS ──────────────────────────────────────────────────────────────────
    function cambiarTab(tab) {
        var esCat = tab === 'categorias';
        document.getElementById('tabProductos').classList.toggle('hidden', esCat);
        document.getElementById('tabCategorias').classList.toggle('hidden', !esCat);
        document.getElementById('tabProductosBtn').classList.toggle('activo', !esCat);
        document.getElementById('tabCategoriasBtn').classList.toggle('activo', esCat);
        document.getElementById('tabProductosBtn').classList.toggle('text-gray-500', esCat);
        document.getElementById('tabCategoriasBtn').classList.toggle('text-gray-500', !esCat);
    }

    // Si viene de una acción de categoría, abrir tab categorías
    var urlParams = new URLSearchParams(window.location.search);
    if (urlParams.get('tab') === 'categorias' || '${tabActivo}' === 'categorias'
            || '${not empty categoriaEditar}' === 'true') {
        cambiarTab('categorias');
    }

    // ── IMAGEN PRODUCTO ───────────────────────────────────────────────────────
    function mostrarPreview(input) {
        if (input.files && input.files[0]) {
            var file = input.files[0];
            document.getElementById('fileName').textContent = '✅ ' + file.name;
            var reader = new FileReader();
            reader.onload = function(e) {
                document.getElementById('imgPreview').src = e.target.result;
                document.getElementById('previewNueva').classList.remove('hidden');
            };
            reader.readAsDataURL(file);
        }
    }

    var dropZone = document.getElementById('dropZone');
    if (dropZone) {
        dropZone.addEventListener('dragover', function(e) {
            e.preventDefault(); dropZone.classList.add('dragover');
        });
        dropZone.addEventListener('dragleave', function() { dropZone.classList.remove('dragover'); });
        dropZone.addEventListener('drop', function(e) {
            e.preventDefault(); dropZone.classList.remove('dragover');
            var file = e.dataTransfer.files[0];
            if (file && file.type.startsWith('image/')) {
                var input = document.getElementById('imagenFile');
                var dt = new DataTransfer();
                dt.items.add(file);
                input.files = dt.files;
                mostrarPreview(input);
            }
        });
    }
</script>
</body>
</html>
