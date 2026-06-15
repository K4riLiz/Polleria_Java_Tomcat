package com.polleria.servlet;

import com.polleria.dao.PedidoDAO;
import com.polleria.model.Pedido;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class EstadoPedidoServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        String idParam = req.getParameter("pedidoId");
        if (idParam == null) {
            resp.getWriter().write("{\"error\":\"Sin ID\"}");
            return;
        }

        try {
            Pedido pedido = new PedidoDAO().obtenerPorId(Integer.parseInt(idParam));
            if (pedido == null) {
                resp.getWriter().write("{\"error\":\"No encontrado\"}");
                return;
            }
            resp.getWriter().write("{\"estado\":\"" + pedido.getEstado() + "\"}");
        } catch (Exception e) {
            resp.getWriter().write("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }
}