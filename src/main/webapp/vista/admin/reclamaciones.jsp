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
    <aside class="w-64 bg-gray-900 text-white flex flex-col">
        <div class="p-6 border-b border-gray-700">
            <h1 class="text-xl font-bold text-red-400">Hola, admin</h1>
            <p class="text-xs text-gray-400 mt-1"><c:out value="${sessionScope.usuario.nombre}"/></p>
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
               class="flex items-center gap-3 px-4 py-2 rounded-lg hover:bg-gray-700 transition">
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
               class="flex items-center gap-3 px-4 py-2 rounded-lg bg-red-600 text-white font-medium">
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

        <!-- ALERTAS -->
        <c:if test="${not empty sessionScope.exito}">
            <div class="bg-green-100 border border-green-300 text-green-700 px-4 py-3 rounded-xl mb-4 flex items-center gap-2">
                <i class="fa-solid fa-circle-check"></i>
                <c:out value="${sessionScope.exito}"/>
                <c:remove var="exito" scope="session"/>
            </div>
        </c:if>
        <c:if test="${not empty sessionScope.error}">
            <div class="bg-red-100 border border-red-300 text-red-700 px-4 py-3 rounded-xl mb-4 flex items-center gap-2">
                <i class="fa-solid fa-triangle-exclamation"></i>
                <c:out value="${sessionScope.error}"/>
                <c:remove var="error" scope="session"/>
            </div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="bg-red-100 text-red-700 px-4 py-3 rounded-lg mb-4"><c:out value="${error}"/></div>
        </c:if>

        <!-- ESTADÍSTICAS -->
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
            <div class="bg-white rounded-2xl shadow p-5 text-center">
                <p class="text-3xl font-bold text-gray-800">${reclamaciones.size()}</p>
                <p class="text-sm text-gray-500 mt-1">Total</p>
            </div>
            <div class="bg-white rounded-2xl shadow p-5 text-center">
                <c:set var="pendientes" value="0"/>
                <c:forEach items="${reclamaciones}" var="r">
                    <c:if test="${r.estado == 'Pendiente'}"><c:set var="pendientes" value="${pendientes + 1}"/></c:if>
                </c:forEach>
                <p class="text-3xl font-bold text-yellow-500">${pendientes}</p>
                <p class="text-sm text-gray-500 mt-1">Pendientes</p>
            </div>
            <div class="bg-white rounded-2xl shadow p-5 text-center">
                <c:set var="reclamos" value="0"/>
                <c:forEach items="${reclamaciones}" var="r">
                    <c:if test="${r.tipoReclamo == 'Reclamo'}"><c:set var="reclamos" value="${reclamos + 1}"/></c:if>
                </c:forEach>
                <p class="text-3xl font-bold text-red-600">${reclamos}</p>
                <p class="text-sm text-gray-500 mt-1">Reclamos</p>
            </div>
            <div class="bg-white rounded-2xl shadow p-5 text-center">
                <c:set var="quejas" value="0"/>
                <c:forEach items="${reclamaciones}" var="r">
                    <c:if test="${r.tipoReclamo == 'Queja'}"><c:set var="quejas" value="${quejas + 1}"/></c:if>
                </c:forEach>
                <p class="text-3xl font-bold text-orange-500">${quejas}</p>
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
                    <div class="overflow-x-auto">
                        <table class="w-full text-sm">
                            <thead class="bg-gray-50 text-gray-600 uppercase text-xs">
                                <tr>
                                    <th class="px-4 py-3 text-left">#</th>
                                    <th class="px-4 py-3 text-left">Cliente</th>
                                    <th class="px-4 py-3 text-left">Fecha</th>
                                    <th class="px-4 py-3 text-left">Tipo</th>
                                    <th class="px-4 py-3 text-left">Asunto</th>
                                    <th class="px-4 py-3 text-left">Estado</th>
                                    <th class="px-4 py-3 text-left">Acciones</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-gray-100">
                                <c:forEach items="${reclamaciones}" var="r">
                                    <tr class="hover:bg-gray-50">
                                        <td class="px-4 py-3 text-gray-400">${r.id}</td>
                                        <td class="px-4 py-3">
                                            <p class="font-medium"><c:out value="${r.nombre}"/></p>
                                            <p class="text-xs text-gray-400"><c:out value="${r.email}"/></p>
                                        </td>
                                        <td class="px-4 py-3 text-gray-400 text-xs whitespace-nowrap">
                                            <c:out value="${r.fecha}"/>
                                        </td>
                                        <td class="px-4 py-3">
                                            <span class="px-2 py-1 rounded-full text-xs font-semibold
                                                ${r.tipoReclamo == 'Reclamo' ? 'bg-red-100 text-red-600' : 'bg-orange-100 text-orange-600'}">
                                                <c:out value="${r.tipoReclamo}"/>
                                            </span>
                                        </td>
                                        <td class="px-4 py-3 text-gray-600 max-w-[180px]">
                                            <p class="truncate" title="${r.asunto}"><c:out value="${r.asunto}"/></p>
                                        </td>
                                        <td class="px-4 py-3">
                                            <span class="px-2 py-1 rounded-full text-xs font-semibold
                                                ${r.estado == 'Pendiente' ? 'bg-yellow-100 text-yellow-600' :
                                                  r.estado == 'En proceso' ? 'bg-blue-100 text-blue-600' :
                                                  'bg-green-100 text-green-600'}">
                                                <c:out value="${r.estado}"/>
                                            </span>
                                        </td>
                                        <td class="px-4 py-3">
                                            <div class="flex gap-2">
                                                <button onclick="abrirModal('modal-detalle-${r.id}')"
                                                        class="bg-gray-100 hover:bg-gray-200 text-gray-700 px-3 py-1.5 rounded-lg text-xs flex items-center gap-1 transition">
                                                    <i class="fa-solid fa-eye"></i> Ver detalle
                                                </button>
                                                <c:if test="${r.estado != 'Respondido'}">
                                                    <button onclick="abrirResponder(${r.id})"
                                                            class="bg-red-600 hover:bg-red-700 text-white px-3 py-1.5 rounded-lg text-xs flex items-center gap-1 transition">
                                                        <i class="fa-solid fa-reply"></i> Responder
                                                    </button>
                                                </c:if>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </main>
