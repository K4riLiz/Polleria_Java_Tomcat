package com.polleria.servlet;

import com.polleria.dao.ProductoDAO;
import com.polleria.dao.PromocionDAO;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

public class BuscarServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String query = req.getParameter("q");

        if (query == null || query.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        try {
            ProductoDAO prodDAO = new ProductoDAO();
            PromocionDAO promoDAO = new PromocionDAO();

            req.setAttribute("query", query);
            req.setAttribute("productos", prodDAO.buscar(query));
            req.setAttribute("promociones", promoDAO.buscar(query));
            req.getRequestDispatcher("/vista/buscar.jsp").forward(req, resp);

        } catch (SQLException e) {
            req.setAttribute("error", "Error al buscar: " + e.getMessage());
            req.getRequestDispatcher("/vista/buscar.jsp").forward(req, resp);
        }
    }
}