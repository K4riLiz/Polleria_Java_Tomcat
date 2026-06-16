<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/login.css?v=4">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <script src="https://www.google.com/recaptcha/api.js?render=6LcthQQtAAAAABq3-5JjXFFMfPJhGlbYcYVP139S"></script>
    <style>
        #btn-olvide-pass {
            display: inline-block;
            background: none !important;
            border: none !important;
            padding: 0 !important;
            margin: 5px 0 20px !important;
            color: #000 !important;
            font-size: 14px !important;
            font-family: inherit !important;
            cursor: pointer !important;
            text-decoration: none !important;
            box-shadow: none !important;
            outline: none !important;
            width: auto !important;
            height: auto !important;
        }
        #btn-olvide-pass:hover {
            color: #a0594b !important;
            font-weight: 900;
        }
    </style>
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

                <a href="javascript:void(0)" id="btn-olvide-pass" class="link-olvide-pass"
                   onclick="abrirModalRecuperar(); return false;">¿Olvidaste tu contraseña?</a>

                <!-- ID agregado para que reCAPTCHA pueda interceptar el click -->
                <button type="submit" class="button" id="btnLogin">Iniciar sesión</button>
                <br>

                <!-- Solo para móvil -->
                <p class="mobile-switch">
                    ¿No tienes cuenta?
                    <a href="?modo=registro">Regístrate</a>
                </p>

                <p>Síguenos en nuestras redes sociales</p>
                <div class="social-networks">
                    <ion-icon name="logo-facebook"></ion-icon>
                    <ion-icon name="logo-instagram"></ion-icon>
                    <ion-icon name="logo-whatsapp"></ion-icon>
                    <ion-icon name="logo-tiktok"></ion-icon>
                </div>
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
                <p id="errorNombre" style="color:red;font-size:13px;margin-bottom:8px;display:none;">
                    El nombre solo debe contener letras y espacios.
                </p>
                <p id="errorApellido" style="color:red;font-size:13px;margin-bottom:8px;display:none;">
                    El apellido solo debe contener letras y espacios.
                </p>

                <div class="container-input">
                    <ion-icon name="person-outline"></ion-icon>
                    <input type="text" name="nombre" placeholder="Nombre completo" required>
                </div>

                <div class="container-input">
                    <ion-icon name="person-outline"></ion-icon>
                    <input type="text" name="apellido" placeholder="Apellido" required>
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
                    <input type="password" id="pass2" name="confirmPassword" placeholder="Repetir contraseña" required>
                </div>

                <ul id="passRequirementsRegistro"></ul>
                <ul id="passMatchRegistro" class="pass-match-list"></ul>

                <!-- ID agregado para que reCAPTCHA pueda interceptar el click -->
                <button type="submit" class="button pass-submit-disabled" id="btnRegistro" disabled>Registrarse</button>

                <!-- Solo para móvil -->
                <p class="mobile-switch">
                    ¿Ya tienes cuenta?
                    <a href="?">Inicia sesión</a>
                </p>

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

<!-- Modal recuperar contraseña -->
<div id="modal-recuperar" class="modal-overlay" style="display:none;" aria-hidden="true">
    <div class="modal-recuperar">

        <!-- Paso 1 y 2: correo + código -->
        <div id="paso-email" class="modal-paso">
            <div class="modal-header">
                <button type="button" class="modal-volver" id="modal-cerrar-volver" onclick="cerrarModalRecuperar()">
                    <i class="fas fa-chevron-left"></i> Volver
                </button>
                <button type="button" class="modal-cerrar" id="modal-cerrar-x" onclick="cerrarModalRecuperar()">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <h2>Recuperar contraseña</h2>
            <p class="modal-desc">Ingresa el <span class="text-highlight">correo electrónico</span> con el que te registraste para recibir un enlace.</p>

            <div class="modal-input-row">
                <input type="email" id="rec-email" placeholder="Correo electrónico">
                <button type="button" id="btn-enviar-codigo" class="btn-modal-enviar" disabled>
                    <i class="fas fa-envelope"></i> Enviar
                </button>
            </div>

            <div id="exito-correo" class="modal-exito" style="display:none;"></div>

            <div id="seccion-codigo" style="display:none;">
                <p class="modal-desc" style="margin-top:18px;">Ingresa el <span class="text-highlight">código de 6 dígitos</span> que recibiste en tu correo.</p>
                <div class="modal-input-row">
                    <input type="text" id="rec-codigo" placeholder="Código de 6 dígitos" maxlength="6" inputmode="numeric">
                    <button type="button" id="btn-verificar-codigo" class="btn-modal-enviar" disabled>
                        <i class="fas fa-check"></i> Verificar
                    </button>
                </div>
                <p id="timer-codigo" class="modal-timer"></p>
                <button type="button" id="btn-reenviar-codigo" class="btn-reenviar-codigo" style="display:none;">
                    <i class="fas fa-redo"></i> Reenviar código
                </button>
            </div>

            <p id="error-recuperar" class="modal-error" style="display:none;"></p>
        </div>

        <!-- Paso 3: nueva contraseña -->
        <div id="paso-password" class="modal-paso" style="display:none;">
            <div class="modal-header-cambiar">
                <h2>Cambiar contraseña</h2>
            </div>
            <p class="modal-desc-cambiar">Ahora puedes ingresar tu nueva contraseña, recuerda que debe ser <span class="text-highlight">mayor a 8 caracteres</span> con mayúscula, minúscula, número y carácter especial.</p>

            <div class="modal-campo-pass">
                <label for="rec-pass1">Contraseña</label>
                <div class="pass-input-wrap">
                    <input type="password" id="rec-pass1" placeholder="Nueva contraseña">
                    <button type="button" class="toggle-pass" data-target="rec-pass1">
                        <i class="fas fa-eye-slash"></i>
                    </button>
                </div>
            </div>

            <div class="modal-campo-pass">
                <label for="rec-pass2">Repetir contraseña</label>
                <div class="pass-input-wrap">
                    <input type="password" id="rec-pass2" placeholder="Repetir contraseña">
                    <button type="button" class="toggle-pass" data-target="rec-pass2">
                        <i class="fas fa-eye-slash"></i>
                    </button>
                </div>
            </div>

            <ul id="passRequirementsRecuperar"></ul>
            <ul id="passMatchRecuperar" class="pass-match-list"></ul>

            <p id="error-password" class="modal-error" style="display:none;"></p>

            <button type="button" id="btn-cambiar-pass" class="btn-cambiar-pass" disabled>
                <i class="fas fa-lock"></i> Cambiar
            </button>
        </div>

    </div>
