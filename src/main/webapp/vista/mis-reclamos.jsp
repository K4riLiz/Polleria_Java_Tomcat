<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <title>Mis Reclamos - El Dorado</title>
</head>
<body class="bg-gray-50 min-h-screen">

    <jsp:include page="/components/header.jsp"/>

    <div class="max-w-4xl mx-auto px-4 py-10">

        <div class="flex items-center justify-between mb-6">
            <h1 class="text-2xl font-bold text-gray-800 flex items-center gap-3">
                <i class="fa-solid fa-clipboard-list text-red-600"></i> Mis Reclamos
            </h1>
            <a href="${pageContext.request.contextPath}/libro-reclamaciones"
               class="bg-red-600 hover:bg-red-700 text-white text-sm font-semibold px-4 py-2 rounded-xl transition flex items-center gap-2">
                <i class="fa-solid fa-plus"></i> Nuevo reclamo
            </a>
        </div>

        <c:if test="${not empty error}">
            <div class="bg-red-100 border border-red-300 text-red-700 px-4 py-3 rounded-xl mb-4">
                <i class="fa-solid fa-triangle-exclamation mr-2"></i><c:out value="${error}"/>
            </div>
        </c:if>

        <div class="bg-white rounded-2xl shadow-sm overflow-hidden">
            <c:choose>
                <c:when test="${empty reclamaciones}">
                    <div class="text-center py-16 text-gray-400">
                        <i class="fa-solid fa-inbox text-5xl mb-4"></i>
                        <p class="mb-4">Aún no has registrado ningún reclamo.</p>
                        <a href="${pageContext.request.contextPath}/libro-reclamaciones"
                           class="text-red-600 hover:underline text-sm font-semibold">
                            Registrar un reclamo
                        </a>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="overflow-x-auto">
                        <table class="w-full text-sm">
                            <thead class="bg-gray-50 text-gray-600 uppercase text-xs">
                                <tr>
                                    <th class="px-4 py-3 text-left">#</th>
                                    <th class="px-4 py-3 text-left">Fecha</th>
                                    <th class="px-4 py-3 text-left">Tipo</th>
                                    <th class="px-4 py-3 text-left">Asunto</th>
                                    <th class="px-4 py-3 text-left">Estado</th>
                                    <th class="px-4 py-3 text-left">Acción</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-gray-100">
                                <c:forEach items="${reclamaciones}" var="r">
                                    <tr class="hover:bg-gray-50">
                                        <td class="px-4 py-3 text-gray-400">${r.id}</td>
                                        <td class="px-4 py-3 text-gray-500 text-xs whitespace-nowrap">
                                            <c:out value="${r.fecha}"/>
                                        </td>
                                        <td class="px-4 py-3">
                                            <span class="px-2 py-1 rounded-full text-xs font-semibold
                                                ${r.tipoReclamo == 'Reclamo' ? 'bg-red-100 text-red-600' : 'bg-orange-100 text-orange-600'}">
                                                <c:out value="${r.tipoReclamo}"/>
                                            </span>
                                        </td>
                                        <td class="px-4 py-3 text-gray-700 max-w-[200px]">
                                            <p class="truncate"><c:out value="${r.asunto}"/></p>
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
                                            <button onclick="abrirModal('modal-${r.id}')"
                                                    class="bg-gray-100 hover:bg-gray-200 text-gray-700 px-3 py-1.5 rounded-lg text-xs flex items-center gap-1 transition">
                                                <i class="fa-solid fa-eye"></i> Ver detalle
                                            </button>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- MODALES DETALLE CLIENTE -->
    <c:forEach items="${reclamaciones}" var="r">
    <div id="modal-${r.id}"
         class="fixed inset-0 bg-black/50 z-50 hidden flex items-center justify-center p-4">
        <div class="bg-white rounded-2xl shadow-xl w-full max-w-lg max-h-[85vh] overflow-y-auto">
            <div class="flex items-center justify-between px-6 py-4 border-b">
                <h3 class="font-bold text-gray-800 flex items-center gap-2">
                    <i class="fa-solid fa-file-lines text-red-600"></i>
                    Reclamo #${r.id}
                </h3>
                <button onclick="cerrarModal('modal-${r.id}')"
                        class="text-gray-400 hover:text-gray-600 text-xl">
                    <i class="fa-solid fa-xmark"></i>
                </button>
            </div>
            <div class="px-6 py-5 space-y-4 text-sm">
                <div class="grid grid-cols-2 gap-3">
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
                <c:if test="${r.estado == 'Respondido'}">
                    <div class="bg-green-50 border border-green-200 rounded-xl p-4">
                        <p class="text-xs text-green-600 uppercase font-semibold mb-1">
                            <i class="fa-solid fa-reply mr-1"></i> Respuesta del administrador
                        </p>
                        <p class="text-gray-700 whitespace-pre-wrap"><c:out value="${r.respuestaAdmin}"/></p>
                        <p class="text-xs text-gray-400 mt-2">
                            <i class="fa-solid fa-clock mr-1"></i> Fecha de respuesta:
                            <c:out value="${r.fechaRespuesta}"/>
                        </p>
                    </div>
                </c:if>
            </div>
            <div class="px-6 py-4 border-t flex justify-end">
                <button onclick="cerrarModal('modal-${r.id}')"
                        class="bg-gray-200 hover:bg-gray-300 text-gray-700 px-4 py-2 rounded-lg text-sm font-semibold transition">
                    Cerrar
                </button>
            </div>
        </div>
    </div>
    </c:forEach>

    <jsp:include page="/components/footer.jsp"/>

    <script>
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
    </script>
    <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
    <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
</body>
</html>
