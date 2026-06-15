package com.polleria.servlet;

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

        // Verificar sesión
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Verificar carrito
        List<ItemCarrito> carrito = (List<ItemCarrito>) session.getAttribute("carrito");
        if (carrito == null || carrito.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/carrito");
            return;
        }

        // Calcular total
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

    // Leer coordenadas del mapa
    Double latitud  = null;
    Double longitud = null;
    try {
        String latStr = req.getParameter("latitud");
        String lngStr = req.getParameter("longitud");
        if (latStr != null && !latStr.isEmpty()) latitud  = Double.parseDouble(latStr);
        if (lngStr != null && !lngStr.isEmpty()) longitud = Double.parseDouble(lngStr);
    } catch (NumberFormatException ignored) {}

    try {
        // Validar stock antes de confirmar el pedido
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

        session.removeAttribute("carrito");
        resp.sendRedirect(req.getContextPath() + "/confirmacion?pedidoId=" + pedidoId);

    } catch (SQLException e) {
        req.setAttribute("error", "Error al procesar el pago: " + e.getMessage());
        req.setAttribute("total", total);
        req.getRequestDispatcher("/vista/checkout.jsp").forward(req, resp);
    }
}
}