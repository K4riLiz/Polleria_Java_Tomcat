<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <title>Admin - Opciones</title>
    <style>
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
            <a href="${pageContext.request.contextPath}/admin/usuarios"
               class="flex items-center gap-3 px-4 py-2 rounded-lg hover:bg-gray-700 transition">
                <i class="fa-solid fa-users"></i> Usuarios
            </a>
            <!-- Roles: fa-shield-halved puede no cargar, usar fa-shield -->
            <a href="${pageContext.request.contextPath}/admin/roles"
               class="flex items-center gap-3 px-4 py-2 rounded-lg hover:bg-gray-700 transition">
                <i class="fa-solid fa-shield"></i> Roles
            </a>
            <!-- Productos: fa-bowl-food puede no cargar, usar fa-utensils -->
            <a href="${pageContext.request.contextPath}/admin/productos"
               class="flex items-center gap-3 px-4 py-2 rounded-lg hover:bg-gray-700 transition">
                <i class="fa-solid fa-utensils"></i> Productos
            </a>
            <a href="${pageContext.request.contextPath}/admin/pedidos"
               class="flex items-center gap-3 px-4 py-2 rounded-lg hover:bg-gray-700 transition">
                <i class="fa-solid fa-receipt"></i> Pedidos
            </a>
            <a href="${pageContext.request.contextPath}/admin/opciones"
               class="flex items-center gap-3 px-4 py-2 rounded-lg bg-red-600 text-white font-medium">
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

    <main class="flex-1 p-8 overflow-auto">
        <h2 class="text-2xl font-bold text-gray-800 mb-6">Gestión de Opciones</h2>

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
            <button class="tab-btn pb-3 text-sm ${tab == 'productos' or empty tab ? 'activo' : 'text-gray-500'}"
                    onclick="cambiarTab('productos', this)">
                <i class="fa-solid fa-utensils mr-1"></i> Productos
            </button>
            <button class="tab-btn pb-3 text-sm ${tab == 'promociones' ? 'activo' : 'text-gray-500'}"
                    onclick="cambiarTab('promociones', this)">
                <i class="fa-solid fa-tag mr-1"></i> Promociones
            </button>
        </div>

        <!-- ── TAB PRODUCTOS ── -->
        <div id="secProductos" class="${tab == 'promociones' ? 'hidden' : ''}">
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6">

                <!-- Lista de productos -->
                <div class="bg-white rounded-2xl shadow p-4">
                    <h3 class="font-semibold text-gray-700 mb-3 text-sm uppercase tracking-wide">
                        Selecciona un producto
                    </h3>
                    <div class="flex flex-col gap-1 max-h-[500px] overflow-y-auto">
                        <c:forEach items="${productos}" var="prod">
                            <a href="${pageContext.request.contextPath}/admin/opciones?productoId=${prod.id}"
                               class="flex items-center gap-2 px-3 py-2 rounded-lg text-sm transition
                                      ${not empty productoSeleccionado and productoSeleccionado.id == prod.id
                                        ? 'bg-red-600 text-white font-semibold'
                                        : 'hover:bg-red-50 hover:text-red-600 text-gray-700'}">
                                <i class="fa-solid fa-utensils text-xs"></i>
                                ${prod.nombre}
                            </a>
                        </c:forEach>
                    </div>
                </div>

                <!-- Opciones del producto seleccionado -->
                <div class="md:col-span-2">
                    <c:choose>
                        <c:when test="${not empty productoSeleccionado}">

                            <!-- Formulario crear/editar -->
                            <div class="bg-white rounded-2xl shadow p-6 mb-4">
                                <h3 class="font-semibold text-gray-700 mb-4">
                                    <c:choose>
                                        <c:when test="${not empty opcionEditar}">
                                            ✏️ Editar opción de <strong>${productoSeleccionado.nombre}</strong>
                                        </c:when>
                                        <c:otherwise>
                                            ➕ Nueva opción para <strong>${productoSeleccionado.nombre}</strong>
                                        </c:otherwise>
                                    </c:choose>
                                </h3>
                                <form action="${pageContext.request.contextPath}/admin/opciones"
                                      method="post" class="grid grid-cols-1 md:grid-cols-2 gap-4"
                                      onsubmit="return procesarGrupoProducto(this)">
                                    <c:choose>
                                        <c:when test="${not empty opcionEditar}">
                                            <input type="hidden" name="action" value="actualizarOpcionProducto">
                                            <input type="hidden" name="id" value="${opcionEditar.id}">
                                        </c:when>
                                        <c:otherwise>
                                            <input type="hidden" name="action" value="crearOpcionProducto">
                                        </c:otherwise>
                                    </c:choose>
                                    <input type="hidden" name="productoId" value="${productoSeleccionado.id}">

                                    <div>
                                        <label class="block text-sm font-medium text-gray-600 mb-1">Nombre</label>
                                        <input type="text" name="nombre" required
                                               value="${opcionEditar.nombre}"
                                               placeholder="Ej: Papas Fritas"
                                               class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-400">
                                    </div>

                                    <div>
                                        <label class="block text-sm font-medium text-gray-600 mb-1">Grupo</label>
                                        <select name="grupo" id="grupoProducto"
                                                onchange="toggleNuevoGrupo('grupoProducto', 'nuevoGrupoProducto')"
                                                class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-400">
                                            <c:set var="grupos" value="Complemento,Guarnición,Tipo de Ensalada,Tipo de Bebida,Tipo de Jugo,Otro..."/>
                                            <c:forTokens items="${grupos}" delims="," var="g">
                                                <option value="${g}" ${opcionEditar.grupo == g ? 'selected' : ''}>${g}</option>
                                            </c:forTokens>
                                        </select>
                                        <!-- Campo nuevo grupo producto -->
                                        <input type="text" id="nuevoGrupoProducto"
                                               placeholder="Escribe el nuevo grupo..."
                                               class="hidden w-full border rounded-lg px-3 py-2 text-sm mt-2 focus:outline-none focus:ring-2 focus:ring-red-400">
                                    </div>

                                    <div>
                                        <label class="block text-sm font-medium text-gray-600 mb-1">Precio adicional (S/)</label>
                                        <input type="number" name="precioAdicional" step="0.01" min="0"
                                               value="${not empty opcionEditar ? opcionEditar.precioAdicional : '0.00'}"
                                               class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-400">
                                    </div>

                                    <div class="flex items-end gap-2">
                                        <button type="submit"
                                                class="bg-red-600 hover:bg-red-700 text-white px-5 py-2 rounded-lg text-sm font-semibold transition">
                                            <c:choose>
                                                <c:when test="${not empty opcionEditar}">
                                                    <i class="fa-solid fa-floppy-disk mr-1"></i> Actualizar
                                                </c:when>
                                                <c:otherwise>
                                                    <i class="fa-solid fa-plus mr-1"></i> Crear
                                                </c:otherwise>
                                            </c:choose>
                                        </button>
                                        <c:if test="${not empty opcionEditar}">
                                            <a href="${pageContext.request.contextPath}/admin/opciones?productoId=${productoSeleccionado.id}"
                                               class="bg-gray-200 hover:bg-gray-300 text-gray-700 px-5 py-2 rounded-lg text-sm font-semibold transition">
                                                Cancelar
                                            </a>
                                        </c:if>
                                    </div>
                                </form>
                            </div>

                            <!-- Tabla de opciones -->
                            <div class="bg-white rounded-2xl shadow overflow-hidden">
                                <div class="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
                                    <h3 class="font-semibold text-gray-700">
                                        Opciones de ${productoSeleccionado.nombre}
                                    </h3>
                                    <span class="text-xs text-gray-400">
                                        ${fn:length(opcionesProducto)} opciones
                                    </span>
                                </div>
                                <table class="w-full text-sm">
                                    <thead class="bg-gray-50 text-gray-600 uppercase text-xs">
                                        <tr>
                                            <th class="px-4 py-3 text-left">Nombre</th>
                                            <th class="px-4 py-3 text-left">Grupo</th>
                                            <th class="px-4 py-3 text-left">Precio extra</th>
                                            <th class="px-4 py-3 text-center">Estado</th>
                                            <th class="px-4 py-3 text-center">Acciones</th>
                                        </tr>
                                    </thead>
                                    <tbody class="divide-y divide-gray-100">
                                        <c:forEach items="${opcionesProducto}" var="op">
                                            <tr class="hover:bg-gray-50 ${!op.activo ? 'opacity-50' : ''}">
                                                <td class="px-4 py-3 font-medium">${op.nombre}</td>
                                                <td class="px-4 py-3">
                                                    <span class="px-2 py-1 rounded-full text-xs font-semibold bg-orange-100 text-orange-600">
                                                        ${op.grupo}
                                                    </span>
                                                </td>
                                                <td class="px-4 py-3 text-red-600 font-semibold">
                                                    <c:choose>
                                                        <c:when test="${op.precioAdicional > 0}">
                                                            +S/<fmt:formatNumber value="${op.precioAdicional}" pattern="#,##0.00"/>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-gray-400">Incluido</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="px-4 py-3 text-center">
                                                    <span class="px-2 py-1 rounded-full text-xs font-semibold
                                                        ${op.activo ? 'bg-green-100 text-green-600' : 'bg-gray-100 text-gray-500'}">
                                                        ${op.activo ? 'Activo' : 'Inactivo'}
                                                    </span>
                                                </td>
                                                <td class="px-4 py-3 text-center">
                                                    <div class="flex items-center justify-center gap-2">
                                                        <a href="${pageContext.request.contextPath}/admin/opciones?productoId=${productoSeleccionado.id}&editPO=${op.id}"
                                                           class="text-blue-500 hover:text-blue-700 text-sm">
                                                            <i class="fa-solid fa-pen-to-square"></i>
                                                        </a>
                                                        <form action="${pageContext.request.contextPath}/admin/opciones"
                                                              method="post" class="inline">
                                                            <input type="hidden" name="action" value="toggleOpcionProducto">
                                                            <input type="hidden" name="id" value="${op.id}">
                                                            <input type="hidden" name="productoId" value="${productoSeleccionado.id}">
                                                            <input type="hidden" name="activo" value="${op.activo ? '0' : '1'}">
                                                            <button type="submit"
                                                                    class="${op.activo ? 'text-red-400 hover:text-red-600' : 'text-green-500 hover:text-green-700'} text-sm"
                                                                    title="${op.activo ? 'Desactivar' : 'Activar'}">
                                                                <i class="fa-solid ${op.activo ? 'fa-toggle-on' : 'fa-toggle-off'}"></i>
                                                            </button>
                                                        </form>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        <c:if test="${empty opcionesProducto}">
                                            <tr>
                                                <td colspan="5" class="px-4 py-6 text-center text-gray-400 text-sm">
                                                    No hay opciones para este producto
                                                </td>
                                            </tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>

                        </c:when>
                        <c:otherwise>
                            <div class="bg-white rounded-2xl shadow p-12 text-center text-gray-400">
                                <i class="fa-solid fa-hand-pointer text-4xl mb-3 text-gray-300"></i>
                                <p class="font-medium">Selecciona un producto para ver y gestionar sus opciones</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <!-- ── TAB PROMOCIONES ── -->
        <div id="secPromociones" class="${tab == 'promociones' ? '' : 'hidden'}">
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6">

                <!-- Lista de promociones -->
                <div class="bg-white rounded-2xl shadow p-4">
                    <h3 class="font-semibold text-gray-700 mb-3 text-sm uppercase tracking-wide">
                        Selecciona una promoción
                    </h3>
                    <div class="flex flex-col gap-1 max-h-[500px] overflow-y-auto">
                        <c:forEach items="${promociones}" var="prom">
                            <a href="${pageContext.request.contextPath}/admin/opciones?promocionId=${prom.id}&tab=promociones"
                               class="flex items-center gap-2 px-3 py-2 rounded-lg text-sm transition
                                      ${not empty promocionSeleccionada and promocionSeleccionada.id == prom.id
                                        ? 'bg-red-600 text-white font-semibold'
                                        : 'hover:bg-red-50 hover:text-red-600 text-gray-700'}">
                                <i class="fa-solid fa-tag text-xs"></i>
                                ${prom.nombre}
                            </a>
                        </c:forEach>
                    </div>
                </div>

                <!-- Opciones de la promoción seleccionada -->
                <div class="md:col-span-2">
                    <c:choose>
                        <c:when test="${not empty promocionSeleccionada}">

                            <!-- Formulario crear/editar -->
                            <div class="bg-white rounded-2xl shadow p-6 mb-4">
                                <h3 class="font-semibold text-gray-700 mb-4">
                                    <c:choose>
                                        <c:when test="${not empty opcionPromoEditar}">
                                            ✏️ Editar opción de <strong>${promocionSeleccionada.nombre}</strong>
                                        </c:when>
                                        <c:otherwise>
                                            ➕ Nueva opción para <strong>${promocionSeleccionada.nombre}</strong>
                                        </c:otherwise>
                                    </c:choose>
                                </h3>
                                <form action="${pageContext.request.contextPath}/admin/opciones"
                                      method="post" class="grid grid-cols-1 md:grid-cols-2 gap-4"
                                      onsubmit="return procesarGrupoPromocion(this)">
                                    <c:choose>
                                        <c:when test="${not empty opcionPromoEditar}">
                                            <input type="hidden" name="action" value="actualizarOpcionPromocion">
                                            <input type="hidden" name="id" value="${opcionPromoEditar.id}">
                                        </c:when>
                                        <c:otherwise>
                                            <input type="hidden" name="action" value="crearOpcionPromocion">
                                        </c:otherwise>
                                    </c:choose>
                                    <input type="hidden" name="promocionId" value="${promocionSeleccionada.id}">

                                    <div>
                                        <label class="block text-sm font-medium text-gray-600 mb-1">Nombre</label>
                                        <input type="text" name="nombre" required
                                               value="${opcionPromoEditar.nombre}"
                                               placeholder="Ej: Gaseosa 1.5L Inca Kola"
                                               class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-400">
                                    </div>

                                    <div>
                                        <label class="block text-sm font-medium text-gray-600 mb-1">Grupo</label>
                                        <select name="grupo" id="grupoPromocion"
                                                onchange="toggleNuevoGrupo('grupoPromocion', 'nuevoGrupoPromocion')"
                                                class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-400">
                                            <c:set var="gruposPromo" value="Bebida,Guarnición,Otro..."/>
                                            <c:forTokens items="${gruposPromo}" delims="," var="g">
                                                <option value="${g}" ${opcionPromoEditar.grupo == g ? 'selected' : ''}>${g}</option>
                                            </c:forTokens>
                                        </select>
                                        <!-- Campo nuevo grupo promocion -->
                                        <input type="text" id="nuevoGrupoPromocion"
                                               placeholder="Escribe el nuevo grupo..."
                                               class="hidden w-full border rounded-lg px-3 py-2 text-sm mt-2 focus:outline-none focus:ring-2 focus:ring-red-400">
                                    </div>

                                    <div>
                                        <label class="block text-sm font-medium text-gray-600 mb-1">Precio adicional (S/)</label>
                                        <input type="number" name="precioAdicional" step="0.01" min="0"
                                               value="${not empty opcionPromoEditar ? opcionPromoEditar.precioAdicional : '0.00'}"
                                               class="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-400">
                                    </div>

                                    <div class="flex items-end gap-2">
                                        <button type="submit"
                                                class="bg-red-600 hover:bg-red-700 text-white px-5 py-2 rounded-lg text-sm font-semibold transition">
                                            <c:choose>
                                                <c:when test="${not empty opcionPromoEditar}">
                                                    <i class="fa-solid fa-floppy-disk mr-1"></i> Actualizar
                                                </c:when>
                                                <c:otherwise>
                                                    <i class="fa-solid fa-plus mr-1"></i> Crear
                                                </c:otherwise>
                                            </c:choose>
                                        </button>
                                        <c:if test="${not empty opcionPromoEditar}">
                                            <a href="${pageContext.request.contextPath}/admin/opciones?promocionId=${promocionSeleccionada.id}&tab=promociones"
                                               class="bg-gray-200 hover:bg-gray-300 text-gray-700 px-5 py-2 rounded-lg text-sm font-semibold transition">
                                                Cancelar
                                            </a>
                                        </c:if>
                                    </div>
                                </form>
                            </div>

                            <!-- Tabla de opciones -->
                            <div class="bg-white rounded-2xl shadow overflow-hidden">
                                <div class="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
                                    <h3 class="font-semibold text-gray-700">
                                        Opciones de ${promocionSeleccionada.nombre}
                                    </h3>
                                    <span class="text-xs text-gray-400">
                                        ${fn:length(opcionesPromocion)} opciones
                                    </span>
                                </div>
                                <table class="w-full text-sm">
                                    <thead class="bg-gray-50 text-gray-600 uppercase text-xs">
                                        <tr>
                                            <th class="px-4 py-3 text-left">Nombre</th>
                                            <th class="px-4 py-3 text-left">Grupo</th>
                                            <th class="px-4 py-3 text-left">Precio extra</th>
                                            <th class="px-4 py-3 text-center">Estado</th>
                                            <th class="px-4 py-3 text-center">Acciones</th>
                                        </tr>
                                    </thead>
                                    <tbody class="divide-y divide-gray-100">
                                        <c:forEach items="${opcionesPromocion}" var="op">
                                            <tr class="hover:bg-gray-50 ${!op.activo ? 'opacity-50' : ''}">
                                                <td class="px-4 py-3 font-medium">${op.nombre}</td>
                                                <td class="px-4 py-3">
                                                    <span class="px-2 py-1 rounded-full text-xs font-semibold bg-blue-100 text-blue-600">
                                                        ${op.grupo}
                                                    </span>
                                                </td>
                                                <td class="px-4 py-3 text-red-600 font-semibold">
                                                    <c:choose>
                                                        <c:when test="${op.precioAdicional > 0}">
                                                            +S/<fmt:formatNumber value="${op.precioAdicional}" pattern="#,##0.00"/>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-gray-400">Incluido</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="px-4 py-3 text-center">
                                                    <span class="px-2 py-1 rounded-full text-xs font-semibold
                                                        ${op.activo ? 'bg-green-100 text-green-600' : 'bg-gray-100 text-gray-500'}">
                                                        ${op.activo ? 'Activo' : 'Inactivo'}
                                                    </span>
                                                </td>
                                                <td class="px-4 py-3 text-center">
                                                    <div class="flex items-center justify-center gap-2">
                                                        <a href="${pageContext.request.contextPath}/admin/opciones?promocionId=${promocionSeleccionada.id}&tab=promociones&editPRO=${op.id}"
                                                           class="text-blue-500 hover:text-blue-700 text-sm">
                                                            <i class="fa-solid fa-pen-to-square"></i>
                                                        </a>
                                                        <form action="${pageContext.request.contextPath}/admin/opciones"
                                                              method="post" class="inline">
                                                            <input type="hidden" name="action" value="toggleOpcionPromocion">
                                                            <input type="hidden" name="id" value="${op.id}">
                                                            <input type="hidden" name="promocionId" value="${promocionSeleccionada.id}">
                                                            <input type="hidden" name="activo" value="${op.activo ? '0' : '1'}">
                                                            <button type="submit"
                                                                    class="${op.activo ? 'text-red-400 hover:text-red-600' : 'text-green-500 hover:text-green-700'} text-sm"
                                                                    title="${op.activo ? 'Desactivar' : 'Activar'}">
                                                                <i class="fa-solid ${op.activo ? 'fa-toggle-on' : 'fa-toggle-off'}"></i>
                                                            </button>
                                                        </form>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        <c:if test="${empty opcionesPromocion}">
                                            <tr>
                                                <td colspan="5" class="px-4 py-6 text-center text-gray-400 text-sm">
                                                    No hay opciones para esta promoción
                                                </td>
                                            </tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>

                        </c:when>
                        <c:otherwise>
                            <div class="bg-white rounded-2xl shadow p-12 text-center text-gray-400">
                                <i class="fa-solid fa-hand-pointer text-4xl mb-3 text-gray-300"></i>
                                <p class="font-medium">Selecciona una promoción para ver y gestionar sus opciones</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

    </main>
