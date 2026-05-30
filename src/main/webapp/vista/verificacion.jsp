<%-- 
    Document   : verificacion
    Created on : 30 may. 2026, 03:18:48
    Author     : Karina
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Verificación - Pollería El Dorado</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/login.css">
    <style>
        .verificacion-box {
            max-width: 400px;
            margin: 100px auto;
            padding: 40px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            text-align: center;
        }
        .verificacion-box h2 { margin-bottom: 10px; }
        .verificacion-box p  { color: #666; margin-bottom: 24px; font-size: 14px; }
        .verificacion-box input {
            width: 100%;
            padding: 12px;
            font-size: 22px;
            text-align: center;
            letter-spacing: 8px;
            border: 2px solid #ddd;
            border-radius: 8px;
            margin-bottom: 16px;
            box-sizing: border-box;
        }
        .verificacion-box button {
            width: 100%;
            padding: 12px;
            background: #c0392b;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            cursor: pointer;
            margin-bottom: 10px;
        }
        .verificacion-box button:hover { background: #a93226; }
        .verificacion-box button:disabled {
            background: #ccc;
            cursor: not-allowed;
        }
        .btn-reenviar {
            background: transparent !important;
            color: #c0392b !important;
            border: 2px solid #c0392b !important;
        }
        .btn-reenviar:hover { background: #fdecea !important; }
        .error { color: red; font-size: 13px; margin-bottom: 12px; }
        .info  { color: green; font-size: 13px; margin-bottom: 12px; }

        /* Temporizador */
        .timer-box {
            background: #fdecea;
            border-radius: 8px;
            padding: 10px;
            margin-bottom: 20px;
        }
        .timer-box p {
            margin: 0;
            font-size: 14px;
            color: #666;
        }
        #timer {
            font-size: 32px;
            font-weight: bold;
            color: #c0392b;
            display: block;
            margin-top: 4px;
        }
        #timer.urgente { color: red; animation: parpadeo 0.8s infinite; }
        @keyframes parpadeo {
            0%, 100% { opacity: 1; }
            50%       { opacity: 0.4; }
        }
    </style>
</head>
<body>
<div class="verificacion-box">
    <h2>Verifica tu correo</h2>
    <p>Te enviamos un código de 6 dígitos.<br>Ingrésalo antes de que expire el tiempo.</p>

    <% if (request.getAttribute("error") != null) { %>
        <p class="error">${error}</p>
    <% } %>
    <% if (request.getAttribute("info") != null) { %>
        <p class="info">${info}</p>
    <% } %>

    <!-- Temporizador visual -->
    <div class="timer-box">
        <p>Tiempo restante</p>
        <span id="timer">05:00</span>
    </div>

    <!-- Formulario verificar -->
    <form action="${pageContext.request.contextPath}/verificacion" method="post">
        <input type="hidden" name="accion" value="verificar">
        <input type="text" name="codigo" id="inputCodigo"
               maxlength="6" placeholder="000000" required autofocus>
        <button type="submit" id="btnVerificar">Verificar cuenta</button>
    </form>

    <!-- Formulario reenviar -->
    <form action="${pageContext.request.contextPath}/verificacion" method="post">
        <input type="hidden" name="accion" value="reenviar">
        <button type="submit" class="btn-reenviar">Reenviar código</button>
    </form>
</div>

<script>
    let segundos = 5 * 60; // 5 minutos
    const timer      = document.getElementById('timer');
    const btnVerif   = document.getElementById('btnVerificar');
    const inputCodigo = document.getElementById('inputCodigo');

    const intervalo = setInterval(function () {
        segundos--;

        const min = Math.floor(segundos / 60);
        const seg = segundos % 60;
        timer.textContent =
            (min < 10 ? '0' + min : min) + ':' +
            (seg < 10 ? '0' + seg : seg);

        // Parpadeo cuando queda menos de 1 minuto
        if (segundos <= 60) {
            timer.classList.add('urgente');
        }

        // Tiempo agotado
        if (segundos <= 0) {
            clearInterval(intervalo);
            timer.textContent = '00:00';
            timer.style.color = 'gray';
            timer.classList.remove('urgente');
            btnVerif.disabled = true;
            btnVerif.textContent = 'Código expirado';
            inputCodigo.disabled = true;
        }
    }, 1000);
</script>
</body>
</html>