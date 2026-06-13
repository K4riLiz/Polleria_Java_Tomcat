<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <title>Admin - Reclamaciones</title>
</head>
<body class="bg-gray-100 min-h-screen">

<div class="flex min-h-screen">

    <!-- SIDEBAR -->
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

    <!-- CONTENIDO -->
    <main class="flex-1 p-8 overflow-auto">
        <h2 class="text-2xl font-bold text-gray-800 mb-6">
            <i class="fa-solid fa-book-open text-red-600 mr-2"></i>Libro de Reclamaciones
        </h2>

        <c:if test="${not empty error}">
            <div class="bg-red-100 text-red-700 px-4 py-3 rounded-lg mb-4">${error}</div>
        </c:if>

        <!-- ESTADÍSTICAS -->
        <div class="grid grid-cols-3 gap-4 mb-8">
            <div class="bg-white rounded-2xl shadow p-5 text-center">
                <p class="text-3xl font-bold text-gray-800">${reclamaciones.size()}</p>
                <p class="text-sm text-gray-500 mt-1">Total registros</p>
            </div>
            <div class="bg-white rounded-2xl shadow p-5 text-center">
                <p class="text-3xl font-bold text-red-600">
                    <c:set var="reclamos" value="0"/>
                    <c:forEach items="${reclamaciones}" var="r">
                        <c:if test="${r.tipoReclamo == 'Reclamo'}">
                            <c:set var="reclamos" value="${reclamos + 1}"/>
                        </c:if>
                    </c:forEach>
                    ${reclamos}
                </p>
                <p class="text-sm text-gray-500 mt-1">Reclamos</p>
            </div>
            <div class="bg-white rounded-2xl shadow p-5 text-center">
                <p class="text-3xl font-bold text-orange-500">
                    <c:set var="quejas" value="0"/>
                    <c:forEach items="${reclamaciones}" var="r">
                        <c:if test="${r.tipoReclamo == 'Queja'}">
                            <c:set var="quejas" value="${quejas + 1}"/>
                        </c:if>
                    </c:forEach>
                    ${quejas}
                </p>
                <p class="text-sm text-gray-500 mt-1">Quejas</p>
            </div>
        </div>

        <!-- TABLA -->
        <div class="bg-white rounded-2xl shadow overflow-hidden">
            <c:choose>
                <c:when test="${empty reclamaciones}">
                    <div class="text-center py-16 text-gray-400">
                        <i class="fa-solid fa-book-open text-5xl mb-4"></i>
                        <p>No hay reclamaciones registradas aún.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <table class="w-full text-sm">
                        <thead class="bg-gray-50 text-gray-600 uppercase text-xs">
                            <tr>
                                <th class="px-4 py-3 text-left">#</th>
                                <th class="px-4 py-3 text-left">Tipo</th>
                                <th class="px-4 py-3 text-left">Cliente</th>
                                <th class="px-4 py-3 text-left">Email</th>
                                <th class="px-4 py-3 text-left">Documento</th>
                                <th class="px-4 py-3 text-left">Descripción</th>
                                <th class="px-4 py-3 text-left">Fecha</th>
                                <th class="px-4 py-3 text-left">Estado</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100">
                            <c:forEach items="${reclamaciones}" var="r">
                                <tr class="hover:bg-gray-50">
                                    <td class="px-4 py-3 text-gray-400">${r.id}</td>
                                    <td class="px-4 py-3">
                                        <span class="px-2 py-1 rounded-full text-xs font-semibold
                                            ${r.tipoReclamo == 'Reclamo' ? 'bg-red-100 text-red-600' : 'bg-orange-100 text-orange-600'}">
                                            ${r.tipoReclamo}
                                        </span>
                                    </td>
                                    <td class="px-4 py-3 font-medium">${r.nombre}</td>
                                    <td class="px-4 py-3 text-gray-500">${r.email}</td>
                                    <td class="px-4 py-3 text-gray-500">${r.tipoDocumento}: ${r.numeroDocumento}</td>
                                    <td class="px-4 py-3 text-gray-500 max-w-xs">
                                        <p class="truncate" title="${r.descripcion}">${r.descripcion}</p>
                                    </td>
                                    <td class="px-4 py-3 text-gray-400 text-xs">${r.fecha}</td>
                                    <td class="px-4 py-3">
                                        <span class="px-2 py-1 rounded-full text-xs font-semibold
                                            ${r.estado == 'Pendiente' ? 'bg-yellow-100 text-yellow-600' :
                                              r.estado == 'En proceso' ? 'bg-blue-100 text-blue-600' :
                                              'bg-green-100 text-green-600'}">
                                            ${r.estado}
                                        </span>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:otherwise>
            </c:choose>
        </div>
    </main>
</div>

</body>
</html>
