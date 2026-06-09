package com.polleria.servlet;

import com.polleria.dao.LibroReclamacionDAO;
import com.polleria.model.LibroReclamacion;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import com.polleria.model.Usuario;

public class LibroReclamacionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        // Verificar si está logueado
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        
        req.getRequestDispatcher("/vista/libro-reclamaciones.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        LibroReclamacion r = new LibroReclamacion();
        r.setNombre(req.getParameter("nombre"));
        r.setEmail(req.getParameter("email"));
        r.setTelefono(req.getParameter("telefono"));
        r.setTipoDocumento(req.getParameter("tipoDocumento"));
        r.setNumeroDocumento(req.getParameter("numeroDocumento"));
        r.setTipoReclamo(req.getParameter("tipoReclamo"));
        r.setDescripcion(req.getParameter("descripcion"));
        r.setPedidoId(req.getParameter("pedidoId"));

        // Guardar el usuario logueado
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("usuario") != null) {
            Usuario u = (Usuario) session.getAttribute("usuario");
            r.setUsuarioId(u.getId());
        }

        try {
            LibroReclamacionDAO dao = new LibroReclamacionDAO();
            dao.crear(r);
            req.setAttribute("exito", "Tu reclamo fue registrado correctamente. Número: #" +
                    System.currentTimeMillis() % 10000);
        } catch (SQLException e) {
            req.setAttribute("error", "Error al registrar: " + e.getMessage());
        }

        req.getRequestDispatcher("/vista/libro-reclamaciones.jsp").forward(req, resp);
    }
}