</div>

<script>
    /* Abre el modal aunque falle la carga de login.js */
    function abrirModalRecuperar() {
        var modal = document.getElementById('modal-recuperar');
        if (!modal) return;
        modal.style.display = 'flex';
        modal.setAttribute('aria-hidden', 'false');
        document.body.style.overflow = 'hidden';
    }

    function cerrarModalRecuperar() {
        var modal = document.getElementById('modal-recuperar');
        if (!modal) return;
        modal.style.display = 'none';
        modal.setAttribute('aria-hidden', 'true');
        document.body.style.overflow = '';
    }
</script>
<script src="${pageContext.request.contextPath}/js/password-validator.js?v=1"></script>
<script src="${pageContext.request.contextPath}/js/login.js?v=5"></script>
<script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
<script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
<script>
    var registroPasswordValidator = null;

    function validarRegistro() {
        const nombre   = document.querySelector('.sign-up input[name="nombre"]').value;
        const apellido = document.querySelector('.sign-up input[name="apellido"]').value;
        const dni      = document.querySelector('.sign-up input[name="dni"]').value;
        const telefono = document.querySelector('.sign-up input[name="telefono"]').value;

        document.getElementById('errorNombre').style.display   = 'none';
        document.getElementById('errorApellido').style.display = 'none';
        document.getElementById('errorDni').style.display      = 'none';
        document.getElementById('errorTel').style.display      = 'none';

        const regexNombre = /^[A-Za-zÁÉÍÓÚáéíóúÑñ ]{3,50}$/;
        if (!regexNombre.test(nombre)) {
            document.getElementById('errorNombre').style.display = 'block';
            return false;
        }

        if (!regexNombre.test(apellido)) {
            document.getElementById('errorApellido').style.display = 'block';
            return false;
        }

        if (!/^\d{8}$/.test(dni)) {
            document.getElementById('errorDni').style.display = 'block';
            return false;
        }

        if (!/^\d{9}$/.test(telefono)) {
            document.getElementById('errorTel').style.display = 'block';
            return false;
        }

        if (registroPasswordValidator && !registroPasswordValidator.esValido()) {
            return false;
        }

        return true;
    }

    document.addEventListener('DOMContentLoaded', function() {

        // Selectores con scope .sign-up para no afectar el form de login
        const nombreInput   = document.querySelector('.sign-up input[name="nombre"]');
        const apellidoInput = document.querySelector('.sign-up input[name="apellido"]');
        const dniInput      = document.querySelector('.sign-up input[name="dni"]');
        const telInput      = document.querySelector('.sign-up input[name="telefono"]');

        // Solo letras en nombre
        if (nombreInput) {
            nombreInput.addEventListener('input', function() {
                this.value = this.value.replace(/[^A-Za-zÁÉÍÓÚáéíóúÑñ ]/g, '');
            });
        }

        // Solo letras en apellido
        if (apellidoInput) {
            apellidoInput.addEventListener('input', function() {
                this.value = this.value.replace(/[^A-Za-zÁÉÍÓÚáéíóúÑñ ]/g, '');
            });
        }

        // Solo números en DNI
        if (dniInput) {
            dniInput.addEventListener('input', function() {
                this.value = this.value.replace(/[^0-9]/g, '').slice(0, 8);
            });
        }

        // Solo números en teléfono
        if (telInput) {
            telInput.addEventListener('input', function() {
                this.value = this.value.replace(/[^0-9]/g, '').slice(0, 9);
            });
        }

        // reCAPTCHA en LOGIN
        document.getElementById('btnLogin').addEventListener('click', function(e) {
            e.preventDefault();
            grecaptcha.execute('6LcthQQtAAAAABq3-5JjXFFMfPJhGlbYcYVP139S', { action: 'login' }).then(function(token) {
                document.getElementById('captchaLogin').value = token;
                document.querySelector('form.sign-in').submit();
            });
        });

        registroPasswordValidator = PasswordValidatorUI.init({
            passInput: document.getElementById('pass1'),
            confirmInput: document.getElementById('pass2'),
            requirementsList: document.getElementById('passRequirementsRegistro'),
            matchList: document.getElementById('passMatchRegistro'),
            submitBtn: document.getElementById('btnRegistro')
        });

        // reCAPTCHA en REGISTRO
        document.getElementById('btnRegistro').addEventListener('click', function(e) {
            e.preventDefault();
            if (!validarRegistro()) return;
            grecaptcha.execute('6LcthQQtAAAAABq3-5JjXFFMfPJhGlbYcYVP139S', { action: 'registro' }).then(function(token) {
                document.getElementById('captchaRegistro').value = token;
                document.querySelector('form.sign-up').submit();
            });
        });

    });
</script>

</body>
</html>
