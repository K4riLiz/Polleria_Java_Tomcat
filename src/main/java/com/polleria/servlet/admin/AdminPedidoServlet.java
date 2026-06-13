package com.polleria.servlet.admin;

import com.polleria.dao.PedidoDAO;
import com.polleria.model.Usuario;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

import com.polleria.dao.DetallePedidoOpcionDAO;
import com.polleria.model.DetallePedido;
import com.polleria.model.Pedido;
import java.util.List;

public class AdminPedidoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!esAdmin(req, resp)) {
            return;
        }
        try {
            PedidoDAO dao = new PedidoDAO();
            DetallePedidoOpcionDAO opcionDAO = new DetallePedidoOpcionDAO();

            // Ya no necesitamos el action=detalle porque el detalle es modal
            String filtro = req.getParameter("estado");
            List<Pedido> pedidos = (filtro != null && !filtro.isEmpty())
                    ? dao.listarPorEstado(filtro)
                    : dao.listarTodos();

            // Cargar detalles y opciones de cada pedido para el modal
            for (Pedido p : pedidos) {
                List<DetallePedido> detalles = dao.listarDetalles(p.getId());
                for (DetallePedido d : detalles) {
                    d.setOpciones(opcionDAO.listarPorDetalle(d.getId()));
                }
                p.setDetalles(detalles);
            }

            req.setAttribute("pedidos", pedidos);
            req.setAttribute("filtro", filtro);
            req.getRequestDispatcher("/vista/admin/pedidos.jsp").forward(req, resp);
        } catch (SQLException e) {
            req.setAttribute("error", "Error: " + e.getMessage());
            req.getRequestDispatcher("/vista/admin/pedidos.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!esAdmin(req, resp)) return;
        String action = req.getParameter("action");
        try {
            PedidoDAO dao = new PedidoDAO();
            int id = Integer.parseInt(req.getParameter("id"));
            if ("cambiarEstado".equals(action)) {
                String estado = req.getParameter("estado");
                dao.actualizarEstado(id, estado);
                req.getSession().setAttribute("exito", "Estado actualizado correctamente.");
            }
        } catch (SQLException e) {
            req.getSession().setAttribute("error", "Error: " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/admin/pedidos");
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