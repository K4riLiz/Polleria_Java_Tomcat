package com.polleria.servlet;

import com.polleria.dao.PedidoDAO;
import com.polleria.model.Usuario;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

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
            String action = req.getParameter("action");
            if ("detalle".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                // Verificar que el pedido pertenece al cliente
                com.polleria.model.Pedido pedido = dao.obtenerPorId(id);
                if (pedido == null || pedido.getUsuarioId() != usuario.getId()) {
                    resp.sendRedirect(req.getContextPath() + "/historial");
                    return;
                }
                req.setAttribute("pedido", pedido);
                req.setAttribute("detalles", dao.listarDetalles(id));
                req.getRequestDispatcher("/vista/historial-detalle.jsp").forward(req, resp);
                return;
            }
            req.setAttribute("pedidos", dao.listarEntregadosPorUsuario(usuario.getId()));
            req.getRequestDispatcher("/vista/historial.jsp").forward(req, resp);
        } catch (SQLException e) {
            req.setAttribute("error", "Error: " + e.getMessage());
            req.getRequestDispatcher("/vista/historial.jsp").forward(req, resp);
        }
    }
}