package com.polleria.servlet.admin;

import com.polleria.dao.LibroReclamacionDAO;
import com.polleria.model.LibroReclamacion;
import com.polleria.model.Usuario;
import com.polleria.util.EmailService;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

/**
 * Servlet admin del Libro de Reclamaciones.
 * GET: listar | POST: responder reclamo o marcar en proceso.
 */
public class AdminReclamacionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!esAdmin(req, resp)) return;

        String action = req.getParameter("action");
        if ("enProceso".equals(action)) {
            marcarEnProceso(req, resp);
            return;
        }

        try {
            LibroReclamacionDAO dao = new LibroReclamacionDAO();
            req.setAttribute("reclamaciones", dao.listarTodas());
            req.getRequestDispatcher("/vista/admin/reclamaciones.jsp").forward(req, resp);
        } catch (SQLException e) {
            req.setAttribute("error", "Error: " + e.getMessage());
            req.getRequestDispatcher("/vista/admin/reclamaciones.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!esAdmin(req, resp)) return;
        req.setCharacterEncoding("UTF-8");

        String action = req.getParameter("action");
        if (!"responder".equals(action)) {
            resp.sendRedirect(req.getContextPath() + "/admin/reclamaciones");
            return;
        }

        HttpSession session = req.getSession();
        int id;
        try {
            id = Integer.parseInt(req.getParameter("id"));
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Reclamo inválido.");
            resp.sendRedirect(req.getContextPath() + "/admin/reclamaciones");
            return;
        }

        String respuesta = req.getParameter("respuestaAdmin");
        if (respuesta != null) respuesta = respuesta.trim();

        if (respuesta == null || respuesta.isEmpty()) {
            session.setAttribute("error", "La respuesta no puede estar vacía.");
            resp.sendRedirect(req.getContextPath() + "/admin/reclamaciones");
            return;
        }
        if (respuesta.length() > LibroReclamacion.MAX_RESPUESTA) {
            session.setAttribute("error",
                    "La respuesta no puede superar " + LibroReclamacion.MAX_RESPUESTA + " caracteres.");
            resp.sendRedirect(req.getContextPath() + "/admin/reclamaciones");
            return;
        }

        try {
            LibroReclamacionDAO dao = new LibroReclamacionDAO();
            LibroReclamacion reclamo = dao.obtenerPorId(id);
            if (reclamo == null) {
                session.setAttribute("error", "Reclamo no encontrado.");
                resp.sendRedirect(req.getContextPath() + "/admin/reclamaciones");
                return;
            }
            if (LibroReclamacion.ESTADO_RESPONDIDO.equals(reclamo.getEstado())) {
                session.setAttribute("error", "Este reclamo ya fue respondido.");
                resp.sendRedirect(req.getContextPath() + "/admin/reclamaciones");
                return;
            }

            if (!dao.responder(id, respuesta)) {
                session.setAttribute("error", "No se pudo guardar la respuesta.");
                resp.sendRedirect(req.getContextPath() + "/admin/reclamaciones");
                return;
            }

            EmailService.enviarRespuestaReclamo(
                    reclamo.getEmail(),
                    reclamo.getNombre(),
                    reclamo.getId(),
                    reclamo.getTipoReclamo(),
                    reclamo.getAsunto() != null ? reclamo.getAsunto() : "Sin asunto",
                    reclamo.getFecha(),
                    respuesta);

            session.setAttribute("exito",
                    "Respuesta enviada correctamente al reclamo #" + id + ".");
            resp.sendRedirect(req.getContextPath() + "/admin/reclamaciones");

        } catch (SQLException e) {
            session.setAttribute("error", "Error al responder: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/admin/reclamaciones");
        }
    }

    /** Marca reclamo como En proceso (opcional, vía AJAX al abrir modal). */
    private void marcarEnProceso(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        int id;
        try {
            id = Integer.parseInt(req.getParameter("id"));
        } catch (NumberFormatException e) {
            resp.getWriter().write("{\"ok\":false}");
            return;
        }
        try {
            new LibroReclamacionDAO().marcarEnProceso(id);
            resp.getWriter().write("{\"ok\":true}");
        } catch (SQLException e) {
            resp.getWriter().write("{\"ok\":false}");
        }
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
