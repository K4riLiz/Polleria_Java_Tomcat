package com.polleria.util;

import java.util.regex.Pattern;

/**
 * Validación centralizada de contraseñas robustas.
 * Mínimo 8 caracteres, mayúscula, minúscula, número y carácter especial.
 */
public final class PasswordValidator {

    public static final Pattern PASS_ROBUSTA = Pattern.compile(
            "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&._\\-])[A-Za-z\\d@$!%*?&._\\-]{8,}$"
    );

    public static final String MENSAJE_ERROR =
            "La contraseña debe tener mínimo 8 caracteres, mayúscula, minúscula, número y carácter especial (@$!%*?&._-).";

    private PasswordValidator() {}

    public static boolean esValida(String password) {
        return password != null && PASS_ROBUSTA.matcher(password).matches();
    }

    public static boolean coinciden(String pass1, String pass2) {
        return pass1 != null && pass1.equals(pass2);
    }
}
