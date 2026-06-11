package com.polleria.servlet;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;
import com.polleria.dao.PagoDAO;
import com.polleria.dao.PedidoDAO;
import com.polleria.model.DetallePedido;
import com.polleria.model.Pago;
import com.polleria.model.Pedido;
import com.polleria.model.Usuario;
import com.itextpdf.text.pdf.draw.LineSeparator;
import com.polleria.util.EmailService;

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
            PedidoDAO pedidoDAO = new PedidoDAO();
            PagoDAO pagoDAO = new PagoDAO();

            Pedido pedido = pedidoDAO.obtenerPorId(pedidoId);
            Pago pago = pagoDAO.obtenerPorPedido(pedidoId);
            List<DetallePedido> detalles = pedidoDAO.listarDetalles(pedidoId);
            Usuario usuario = (Usuario) session.getAttribute("usuario");

            if (pedido == null) {
                resp.sendRedirect(req.getContextPath() + "/home");
                return;
            }

            resp.setContentType("application/pdf");
            resp.setHeader("Content-Disposition", "attachment; filename=boleta-" + pedidoId + ".pdf");

            Document doc = new Document(PageSize.A4, 50, 50, 50, 50);
            PdfWriter.getInstance(doc, resp.getOutputStream());
            doc.open();

            BaseColor rojo = new BaseColor(192, 57, 43);
            BaseColor grisClaro = new BaseColor(245, 245, 245);
            BaseColor grisOscuro = new BaseColor(100, 100, 100);

            Font fTitulo    = new Font(Font.FontFamily.HELVETICA, 22, Font.BOLD, rojo);
            Font fSubtitulo = new Font(Font.FontFamily.HELVETICA, 11, Font.BOLD, BaseColor.WHITE);
            Font fNormal    = new Font(Font.FontFamily.HELVETICA, 10, Font.NORMAL, BaseColor.DARK_GRAY);
            Font fBold      = new Font(Font.FontFamily.HELVETICA, 10, Font.BOLD, BaseColor.DARK_GRAY);
            Font fSmall     = new Font(Font.FontFamily.HELVETICA, 9, Font.NORMAL, grisOscuro);
            Font fTotal     = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD, rojo);

            // ENCABEZADO
            PdfPTable header = new PdfPTable(2);
            header.setWidthPercentage(100);
            header.setWidths(new float[]{2f, 1f});
            header.setSpacingAfter(15);

            PdfPCell cEmpresa = new PdfPCell();
            cEmpresa.setBorder(Rectangle.NO_BORDER);
            cEmpresa.setPadding(5);
            cEmpresa.addElement(new Paragraph("Polleria El Dorado", fTitulo));
            cEmpresa.addElement(new Paragraph("RUC: 20123456789", fNormal));
            cEmpresa.addElement(new Paragraph("Av. La Marina 4534, San Miguel, Lima", fSmall));
            cEmpresa.addElement(new Paragraph("Tel: +51 999 888 777", fSmall));
            header.addCell(cEmpresa);

            PdfPCell cBoleta = new PdfPCell();
            cBoleta.setBorder(Rectangle.NO_BORDER);
            cBoleta.setPadding(5);
            Font fBoletaTit = new Font(Font.FontFamily.HELVETICA, 14, Font.BOLD, rojo);
            Paragraph pBoleta = new Paragraph("BOLETA DE VENTA", fBoletaTit);
            pBoleta.setAlignment(Element.ALIGN_RIGHT);
            Paragraph pNro = new Paragraph("N B001-" + String.format("%06d", pedidoId), fBold);
            pNro.setAlignment(Element.ALIGN_RIGHT);
            Paragraph pFecha = new Paragraph("Fecha: " + pedido.getFecha(), fSmall);
            pFecha.setAlignment(Element.ALIGN_RIGHT);
            cBoleta.addElement(pBoleta);
            cBoleta.addElement(pNro);
            cBoleta.addElement(pFecha);
            header.addCell(cBoleta);
            doc.add(header);

            doc.add(new Chunk(new LineSeparator(1, 100, rojo, Element.ALIGN_CENTER, -2)));
            doc.add(Chunk.NEWLINE);

            // DATOS CLIENTE
            PdfPTable tCliente = new PdfPTable(2);
            tCliente.setWidthPercentage(100);
            tCliente.setSpacingBefore(10);
            tCliente.setSpacingAfter(15);

            PdfPCell titCliente = new PdfPCell(new Phrase("DATOS DEL CLIENTE", fSubtitulo));
            titCliente.setBackgroundColor(rojo);
            titCliente.setPadding(6);
            titCliente.setColspan(2);
            titCliente.setBorder(Rectangle.NO_BORDER);
            tCliente.addCell(titCliente);

            filaCliente(tCliente, "Cliente:", usuario.getNombre(), fBold, fNormal);
            filaCliente(tCliente, "Correo:", usuario.getEmail(), fBold, fNormal);
            filaCliente(tCliente, "Direccion:", pedido.getDireccion() != null ? pedido.getDireccion() : "-", fBold, fNormal);
            doc.add(tCliente);

            // DETALLE PRODUCTOS
            PdfPTable tDetalle = new PdfPTable(4);
            tDetalle.setWidthPercentage(100);
            tDetalle.setWidths(new float[]{3.5f, 1f, 1.5f, 1.5f});
            tDetalle.setSpacingAfter(15);

            for (String enc : new String[]{"PRODUCTO", "CANT.", "PRECIO UNIT.", "SUBTOTAL"}) {
                PdfPCell c = new PdfPCell(new Phrase(enc, fSubtitulo));
                c.setBackgroundColor(rojo);
                c.setPadding(7);
                c.setBorder(Rectangle.NO_BORDER);
                c.setHorizontalAlignment(Element.ALIGN_CENTER);
                tDetalle.addCell(c);
            }

            boolean alterna = false;
            for (DetallePedido d : detalles) {
                BaseColor bg = alterna ? grisClaro : BaseColor.WHITE;

                PdfPCell cNom = new PdfPCell();
                cNom.setBorder(Rectangle.NO_BORDER);
                cNom.setBackgroundColor(bg);
                cNom.setPadding(6);
                cNom.addElement(new Paragraph(d.getProductoNombre(), fBold));
                if (d.getOpciones() != null && !d.getOpciones().isEmpty()) {
                    cNom.addElement(new Paragraph(d.getOpciones(), fSmall));
                }
                tDetalle.addCell(cNom);
                tDetalle.addCell(celda(String.valueOf(d.getCantidad()), fNormal, bg, Element.ALIGN_CENTER));
                tDetalle.addCell(celda("S/ " + String.format("%.2f", d.getPrecio()), fNormal, bg, Element.ALIGN_RIGHT));
                tDetalle.addCell(celda("S/ " + String.format("%.2f", d.getSubtotal()), fBold, bg, Element.ALIGN_RIGHT));
                alterna = !alterna;
            }
            doc.add(tDetalle);

            // TOTALES
            PdfPTable tTotales = new PdfPTable(2);
            tTotales.setWidthPercentage(45);
            tTotales.setHorizontalAlignment(Element.ALIGN_RIGHT);
            tTotales.setSpacingAfter(15);

            filaTotal(tTotales, "Subtotal:", "S/ " + String.format("%.2f", pedido.getTotal()), fNormal, fNormal);
            filaTotal(tTotales, "Delivery:", "Gratis", fNormal, fNormal);
            filaTotal(tTotales, "IGV (18%):", "Incluido", fNormal, fNormal);

            PdfPCell cTL = new PdfPCell(new Phrase("TOTAL:", fTotal));
            cTL.setBorder(Rectangle.TOP);
            cTL.setPadding(6);
            PdfPCell cTV = new PdfPCell(new Phrase("S/ " + String.format("%.2f", pedido.getTotal()), fTotal));
            cTV.setBorder(Rectangle.TOP);
            cTV.setPadding(6);
            cTV.setHorizontalAlignment(Element.ALIGN_RIGHT);
            tTotales.addCell(cTL);
            tTotales.addCell(cTV);
            doc.add(tTotales);

            // INFO PAGO
            if (pago != null) {
                PdfPTable tPago = new PdfPTable(2);
                tPago.setWidthPercentage(100);
                tPago.setSpacingAfter(15);

                PdfPCell titPago = new PdfPCell(new Phrase("INFORMACION DE PAGO", fSubtitulo));
                titPago.setBackgroundColor(rojo);
                titPago.setPadding(6);
                titPago.setColspan(2);
                titPago.setBorder(Rectangle.NO_BORDER);
                tPago.addCell(titPago);

                filaCliente(tPago, "Metodo:", pago.getMetodo(), fBold, fNormal);
                filaCliente(tPago, "Referencia:", pago.getReferencia(), fBold, fNormal);
                filaCliente(tPago, "Estado:", pago.getEstado(), fBold, fNormal);
                doc.add(tPago);
            }

            // PIE
            doc.add(new Chunk(new LineSeparator(1, 100, rojo, Element.ALIGN_CENTER, -2)));
            Paragraph pie = new Paragraph("\nGracias por su preferencia. Que disfrute su pedido!\nwww.polleriaeldorado.com", fSmall);
            pie.setAlignment(Element.ALIGN_CENTER);
            pie.setSpacingBefore(10);
            doc.add(pie);

            // Enviar boleta por correo registrado
            EmailService.enviarBoleta(usuario.getEmail(), usuario.getNombre(), pedidoId, detalles, pedido, pago);
            
            doc.close();

        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/home");
        }
    }

    private void filaCliente(PdfPTable t, String label, String val, Font fL, Font fV) {
        BaseColor borde = new BaseColor(230, 230, 230);
        PdfPCell c1 = new PdfPCell(new Phrase(label, fL));
        c1.setBorder(Rectangle.BOTTOM); c1.setBorderColor(borde); c1.setPadding(5);
        PdfPCell c2 = new PdfPCell(new Phrase(val, fV));
        c2.setBorder(Rectangle.BOTTOM); c2.setBorderColor(borde); c2.setPadding(5);
        t.addCell(c1); t.addCell(c2);
    }

    private void filaTotal(PdfPTable t, String label, String val, Font fL, Font fV) {
        PdfPCell c1 = new PdfPCell(new Phrase(label, fL));
        c1.setBorder(Rectangle.NO_BORDER); c1.setPadding(4);
        PdfPCell c2 = new PdfPCell(new Phrase(val, fV));
        c2.setBorder(Rectangle.NO_BORDER); c2.setPadding(4);
        c2.setHorizontalAlignment(Element.ALIGN_RIGHT);
        t.addCell(c1); t.addCell(c2);
    }

    private PdfPCell celda(String txt, Font f, BaseColor bg, int align) {
        PdfPCell c = new PdfPCell(new Phrase(txt, f));
        c.setBorder(Rectangle.NO_BORDER); c.setBackgroundColor(bg);
        c.setPadding(6); c.setHorizontalAlignment(align);
        return c;
    }
}