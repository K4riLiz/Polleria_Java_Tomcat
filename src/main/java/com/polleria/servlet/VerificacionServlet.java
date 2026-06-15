package com.polleria.servlet;

import com.polleria.dao.ClienteDAO;
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

        // ── REENVIAR código ────────────────────────────────────────────────────
        if ("reenviar".equals(accion)) {
            Usuario u = (Usuario) session.getAttribute("usuarioPendiente");
            if (u == null) {
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }
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

        // ── Verificar expiración ───────────────────────────────────────────────
        Long expiracion = (Long) session.getAttribute("codigoExpiracion");
        if (expiracion == null || System.currentTimeMillis() > expiracion) {
            session.removeAttribute("codigoVerificacion");
            session.removeAttribute("codigoExpiracion");
            session.removeAttribute("usuarioPendiente");
            session.removeAttribute("apellidoPendiente");
            req.setAttribute("errorRegistro", "El código expiró. Vuelve a registrarte.");
            req.getRequestDispatcher("/vista/login.jsp").forward(req, resp);
            return;
        }

        // ── VERIFICAR código ───────────────────────────────────────────────────
        if ("verificar".equals(accion)) {
            String codigoIngresado = req.getParameter("codigo");
            String codigoSession   = (String) session.getAttribute("codigoVerificacion");
            Usuario u              = (Usuario) session.getAttribute("usuarioPendiente");

            if (u == null || codigoSession == null) {
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }

            if (codigoIngresado.equals(codigoSession)) {
                try {
                    UsuarioDAO usuarioDAO = new UsuarioDAO();

                    if (usuarioDAO.registrar(u)) {
                        // Recuperar el apellido guardado en sesión
                        String apellido = (String) session.getAttribute("apellidoPendiente");

                        // Obtener el id del usuario recién creado
                        Usuario registrado = usuarioDAO.obtenerPorEmail(u.getEmail());

                        // Crear registro en clientes con apellido y teléfono
                        // (el teléfono ya viene en el objeto u desde el registro)
                        ClienteDAO clienteDAO = new ClienteDAO();
                        clienteDAO.crearConDatos(registrado.getId(), apellido, u.getTelefono());

                        // Limpiar sesión
                        session.removeAttribute("codigoVerificacion");
                        session.removeAttribute("codigoExpiracion");
                        session.removeAttribute("usuarioPendiente");
                        session.removeAttribute("apellidoPendiente");

                        req.setAttribute("exito", "Cuenta creada exitosamente. Inicia sesión.");
                    } else {
                        req.setAttribute("error", "Error al registrar. Intenta de nuevo.");
                    }

                } catch (SQLException e) {
                    req.setAttribute("error", "Error del servidor: " + e.getMessage());
                }
                req.getRequestDispatcher("/vista/login.jsp").forward(req, resp);

            } else {
                req.setAttribute("error", "Código incorrecto. Intenta de nuevo.");
                req.getRequestDispatcher("/vista/verificacion.jsp").forward(req, resp);
            }
        }
    }

    private String generarCodigo() {
        return String.valueOf(100000 + new Random().nextInt(900000));
    }
}