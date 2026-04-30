package com.polleria.servlet;

import com.polleria.model.ItemCarrito;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

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

        // Mostrar carrito
        req.getRequestDispatcher("/vista/carrito.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");

        if ("agregar".equals(action)) {
            agregarItem(req);
        } else if ("actualizar".equals(action)) {
            actualizarCantidad(req);
        }

        resp.sendRedirect(req.getContextPath() + "/carrito");
    }

    // ── AGREGAR ITEM ───────────────────────────────────────
    @SuppressWarnings("unchecked")
    private void agregarItem(HttpServletRequest req) {
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

        // Si ya existe en el carrito, aumentar cantidad
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
    }

    // ── ACTUALIZAR CANTIDAD ────────────────────────────────
    @SuppressWarnings("unchecked")
    private void actualizarCantidad(HttpServletRequest req) {
        HttpSession session = req.getSession();
        List<ItemCarrito> carrito = (List<ItemCarrito>) session.getAttribute("carrito");
        if (carrito == null) return;

        int productoId = Integer.parseInt(req.getParameter("productoId"));
        int cantidad   = Integer.parseInt(req.getParameter("cantidad"));
        String tipo    = req.getParameter("tipo");

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
    }

    // ── ELIMINAR ITEM ──────────────────────────────────────
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