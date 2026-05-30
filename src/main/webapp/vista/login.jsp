<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/login.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <script src="https://www.google.com/recaptcha/api.js?render=6LcthQQtAAAAABq3-5JjXFFMfPJhGlbYcYVP139S"></script>
    <title>Login - Pollería</title>
</head>
<body>

<div class="login-wrapper">
    <section class="container ${not empty param.modo and param.modo == 'registro' ? 'toggle' : ''}">

        <!-- FORMULARIO LOGIN -->
        <section class="container-form">
            <div class="close">
                <a href="${pageContext.request.contextPath}/home" style="color:inherit;display:flex;text-decoration:none;">
                    <ion-icon name="close-outline"></ion-icon>
                </a>
            </div>

            <form class="sign-in" action="${pageContext.request.contextPath}/login" method="post">
                <input type="hidden" name="action" value="login">
                <input type="hidden" name="g-recaptcha-response" id="captchaLogin">
                <h2>Iniciar sesión</h2>

                <div class="social-networks">
                    <ion-icon name="logo-facebook"></ion-icon>
                    <ion-icon name="logo-instagram"></ion-icon>
                    <ion-icon name="logo-whatsapp"></ion-icon>
                    <ion-icon name="logo-tiktok"></ion-icon>
                </div>

                <span>Use su correo y contraseña</span>

                <% if (request.getAttribute("error") != null) { %>
                    <p style="color:red;font-size:13px;margin-bottom:8px;">${error}</p>
                <% } %>
                <% if (request.getAttribute("exito") != null) { %>
                    <p style="color:green;font-size:13px;margin-bottom:8px;">${exito}</p>
                <% } %>

                <div class="container-input">
                    <ion-icon name="mail-outline"></ion-icon>
                    <input type="email" name="email" placeholder="Correo electrónico" required>
                </div>

                <div class="container-input">
                    <ion-icon name="lock-open-outline"></ion-icon>
                    <input type="password" name="password" placeholder="Contraseña" required>
                </div>

                <a href="#">¿Olvidaste tu contraseña?</a>
                <button type="submit" class="button" id="btnLogin">Iniciar sesión</button>
            </form>
        </section>

        <!-- FORMULARIO REGISTRO -->
        <section class="container-form">
            <form class="sign-up" action="${pageContext.request.contextPath}/login" method="post">
                <input type="hidden" name="action" value="registro">
                <input type="hidden" name="g-recaptcha-response" id="captchaRegistro">
                <h2>Regístrate</h2>

                <span>Use su correo electrónico para registrarse</span>

                <% if (request.getAttribute("errorRegistro") != null) { %>
                    <p style="color:red;font-size:13px;margin-bottom:8px;">${errorRegistro}</p>
                <% } %>

                <p id="errorDni" style="color:red;font-size:13px;margin-bottom:8px;display:none;">
                    El DNI debe tener exactamente 8 números.
                </p>
                <p id="errorTel" style="color:red;font-size:13px;margin-bottom:8px;display:none;">
                    El teléfono debe tener exactamente 9 números.
                </p>
                <p id="errorRobusta" style="color:red;font-size:13px;margin-bottom:8px;display:none;">
                    La contraseña debe tener mínimo 8 caracteres, mayúscula, minúscula, número y carácter especial (@$!%*?&._-)
                </p>
                <p id="errorNombre" style="color:red;font-size:13px;margin-bottom:8px;display:none;">
                    El nombre solo debe contener letras y espacios.
                </p>
                <p id="errorPass" style="color:red;font-size:13px;margin-bottom:8px;display:none;">
                    Las contraseñas no coinciden.
                </p>

                <div class="container-input">
                    <ion-icon name="person-outline"></ion-icon>
                    <input type="text" name="nombre" placeholder="Nombre completo" required>
                </div>

                <div class="container-input">
                    <ion-icon name="card-outline"></ion-icon>
                    <input type="text" name="dni" placeholder="DNI" maxlength="8" required>
                </div>

                <div class="container-input">
                    <ion-icon name="call-outline"></ion-icon>
                    <input type="text" name="telefono" placeholder="Teléfono" maxlength="9" required>
                </div>

                <div class="container-input">
                    <ion-icon name="mail-outline"></ion-icon>
                    <input type="email" name="email" placeholder="Correo electrónico" required>
                </div>

                <div class="container-input">
                    <ion-icon name="lock-open-outline"></ion-icon>
                    <input type="password" name="password" id="pass1" placeholder="Contraseña" required>
                </div>

                <div class="container-input">
                    <ion-icon name="lock-closed-outline"></ion-icon>
                    <input type="password" id="pass2" placeholder="Repetir contraseña" required>
                </div>

                <button type="submit" class="button" id="btnRegistro">Registrarse</button>
            </form>
        </section>

        <!-- PANEL BIENVENIDA -->
        <section class="container-welcome">
            <div class="welcome-sign-up welcome">
                <h3>Bienvenido</h3>
                <p>Ingrese sus datos personales para usar todas las funciones del sitio</p>
                <button class="button" id="btn-sign-up">Registrarse</button>
            </div>
            <div class="welcome-sign-in welcome">
                <h3>¡Hola!</h3>
                <p>Regístrate con tus datos personales para usar todas las funciones del sitio</p>
                <button class="button" id="btn-sign-in">Iniciar sesión</button>
            </div>
        </section>

    </section>
