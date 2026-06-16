/**
 * Validación visual de contraseñas en tiempo real.
 * Uso: PasswordValidatorUI.init({ passInput, confirmInput, requirementsList, matchList, submitBtn })
 */
(function (global) {
    'use strict';

    var REGLAS = [
        { id: 'length',  test: function (p) { return p.length >= 8; },
          text: 'Mínimo 8 caracteres' },
        { id: 'upper',   test: function (p) { return /[A-Z]/.test(p); },
          text: 'Al menos una mayúscula' },
        { id: 'lower',   test: function (p) { return /[a-z]/.test(p); },
          text: 'Al menos una minúscula' },
        { id: 'digit',   test: function (p) { return /\d/.test(p); },
          text: 'Al menos un número' },
        { id: 'special', test: function (p) { return /[@$!%*?&._\-]/.test(p); },
          text: 'Al menos un carácter especial (@$!%*?&._-)' }
    ];

    var PASS_ROBUSTA = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&._\-])[A-Za-z\d@$!%*?&._\-]{8,}$/;

    function crearListaRequisitos(container) {
        if (!container) return;
        container.className = (container.className ? container.className + ' ' : '') + 'pass-requirements';
        container.innerHTML = REGLAS.map(function (r) {
            return '<li class="pass-req-item pending" data-rule="' + r.id + '">' +
                   '<i class="pass-req-icon fas fa-circle"></i>' +
                   '<span>' + r.text + '</span></li>';
        }).join('');
    }

    function crearListaCoincidencia(container) {
        if (!container) return;
        container.className = (container.className ? container.className + ' ' : '') + 'pass-requirements';
        container.innerHTML =
            '<li class="pass-req-item pending" data-rule="match">' +
            '<i class="pass-req-icon fas fa-circle"></i>' +
            '<span>Las contraseñas coinciden</span></li>';
    }

    function actualizarItem(li, cumple, tieneTexto) {
        if (!li) return;
        li.classList.remove('pending', 'valid', 'invalid');
        var icon = li.querySelector('.pass-req-icon');
        if (!tieneTexto) {
            li.classList.add('pending');
            if (icon) {
                icon.className = 'pass-req-icon fas fa-circle';
            }
        } else if (cumple) {
            li.classList.add('valid');
            if (icon) {
                icon.className = 'pass-req-icon fas fa-check-circle';
            }
        } else {
            li.classList.add('invalid');
            if (icon) {
                icon.className = 'pass-req-icon fas fa-times-circle';
            }
        }
    }

    function evaluar(password, confirm) {
        var resultado = { reglas: {}, todoValido: false, coinciden: false };
        REGLAS.forEach(function (r) {
            resultado.reglas[r.id] = r.test(password);
        });
        resultado.todoValido = PASS_ROBUSTA.test(password);
        resultado.coinciden = password.length > 0 && password === confirm;
        return resultado;
    }

    function init(config) {
        var passInput = config.passInput;
        var confirmInput = config.confirmInput;
        var requirementsList = config.requirementsList;
        var matchList = config.matchList;
        var submitBtn = config.submitBtn;

        if (!passInput) return { esValido: function () { return false; } };

        crearListaRequisitos(requirementsList);
        if (matchList && confirmInput) {
            crearListaCoincidencia(matchList);
        }

        function actualizar() {
            var pass = passInput.value;
            var confirm = confirmInput ? confirmInput.value : '';
            var estado = evaluar(pass, confirm);

            REGLAS.forEach(function (r) {
                var li = requirementsList
                    ? requirementsList.querySelector('[data-rule="' + r.id + '"]')
                    : null;
                actualizarItem(li, estado.reglas[r.id], pass.length > 0);
            });

            if (matchList && confirmInput) {
                var liMatch = matchList.querySelector('[data-rule="match"]');
                var mostrarMatch = confirm.length > 0 || pass.length > 0;
                actualizarItem(liMatch, estado.coinciden, mostrarMatch && confirm.length > 0);
            }

            var valido = estado.todoValido && (!confirmInput || estado.coinciden);
            if (submitBtn) {
                submitBtn.disabled = !valido;
                submitBtn.classList.toggle('pass-submit-disabled', !valido);
            }
            return valido;
        }

        passInput.addEventListener('input', actualizar);
        if (confirmInput) {
            confirmInput.addEventListener('input', actualizar);
        }
        actualizar();

        return {
            esValido: function () { return actualizar(); },
            PASS_ROBUSTA: PASS_ROBUSTA
        };
    }

    global.PasswordValidatorUI = {
        REGLAS: REGLAS,
        PASS_ROBUSTA: PASS_ROBUSTA,
        evaluar: evaluar,
        init: init
    };
})(window);
