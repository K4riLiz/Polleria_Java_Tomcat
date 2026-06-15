package com.polleria.util;

import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

public class ReportePDF {

    private static final String[] COLUMNAS = {
        "ID Pedido", "ID Cliente", "Nombre Cliente",
        "Producto / Pedido", "Opciones", "Total (S/)", "Fecha", "Estado"
    };

    public static void exportar(HttpServletResponse response,
                                List<Map<String, Object>> pedidos) throws IOException {

        String fechaHoy = LocalDateTime.now()
                .format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));

        // Calcular total solo de pedidos Entregados
        double totalGeneral = pedidos.stream()
                .filter(p -> "Entregado".equals(str(p, "estado")))
                .mapToDouble(p -> {
                    try { return Double.parseDouble(str(p, "total").replace(",", ".")); }
                    catch (Exception e) { return 0; }
                }).sum();

        response.setContentType("text/html;charset=UTF-8");
        response.setHeader("Content-Disposition", "inline");

        OutputStream os = response.getOutputStream();

        StringBuilder sb = new StringBuilder();
        sb.append("<!DOCTYPE html><html lang='es'><head>")
          .append("<meta charset='UTF-8'>")
          .append("<title>Reporte Ventas — Pollería El Dorado</title>")
          .append("<style>")
          // ── Reset y base ───────────────────────────────────────────────
          .append("*{margin:0;padding:0;box-sizing:border-box;}")
          .append("body{font-family:'Segoe UI',Arial,sans-serif;font-size:11px;")
          .append("     color:#111827;background:#f9fafb;padding:24px;}")
          // ── Encabezado ─────────────────────────────────────────────────
          .append(".header{background:#991B1B;color:#fff;padding:16px 20px;")
          .append("        border-radius:10px 10px 0 0;margin-bottom:0;}")
          .append(".header h1{font-size:18px;font-weight:700;letter-spacing:.5px;}")
          .append(".header p{font-size:10px;color:#FCA5A5;margin-top:4px;}")
          .append(".meta{background:#7F1D1D;color:#FCA5A5;font-size:10px;")
          .append("      padding:6px 20px;margin-bottom:16px;border-radius:0 0 6px 6px;}")
          // ── Tabla ──────────────────────────────────────────────────────
          .append("table{width:100%;border-collapse:collapse;margin-bottom:16px;}")
          .append("thead tr{background:#991B1B;color:#fff;}")
          .append("thead th{padding:7px 10px;text-align:left;font-size:10px;")
          .append("          font-weight:600;letter-spacing:.4px;white-space:nowrap;}")
          .append("tbody tr:nth-child(even){background:#F9FAFB;}")
          .append("tbody tr:nth-child(odd){background:#fff;}")
          .append("tbody td{padding:6px 10px;border-bottom:1px solid #F3F4F6;")
          .append("          vertical-align:top;word-break:break-word;}")
          // ── Badges de estado ───────────────────────────────────────────
          .append(".badge{display:inline-block;padding:2px 8px;border-radius:20px;")
          .append("       font-size:10px;font-weight:600;white-space:nowrap;}")
          .append(".badge-entregado{background:#DCFCE7;color:#166534;}")
          .append(".badge-cancelado{background:#FEE2E2;color:#991B1B;}")
          // ── Total general ──────────────────────────────────────────────
          .append(".total-box{background:#FEF2F2;border:1px solid #FECACA;")
          .append("           border-radius:8px;padding:10px 16px;display:inline-block;")
          .append("           margin-left:auto;}")
          .append(".total-box span{font-size:11px;color:#6B7280;}")
          .append(".total-box strong{font-size:15px;color:#991B1B;display:block;margin-top:2px;}")
          .append(".total-row{display:flex;justify-content:flex-end;margin-bottom:20px;}")
          // ── Pie ────────────────────────────────────────────────────────
          .append(".footer{font-size:9px;color:#9CA3AF;text-align:center;")
          .append("        border-top:1px solid #E5E7EB;padding-top:10px;margin-top:8px;}")
          // ── Print ─────────────────────────────────────────────────────
          .append("@media print{")
          .append("  body{background:#fff;padding:12px;}")
          .append("  @page{size:A4 landscape;margin:10mm 12mm;}")
          .append("  .no-print{display:none!important;}")
          .append("  .header{border-radius:6px 6px 0 0;-webkit-print-color-adjust:exact;")
          .append("           print-color-adjust:exact;}")
          .append("  thead tr{-webkit-print-color-adjust:exact;print-color-adjust:exact;}")
          .append("  .badge{-webkit-print-color-adjust:exact;print-color-adjust:exact;}")
          .append("  .total-box{-webkit-print-color-adjust:exact;print-color-adjust:exact;}")
          .append("  table{page-break-inside:auto;}")
          .append("  tr{page-break-inside:avoid;}")
          .append("}")
          .append("</style></head><body>");

        // ── Botón imprimir (no aparece al imprimir) ──────────────────────
        sb.append("<div class='no-print' style='margin-bottom:16px;'>")
          .append("<button onclick='window.print()' style='background:#991B1B;color:#fff;")
          .append("border:none;padding:8px 20px;border-radius:8px;font-size:12px;")
          .append("font-weight:600;cursor:pointer;display:flex;align-items:center;gap:6px;'>")
          .append("&#128438; Guardar como PDF (Ctrl+P)</button>")
          .append("<p style='font-size:10px;color:#6B7280;margin-top:6px;'>")
          .append("En el diálogo de impresión selecciona <strong>Guardar como PDF</strong>.")
          .append("</p></div>");

        // ── Encabezado ────────────────────────────────────────────────────
        sb.append("<div class='header'>")
          .append("<h1>&#127831; Pollería El Dorado</h1>")
          .append("<p>Reporte de Ventas — Pedidos Entregados y Cancelados</p>")
          .append("</div>")
          .append("<div class='meta'>Generado el: ").append(fechaHoy)
          .append(" &nbsp;|&nbsp; Total de registros: ").append(pedidos.size())
          .append("</div>");

        // ── Tabla ─────────────────────────────────────────────────────────
        sb.append("<table><thead><tr>");
        for (String col : COLUMNAS) {
            sb.append("<th>").append(col).append("</th>");
        }
        sb.append("</tr></thead><tbody>");

        for (Map<String, Object> p : pedidos) {
            boolean esEntregado = "Entregado".equals(str(p, "estado"));
            String badgeClass   = esEntregado ? "badge-entregado" : "badge-cancelado";

            sb.append("<tr>")
              .append("<td>").append(esc(str(p, "id"))).append("</td>")
              .append("<td>").append(esc(str(p, "idCliente"))).append("</td>")
              .append("<td>").append(esc(str(p, "cliente"))).append("</td>")
              .append("<td>").append(esc(str(p, "pedido"))).append("</td>")
              .append("<td>").append(esc(str(p, "opciones"))).append("</td>")
              .append("<td style='font-weight:600;color:#166534;white-space:nowrap;'>")
              .append("S/ ").append(esc(str(p, "total"))).append("</td>")
              .append("<td style='white-space:nowrap;'>").append(esc(str(p, "fecha"))).append("</td>")
              .append("<td><span class='badge ").append(badgeClass).append("'>")
              .append(esc(str(p, "estado"))).append("</span></td>")
              .append("</tr>");
        }

        sb.append("</tbody></table>");

        // ── Total general ─────────────────────────────────────────────────
        sb.append("<div class='total-row'>")
          .append("<div class='total-box'>")
          .append("<span>Total ventas entregadas</span>")
          .append("<strong>S/ ").append(String.format("%.2f", totalGeneral)).append("</strong>")
          .append("</div></div>");

        // ── Pie ───────────────────────────────────────────────────────────
        sb.append("<div class='footer'>")
          .append("Pollería El Dorado &mdash; Reporte generado automáticamente el ")
          .append(fechaHoy)
          .append("</div>");

        // ── Auto-print al abrir ────────────────────────────────────────────
        sb.append("<script>")
          .append("window.onload = function(){ window.print(); };")
          .append("</script>");

        sb.append("</body></html>");

        os.write(sb.toString().getBytes(StandardCharsets.UTF_8));
    }

    // ── Helpers ──────────────────────────────────────────────────────────────
    private static String str(Map<String, Object> map, String key) {
        Object v = map.get(key);
        return v != null ? v.toString() : "";
    }

    /** Escapa caracteres HTML para evitar XSS en el reporte. */
    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;");
    }
}