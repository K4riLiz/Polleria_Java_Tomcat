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

public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/vista/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Asegurar encoding UTF-8 para ñ y tildes
        req.setCharacterEncoding("UTF-8");

        String action = req.getParameter("action");

        if ("login".equals(action)) {
            handleLogin(req, resp);
        } else if ("registro".equals(action)) {
            handleRegistro(req, resp);
        }
    }

    // ── LOGIN ──────────────────────────────────────────────────────────────────
    private void handleLogin(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        try {
            UsuarioDAO dao = new UsuarioDAO();
            Usuario usuario = dao.login(email, password);

            if (usuario != null) {
                // Guardar usuario en sesión
                HttpSession session = req.getSession();
                session.setAttribute("usuario", usuario);
                session.setAttribute("rolNombre", usuario.getRolNombre());

                // Redirigir según rol
                if ("ADMIN".equals(usuario.getRolNombre())) {
                    resp.sendRedirect(req.getContextPath() + "/admin/usuarios");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/home");
                }
            } else {
                req.setAttribute("error", "Correo o contraseña incorrectos");
                req.getRequestDispatcher("/vista/login.jsp").forward(req, resp);
            }
        } catch (SQLException e) {
            req.setAttribute("error", "Error del servidor: " + e.getMessage());
            req.getRequestDispatcher("/vista/login.jsp").forward(req, resp);
        }
    }

    // ── REGISTRO ───────────────────────────────────────────────────────────────
    private void handleRegistro(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String nombre   = req.getParameter("nombre");
        String email    = req.getParameter("email");
        String password = req.getParameter("password");
        String telefono = req.getParameter("telefono");

        try {
            // Validación: solo letras y espacios en el nombre
            if (!nombre.matches("^[a-zA-ZáéíóúÁÉÍÓÚñÑ ]+$")) {
                req.setAttribute("errorRegistro", "El nombre solo debe contener letras");
                req.getRequestDispatcher("/vista/login.jsp").forward(req, resp);
                return;
            }

            // Validación: longitud del nombre
            if (nombre.length() < 3 || nombre.length() > 50) {
                req.setAttribute("errorRegistro", "El nombre debe tener entre 3 y 50 caracteres");
                req.getRequestDispatcher("/vista/login.jsp").forward(req, resp);
                return;
            }

            // Validación: formato de email
            if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
                req.setAttribute("errorRegistro", "Formato de correo inválido");
                req.getRequestDispatcher("/vista/login.jsp").forward(req, resp);
                return;
            }

            // Validación: solo dominios conocidos y reales
            String[] dominiosValidos = {
                "gmail.com", "hotmail.com", "outlook.com", "yahoo.com", "icloud.com"
            };
            boolean valido = false;
            for (String dominio : dominiosValidos) {
                if (email.toLowerCase().endsWith("@" + dominio)) {
                    valido = true;
                    break;
                }
            }
            if (!valido) {
                req.setAttribute("errorRegistro", "Debes usar un correo válido");
                req.getRequestDispatcher("/vista/login.jsp").forward(req, resp);
                return;
            }

            // Validación: correo no duplicado en BD
            UsuarioDAO dao = new UsuarioDAO();
            if (dao.emailExiste(email)) {
                req.setAttribute("errorRegistro", "El correo ya está registrado");
                req.getRequestDispatcher("/vista/login.jsp").forward(req, resp);
                return;
            }

            // Guardar datos del usuario en sesión (aún NO se registra en BD)
            Usuario u = new Usuario();
            u.setNombre(nombre);
            u.setEmail(email);
            u.setPassword(password);
            u.setTelefono(telefono);

            // Generar código de 6 dígitos aleatorio
            String codigo = String.valueOf(100000 + new Random().nextInt(900000));

            // Guardar en sesión para verificar después
            HttpSession session = req.getSession();
            session.setAttribute("usuarioPendiente", u);
            session.setAttribute("codigoVerificacion", codigo);
            
            // Guardar tiempo de expiración (5 minutos)
            session.setAttribute("codigoExpiracion", System.currentTimeMillis() + (5 * 60 * 1000));

            // Enviar código al correo del usuario
            EmailService.enviarCodigo(email, codigo);

            // Redirigir a pantalla de verificación
            resp.sendRedirect(req.getContextPath() + "/verificacion");

        } catch (SQLException e) {
            req.setAttribute("errorRegistro", "Error del servidor: " + e.getMessage());
            req.getRequestDispatcher("/vista/login.jsp").forward(req, resp);
        } catch (Exception e) {
            // Error al enviar el correo
            req.setAttribute("errorRegistro", "Error al enviar el correo: " + e.getMessage());
            req.getRequestDispatcher("/vista/login.jsp").forward(req, resp);
        }
    }
}