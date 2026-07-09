<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <title>Libro de Reclamaciones - El Dorado</title>
</head>
<body class="bg-gray-50 min-h-screen">

    <jsp:include page="/components/header.jsp"/>

    <div class="max-w-2xl mx-auto px-4 py-12">

        <!-- ENCABEZADO -->
        <div class="text-center mb-8">
            <div class="inline-flex items-center justify-center w-16 h-16 bg-red-100 rounded-full mb-4">
                <i class="fa-solid fa-book-open text-3xl text-red-600"></i>
            </div>
            <h1 class="text-2xl font-bold text-gray-800">Libro de Reclamaciones</h1>
            <p class="text-gray-500 text-sm mt-2">
                Conforme a lo establecido en el Código de Protección y Defensa del Consumidor
            </p>
        </div>

        <!-- ALERTA ÉXITO -->
        <c:if test="${not empty sessionScope.exito}">
            <div class="bg-green-100 border border-green-300 text-green-700 px-4 py-4 rounded-xl mb-6 flex items-start gap-3">
                <i class="fa-solid fa-circle-check text-xl mt-0.5"></i>
                <div>
                    <p class="font-semibold">Reclamo registrado exitosamente</p>
                    <p class="text-sm"><c:out value="${sessionScope.exito}"/></p>
                    <p class="text-sm mt-1">Nos comunicaremos contigo en un plazo de 30 días hábiles.</p>
                </div>
            </div>
            <c:remove var="exito" scope="session"/>
        </c:if>

        <!-- ALERTA ERROR -->
        <c:if test="${not empty error}">
            <div class="bg-red-100 border border-red-300 text-red-700 px-4 py-3 rounded-xl mb-6">
                <i class="fa-solid fa-triangle-exclamation mr-2"></i><c:out value="${error}"/>
            </div>
        </c:if>

        <!-- FORMULARIO -->
        <div class="bg-white rounded-2xl shadow-sm p-8">

            <form action="${pageContext.request.contextPath}/libro-reclamaciones" method="post"
                  class="flex flex-col gap-5" id="formReclamo" onsubmit="return enviarReclamo()">

                <!-- Tipo de reclamo -->
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-2">Tipo de registro</label>
                    <div class="grid grid-cols-2 gap-3">
                        <label class="flex items-center gap-2 border-2 border-gray-200 rounded-xl px-4 py-3 cursor-pointer hover:border-red-400 transition has-[:checked]:border-red-500 has-[:checked]:bg-red-50">
                            <input type="radio" name="tipoReclamo" value="Reclamo" checked class="accent-red-600">
                            <div>
                                <p class="font-semibold text-sm">Reclamo</p>
                                <p class="text-xs text-gray-400">Disconformidad con el servicio</p>
                            </div>
                        </label>
                        <label class="flex items-center gap-2 border-2 border-gray-200 rounded-xl px-4 py-3 cursor-pointer hover:border-red-400 transition has-[:checked]:border-red-500 has-[:checked]:bg-red-50">
                            <input type="radio" name="tipoReclamo" value="Queja" class="accent-red-600">
                            <div>
                                <p class="font-semibold text-sm">Queja</p>
                                <p class="text-xs text-gray-400">Malestar sin afectación económica</p>
                            </div>
                        </label>
                    </div>
                </div>

                <hr class="border-gray-100">

                <!-- Datos personales -->
                <h3 class="text-sm font-semibold text-gray-500 uppercase tracking-wide">Datos del consumidor</h3>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-600 mb-1">Nombre completo *</label>
                        <input type="text" name="nombre" required
                               value="${not empty sessionScope.usuario ? sessionScope.usuario.nombre : ''}"
                               class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-red-300">
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-600 mb-1">Correo electrónico *</label>
                        <input type="email" name="email" required
                               value="${not empty sessionScope.usuario ? sessionScope.usuario.email : ''}"
                               class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-red-300">
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-600 mb-1">Teléfono</label>
                        <input type="text" name="telefono"
                               class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-red-300">
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-600 mb-1">Tipo de documento *</label>
                        <select name="tipoDocumento" required
                                class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-red-300">
                            <option value="DNI">DNI</option>
                            <option value="CE">Carnet de Extranjería</option>
                            <option value="Pasaporte">Pasaporte</option>
                        </select>
                    </div>
                    <div class="md:col-span-2">
                        <label class="block text-sm font-medium text-gray-600 mb-1">Número de documento *</label>
                        <input type="text" name="numeroDocumento" required maxlength="20"
                               class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-red-300">
                    </div>
                </div>

                <hr class="border-gray-100">

                <!-- Detalle del reclamo -->
                <h3 class="text-sm font-semibold text-gray-500 uppercase tracking-wide">Detalle</h3>

                <div>
                    <label class="block text-sm font-medium text-gray-600 mb-1">N° de pedido (opcional)</label>
                    <input type="text" name="pedidoId" placeholder="Ej: 12345"
                           class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-red-300">
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-600 mb-1">Asunto *</label>
                    <input type="text" name="asunto" required maxlength="200"
                           placeholder="Resumen breve de su reclamo o queja"
                           class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-red-300">
                    <p class="text-xs text-gray-400 mt-1">Máximo 200 caracteres</p>
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-600 mb-1">Descripción del reclamo *</label>
                    <textarea name="descripcion" required rows="5" maxlength="2000"
                              placeholder="Describe detalladamente tu reclamo o queja..."
                              class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-red-300 resize-none"></textarea>
                    <p class="text-xs text-gray-400 mt-1">Máximo 2000 caracteres</p>
                </div>

                <p class="text-xs text-gray-400">
                    <i class="fa-solid fa-circle-info mr-1"></i>
                    La empresa responderá tu reclamo en un plazo máximo de 30 días hábiles.
                </p>

                <button type="submit" id="btnEnviarReclamo"
                        class="w-full bg-red-600 hover:bg-red-700 text-white font-bold py-3 rounded-xl transition flex items-center justify-center gap-2">
                    <i class="fa-solid fa-paper-plane"></i> Enviar reclamo
                </button>

            </form>
        </div>
    </div>

    <jsp:include page="/components/footer.jsp"/>

    <script>
        function enviarReclamo() {
            var btn = document.getElementById('btnEnviarReclamo');
            if (btn.disabled) return false;
            btn.disabled = true;
            btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Enviando...';
            return true;
        }
    </script>
    <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
    <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
</body>
</html>
