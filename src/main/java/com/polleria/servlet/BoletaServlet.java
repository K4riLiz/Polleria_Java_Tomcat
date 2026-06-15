package com.polleria.servlet;

import com.polleria.dao.PagoDAO;
import com.polleria.dao.PedidoDAO;
import com.polleria.dao.DetallePedidoOpcionDAO;
import com.polleria.model.DetallePedido;
import com.polleria.model.Pago;
import com.polleria.model.Pedido;
import com.polleria.model.Usuario;
import com.polleria.util.BoletaPDFGenerator;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

public class BoletaServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String idParam = req.getParameter("pedidoId");
        if (idParam == null) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        try {
            int pedidoId = Integer.parseInt(idParam);
            PedidoDAO pedidoDAO               = new PedidoDAO();
            PagoDAO pagoDAO                   = new PagoDAO();
            DetallePedidoOpcionDAO opcionDAO  = new DetallePedidoOpcionDAO();

            Pedido pedido              = pedidoDAO.obtenerPorId(pedidoId);
            Pago pago                  = pagoDAO.obtenerPorPedido(pedidoId);
            List<DetallePedido> detalles = pedidoDAO.listarDetalles(pedidoId);
            Usuario usuario            = (Usuario) session.getAttribute("usuario");

            if (pedido == null) {
                resp.sendRedirect(req.getContextPath() + "/home");
                return;
            }

            // Cargar opciones de cada detalle
            for (DetallePedido d : detalles) {
                d.setOpciones(opcionDAO.listarPorDetalle(d.getId()));
            }

            // Generar PDF usando el generador centralizado
            byte[] pdfBytes = BoletaPDFGenerator.generar(pedido, detalles, pago, usuario);

            resp.setContentType("application/pdf");
            resp.setHeader("Content-Disposition", "attachment; filename=boleta-" + pedidoId + ".pdf");
            resp.setContentLength(pdfBytes.length);
            resp.getOutputStream().write(pdfBytes);

        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/home");
        }
    }
}