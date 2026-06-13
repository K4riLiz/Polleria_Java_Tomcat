package com.polleria.servlet.admin;

import com.polleria.dao.ProductoDAO;
import com.polleria.dao.ProductoOpcionDAO;
import com.polleria.dao.PromocionDAO;
import com.polleria.dao.PromocionOpcionDAO;
import com.polleria.model.*;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

public class AdminOpcionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!esAdmin(req, resp)) return;
        try {
            ProductoDAO productoDAO     = new ProductoDAO();
            PromocionDAO promocionDAO   = new PromocionDAO();
            ProductoOpcionDAO poDAO     = new ProductoOpcionDAO();
            PromocionOpcionDAO promoDAO = new PromocionOpcionDAO();

            List<Producto>  productos  = productoDAO.listarTodos();
            List<Promocion> promociones = promocionDAO.listarTodas();

            // Producto seleccionado
            String pidStr = req.getParameter("productoId");
            String promotStr = req.getParameter("promocionId");

            if (pidStr != null && !pidStr.isEmpty()) {
                int pid = Integer.parseInt(pidStr);
                req.setAttribute("productoSeleccionado", productoDAO.obtenerPorId(pid));
                req.setAttribute("opcionesProducto", poDAO.listarPorProducto(pid));
                req.setAttribute("tab", "productos");
            } else if (promotStr != null && !promotStr.isEmpty()) {
                int promId = Integer.parseInt(promotStr);
                req.setAttribute("promocionSeleccionada", promocionDAO.obtenerPorId(promId));
                req.setAttribute("opcionesPromocion", promoDAO.listarPorPromocion(promId));
                req.setAttribute("tab", "promociones");
            } else {
                req.setAttribute("tab", "productos");
            }

            // Editar opción producto
            String editPO = req.getParameter("editPO");
            if (editPO != null) {
                req.setAttribute("opcionEditar", poDAO.obtenerPorId(Integer.parseInt(editPO)));
            }
            // Editar opción promocion
            String editPRO = req.getParameter("editPRO");
            if (editPRO != null) {
                req.setAttribute("opcionPromoEditar", promoDAO.obtenerPorId(Integer.parseInt(editPRO)));
            }

            req.setAttribute("productos", productos);
            req.setAttribute("promociones", promociones);
            req.getRequestDispatcher("/vista/admin/opciones.jsp").forward(req, resp);
        } catch (SQLException e) {
            req.setAttribute("error", "Error: " + e.getMessage());
            req.getRequestDispatcher("/vista/admin/opciones.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!esAdmin(req, resp)) return;
        String action = req.getParameter("action");
        String redirectUrl = req.getContextPath() + "/admin/opciones";
        try {
            ProductoOpcionDAO poDAO     = new ProductoOpcionDAO();
            PromocionOpcionDAO promoDAO = new PromocionOpcionDAO();

            switch (action) {
                case "crearOpcionProducto" -> {
                    ProductoOpcion o = new ProductoOpcion();
                    o.setProductoId(Integer.parseInt(req.getParameter("productoId")));
                    o.setNombre(req.getParameter("nombre"));
                    o.setGrupo(req.getParameter("grupo"));
                    o.setPrecioAdicional(Double.parseDouble(req.getParameter("precioAdicional")));
                    poDAO.crear(o);
                    redirectUrl += "?productoId=" + o.getProductoId();
                    req.getSession().setAttribute("exito", "Opción creada correctamente.");
                }
                case "actualizarOpcionProducto" -> {
                    ProductoOpcion o = new ProductoOpcion();
                    o.setId(Integer.parseInt(req.getParameter("id")));
                    o.setNombre(req.getParameter("nombre"));
                    o.setGrupo(req.getParameter("grupo"));
                    o.setPrecioAdicional(Double.parseDouble(req.getParameter("precioAdicional")));
                    poDAO.actualizar(o);
                    redirectUrl += "?productoId=" + req.getParameter("productoId");
                    req.getSession().setAttribute("exito", "Opción actualizada correctamente.");
                }
                case "toggleOpcionProducto" -> {
                    int id = Integer.parseInt(req.getParameter("id"));
                    boolean activo = "1".equals(req.getParameter("activo"));
                    poDAO.toggleActivo(id, activo);
                    redirectUrl += "?productoId=" + req.getParameter("productoId");
                    req.getSession().setAttribute("exito", activo ? "Opción activada." : "Opción desactivada.");
                }
                case "crearOpcionPromocion" -> {
                    PromocionOpcion o = new PromocionOpcion();
                    o.setPromocionId(Integer.parseInt(req.getParameter("promocionId")));
                    o.setNombre(req.getParameter("nombre"));
                    o.setGrupo(req.getParameter("grupo"));
                    o.setPrecioAdicional(Double.parseDouble(req.getParameter("precioAdicional")));
                    promoDAO.crear(o);
                    redirectUrl += "?promocionId=" + o.getPromocionId() + "&tab=promociones";
                    req.getSession().setAttribute("exito", "Opción creada correctamente.");
                }
                case "actualizarOpcionPromocion" -> {
                    PromocionOpcion o = new PromocionOpcion();
                    o.setId(Integer.parseInt(req.getParameter("id")));
                    o.setNombre(req.getParameter("nombre"));
                    o.setGrupo(req.getParameter("grupo"));
                    o.setPrecioAdicional(Double.parseDouble(req.getParameter("precioAdicional")));
                    promoDAO.actualizar(o);
                    redirectUrl += "?promocionId=" + req.getParameter("promocionId") + "&tab=promociones";
                    req.getSession().setAttribute("exito", "Opción actualizada correctamente.");
                }
                case "toggleOpcionPromocion" -> {
                    int id = Integer.parseInt(req.getParameter("id"));
                    boolean activo = "1".equals(req.getParameter("activo"));
                    promoDAO.toggleActivo(id, activo);
                    redirectUrl += "?promocionId=" + req.getParameter("promocionId") + "&tab=promociones";
                    req.getSession().setAttribute("exito", activo ? "Opción activada." : "Opción desactivada.");
                }
            }
        } catch (SQLException e) {
            req.getSession().setAttribute("error", "Error: " + e.getMessage());
        }
        resp.sendRedirect(redirectUrl);
    }

    private boolean esAdmin(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return false;
        }
        Usuario u = (Usuario) session.getAttribute("usuario");
        if (!"ADMIN".equals(u.getRolNombre())) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return false;
        }
        return true;
    }
}