</div>

<!-- MODALES DETALLE -->
<c:forEach items="${reclamaciones}" var="r">
<div id="modal-detalle-${r.id}"
     class="fixed inset-0 bg-black/50 z-50 hidden flex items-center justify-center p-4">
    <div class="bg-white rounded-2xl shadow-xl w-full max-w-lg max-h-[85vh] overflow-y-auto">
        <div class="flex items-center justify-between px-6 py-4 border-b">
            <h3 class="font-bold text-gray-800 flex items-center gap-2">
                <i class="fa-solid fa-file-lines text-red-600"></i>
                Reclamo #${r.id}
            </h3>
            <button onclick="cerrarModal('modal-detalle-${r.id}')"
                    class="text-gray-400 hover:text-gray-600 text-xl">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>
        <div class="px-6 py-5 space-y-4 text-sm">
            <div class="grid grid-cols-2 gap-3">
                <div>
                    <p class="text-xs text-gray-400 uppercase font-semibold">Cliente</p>
                    <p class="font-medium"><c:out value="${r.nombre}"/></p>
                </div>
                <div>
                    <p class="text-xs text-gray-400 uppercase font-semibold">Email</p>
                    <p><c:out value="${r.email}"/></p>
                </div>
                <div>
                    <p class="text-xs text-gray-400 uppercase font-semibold">Teléfono</p>
                    <p><c:out value="${r.telefono}"/></p>
                </div>
                <div>
                    <p class="text-xs text-gray-400 uppercase font-semibold">Documento</p>
                    <p><c:out value="${r.tipoDocumento}"/>: <c:out value="${r.numeroDocumento}"/></p>
                </div>
                <div>
                    <p class="text-xs text-gray-400 uppercase font-semibold">Fecha</p>
                    <p><c:out value="${r.fecha}"/></p>
                </div>
                <div>
                    <p class="text-xs text-gray-400 uppercase font-semibold">Tipo</p>
                    <span class="px-2 py-0.5 rounded-full text-xs font-semibold
                        ${r.tipoReclamo == 'Reclamo' ? 'bg-red-100 text-red-600' : 'bg-orange-100 text-orange-600'}">
                        <c:out value="${r.tipoReclamo}"/>
                    </span>
                </div>
                <div class="col-span-2">
                    <p class="text-xs text-gray-400 uppercase font-semibold">Estado</p>
                    <span class="px-2 py-0.5 rounded-full text-xs font-semibold
                        ${r.estado == 'Pendiente' ? 'bg-yellow-100 text-yellow-600' :
                          r.estado == 'En proceso' ? 'bg-blue-100 text-blue-600' :
                          'bg-green-100 text-green-600'}">
                        <c:out value="${r.estado}"/>
                    </span>
                </div>
            </div>
            <div>
                <p class="text-xs text-gray-400 uppercase font-semibold mb-1">Asunto</p>
                <p class="text-gray-700"><c:out value="${r.asunto}"/></p>
            </div>
            <div>
                <p class="text-xs text-gray-400 uppercase font-semibold mb-1">Descripción</p>
                <p class="text-gray-700 whitespace-pre-wrap"><c:out value="${r.descripcion}"/></p>
            </div>
            <c:if test="${not empty r.pedidoId}">
                <div>
                    <p class="text-xs text-gray-400 uppercase font-semibold mb-1">N° Pedido</p>
                    <p class="text-gray-700"><c:out value="${r.pedidoId}"/></p>
                </div>
            </c:if>
            <c:if test="${r.estado == 'Respondido'}">
                <div class="bg-green-50 border border-green-200 rounded-xl p-4">
                    <p class="text-xs text-green-600 uppercase font-semibold mb-1">
                        <i class="fa-solid fa-reply mr-1"></i> Respuesta del administrador
                    </p>
                    <p class="text-gray-700 whitespace-pre-wrap"><c:out value="${r.respuestaAdmin}"/></p>
                    <p class="text-xs text-gray-400 mt-2">
                        <i class="fa-solid fa-clock mr-1"></i>
                        <c:out value="${r.fechaRespuesta}"/>
                    </p>
                </div>
            </c:if>
        </div>
        <div class="px-6 py-4 border-t flex justify-end">
            <button onclick="cerrarModal('modal-detalle-${r.id}')"
                    class="bg-gray-200 hover:bg-gray-300 text-gray-700 px-4 py-2 rounded-lg text-sm font-semibold transition">
                Cerrar
            </button>
        </div>
    </div>