</div>

<script>
    // Cambiar entre tabs
    function cambiarTab(tab, btn) {
        document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('activo'));
        btn.classList.add('activo');
        document.getElementById('secProductos').classList.toggle('hidden', tab !== 'productos');
        document.getElementById('secPromociones').classList.toggle('hidden', tab !== 'promociones');
    }

    // Mostrar/ocultar campo nuevo grupo
    function toggleNuevoGrupo(selectId, inputId) {
        const select = document.getElementById(selectId);
        const input  = document.getElementById(inputId);
        if (select.value === 'Otro...') {
            input.classList.remove('hidden');
            input.required = true;
        } else {
            input.classList.add('hidden');
            input.required = false;
            input.value = '';
        }
    }

    // Antes de enviar el form de producto, si es "Otro..." reemplazar valor del select
    function procesarGrupoProducto(form) {
        const select = document.getElementById('grupoProducto');
        const input  = document.getElementById('nuevoGrupoProducto');
        if (select.value === 'Otro...') {
            if (!input.value.trim()) {
                alert('Por favor escribe el nombre del nuevo grupo.');
                return false;
            }
            // Crear opción temporal y seleccionarla
            const opt = document.createElement('option');
            opt.value = input.value.trim();
            opt.selected = true;
            select.appendChild(opt);
            select.value = input.value.trim();
        }
        return true;
    }

    // Antes de enviar el form de promoción
    function procesarGrupoPromocion(form) {
        const select = document.getElementById('grupoPromocion');
        const input  = document.getElementById('nuevoGrupoPromocion');
        if (select.value === 'Otro...') {
            if (!input.value.trim()) {
                alert('Por favor escribe el nombre del nuevo grupo.');
                return false;
            }
            const opt = document.createElement('option');
            opt.value = input.value.trim();
            opt.selected = true;
            select.appendChild(opt);
            select.value = input.value.trim();
        }
        return true;
    }
</script>
</body>
</html>