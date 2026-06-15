package com.polleria.servlet;

import com.polleria.dao.UsuarioDAO;
import org.mindrot.jbcrypt.BCrypt;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;
import java.util.regex.Pattern;

public class RecuperarPasswordServlet extends HttpServlet {

    private static final long EXPIRACION_MS = 5 * 60 * 1000L;
    private static final Pattern PASS_ROBUSTA = Pattern.compile(
            "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&._\\-])[A-Za-z\\d@$!%*?&._\\-]{8,}$"
    );

    private static final Map<String, String[]> codigos = new HashMap<>();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");

        String action = req.getParameter("action");
        if (action == null) {
            responderJson(resp, false, "Acción no válida.", null);
            return;
        }

        switch (action) {
            case "enviarCodigo"    -> enviarCodigo(req, resp);
            case "verificarCodigo" -> verificarCodigo(req, resp);
            case "cambiarPass"     -> cambiarPassword(req, resp);
            default                -> responderJson(resp, false, "Acción no válida.", null);
        }
    }

    private void enviarCodigo(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String email = req.getParameter("email");
        if (email == null || email.trim().isEmpty()) {
            responderJson(resp, false, "Ingresa tu correo electrónico.", null);
            return;
        }
        email = email.trim();

        try {
            UsuarioDAO dao = new UsuarioDAO();
            if (!dao.emailExiste(email)) {
                responderJson(resp, false, "No existe una cuenta con ese correo.", null);
                return;
            }

            String codigo = String.valueOf(100000 + new Random().nextInt(900000));
            long expiracion = System.currentTimeMillis() + EXPIRACION_MS;
            codigos.put(email, new String[]{codigo, String.valueOf(expiracion)});

            com.polleria.util.EmailService.enviarCodigoRecuperacion(email, codigo, expiracion);

            req.getSession().setAttribute("emailRecuperacion", email);
            responderJson(resp, true, "Se le envió un correo a " + email, email);

        } catch (SQLException e) {
            responderJson(resp, false, "Error del servidor: " + e.getMessage(), null);
        } catch (javax.mail.MessagingException e) {
            responderJson(resp, false, "No se pudo enviar el correo. Intenta más tarde.", null);
        }
    }

    private void verificarCodigo(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String codigoIngresado = req.getParameter("codigo");
        String email = (String) req.getSession().getAttribute("emailRecuperacion");

        if (codigoIngresado == null || codigoIngresado.trim().isEmpty()) {
            responderJson(resp, false, "Ingresa el código de 6 dígitos.", null);
            return;
        }
        codigoIngresado = codigoIngresado.trim();

        if (email == null || !codigos.containsKey(email)) {
            responderJson(resp, false, "Sesión expirada. Solicita un nuevo código.", null);
            return;
        }

        String[] data = codigos.get(email);
        long expiracion = Long.parseLong(data[1]);

        if (System.currentTimeMillis() > expiracion) {
            codigos.remove(email);
            responderJson(resp, false, "El código expiró. Solicita uno nuevo.", null);
            return;
        }

        if (!data[0].equals(codigoIngresado)) {
            responderJson(resp, false, "Código incorrecto. Intenta de nuevo.", null);
            return;
        }

        req.getSession().setAttribute("codigoVerificado", true);
        responderJson(resp, true, "Código verificado correctamente.", null);
    }

    private void cambiarPassword(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String email = (String) req.getSession().getAttribute("emailRecuperacion");
        Boolean verificado = (Boolean) req.getSession().getAttribute("codigoVerificado");
        String nuevaPass   = req.getParameter("nuevaPassword");
        String repetirPass = req.getParameter("repetirPassword");

        if (email == null || !Boolean.TRUE.equals(verificado)) {
            responderJson(resp, false, "Sesión expirada. Inicia el proceso de nuevo.", null);
            return;
        }

        if (nuevaPass == null || repetirPass == null) {
            responderJson(resp, false, "Completa ambos campos de contraseña.", null);
            return;
        }

        if (!nuevaPass.equals(repetirPass)) {
            responderJson(resp, false, "Las contraseñas no coinciden.", null);
            return;
        }

        if (!PASS_ROBUSTA.matcher(nuevaPass).matches()) {
            responderJson(resp, false,
                    "La contraseña debe tener mínimo 8 caracteres, mayúscula, minúscula, número y carácter especial (@$!%*?&._-).",
                    null);
            return;
        }

        try {
            UsuarioDAO dao = new UsuarioDAO();
            String hash = BCrypt.hashpw(nuevaPass, BCrypt.gensalt());
            dao.actualizarPassword(email, hash);

            req.getSession().removeAttribute("emailRecuperacion");
            req.getSession().removeAttribute("codigoVerificado");
            codigos.remove(email);

            responderJson(resp, true, "Contraseña actualizada. Ya puedes iniciar sesión.", null);

        } catch (SQLException e) {
            responderJson(resp, false, "Error del servidor: " + e.getMessage(), null);
        }
    }

    private void responderJson(HttpServletResponse resp, boolean ok, String mensaje, String email)
            throws IOException {
        PrintWriter out = resp.getWriter();
        String emailJson = email != null ? "\"" + email.replace("\"", "\\\"") + "\"" : "null";
        String mensajeJson = mensaje.replace("\\", "\\\\").replace("\"", "\\\"");
        out.print("{\"ok\":" + ok + ",\"mensaje\":\"" + mensajeJson + "\",\"email\":" + emailJson + "}");
        out.flush();
    }
}
