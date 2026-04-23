package com.polleria.servlet;

import com.polleria.dao.UsuarioDAO;
import com.polleria.model.Usuario;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;


public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/vista/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");

        if ("login".equals(action)) {
            handleLogin(req, resp);
        } else if ("registro".equals(action)) {
            handleRegistro(req, resp);
        }
    }

    private void handleLogin(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        try {
            UsuarioDAO dao = new UsuarioDAO();
            Usuario usuario = dao.login(email, password);

            if (usuario != null) {
                HttpSession session = req.getSession();
                session.setAttribute("usuario", usuario);
                session.setAttribute("rolNombre", usuario.getRolNombre());

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

    private void handleRegistro(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String nombre = req.getParameter("nombre");
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        try {
            UsuarioDAO dao = new UsuarioDAO();
            if (dao.emailExiste(email)) {
                req.setAttribute("errorRegistro", "El correo ya está registrado");
                req.getRequestDispatcher("/vista/login.jsp").forward(req, resp);
                return;
            }
            Usuario u = new Usuario();
            u.setNombre(nombre);
            u.setEmail(email);
            u.setPassword(password);

            if (dao.registrar(u)) {
                req.setAttribute("exito", "Cuenta creada exitosamente. Inicia sesión.");
            } else {
                req.setAttribute("errorRegistro", "Error al registrar. Intenta de nuevo.");
            }
            req.getRequestDispatcher("/vista/login.jsp").forward(req, resp);
        } catch (SQLException e) {
            req.setAttribute("errorRegistro", "Error del servidor: " + e.getMessage());
            req.getRequestDispatcher("/vista/login.jsp").forward(req, resp);
        }
    }
}