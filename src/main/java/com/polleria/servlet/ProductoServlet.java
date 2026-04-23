package com.polleria.servlet;

import com.polleria.dao.ProductoDAO;
import com.polleria.model.Producto;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;


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

            req.setAttribute("producto", producto);
            req.getRequestDispatcher("/vista/detalle-producto.jsp").forward(req, resp);

        } catch (NumberFormatException | SQLException e) {
            resp.sendRedirect(req.getContextPath() + "/home");
        }
    }
}