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
import java.util.*;

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

            // Cargar opciones y agrupar
            ProductoOpcionDAO opcionDAO = new ProductoOpcionDAO();
            List<ProductoOpcion> opciones = opcionDAO.listarActivasPorProducto(id);
            req.setAttribute("opciones", opciones);

            Map<String, List<ProductoOpcion>> opcionesPorGrupo = new LinkedHashMap<>();
            for (ProductoOpcion op : opciones) {
                opcionesPorGrupo
                    .computeIfAbsent(op.getGrupo(), k -> new ArrayList<>())
                    .add(op);
            }

            // Colores por grupo
            Map<String, String> coloresPorGrupo = new LinkedHashMap<>();
            coloresPorGrupo.put("Pollo",            "bg-red-600");
            coloresPorGrupo.put("Complemento",      "bg-orange-500");
            coloresPorGrupo.put("Guarnición",       "bg-yellow-500");
            coloresPorGrupo.put("Tipo de Ensalada", "bg-green-500");
            coloresPorGrupo.put("Bebida",           "bg-blue-500");
            coloresPorGrupo.put("Tipo de Bebida",   "bg-blue-500");
            coloresPorGrupo.put("Tipo de Jugo",     "bg-blue-400");

            req.setAttribute("producto", producto);
            req.setAttribute("opcionesPorGrupo", opcionesPorGrupo);
            req.setAttribute("coloresPorGrupo", coloresPorGrupo);

            // Cantidad en carrito
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