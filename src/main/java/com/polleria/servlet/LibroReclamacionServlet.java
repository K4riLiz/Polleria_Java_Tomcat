package com.polleria.servlet;

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
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Servlet del Libro de Reclamaciones (cliente).
 * GET: formulario | POST: registrar reclamo con validaciones, correo y PRG.
 */
public class LibroReclamacionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

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

        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Usuario u = (Usuario) session.getAttribute("usuario");

        String tipoReclamo   = trim(req.getParameter("tipoReclamo"));
        String nombre        = trim(req.getParameter("nombre"));
        String email         = trim(req.getParameter("email"));
        String telefono      = trim(req.getParameter("telefono"));
        String tipoDocumento = trim(req.getParameter("tipoDocumento"));
        String numeroDoc     = trim(req.getParameter("numeroDocumento"));
        String asunto        = trim(req.getParameter("asunto"));
        String descripcion   = trim(req.getParameter("descripcion"));
        String pedidoId      = trim(req.getParameter("pedidoId"));

        String error = validar(tipoReclamo, nombre, email, tipoDocumento,
                numeroDoc, asunto, descripcion);
        if (error != null) {
            req.setAttribute("error", error);
            req.getRequestDispatcher("/vista/libro-reclamaciones.jsp").forward(req, resp);
            return;
        }

        LibroReclamacion r = new LibroReclamacion();
        r.setNombre(nombre);
        r.setEmail(email);
        r.setTelefono(telefono);
        r.setTipoDocumento(tipoDocumento);
        r.setNumeroDocumento(numeroDoc);
        r.setTipoReclamo(tipoReclamo);
        r.setAsunto(asunto);
        r.setDescripcion(descripcion);
        r.setPedidoId(pedidoId.isEmpty() ? null : pedidoId);
        r.setUsuarioId(u.getId());

        try {
            LibroReclamacionDAO dao = new LibroReclamacionDAO();
            int id = dao.crear(r);
            if (id <= 0) {
                req.setAttribute("error", "No se pudo registrar el reclamo. Intente nuevamente.");
                req.getRequestDispatcher("/vista/libro-reclamaciones.jsp").forward(req, resp);
                return;
            }

            String fecha = LocalDateTime.now()
                    .format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
            EmailService.enviarConfirmacionReclamo(email, nombre, id, tipoReclamo, asunto, fecha);

            session.setAttribute("exito",
                    "Tu reclamo fue registrado correctamente. Número: #" + id);
            resp.sendRedirect(req.getContextPath() + "/libro-reclamaciones");

        } catch (SQLException e) {
            req.setAttribute("error", "Error al registrar: " + e.getMessage());
            req.getRequestDispatcher("/vista/libro-reclamaciones.jsp").forward(req, resp);
        }
    }

    private String validar(String tipo, String nombre, String email,
                           String tipoDoc, String numeroDoc,
                           String asunto, String descripcion) {
        if (!"Reclamo".equals(tipo) && !"Queja".equals(tipo))
            return "Tipo de registro inválido.";
        if (nombre == null || nombre.isEmpty())
            return "El nombre es obligatorio.";
        if (nombre.length() > 100)
            return "El nombre no puede superar 100 caracteres.";
        if (email == null || !email.matches("^[A-Za-z0-9+_.-]+@(.+)$"))
            return "Correo electrónico inválido.";
        if (tipoDoc == null || tipoDoc.isEmpty())
            return "Seleccione un tipo de documento.";
        if (numeroDoc == null || numeroDoc.isEmpty())
            return "El número de documento es obligatorio.";
        if (asunto == null || asunto.isEmpty())
            return "El asunto es obligatorio.";
        if (asunto.length() > LibroReclamacion.MAX_ASUNTO)
            return "El asunto no puede superar " + LibroReclamacion.MAX_ASUNTO + " caracteres.";
        if (descripcion == null || descripcion.isEmpty())
            return "La descripción es obligatoria.";
        if (descripcion.length() > LibroReclamacion.MAX_DESCRIPCION)
            return "La descripción no puede superar " + LibroReclamacion.MAX_DESCRIPCION + " caracteres.";
        return null;
    }

    private String trim(String s) {
        return s != null ? s.trim() : "";
    }
}
