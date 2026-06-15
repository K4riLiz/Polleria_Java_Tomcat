package com.polleria.servlet.admin;

import com.polleria.dao.PedidoDAO;
import com.polleria.model.Usuario;

import com.polleria.dao.DetallePedidoOpcionDAO;
import com.polleria.model.DetallePedido;
import com.polleria.model.Pedido;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

public class DeliveryPedidoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!esDelivery(req, resp)) {
            return;
        }
        try {
            PedidoDAO dao = new PedidoDAO();
            DetallePedidoOpcionDAO opcionDAO = new DetallePedidoOpcionDAO();

            List<Pedido> pedidos = dao.listarPorEstado("Por despachar");
            for (Pedido p : pedidos) {
                List<DetallePedido> detalles = dao.listarDetalles(p.getId());
                for (DetallePedido d : detalles) {
                    d.setOpciones(opcionDAO.listarPorDetalle(d.getId()));
                }
                p.setDetalles(detalles);
            }

            req.setAttribute("pedidos", pedidos);
            req.getRequestDispatcher("/vista/admin/delivery-pedidos.jsp").forward(req, resp);
        } catch (SQLException e) {
            req.setAttribute("error", "Error: " + e.getMessage());
            req.getRequestDispatcher("/vista/admin/delivery-pedidos.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!esDelivery(req, resp)) return;
        try {
            PedidoDAO dao = new PedidoDAO();
            int id = Integer.parseInt(req.getParameter("id"));
            String estado = req.getParameter("estado");
            // Delivery solo puede cambiar a Entregado
            if ("Entregado".equals(estado)) {
                dao.actualizarEstado(id, estado);
                req.getSession().setAttribute("exito", "Pedido marcado como entregado.");
            }
        } catch (SQLException e) {
            req.getSession().setAttribute("error", "Error: " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/delivery/pedidos");
    }

    private boolean esDelivery(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return false;
        }
        Usuario u = (Usuario) session.getAttribute("usuario");
        if (!"DELIVERY".equals(u.getRolNombre()) && !"ADMIN".equals(u.getRolNombre())) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return false;
        }
        return true;
    }
}