</div>
</c:forEach>

<!-- MODALES RESPONDER -->
<c:forEach items="${reclamaciones}" var="r">
<c:if test="${r.estado != 'Respondido'}">
<div id="modal-responder-${r.id}"
     class="fixed inset-0 bg-black/50 z-50 hidden flex items-center justify-center p-4">
    <div class="bg-white rounded-2xl shadow-xl w-full max-w-lg">
        <div class="flex items-center justify-between px-6 py-4 border-b">
            <h3 class="font-bold text-gray-800 flex items-center gap-2">
                <i class="fa-solid fa-reply text-red-600"></i>
                Responder reclamo #${r.id}
            </h3>
            <button onclick="cerrarModal('modal-responder-${r.id}')"
                    class="text-gray-400 hover:text-gray-600 text-xl">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>
        <form action="${pageContext.request.contextPath}/admin/reclamaciones" method="post"
              onsubmit="return enviarRespuesta(this)">
            <input type="hidden" name="action" value="responder">
            <input type="hidden" name="id" value="${r.id}">
            <div class="px-6 py-5 space-y-4">
                <div class="bg-gray-50 rounded-xl p-3 text-sm">
                    <p><strong>Cliente:</strong> <c:out value="${r.nombre}"/></p>
                    <p><strong>Asunto:</strong> <c:out value="${r.asunto}"/></p>
                </div>
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">
                        Respuesta del administrador *
                    </label>
                    <textarea name="respuestaAdmin" required rows="5" maxlength="2000"
                              placeholder="Escriba la respuesta oficial al cliente..."
                              class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-red-300 resize-none"></textarea>
                    <p class="text-xs text-gray-400 mt-1">Máximo 2000 caracteres</p>
                </div>
            </div>
            <div class="px-6 py-4 border-t flex justify-end gap-3">
                <button type="button" onclick="cerrarModal('modal-responder-${r.id}')"
                        class="bg-gray-200 hover:bg-gray-300 text-gray-700 px-4 py-2 rounded-lg text-sm font-semibold transition">
                    Cancelar
                </button>
                <button type="submit" id="btn-enviar-${r.id}"
                        class="bg-red-600 hover:bg-red-700 text-white px-5 py-2 rounded-lg text-sm font-semibold transition flex items-center gap-2">
                    <i class="fa-solid fa-paper-plane"></i> Enviar respuesta
                </button>
            </div>
        </form>
    </div>
</div>
</c:if>
</c:forEach>

<script>
    var contextPath = '${pageContext.request.contextPath}';

    function abrirModal(id) {
        document.getElementById(id).classList.remove('hidden');
        document.body.style.overflow = 'hidden';
    }
    function cerrarModal(id) {
        document.getElementById(id).classList.add('hidden');
        document.body.style.overflow = '';
    }
    document.querySelectorAll('[id^="modal-"]').forEach(function(modal) {
        modal.addEventListener('click', function(e) {
            if (e.target === this) cerrarModal(this.id);
        });
    });

    function abrirResponder(id) {
        fetch(contextPath + '/admin/reclamaciones?action=enProceso&id=' + id)
            .then(function() {
                var badge = document.getElementById('estado-badge-' + id);
                if (badge) {
                    badge.className = 'px-2 py-1 rounded-full text-xs font-semibold bg-blue-100 text-blue-600';
                    badge.textContent = 'En proceso';
                }
            });
        abrirModal('modal-responder-' + id);
    }

    function enviarRespuesta(form) {
        var btn = form.querySelector('button[type="submit"]');
        if (btn.disabled) return false;
        var textarea = form.querySelector('textarea');
        if (!textarea.value.trim()) {
            alert('La respuesta no puede estar vacía.');
            return false;
        }
        btn.disabled = true;
        btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Enviando...';
        return true;
    }
</script>

</body>
</html>
