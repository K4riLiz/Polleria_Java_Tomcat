package com.polleria.servlet;

import com.polleria.dao.UsuarioDAO;
import com.polleria.model.Usuario;
import com.polleria.util.EmailService;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Random;

public class VerificacionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/vista/verificacion.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession();

        String accion = req.getParameter("accion");

        // Si es reenviar, NO verificar expiración — se genera código nuevo
        if ("reenviar".equals(accion)) {
            Usuario u = (Usuario) session.getAttribute("usuarioPendiente");
            if (u == null) {
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }
            // Generar nuevo código y nueva expiración de 5 minutos
            String nuevoCodigo = generarCodigo();
            session.setAttribute("codigoVerificacion", nuevoCodigo);
            session.setAttribute("codigoExpiracion", System.currentTimeMillis() + (5 * 60 * 1000));
            try {
                EmailService.enviarCodigo(u.getEmail(), nuevoCodigo);
                req.setAttribute("info", "Código reenviado a tu correo.");
            } catch (Exception e) {
                req.setAttribute("error", "Error al reenviar el código.");
            }
            req.getRequestDispatcher("/vista/verificacion.jsp").forward(req, resp);
            return;
        }

        // Para cualquier otra acción, verificar si el código expiró
        Long expiracion = (Long) session.getAttribute("codigoExpiracion");
        if (expiracion == null || System.currentTimeMillis() > expiracion) {
            // Limpiar sesión y mandar de vuelta al login
            session.removeAttribute("codigoVerificacion");
            session.removeAttribute("codigoExpiracion");
            session.removeAttribute("usuarioPendiente");
            req.setAttribute("errorRegistro", "El código expiró. Vuelve a registrarte.");
            req.getRequestDispatcher("/vista/login.jsp").forward(req, resp);
            return;
        }

        if ("verificar".equals(accion)) {
            String codigoIngresado = req.getParameter("codigo");
            String codigoSession   = (String) session.getAttribute("codigoVerificacion");
            Usuario u              = (Usuario) session.getAttribute("usuarioPendiente");

            if (u == null || codigoSession == null) {
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }

            if (codigoIngresado.equals(codigoSession)) {
                // Código correcto → registrar en BD
                try {
                    UsuarioDAO dao = new UsuarioDAO();
                    if (dao.registrar(u)) {
                        // Limpiar sesión después de registrar
                        session.removeAttribute("codigoVerificacion");
                        session.removeAttribute("codigoExpiracion");
                        session.removeAttribute("usuarioPendiente");
                        req.setAttribute("exito", "Cuenta creada exitosamente. Inicia sesión.");
                    } else {
                        req.setAttribute("error", "Error al registrar. Intenta de nuevo.");
                    }
                } catch (SQLException e) {
                    req.setAttribute("error", "Error del servidor: " + e.getMessage());
                }
                req.getRequestDispatcher("/vista/login.jsp").forward(req, resp);
            } else {
                // Código incorrecto → volver a verificación
                req.setAttribute("error", "Código incorrecto. Intenta de nuevo.");
                req.getRequestDispatcher("/vista/verificacion.jsp").forward(req, resp);
            }
        }
    }

    // Genera un código de 6 dígitos aleatorio
    private String generarCodigo() {
        return String.valueOf(100000 + new Random().nextInt(900000));
    }
}