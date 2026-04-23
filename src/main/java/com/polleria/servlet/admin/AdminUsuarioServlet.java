package com.polleria.servlet.admin;

import com.polleria.dao.RolDAO;
import com.polleria.dao.UsuarioDAO;
import com.polleria.model.Usuario;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;


public class AdminUsuarioServlet extends HttpServlet {

    // ── GET: listar o mostrar formulario edición ───────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!esAdmin(req, resp)) return;

        String action = req.getParameter("action");

        try {
            UsuarioDAO usuarioDAO = new UsuarioDAO();
            RolDAO rolDAO = new RolDAO();

            if ("editar".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                req.setAttribute("usuarioEditar", usuarioDAO.obtenerPorId(id));
            }

            req.setAttribute("usuarios", usuarioDAO.listarTodos());
            req.setAttribute("roles", rolDAO.listarTodos());
            req.getRequestDispatcher("/vista/admin/usuarios.jsp").forward(req, resp);

        } catch (SQLException e) {
            req.setAttribute("error", "Error: " + e.getMessage());
            req.getRequestDispatcher("/vista/admin/usuarios.jsp").forward(req, resp);
        }
    }

    // ── POST: crear, actualizar, eliminar ──────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!esAdmin(req, resp)) return;

        String action = req.getParameter("action");

        try {
            UsuarioDAO dao = new UsuarioDAO();

            switch (action) {
                case "crear" -> {
                    Usuario u = new Usuario();
                    u.setNombre(req.getParameter("nombre"));
                    u.setEmail(req.getParameter("email"));
                    u.setPassword(req.getParameter("password"));
                    u.setTelefono(req.getParameter("telefono"));
                    u.setRolId(Integer.parseInt(req.getParameter("rolId")));
                    if (dao.emailExiste(u.getEmail())) {
                        req.getSession().setAttribute("error", "El correo ya está registrado.");
                    } else {
                        dao.registrar(u);
                        req.getSession().setAttribute("exito", "Usuario creado correctamente.");
                    }
                }
                case "actualizar" -> {
                    Usuario u = new Usuario();
                    u.setId(Integer.parseInt(req.getParameter("id")));
                    u.setNombre(req.getParameter("nombre"));
                    u.setEmail(req.getParameter("email"));
                    u.setTelefono(req.getParameter("telefono"));
                    u.setRolId(Integer.parseInt(req.getParameter("rolId")));
                    u.setActivo("1".equals(req.getParameter("activo")));
                    dao.actualizar(u);
                    req.getSession().setAttribute("exito", "Usuario actualizado correctamente.");
                }
                case "eliminar" -> {
                    int id = Integer.parseInt(req.getParameter("id"));
                    dao.eliminar(id);
                    req.getSession().setAttribute("exito", "Usuario eliminado correctamente.");
                }
            }
        } catch (SQLException e) {
            req.getSession().setAttribute("error", "Error: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/admin/usuarios");
    }

    // ── Verificar que sea ADMIN ────────────────────────────
    private boolean esAdmin(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return false;
        }
        Usuario u = (Usuario) session.getAttribute("usuario");
        if (!"ADMIN".equals(u.getRolNombre())) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return false;
        }
        return true;
    }
}