package com.polleria.servlet;

import com.polleria.dao.LibroReclamacionDAO;
import com.polleria.model.Usuario;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

/**
 * Servlet para que el cliente vea su historial de reclamos ("Mis Reclamos").
 */
public class MisReclamosServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Usuario u = (Usuario) session.getAttribute("usuario");
        try {
            LibroReclamacionDAO dao = new LibroReclamacionDAO();
            req.setAttribute("reclamaciones", dao.listarPorUsuario(u.getId()));
            req.getRequestDispatcher("/vista/mis-reclamos.jsp").forward(req, resp);
        } catch (SQLException e) {
            req.setAttribute("error", "Error al cargar reclamos: " + e.getMessage());
            req.getRequestDispatcher("/vista/mis-reclamos.jsp").forward(req, resp);
        }
    }
}
