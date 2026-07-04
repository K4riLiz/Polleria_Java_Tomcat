package com.polleria.servlet;

import com.polleria.dao.ClienteDAO;
import com.polleria.dao.PagoDAO;
import com.polleria.dao.PedidoDAO;
import com.polleria.model.*;
import com.polleria.util.CulqiService;
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

        Usuario usuario = (Usuario) session.getAttribute("usuario");
        try {
            ClienteDAO clienteDAO = new ClienteDAO();
            Cliente cliente = clienteDAO.obtenerPorUsuarioId(usuario.getId());
            boolean sinDireccion = (cliente == null
                    || cliente.getDireccion() == null
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

        Usuario usuario      = (Usuario) session.getAttribute("usuario");
        String metodo        = req.getParameter("metodo");
        String direccion     = req.getParameter("direccion");
        String culqiToken    = req.getParameter("culqiToken");
        String culqiEmail    = req.getParameter("culqiEmail");
        String yapeNumero    = req.getParameter("yapeNumero");
        String yapeOtp       = req.getParameter("yapeOtp");
        boolean guardarDir   = "true".equals(req.getParameter("guardarDireccion"));
        double total         = carrito.stream().mapToDouble(ItemCarrito::getSubtotal).sum();

        Double latitud  = null;
        Double longitud = null;
        try {
            String latStr = req.getParameter("latitud");
            String lngStr = req.getParameter("longitud");
            if (latStr != null && !latStr.isEmpty()) latitud  = Double.parseDouble(latStr);
            if (lngStr != null && !lngStr.isEmpty()) longitud = Double.parseDouble(lngStr);
        } catch (NumberFormatException ignored) {}

        try {
            // Validar stock
     
            String errorStock = StockService.validarCarrito(carrito);
            if (errorStock != null) {
                req.setAttribute("error", errorStock);
                req.setAttribute("total", total);
                req.getRequestDispatcher("/vista/checkout.jsp").forward(req, resp);
                return;
            }

            // Crear pedido
            Pedido pedido = new Pedido();
            pedido.setUsuarioId(usuario.getId());
            pedido.setTotal(total);
            pedido.setDireccion(direccion);
            pedido.setLatitud(latitud);
            pedido.setLongitud(longitud);

            PedidoDAO pedidoDAO = new PedidoDAO();
            int pedidoId = pedidoDAO.crear(pedido, carrito);

            // Procesar pago
            Pago pago = new Pago();
            pago.setPedidoId(pedidoId);
            pago.setMonto(total);

            try {
                if (culqiToken != null && !culqiToken.isEmpty()) {
                    String email = (culqiEmail != null && !culqiEmail.isEmpty())
                            ? culqiEmail : usuario.getEmail();
                    String chargeId = CulqiService.cobrar(culqiToken, total, email, pedidoId);
                    pago.setMetodo(metodo != null ? metodo : "Tarjeta");
                    pago.setEstado("Aprobado");
                    pago.setReferencia(chargeId);
                } else {
                    throw new Exception("No se recibió token de pago");
                }
            } catch (Exception e) {
                // Pago rechazado — cancelar pedido
                pedidoDAO.actualizarEstado(pedidoId, "Cancelado");
                req.setAttribute("error", "Pago rechazado: " + e.getMessage());
                req.setAttribute("total", total);

                // Recargar datos del cliente para el JSP
                try {
                    ClienteDAO cDAO = new ClienteDAO();
                    Cliente c = cDAO.obtenerPorUsuarioId(usuario.getId());
                    req.setAttribute("clientePerfil", c);
                    req.setAttribute("sinDireccion",
                        c == null || c.getDireccion() == null
                        || c.getDireccion().trim().isEmpty());
                } catch (SQLException ignored) {}

                req.getRequestDispatcher("/vista/checkout.jsp").forward(req, resp);
                return;
            }

            // Registrar pago aprobado
            new PagoDAO().registrar(pago);

            // Guardar dirección en perfil si marcó el checkbox
            if (guardarDir && direccion != null && !direccion.trim().isEmpty()) {
                try {
                    ClienteDAO clienteDAO = new ClienteDAO();
                    Cliente cliente = clienteDAO.obtenerPorUsuarioId(usuario.getId());
                    if (cliente != null) {
                        cliente.setDireccion(direccion);
                        cliente.setLatitud(latitud);
                        cliente.setLongitud(longitud);
                        clienteDAO.actualizar(cliente);
                    }
                } catch (SQLException ignored) {}
            }

            // Limpiar carrito y redirigir
            session.removeAttribute("carrito");
            resp.sendRedirect(req.getContextPath() + "/confirmacion?pedidoId=" + pedidoId);

        } catch (SQLException e) {
            req.setAttribute("error", "Error del servidor: " + e.getMessage());
            req.setAttribute("total", total);
            req.getRequestDispatcher("/vista/checkout.jsp").forward(req, resp);
        }
    }
}