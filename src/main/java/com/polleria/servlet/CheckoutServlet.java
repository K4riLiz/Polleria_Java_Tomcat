package com.polleria.servlet;

import com.polleria.dao.ClienteDAO;
import com.polleria.dao.PagoDAO;
import com.polleria.dao.PedidoDAO;
import com.polleria.model.*;
import com.polleria.util.StockService;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

public class CheckoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        List<ItemCarrito> carrito = (List<ItemCarrito>) session.getAttribute("carrito");
        if (carrito == null || carrito.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/carrito");
            return;
        }

        // Verificar si el cliente tiene dirección guardada para mostrar el checkbox
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        try {
            ClienteDAO clienteDAO = new ClienteDAO();
            Cliente cliente = clienteDAO.obtenerPorUsuarioId(usuario.getId());
            boolean sinDireccion = (cliente == null || cliente.getDireccion() == null
                                    || cliente.getDireccion().trim().isEmpty());
            req.setAttribute("clientePerfil", cliente);
            req.setAttribute("sinDireccion", sinDireccion);
        } catch (SQLException e) {
            req.setAttribute("sinDireccion", false);
        }

        double total = carrito.stream().mapToDouble(ItemCarrito::getSubtotal).sum();
        req.setAttribute("total", total);
        req.getRequestDispatcher("/vista/checkout.jsp").forward(req, resp);
    }

    @Override
    @SuppressWarnings("unchecked")
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        List<ItemCarrito> carrito = (List<ItemCarrito>) session.getAttribute("carrito");
        if (carrito == null || carrito.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/carrito");
            return;
        }

        Usuario usuario  = (Usuario) session.getAttribute("usuario");
        String metodo    = req.getParameter("metodo");
        String direccion = req.getParameter("direccion");
        double total     = carrito.stream().mapToDouble(ItemCarrito::getSubtotal).sum();

        Double latitud  = null;
        Double longitud = null;
        try {
            String latStr = req.getParameter("latitud");
            String lngStr = req.getParameter("longitud");
            if (latStr != null && !latStr.isEmpty()) latitud  = Double.parseDouble(latStr);
            if (lngStr != null && !lngStr.isEmpty()) longitud = Double.parseDouble(lngStr);
        } catch (NumberFormatException ignored) {}

        // ¿El cliente marcó "guardar dirección en perfil"?
        boolean guardarDireccion = "true".equals(req.getParameter("guardarDireccion"));

        try {
            String errorStock = StockService.validarCarrito(carrito);
            if (errorStock != null) {
                req.setAttribute("error", errorStock);
                req.setAttribute("total", total);
                req.getRequestDispatcher("/vista/checkout.jsp").forward(req, resp);
                return;
            }

            Pedido pedido = new Pedido();
            pedido.setUsuarioId(usuario.getId());
            pedido.setTotal(total);
            pedido.setDireccion(direccion);
            pedido.setLatitud(latitud);
            pedido.setLongitud(longitud);

            PedidoDAO pedidoDAO = new PedidoDAO();
            int pedidoId = pedidoDAO.crear(pedido, carrito);

            Pago pago = new Pago();
            pago.setPedidoId(pedidoId);
            pago.setMetodo(metodo);
            pago.setMonto(total);
            pago.setReferencia("REF-" + System.currentTimeMillis() % 100000);
            new PagoDAO().registrar(pago);

            // Si el cliente no tenía dirección y marcó la opción, guardar en perfil
            if (guardarDireccion && direccion != null && !direccion.trim().isEmpty()) {
                try {
                    ClienteDAO clienteDAO = new ClienteDAO();
                    Cliente cliente = clienteDAO.obtenerPorUsuarioId(usuario.getId());
                    if (cliente != null) {
                        cliente.setDireccion(direccion);
                        cliente.setLatitud(latitud);
                        cliente.setLongitud(longitud);
                        clienteDAO.actualizar(cliente);
                    }
                } catch (SQLException ignored) {
                    // No interrumpir el flujo del pedido si falla guardar en perfil
                }
            }

            session.removeAttribute("carrito");
            resp.sendRedirect(req.getContextPath() + "/confirmacion?pedidoId=" + pedidoId);

        } catch (SQLException e) {
            req.setAttribute("error", "Error al procesar el pago: " + e.getMessage());
            req.setAttribute("total", total);
            req.getRequestDispatcher("/vista/checkout.jsp").forward(req, resp);
        }
    }
}