package com.polleria.servlet;

import com.polleria.dao.PromocionDAO;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

public class PromocionesServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            PromocionDAO dao = new PromocionDAO();
            req.setAttribute("promociones", dao.listarTodas());
        } catch (SQLException e) {
            req.setAttribute("error", "Error cargando promociones: " + e.getMessage());
        }
        req.getRequestDispatcher("/vista/promociones.jsp").forward(req, resp);
    }
}