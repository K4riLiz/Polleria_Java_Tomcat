package com.polleria.servlet;

import com.polleria.dao.CategoriaDAO;
import com.polleria.dao.ProductoDAO;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;


public class HomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        
        try {
            CategoriaDAO catDao = new CategoriaDAO();
            req.setAttribute("categorias", catDao.listarTodas());
        } catch (SQLException e) {
            req.setAttribute("error", "Error cargando categorías");
        }
        req.getRequestDispatcher("/vista/home.jsp").forward(req, resp);
    }
}