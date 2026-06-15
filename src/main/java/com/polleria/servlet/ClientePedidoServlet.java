package com.polleria.servlet;

import com.polleria.dao.DetallePedidoOpcionDAO;
import com.polleria.dao.PedidoDAO;
import com.polleria.model.DetallePedido;
import com.polleria.model.Pedido;
import com.polleria.model.Usuario;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

public class ClientePedidoServlet extends HttpServlet {

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
            PedidoDAO dao = new PedidoDAO();
            DetallePedidoOpcionDAO opcionDAO = new DetallePedidoOpcionDAO();

            List<Pedido> pedidos = dao.listarPorUsuario(usuario.getId());

            for (Pedido p : pedidos) {
                List<DetallePedido> detalles = dao.listarDetalles(p.getId());
                for (DetallePedido d : detalles) {
                    d.setOpciones(opcionDAO.listarPorDetalle(d.getId()));
                }
                p.setDetalles(detalles);
            }

            req.setAttribute("pedidos", pedidos);
            req.getRequestDispatcher("/vista/historial.jsp").forward(req, resp);
        } catch (SQLException e) {
            req.setAttribute("error", "Error: " + e.getMessage());
            req.getRequestDispatcher("/vista/historial.jsp").forward(req, resp);
        }
    }
}