</div>

<script src="${pageContext.request.contextPath}/js/login.js"></script>
<script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
<script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
<script>
    function validarRegistro() {
        const nombre   = document.querySelector('input[name="nombre"]').value;
        const dni      = document.querySelector('input[name="dni"]').value;
        const telefono = document.querySelector('input[name="telefono"]').value;
        const p1       = document.getElementById('pass1').value;
        const p2       = document.getElementById('pass2').value;

        const regexNombre = /^[A-Za-zÁÉÍÓÚáéíóúÑñ ]{3,50}$/;
        if (!regexNombre.test(nombre)) {
            document.getElementById('errorNombre').style.display = 'block';
            return false;
        }

        document.getElementById('errorNombre').style.display = 'none';
        document.getElementById('errorPass').style.display = 'none';
        document.getElementById('errorDni').style.display = 'none';
        document.getElementById('errorTel').style.display = 'none';
        document.getElementById('errorRobusta').style.display = 'none';

        if (!/^\d{8}$/.test(dni)) {
            document.getElementById('errorDni').style.display = 'block';
            return false;
        }

        if (!/^\d{9}$/.test(telefono)) {
            document.getElementById('errorTel').style.display = 'block';
            return false;
        }

        const passRobusta = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&._\-])[A-Za-z\d@$!%*?&._\-]{8,}$/;
        if (!passRobusta.test(p1)) {
            document.getElementById('errorRobusta').style.display = 'block';
            return false;
        }

        if (p1 !== p2) {
            document.getElementById('errorPass').style.display = 'block';
            return false;
        }

        return true;
    }

    document.addEventListener('DOMContentLoaded', function() {

        // Solo letras en nombre
        document.querySelector('input[name="nombre"]').addEventListener('input', function() {
            this.value = this.value.replace(/[^A-Za-zÁÉÍÓÚáéíóúÑñ ]/g, '');
        });

        // Solo números en DNI
        document.querySelector('input[name="dni"]').addEventListener('input', function() {
            this.value = this.value.replace(/[^0-9]/g, '').slice(0, 8);
        });

        // Solo números en teléfono
        document.querySelector('input[name="telefono"]').addEventListener('input', function() {
            this.value = this.value.replace(/[^0-9]/g, '').slice(0, 9);
        });

        
        // Captcha en LOGIN
        document.getElementById('btnLogin').addEventListener('click', function(e) {
            e.preventDefault();
            grecaptcha.execute('6LcthQQtAAAAABq3-5JjXFFMfPJhGlbYcYVP139S', {action: 'login'}).then(function(token) {
                document.getElementById('captchaLogin').value = token;
                document.querySelector('form.sign-in').submit();
            });
        });

        // Captcha en REGISTRO
        document.getElementById('btnRegistro').addEventListener('click', function(e) {
            e.preventDefault();
            if (!validarRegistro()) return;
            grecaptcha.execute('6LcthQQtAAAAABq3-5JjXFFMfPJhGlbYcYVP139S', {action: 'registro'}).then(function(token) {
                document.getElementById('captchaRegistro').value = token;
                document.querySelector('form.sign-up').submit();
            });
        });
        
        
        /*

        // Captcha en LOGIN
        document.getElementById('btnLogin').addEventListener('click', function(e) {
            e.preventDefault();
            grecaptcha.ready(function() {
                grecaptcha.execute('6LcthQQtAAAAABq3-5JjXFFMfPJhGlbYcYVP139S', {action: 'login'}).then(function(token) {
                    document.getElementById('captchaLogin').value = token;
                    document.querySelector('form.sign-in').submit();
                });
            });
        });

        // Captcha en REGISTRO
        document.getElementById('btnRegistro').addEventListener('click', function(e) {
            e.preventDefault();
            if (!validarRegistro()) return;
            grecaptcha.ready(function() {
                grecaptcha.execute('6LcthQQtAAAAABq3-5JjXFFMfPJhGlbYcYVP139S', {action: 'registro'}).then(function(token) {
                    document.getElementById('captchaRegistro').value = token;
                    document.querySelector('form.sign-up').submit();
                });
            });
        }); */

    });
</script>

</body>
</html>