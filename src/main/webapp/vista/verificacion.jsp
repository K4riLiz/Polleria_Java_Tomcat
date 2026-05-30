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
        .btn-reenviar {
            background: transparent !important;
            color: #c0392b !important;
            border: 2px solid #c0392b !important;
        }
        .btn-reenviar:hover { background: #fdecea !important; }
        .error { color: red; font-size: 13px; margin-bottom: 12px; }
        .info  { color: green; font-size: 13px; margin-bottom: 12px; }
    </style>
</head>
<body>
<div class="verificacion-box">
    <h2>Verifica tu correo</h2>
    <p>Te enviamos un código de 6 dígitos. Ingrésalo para activar tu cuenta.</p>

    <% if (request.getAttribute("error") != null) { %>
        <p class="error">${error}</p>
    <% } %>
    <% if (request.getAttribute("info") != null) { %>
        <p class="info">${info}</p>
    <% } %>

    <form action="${pageContext.request.contextPath}/verificacion" method="post">
        <input type="hidden" name="accion" value="verificar">
        <input type="text" name="codigo" maxlength="6" placeholder="000000" required autofocus>
        <button type="submit">Verificar cuenta</button>
    </form>

    <form action="${pageContext.request.contextPath}/verificacion" method="post">
        <input type="hidden" name="accion" value="reenviar">
        <button type="submit" class="btn-reenviar">Reenviar código</button>
    </form>
</div>
</body>
</html>