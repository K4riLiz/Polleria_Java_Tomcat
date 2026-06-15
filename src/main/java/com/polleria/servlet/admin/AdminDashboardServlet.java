package com.polleria.servlet.admin;

import com.polleria.dao.DashboardDAO;
import com.polleria.model.Usuario;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class AdminDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!esAdmin(req, resp)) return;
        try {
            DashboardDAO dao = new DashboardDAO();

            // Métricas
            int pedidosHoy    = dao.pedidosHoy();
            int pedidosAyer   = dao.pedidosAyer();
            double ingresosHoy  = dao.ingresosHoy();
            double ingresosAyer = dao.ingresosAyer();
            int enProceso     = dao.pedidosEnProceso();
            int reclamaciones = dao.reclamacionesPendientes();
            int pedidosViejos = dao.pedidosPendientesViejos();
            String idsViejos  = dao.idsPedidosPendientesViejos();

            // Variación porcentual pedidos
            String varPedidos = calcularVariacion(pedidosHoy, pedidosAyer);
            String varIngresos = calcularVariacion(ingresosHoy, ingresosAyer);

            // Gráficos
            Map<String, Integer> pedidosPorEstado     = dao.pedidosPorEstado();
            Map<String, Double>  ventasSemana         = dao.ventasUltimos7Dias();
            Map<String, Integer> productosMasVendidos  = dao.productosMasVendidos();
            Map<String, Integer> promocionesMasVendidas = dao.promocionesMasVendidas();

            // Últimos pedidos
            List<Map<String, String>> ultimosPedidos = new ArrayList<>();
            try (ResultSet rs = dao.ultimosPedidos()) {
                while (rs.next()) {
                    Map<String, String> row = new java.util.LinkedHashMap<>();
                    row.put("id",      String.valueOf(rs.getInt("id")));
                    row.put("cliente", rs.getString("cliente"));
                    row.put("total",   String.format("%.2f", rs.getDouble("total")));
                    row.put("estado",  rs.getString("estado"));
                    row.put("fecha",   rs.getString("fecha"));
                    ultimosPedidos.add(row);
                }
            }

            req.setAttribute("pedidosHoy",           pedidosHoy);
            req.setAttribute("ingresosHoy",           ingresosHoy);
            req.setAttribute("enProceso",             enProceso);
            req.setAttribute("reclamaciones",         reclamaciones);
            req.setAttribute("pedidosViejos",         pedidosViejos);
            req.setAttribute("idsViejos",             idsViejos);
            req.setAttribute("varPedidos",            varPedidos);
            req.setAttribute("varIngresos",           varIngresos);
            req.setAttribute("pedidosPorEstado",      pedidosPorEstado);
            req.setAttribute("ventasSemana",          ventasSemana);
            req.setAttribute("productosMasVendidos",  productosMasVendidos);
            req.setAttribute("promocionesMasVendidas",promocionesMasVendidas);
            req.setAttribute("ultimosPedidos",        ultimosPedidos);

            req.getRequestDispatcher("/vista/admin/dashboard.jsp").forward(req, resp);
        } catch (SQLException e) {
            req.setAttribute("error", "Error: " + e.getMessage());
            req.getRequestDispatcher("/vista/admin/dashboard.jsp").forward(req, resp);
        }
    }

    private String calcularVariacion(double hoy, double ayer) {
        if (ayer == 0) return "+100%";
        double var = ((hoy - ayer) / ayer) * 100;
        return (var >= 0 ? "↑ +" : "↓ ") + String.format("%.0f", var) + "% vs ayer";
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