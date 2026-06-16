document.addEventListener('DOMContentLoaded', function () {
    const container = document.querySelector('.container');
    const btnSignIn = document.getElementById('btn-sign-in');
    const btnSignUp = document.getElementById('btn-sign-up');

    if (btnSignIn && btnSignUp && container) {
        btnSignIn.addEventListener('click', function () {
            container.classList.remove('toggle');
        });
        btnSignUp.addEventListener('click', function () {
            container.classList.add('toggle');
        });
    }

    initRecuperarPassword();
});

function initRecuperarPassword() {
    const signInForm = document.querySelector('form.sign-in');
    const contextPath = signInForm
        ? signInForm.getAttribute('action').replace(/\/login$/, '')
        : '';

    const modal = document.getElementById('modal-recuperar');
    const btnOlvide = document.getElementById('btn-olvide-pass');
    const pasoEmail = document.getElementById('paso-email');
    const pasoPassword = document.getElementById('paso-password');
    const recEmail = document.getElementById('rec-email');
    const recCodigo = document.getElementById('rec-codigo');
    const recPass1 = document.getElementById('rec-pass1');
    const recPass2 = document.getElementById('rec-pass2');
    const btnEnviar = document.getElementById('btn-enviar-codigo');
    const btnVerificar = document.getElementById('btn-verificar-codigo');
    const btnCambiar = document.getElementById('btn-cambiar-pass');
    const exitoCorreo = document.getElementById('exito-correo');
    const seccionCodigo = document.getElementById('seccion-codigo');
    const errorRecuperar = document.getElementById('error-recuperar');
    const errorPassword = document.getElementById('error-password');
    const timerCodigo = document.getElementById('timer-codigo');
    const btnReenviar = document.getElementById('btn-reenviar-codigo');
    const btnCerrarX = document.getElementById('modal-cerrar-x');
    const btnCerrarVolver = document.getElementById('modal-cerrar-volver');

    if (!modal || !btnOlvide) {
        console.warn('Modal de recuperar contraseña no encontrado en la página.');
        return;
    }

    const PASS_ROBUSTA = window.PasswordValidatorUI
        ? window.PasswordValidatorUI.PASS_ROBUSTA
        : /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&._\-])[A-Za-z\d@$!%*?&._\-]{8,}$/;
    const EXPIRACION_MS = 5 * 60 * 1000;
    let timerInterval = null;
    let expiracionCodigo = null;
    let recuperarPasswordValidator = null;

    function abrirModal() {
        resetModal();
        modal.style.display = 'flex';
        modal.setAttribute('aria-hidden', 'false');
        document.body.style.overflow = 'hidden';
    }

    function cerrarModal() {
        modal.style.display = 'none';
        modal.setAttribute('aria-hidden', 'true');
        document.body.style.overflow = '';
        resetModal();
    }

    function resetModal() {
        pasoEmail.style.display = 'block';
        pasoPassword.style.display = 'none';
        recEmail.value = '';
        recCodigo.value = '';
        recPass1.value = '';
        recPass2.value = '';
        exitoCorreo.style.display = 'none';
        seccionCodigo.style.display = 'none';
        errorRecuperar.style.display = 'none';
        errorPassword.style.display = 'none';
        btnEnviar.disabled = true;
        btnEnviar.classList.remove('activo');
        btnVerificar.disabled = true;
        btnVerificar.classList.remove('activo');
        btnCambiar.disabled = true;
        btnCambiar.classList.remove('activo');
        recEmail.disabled = false;
        if (timerInterval) {
            clearInterval(timerInterval);
            timerInterval = null;
        }
        timerCodigo.textContent = '';
        if (btnReenviar) {
            btnReenviar.style.display = 'none';
            btnReenviar.disabled = false;
        }
        recPass1.dispatchEvent(new Event('input'));
    }

    function mostrarError(el, msg) {
        el.textContent = msg;
        el.style.display = 'block';
    }

    function ocultarError(el) {
        el.style.display = 'none';
    }

    async function postRecuperar(action, params) {
        const body = new URLSearchParams();
        body.append('action', action);
        Object.keys(params).forEach(function (key) {
            body.append(key, params[key]);
        });

        const res = await fetch(contextPath + '/recuperar-password', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: body.toString()
        });
        return res.json();
    }

    function mostrarReenviar() {
        if (!btnReenviar) return;
        btnReenviar.style.display = 'flex';
        btnVerificar.disabled = true;
        btnVerificar.classList.remove('activo');
        recCodigo.value = '';
    }

    function ocultarReenviar() {
        if (!btnReenviar) return;
        btnReenviar.style.display = 'none';
        btnReenviar.disabled = false;
    }

    function iniciarTimer() {
        expiracionCodigo = Date.now() + EXPIRACION_MS;
        if (timerInterval) clearInterval(timerInterval);
        ocultarReenviar();

        function actualizar() {
            const restante = expiracionCodigo - Date.now();
            if (restante <= 0) {
                timerCodigo.textContent = 'El código ha expirado.';
                timerCodigo.style.color = '#c0392b';
                clearInterval(timerInterval);
                timerInterval = null;
                mostrarReenviar();
                return;
            }
            const min = Math.floor(restante / 60000);
            const seg = Math.floor((restante % 60000) / 1000);
            timerCodigo.textContent = 'Tiempo restante: ' + min + ':' + String(seg).padStart(2, '0');
            timerCodigo.style.color = '#666';
        }

        actualizar();
        timerInterval = setInterval(actualizar, 1000);
    }

    async function enviarCodigoRecuperacion(esReenvio) {
        ocultarError(errorRecuperar);
        btnEnviar.disabled = true;
        if (btnReenviar) btnReenviar.disabled = true;

        try {
            const data = await postRecuperar('enviarCodigo', { email: recEmail.value.trim() });
            if (data.ok) {
                exitoCorreo.textContent = esReenvio
                    ? 'Se reenvió un nuevo código a ' + recEmail.value.trim()
                    : data.mensaje;
                exitoCorreo.style.display = 'block';
                seccionCodigo.style.display = 'block';
                recEmail.disabled = true;
                recCodigo.value = '';
                btnVerificar.disabled = true;
                btnVerificar.classList.remove('activo');
                iniciarTimer();
            } else {
                mostrarError(errorRecuperar, data.mensaje);
                if (!recEmail.disabled) {
                    btnEnviar.disabled = false;
                    btnEnviar.classList.add('activo');
                }
                if (btnReenviar && btnReenviar.style.display !== 'none') {
                    btnReenviar.disabled = false;
                }
            }
        } catch (err) {
            mostrarError(errorRecuperar, 'Error de conexión. Intenta de nuevo.');
            if (!recEmail.disabled) {
                btnEnviar.disabled = false;
                btnEnviar.classList.add('activo');
            }
            if (btnReenviar && btnReenviar.style.display !== 'none') {
                btnReenviar.disabled = false;
            }
        }
    }

    btnOlvide.addEventListener('click', function (e) {
        e.preventDefault();
        abrirModal();
    });

    window.abrirModalRecuperar = abrirModal;
    window.cerrarModalRecuperar = cerrarModal;

    if (btnCerrarX) btnCerrarX.addEventListener('click', cerrarModal);
    if (btnCerrarVolver) btnCerrarVolver.addEventListener('click', cerrarModal);

    modal.addEventListener('click', function (e) {
        if (e.target === modal) cerrarModal();
    });

    recEmail.addEventListener('input', function () {
        const valido = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(this.value.trim());
        btnEnviar.disabled = !valido;
        btnEnviar.classList.toggle('activo', valido);
    });

    recCodigo.addEventListener('input', function () {
        this.value = this.value.replace(/\D/g, '').slice(0, 6);
        const valido = this.value.length === 6;
        btnVerificar.disabled = !valido;
        btnVerificar.classList.toggle('activo', valido);
    });

    function validarPassForm() {
        const p1 = recPass1.value;
        const p2 = recPass2.value;
        const wrap1 = recPass1.closest('.pass-input-wrap');
        const valido = PASS_ROBUSTA.test(p1) && p1 === p2 && p1.length > 0;
        wrap1.classList.toggle('invalido', p1.length > 0 && !PASS_ROBUSTA.test(p1));
        btnCambiar.disabled = !valido;
        btnCambiar.classList.toggle('activo', valido);
    }

    if (window.PasswordValidatorUI) {
        recuperarPasswordValidator = PasswordValidatorUI.init({
            passInput: recPass1,
            confirmInput: recPass2,
            requirementsList: document.getElementById('passRequirementsRecuperar'),
            matchList: document.getElementById('passMatchRecuperar'),
            submitBtn: btnCambiar
        });
    } else {
        recPass1.addEventListener('input', validarPassForm);
        recPass2.addEventListener('input', validarPassForm);
    }

    document.querySelectorAll('.toggle-pass').forEach(function (btn) {
        btn.addEventListener('click', function () {
            const input = document.getElementById(this.getAttribute('data-target'));
            const icon = this.querySelector('i');
            if (!input || !icon) return;
            if (input.type === 'password') {
                input.type = 'text';
                icon.classList.remove('fa-eye-slash');
                icon.classList.add('fa-eye');
            } else {
                input.type = 'password';
                icon.classList.remove('fa-eye');
                icon.classList.add('fa-eye-slash');
            }
        });
    });

    btnEnviar.addEventListener('click', function () {
        if (btnEnviar.disabled) return;
        enviarCodigoRecuperacion(false);
    });

    if (btnReenviar) {
        btnReenviar.addEventListener('click', function () {
            if (btnReenviar.disabled) return;
            enviarCodigoRecuperacion(true);
        });
    }

    btnVerificar.addEventListener('click', async function () {
        if (btnVerificar.disabled) return;
        ocultarError(errorRecuperar);
        btnVerificar.disabled = true;

        try {
            const data = await postRecuperar('verificarCodigo', { codigo: recCodigo.value.trim() });
            if (data.ok) {
                if (timerInterval) clearInterval(timerInterval);
                pasoEmail.style.display = 'none';
                pasoPassword.style.display = 'block';
                recPass1.dispatchEvent(new Event('input'));
            } else {
                mostrarError(errorRecuperar, data.mensaje);
                if (data.mensaje && (data.mensaje.indexOf('expiró') !== -1 || data.mensaje.indexOf('Solicita') !== -1)) {
                    mostrarReenviar();
                } else {
                    btnVerificar.disabled = false;
                    btnVerificar.classList.add('activo');
                }
            }
        } catch (err) {
            mostrarError(errorRecuperar, 'Error de conexión. Intenta de nuevo.');
            btnVerificar.disabled = false;
            btnVerificar.classList.add('activo');
        }
    });

    btnCambiar.addEventListener('click', async function () {
        if (btnCambiar.disabled) return;
        ocultarError(errorPassword);

        if (recuperarPasswordValidator && !recuperarPasswordValidator.esValido()) {
            mostrarError(errorPassword, 'Completa todos los requisitos de contraseña.');
            return;
        }

        if (!PASS_ROBUSTA.test(recPass1.value)) {
            mostrarError(errorPassword, 'La contraseña debe tener mínimo 8 caracteres, mayúscula, minúscula, número y carácter especial.');
            return;
        }
        if (recPass1.value !== recPass2.value) {
            mostrarError(errorPassword, 'Las contraseñas no coinciden.');
            return;
        }

        btnCambiar.disabled = true;

        try {
            const data = await postRecuperar('cambiarPass', {
                nuevaPassword: recPass1.value,
                repetirPassword: recPass2.value
            });
            if (data.ok) {
                cerrarModal();
                const form = document.querySelector('.sign-in');
                let msg = form.querySelector('.msg-recuperacion-ok');
                if (!msg) {
                    msg = document.createElement('p');
                    msg.className = 'msg-recuperacion-ok';
                    msg.style.cssText = 'color:green;font-size:13px;margin-bottom:8px;';
                    form.querySelector('span').insertAdjacentElement('afterend', msg);
                }
                msg.textContent = data.mensaje;
            } else {
                mostrarError(errorPassword, data.mensaje);
                btnCambiar.disabled = false;
                btnCambiar.classList.add('activo');
            }
        } catch (err) {
            mostrarError(errorPassword, 'Error de conexión. Intenta de nuevo.');
            btnCambiar.disabled = false;
            btnCambiar.classList.add('activo');
        }
    });
}
