package com.polleria.servlet;

import com.polleria.dao.PagoDAO;
import com.polleria.dao.PedidoDAO;
import com.polleria.model.Pago;
import com.polleria.model.Pedido;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

public class ConfirmacionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String idParam = req.getParameter("pedidoId");
        if (idParam == null) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        try {
            int pedidoId = Integer.parseInt(idParam);
            PedidoDAO pedidoDAO = new PedidoDAO();
            PagoDAO pagoDAO = new PagoDAO();

            Pedido pedido = pedidoDAO.obtenerPorId(pedidoId);
            Pago pago = pagoDAO.obtenerPorPedido(pedidoId);

            req.setAttribute("pedido", pedido);
            req.setAttribute("pago", pago);
            req.setAttribute("detalles", pedidoDAO.listarDetalles(pedidoId));
            req.getRequestDispatcher("/vista/confirmacion.jsp").forward(req, resp);

        } catch (NumberFormatException | SQLException e) {
            resp.sendRedirect(req.getContextPath() + "/home");
        }
    }
}