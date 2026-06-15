package com.polleria.servlet;

import com.polleria.dao.ClienteDAO;
import com.polleria.dao.UsuarioDAO;
import com.polleria.model.Cliente;
import com.polleria.model.Usuario;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

public class PerfilServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        try {
            ClienteDAO clienteDAO = new ClienteDAO();
            Cliente cliente = clienteDAO.obtenerPorUsuarioId(usuario.getId());
            // Si no existe el cliente, crear uno vacío
            if (cliente == null) {
                clienteDAO.crear(usuario.getId());
                cliente = clienteDAO.obtenerPorUsuarioId(usuario.getId());
            }
            req.setAttribute("usuario", usuario);
            req.setAttribute("cliente", cliente);
            req.getRequestDispatcher("/vista/perfil.jsp").forward(req, resp);
        } catch (SQLException e) {
            req.setAttribute("error", "Error al cargar el perfil: " + e.getMessage());
            req.getRequestDispatcher("/vista/perfil.jsp").forward(req, resp);
        }
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
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        try {
            // Actualizar nombre en tabla usuarios
            String nombre   = req.getParameter("nombre");
            String telefono = req.getParameter("telefono");
            UsuarioDAO usuarioDAO = new UsuarioDAO();
            usuarioDAO.actualizarNombre(usuario.getId(), nombre);

            // Actualizar cliente
            ClienteDAO clienteDAO = new ClienteDAO();
            Cliente cliente = new Cliente();
            cliente.setUsuarioId(usuario.getId());
            cliente.setApellido(req.getParameter("apellido"));
            cliente.setTelefono(telefono);
            cliente.setDireccion(req.getParameter("direccion"));

            // Coordenadas del mapa
            String latStr = req.getParameter("latitud");
            String lngStr = req.getParameter("longitud");
            if (latStr != null && !latStr.isEmpty()) cliente.setLatitud(Double.parseDouble(latStr));
            if (lngStr != null && !lngStr.isEmpty()) cliente.setLongitud(Double.parseDouble(lngStr));

            clienteDAO.actualizar(cliente);

            // Actualizar sesión con nombre nuevo
            usuario.setNombre(nombre);
            session.setAttribute("usuario", usuario);

            session.setAttribute("exito", "Perfil actualizado correctamente.");
            resp.sendRedirect(req.getContextPath() + "/perfil");

        } catch (SQLException e) {
            session.setAttribute("error", "Error al guardar: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/perfil");
        }
    }
}