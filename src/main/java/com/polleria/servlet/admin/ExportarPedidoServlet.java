package com.polleria.servlet;

import com.polleria.dao.PedidoDAO;
import com.polleria.util.ReporteExcel;
import com.polleria.util.ReportePDF;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/exportarPedidos")
public class ExportarPedidoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ── Leer parámetros ───────────────────────────────────────────────
        String formato             = request.getParameter("formato");           // "excel" | "pdf"
        boolean incluirCancelados  = "true".equalsIgnoreCase(
                                        request.getParameter("incluirCancelados")); // default false

        if (formato == null || (!formato.equals("excel") && !formato.equals("pdf"))) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Formato inválido. Use 'excel' o 'pdf'.");
            return;
        }

        // ── Obtener datos desde DAO ───────────────────────────────────────
        PedidoDAO pedidoDAO = new PedidoDAO();
        List<Map<String, Object>> pedidos = new ArrayList<>();

        // Siempre incluir Entregados
        List<Map<String, Object>> entregados = pedidoDAO.getPedidosPorEstadoReporte("Entregado");
        if (entregados != null) pedidos.addAll(entregados);

        // Opcionalmente incluir Cancelados
        if (incluirCancelados) {
            List<Map<String, Object>> cancelados = pedidoDAO.getPedidosPorEstadoReporte("Cancelado");
            if (cancelados != null) pedidos.addAll(cancelados);
        }

        // ── Delegar al util correspondiente ──────────────────────────────
        if ("excel".equals(formato)) {
            ReporteExcel.exportar(response, pedidos);
        } else {
            ReportePDF.exportar(response, pedidos);
        }
    }
}