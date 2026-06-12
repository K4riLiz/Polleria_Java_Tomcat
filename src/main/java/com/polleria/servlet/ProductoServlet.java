package com.polleria.servlet;

import com.polleria.dao.ProductoDAO;
import com.polleria.dao.ProductoOpcionDAO;
import com.polleria.model.Producto;
import com.polleria.model.ProductoOpcion;
import com.polleria.model.ItemCarrito;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

public class ProductoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String idParam = req.getParameter("id");
        if (idParam == null) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }
        try {
            int id = Integer.parseInt(idParam);
            ProductoDAO dao = new ProductoDAO();
            Producto producto = dao.obtenerPorId(id);
            if (producto == null) {
                resp.sendRedirect(req.getContextPath() + "/home");
                return;
            }

            // Cargar opciones del producto desde la BD
            ProductoOpcionDAO opcionDAO = new ProductoOpcionDAO();
            List<ProductoOpcion> opciones = opcionDAO.listarPorProducto(id);
            req.setAttribute("producto", producto);
            req.setAttribute("opciones", opciones);

            // Verificar si el producto ya está en el carrito (de Danna)
            List<ItemCarrito> carrito = (List<ItemCarrito>) req.getSession().getAttribute("carrito");
            if (carrito != null) {
                for (ItemCarrito item : carrito) {
                    if (item.getProductoId() == id && "producto".equals(item.getTipo())) {
                        req.setAttribute("cantidadEnCarrito", item.getCantidad());
                        break;
                    }
                }
            }

            req.getRequestDispatcher("/vista/detalle-producto.jsp").forward(req, resp);
        } catch (NumberFormatException | SQLException e) {
            resp.sendRedirect(req.getContextPath() + "/home");
        }
    }
}