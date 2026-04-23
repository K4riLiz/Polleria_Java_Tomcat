package com.polleria.servlet;

import com.polleria.dao.CategoriaDAO;
import com.polleria.dao.ProductoDAO;
import com.polleria.model.Categoria;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;


public class CategoriaServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String idParam = req.getParameter("id");

        if (idParam == null) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        try {
            int categoriaId = Integer.parseInt(idParam);
            CategoriaDAO catDao = new CategoriaDAO();
            ProductoDAO prodDao = new ProductoDAO();

            Categoria categoria = catDao.obtenerPorId(categoriaId);
            if (categoria == null) {
                resp.sendRedirect(req.getContextPath() + "/home");
                return;
            }

            req.setAttribute("categoria", categoria);
            req.setAttribute("productos", prodDao.listarPorCategoria(categoriaId));
            req.setAttribute("categorias", catDao.listarTodas());
            req.getRequestDispatcher("/vista/categoria.jsp").forward(req, resp);

        } catch (NumberFormatException | SQLException e) {
            resp.sendRedirect(req.getContextPath() + "/home");
        }
    }
}