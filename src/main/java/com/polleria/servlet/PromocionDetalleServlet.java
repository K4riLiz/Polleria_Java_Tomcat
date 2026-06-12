package com.polleria.servlet;

import com.polleria.dao.PromocionDAO;
import com.polleria.model.Promocion;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

public class PromocionDetalleServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String idParam = req.getParameter("id");
        if (idParam == null) {
            resp.sendRedirect(req.getContextPath() + "/promociones");
            return;
        }
        try {
            int id = Integer.parseInt(idParam);
            PromocionDAO dao = new PromocionDAO();
            Promocion promocion = dao.obtenerPorId(id);
            if (promocion == null) {
                resp.sendRedirect(req.getContextPath() + "/promociones");
                return;
            }
            req.setAttribute("promocion", promocion);
            req.getRequestDispatcher("/vista/detalle-promocion.jsp").forward(req, resp);
        } catch (NumberFormatException | SQLException e) {
            resp.sendRedirect(req.getContextPath() + "/promociones");
        }
    }
}