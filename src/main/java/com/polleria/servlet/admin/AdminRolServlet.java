package com.polleria.servlet.admin;

import com.polleria.dao.RolDAO;
import com.polleria.model.Usuario;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;


public class AdminRolServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!esAdmin(req, resp)) return;

        String action = req.getParameter("action");

        try {
            RolDAO dao = new RolDAO();

            if ("editar".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                req.setAttribute("rolEditar", dao.obtenerPorId(id));
            }

            req.setAttribute("roles", dao.listarTodos());
            req.getRequestDispatcher("/vista/admin/roles.jsp").forward(req, resp);

        } catch (SQLException e) {
            req.setAttribute("error", "Error: " + e.getMessage());
            req.getRequestDispatcher("/vista/admin/roles.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!esAdmin(req, resp)) return;

        String action = req.getParameter("action");

        try {
            RolDAO dao = new RolDAO();

            switch (action) {
                case "crear" -> {
                    dao.crear(req.getParameter("nombre"));
                    req.getSession().setAttribute("exito", "Rol creado correctamente.");
                }
                case "actualizar" -> {
                    int id = Integer.parseInt(req.getParameter("id"));
                    dao.actualizar(id, req.getParameter("nombre"));
                    req.getSession().setAttribute("exito", "Rol actualizado correctamente.");
                }
                case "eliminar" -> {
                    int id = Integer.parseInt(req.getParameter("id"));
                    dao.eliminar(id);
                    req.getSession().setAttribute("exito", "Rol eliminado correctamente.");
                }
            }
        } catch (SQLException e) {
            req.getSession().setAttribute("error", "Error: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/admin/roles");
    }

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