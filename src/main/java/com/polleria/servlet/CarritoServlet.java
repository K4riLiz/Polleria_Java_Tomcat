package com.polleria.servlet;

import com.polleria.dao.ProductoDAO;
import com.polleria.model.ItemCarrito;
import com.polleria.util.StockService;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

public class CarritoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");

        if ("eliminar".equals(action)) {
            eliminarItem(req);
            resp.sendRedirect(req.getContextPath() + "/carrito");
            return;
        }

        if ("vaciar".equals(action)) {
            req.getSession().removeAttribute("carrito");
            resp.sendRedirect(req.getContextPath() + "/carrito");
            return;
        }

        // Cargar stock disponible para productos en el carrito
        cargarStocksEnRequest(req);
        req.getRequestDispatcher("/vista/carrito.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        String redirectUrl = req.getContextPath() + "/carrito";

        try {
            if ("agregar".equals(action)) {
                String error = agregarItem(req);
                if (error != null) {
                    req.getSession().setAttribute("carritoError", error);
                    String referer = req.getHeader("Referer");
                    redirectUrl = (referer != null && !referer.isEmpty())
                            ? referer : req.getContextPath() + "/carrito";
                }
            } else if ("actualizar".equals(action)) {
                String error = actualizarCantidad(req);
                if (error != null) {
                    req.getSession().setAttribute("carritoError", error);
                }
            }
        } catch (SQLException e) {
            req.getSession().setAttribute("carritoError", "Error al validar stock: " + e.getMessage());
        }

        resp.sendRedirect(redirectUrl);
    }

    @SuppressWarnings("unchecked")
    private void cargarStocksEnRequest(HttpServletRequest req) throws ServletException {
        List<ItemCarrito> carrito = (List<ItemCarrito>) req.getSession().getAttribute("carrito");
        if (carrito == null || carrito.isEmpty()) return;

        try {
            List<Integer> ids = carrito.stream()
                    .filter(i -> "producto".equals(i.getTipo()))
                    .map(ItemCarrito::getProductoId)
                    .distinct()
                    .collect(Collectors.toList());
            req.setAttribute("stocks", new ProductoDAO().obtenerStocks(ids));
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @SuppressWarnings("unchecked")
    private String agregarItem(HttpServletRequest req) throws SQLException {
        HttpSession session = req.getSession();
        List<ItemCarrito> carrito = (List<ItemCarrito>) session.getAttribute("carrito");
        if (carrito == null) carrito = new ArrayList<>();

        int productoId = Integer.parseInt(req.getParameter("productoId"));
        String nombre  = req.getParameter("nombre");
        double precio  = Double.parseDouble(req.getParameter("precio"));
        String imagen  = req.getParameter("imagen");
        int cantidad   = Integer.parseInt(req.getParameter("cantidad"));
        String tipo    = req.getParameter("tipo") != null ? req.getParameter("tipo") : "producto";
        String opciones = req.getParameter("opciones");

        // Validar stock solo para productos (no promociones)
        if ("producto".equals(tipo)) {
            String error = StockService.validarAgregar(productoId, cantidad, carrito);
            if (error != null) return error;
        }

        boolean encontrado = false;
        for (ItemCarrito item : carrito) {
            if (item.getProductoId() == productoId && item.getTipo().equals(tipo)) {
                item.setCantidad(item.getCantidad() + cantidad);
                encontrado = true;
                break;
            }
        }

        if (!encontrado) {
            carrito.add(new ItemCarrito(productoId, nombre, precio, imagen, cantidad, tipo, opciones));
        }

        session.setAttribute("carrito", carrito);
        return null;
    }

    @SuppressWarnings("unchecked")
    private String actualizarCantidad(HttpServletRequest req) throws SQLException {
        HttpSession session = req.getSession();
        List<ItemCarrito> carrito = (List<ItemCarrito>) session.getAttribute("carrito");
        if (carrito == null) return null;

        int productoId = Integer.parseInt(req.getParameter("productoId"));
        int cantidad   = Integer.parseInt(req.getParameter("cantidad"));
        String tipo    = req.getParameter("tipo");

        if ("producto".equals(tipo) && cantidad > 0) {
            String error = StockService.validarCantidad(productoId, cantidad, carrito);
            if (error != null) return error;
        }

        for (ItemCarrito item : carrito) {
            if (item.getProductoId() == productoId && item.getTipo().equals(tipo)) {
                if (cantidad <= 0) {
                    carrito.remove(item);
                } else {
                    item.setCantidad(cantidad);
                }
                break;
            }
        }

        session.setAttribute("carrito", carrito);
        return null;
    }

    @SuppressWarnings("unchecked")
    private void eliminarItem(HttpServletRequest req) {
        HttpSession session = req.getSession();
        List<ItemCarrito> carrito = (List<ItemCarrito>) session.getAttribute("carrito");
        if (carrito == null) return;

        int productoId = Integer.parseInt(req.getParameter("productoId"));
        String tipo    = req.getParameter("tipo");

        carrito.removeIf(item -> item.getProductoId() == productoId && item.getTipo().equals(tipo));
        session.setAttribute("carrito", carrito);
    }
}
