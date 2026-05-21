<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <title>Admin - Roles</title>
</head>
<body class="bg-gray-100 min-h-screen">

    <div class="flex min-h-screen">

        <%-- SIDEBAR --%>
        <aside class="w-64 bg-gray-900 text-white flex flex-col">
            <div class="p-6 border-b border-gray-700">
                <h1 class="text-xl font-bold text-red-400"> Hola, admin</h1>
                <p class="text-xs text-gray-400 mt-1">${sessionScope.usuario.nombre}</p>
            </div>
            <nav class="flex flex-col p-4 gap-2 flex-1">
                <a href="${pageContext.request.contextPath}/admin/usuarios"
                   class="flex items-center gap-3 px-4 py-2 rounded-lg hover:bg-gray-700 transition">
                    <i class="fa-solid fa-users"></i> Usuarios
                </a>
                <a href="${pageContext.request.contextPath}/admin/roles"
                   class="flex items-center gap-3 px-4 py-2 rounded-lg bg-red-600 text-white font-medium">
                    <i class="fa-solid fa-shield-halved"></i> Roles
                </a>
                <a href="${pageContext.request.contextPath}/admin/productos"
                    class="flex items-center gap-3 px-4 py-2 rounded-lg hover:bg-gray-700 transition">
                    <i class="fa-solid fa-bowl-food"></i> Productos
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

        <%-- CONTENIDO PRINCIPAL --%>
        <main class="flex-1 p-8">
            <h2 class="text-2xl font-bold text-gray-800 mb-6">Gestión de Roles</h2>

            <%-- ALERTAS --%>
            <c:if test="${not empty sessionScope.exito}">
                <div class="bg-green-100 text-green-700 px-4 py-3 rounded-lg mb-4">
                    ${sessionScope.exito}
                    <c:remove var="exito" scope="session"/>
                </div>
            </c:if>
            <c:if test="${not empty sessionScope.error}">
                <div class="bg-red-100 text-red-700 px-4 py-3 rounded-lg mb-4">
                    ${sessionScope.error}
                    <c:remove var="error" scope="session"/>
                </div>
            </c:if>

            <%-- FORMULARIO CREAR / EDITAR --%>
            <div class="bg-white rounded-2xl shadow p-6 mb-8 max-w-md">
                <h3 class="text-lg font-semibold mb-4">
                    <c:choose>
                        <c:when test="${not empty rolEditar}">✏️ Editar Rol</c:when>
                        <c:otherwise>➕ Nuevo Rol</c:otherwise>
                    </c:choose>
                </h3>

                <form action="${pageContext.request.contextPath}/admin/roles" method="post" class="flex gap-3">
                    <c:choose>
                        <c:when test="${not empty rolEditar}">
                            <input type="hidden" name="action" value="actualizar">
                            <input type="hidden" name="id" value="${rolEditar.id}">
                        </c:when>
                        <c:otherwise>
                            <input type="hidden" name="action" value="crear">
                        </c:otherwise>
                    </c:choose>

                    <input type="text" name="nombre" required
                           value="${rolEditar.nombre}"
                           placeholder="Nombre del rol"
                           class="flex-1 border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-400">

                    <button type="submit"
                            class="bg-red-600 hover:bg-red-700 text-white px-5 py-2 rounded-lg text-sm font-semibold transition">
                        <c:choose>
                            <c:when test="${not empty rolEditar}">Actualizar</c:when>
                            <c:otherwise>Crear</c:otherwise>
                        </c:choose>
                    </button>

                    <c:if test="${not empty rolEditar}">
                        <a href="${pageContext.request.contextPath}/admin/roles"
                           class="bg-gray-200 hover:bg-gray-300 text-gray-700 px-4 py-2 rounded-lg text-sm font-semibold transition">
                            Cancelar
                        </a>
                    </c:if>
                </form>
            </div>

            <%-- TABLA ROLES --%>
            <div class="bg-white rounded-2xl shadow overflow-hidden max-w-lg">
                <table class="w-full text-sm">
                    <thead class="bg-gray-50 text-gray-600 uppercase text-xs">
                        <tr>
                            <th class="px-4 py-3 text-left">#</th>
                            <th class="px-4 py-3 text-left">Nombre</th>
                            <th class="px-4 py-3 text-center">Acciones</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100">
                        <c:forEach items="${roles}" var="rol">
                            <tr class="hover:bg-gray-50">
                                <td class="px-4 py-3 text-gray-400">${rol.id}</td>
                                <td class="px-4 py-3 font-medium">
                                    <span class="px-2 py-1 rounded-full text-xs font-semibold
                                        ${rol.nombre == 'ADMIN' ? 'bg-red-100 text-red-600' : 'bg-blue-100 text-blue-600'}">
                                        ${rol.nombre}
                                    </span>
                                </td>
                                <td class="px-4 py-3 text-center">
                                    <a href="${pageContext.request.contextPath}/admin/roles?action=editar&id=${rol.id}"
                                       class="text-blue-500 hover:text-blue-700 mr-3" title="Editar">
                                        <i class="fa-solid fa-pen-to-square"></i>
                                    </a>
                                    <form action="${pageContext.request.contextPath}/admin/roles"
                                          method="post" class="inline"
                                          onsubmit="return confirm('¿Eliminar este rol?')">
                                        <input type="hidden" name="action" value="eliminar">
                                        <input type="hidden" name="id" value="${rol.id}">
                                        <button type="submit" class="text-red-500 hover:text-red-700" title="Eliminar">
                                            <i class="fa-solid fa-trash"></i>
                                        </button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </main>
    </div>

</body>
</html>
