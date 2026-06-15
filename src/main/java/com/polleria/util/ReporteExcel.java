package com.polleria.util;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.*;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

public class ReporteExcel {

    // ── Colores corporativos ────────────────────────────────────────────────
    private static final byte[] COLOR_ROJO    = hexToRgb("B91C1C"); // rojo oscuro
    private static final byte[] COLOR_ROJO_L  = hexToRgb("FEE2E2"); // rojo claro (filas pares)
    private static final byte[] COLOR_BLANCO  = hexToRgb("FFFFFF");
    private static final byte[] COLOR_GRIS    = hexToRgb("F9FAFB"); // filas impares
    private static final byte[] COLOR_TEXTO   = hexToRgb("111827");
    private static final byte[] COLOR_HEADER  = hexToRgb("FFFFFF"); // texto de cabecera

    // ── Columnas del reporte ────────────────────────────────────────────────
    private static final String[] COLUMNAS = {
        "ID Pedido", "ID Cliente", "Nombre Cliente",
        "Producto / Pedido", "Opciones", "Total (S/)", "Fecha", "Estado"
    };

    // Anchos de columna en unidades POI (256 = 1 carácter)
    private static final int[] ANCHOS = {
        12 * 256, 12 * 256, 28 * 256,
        35 * 256, 38 * 256, 14 * 256, 22 * 256, 15 * 256
    };

    /**
     * Genera y escribe el archivo Excel directamente en el HttpServletResponse.
     *
     * @param response  respuesta HTTP donde se descarga el archivo
     * @param pedidos   lista de mapas con claves:
     *                  id, idCliente, cliente, pedido, opciones, total, fecha, estado
     */
    public static void exportar(HttpServletResponse response,
                                List<Map<String, Object>> pedidos) throws IOException {

        String fechaHoy = LocalDateTime.now()
                .format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
        String nombreArchivo = "Reporte_Ventas_ElDorado_"
                + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmm"))
                + ".xlsx";

        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + nombreArchivo + "\"");

        try (XSSFWorkbook wb = new XSSFWorkbook()) {

            XSSFSheet sheet = wb.createSheet("Ventas");

            // ── 1. Fila de título ───────────────────────────────────────────
            Row rowTitulo = sheet.createRow(0);
            rowTitulo.setHeightInPoints(28);
            Cell cTitulo = rowTitulo.createCell(0);
            cTitulo.setCellValue("Pollería El Dorado — Reporte de Ventas");
            cTitulo.setCellStyle(estiloTitulo(wb));
            sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, COLUMNAS.length - 1));

            // ── 2. Fila de subtítulo (fecha generación) ─────────────────────
            Row rowSub = sheet.createRow(1);
            rowSub.setHeightInPoints(18);
            Cell cSub = rowSub.createCell(0);
            cSub.setCellValue("Generado el: " + fechaHoy
                    + "    |    Total de registros: " + pedidos.size());
            cSub.setCellStyle(estiloSubtitulo(wb));
            sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, COLUMNAS.length - 1));

            // ── 3. Fila vacía de separación ─────────────────────────────────
            sheet.createRow(2).setHeightInPoints(6);

            // ── 4. Cabecera de columnas ─────────────────────────────────────
            Row rowHeader = sheet.createRow(3);
            rowHeader.setHeightInPoints(20);
            CellStyle stHeader = estiloHeader(wb);
            for (int c = 0; c < COLUMNAS.length; c++) {
                Cell cell = rowHeader.createCell(c);
                cell.setCellValue(COLUMNAS[c]);
                cell.setCellStyle(stHeader);
                sheet.setColumnWidth(c, ANCHOS[c]);
            }

            // ── 5. Filas de datos ────────────────────────────────────────────
            int rowNum = 4;
            for (Map<String, Object> p : pedidos) {
                Row row = sheet.createRow(rowNum);
                row.setHeightInPoints(16);

                boolean esEntregado = "Entregado".equals(str(p, "estado"));
                CellStyle stDato    = estiloDato(wb, rowNum % 2 == 0, esEntregado);
                CellStyle stTotal   = estiloTotal(wb, rowNum % 2 == 0, esEntregado);
                CellStyle stEstado  = estiloEstado(wb, esEntregado);

                setCell(row, 0, str(p, "id"),         stDato);
                setCell(row, 1, str(p, "idCliente"),  stDato);
                setCell(row, 2, str(p, "cliente"),    stDato);
                setCell(row, 3, str(p, "pedido"),     stDato);
                setCell(row, 4, str(p, "opciones"),   stDato);
                setCell(row, 5, str(p, "total"),      stTotal);
                setCell(row, 6, str(p, "fecha"),      stDato);
                setCell(row, 7, str(p, "estado"),     stEstado);

                rowNum++;
            }

            // ── 6. Fila de total general ─────────────────────────────────────
            Row rowTotalGen = sheet.createRow(rowNum + 1);
            rowTotalGen.setHeightInPoints(18);
            CellStyle stTotGen = estiloTotalGeneral(wb);

            Cell cLabelTot = rowTotalGen.createCell(4);
            cLabelTot.setCellValue("TOTAL GENERAL:");
            cLabelTot.setCellStyle(stTotGen);

            // Suma solo pedidos Entregados
            double totalGeneral = pedidos.stream()
                    .filter(p -> "Entregado".equals(str(p, "estado")))
                    .mapToDouble(p -> {
                        try { return Double.parseDouble(str(p, "total").replace(",", ".")); }
                        catch (Exception e) { return 0; }
                    }).sum();

            Cell cValTot = rowTotalGen.createCell(5);
            cValTot.setCellValue(String.format("S/ %.2f", totalGeneral));
            cValTot.setCellStyle(stTotGen);

            // ── 7. Autofilter en cabecera ────────────────────────────────────
            sheet.setAutoFilter(new CellRangeAddress(3, rowNum - 1, 0, COLUMNAS.length - 1));

            // ── 8. Congelar primera fila de datos ────────────────────────────
            sheet.createFreezePane(0, 4);

            wb.write(response.getOutputStream());
        }
    }

    // ════════════════════════════════════════════════════════════════════════
    // Estilos
    // ════════════════════════════════════════════════════════════════════════

    private static CellStyle estiloTitulo(XSSFWorkbook wb) {
        XSSFCellStyle st = wb.createCellStyle();
        setFill(st, COLOR_ROJO);
        XSSFFont f = wb.createFont();
        f.setBold(true);
        f.setFontHeightInPoints((short) 14);
        f.setColor(new XSSFColor(COLOR_BLANCO, null));
        st.setFont(f);
        st.setAlignment(HorizontalAlignment.CENTER);
        st.setVerticalAlignment(VerticalAlignment.CENTER);
        return st;
    }

    private static CellStyle estiloSubtitulo(XSSFWorkbook wb) {
        XSSFCellStyle st = wb.createCellStyle();
        setFill(st, hexToRgb("7F1D1D")); // rojo muy oscuro
        XSSFFont f = wb.createFont();
        f.setFontHeightInPoints((short) 10);
        f.setColor(new XSSFColor(hexToRgb("FCA5A5"), null));
        st.setFont(f);
        st.setAlignment(HorizontalAlignment.CENTER);
        st.setVerticalAlignment(VerticalAlignment.CENTER);
        return st;
    }

    private static CellStyle estiloHeader(XSSFWorkbook wb) {
        XSSFCellStyle st = wb.createCellStyle();
        setFill(st, hexToRgb("991B1B")); // rojo header
        XSSFFont f = wb.createFont();
        f.setBold(true);
        f.setFontHeightInPoints((short) 10);
        f.setColor(new XSSFColor(COLOR_BLANCO, null));
        st.setFont(f);
        st.setAlignment(HorizontalAlignment.CENTER);
        st.setVerticalAlignment(VerticalAlignment.CENTER);
        setBorderThin(st, IndexedColors.WHITE.getIndex());
        return st;
    }

    private static CellStyle estiloDato(XSSFWorkbook wb, boolean parImpar, boolean esEntregado) {
        XSSFCellStyle st = wb.createCellStyle();
        byte[] bg = parImpar ? COLOR_GRIS : COLOR_BLANCO;
        setFill(st, bg);
        XSSFFont f = wb.createFont();
        f.setFontHeightInPoints((short) 10);
        f.setColor(new XSSFColor(COLOR_TEXTO, null));
        st.setFont(f);
        st.setVerticalAlignment(VerticalAlignment.CENTER);
        st.setWrapText(true);
        setBorderLight(st);
        return st;
    }

    private static CellStyle estiloTotal(XSSFWorkbook wb, boolean parImpar, boolean esEntregado) {
        XSSFCellStyle st = (XSSFCellStyle) estiloDato(wb, parImpar, esEntregado);
        XSSFFont f = wb.createFont();
        f.setBold(true);
        f.setFontHeightInPoints((short) 10);
        f.setColor(new XSSFColor(hexToRgb("166534"), null)); // verde oscuro
        st.setFont(f);
        st.setAlignment(HorizontalAlignment.RIGHT);
        return st;
    }

    private static CellStyle estiloEstado(XSSFWorkbook wb, boolean esEntregado) {
        XSSFCellStyle st = wb.createCellStyle();
        if (esEntregado) {
            setFill(st, hexToRgb("DCFCE7")); // verde claro
            XSSFFont f = wb.createFont();
            f.setBold(true);
            f.setFontHeightInPoints((short) 10);
            f.setColor(new XSSFColor(hexToRgb("166534"), null));
            st.setFont(f);
        } else {
            setFill(st, hexToRgb("FEE2E2")); // rojo claro
            XSSFFont f = wb.createFont();
            f.setBold(true);
            f.setFontHeightInPoints((short) 10);
            f.setColor(new XSSFColor(hexToRgb("991B1B"), null));
            st.setFont(f);
        }
        st.setAlignment(HorizontalAlignment.CENTER);
        st.setVerticalAlignment(VerticalAlignment.CENTER);
        setBorderLight(st);
        return st;
    }

    private static CellStyle estiloTotalGeneral(XSSFWorkbook wb) {
        XSSFCellStyle st = wb.createCellStyle();
        setFill(st, hexToRgb("FEF2F2"));
        XSSFFont f = wb.createFont();
        f.setBold(true);
        f.setFontHeightInPoints((short) 11);
        f.setColor(new XSSFColor(COLOR_ROJO, null));
        st.setFont(f);
        st.setAlignment(HorizontalAlignment.RIGHT);
        st.setVerticalAlignment(VerticalAlignment.CENTER);
        return st;
    }

    // ════════════════════════════════════════════════════════════════════════
    // Helpers
    // ════════════════════════════════════════════════════════════════════════

    private static void setFill(XSSFCellStyle st, byte[] rgb) {
        st.setFillForegroundColor(new XSSFColor(rgb, null));
        st.setFillPattern(FillPatternType.SOLID_FOREGROUND);
    }

    private static void setBorderThin(XSSFCellStyle st, short colorIdx) {
        st.setBorderTop(BorderStyle.THIN);
        st.setBorderBottom(BorderStyle.THIN);
        st.setBorderLeft(BorderStyle.THIN);
        st.setBorderRight(BorderStyle.THIN);
        st.setTopBorderColor(colorIdx);
        st.setBottomBorderColor(colorIdx);
        st.setLeftBorderColor(colorIdx);
        st.setRightBorderColor(colorIdx);
    }

    private static void setBorderLight(XSSFCellStyle st) {
        st.setBorderTop(BorderStyle.THIN);
        st.setBorderBottom(BorderStyle.THIN);
        st.setBorderLeft(BorderStyle.THIN);
        st.setBorderRight(BorderStyle.THIN);
        st.setTopBorderColor(IndexedColors.GREY_25_PERCENT.getIndex());
        st.setBottomBorderColor(IndexedColors.GREY_25_PERCENT.getIndex());
        st.setLeftBorderColor(IndexedColors.GREY_25_PERCENT.getIndex());
        st.setRightBorderColor(IndexedColors.GREY_25_PERCENT.getIndex());
    }

    private static void setCell(Row row, int col, String value, CellStyle style) {
        Cell cell = row.createCell(col);
        cell.setCellValue(value != null ? value : "");
        cell.setCellStyle(style);
    }

    private static String str(Map<String, Object> map, String key) {
        Object v = map.get(key);
        return v != null ? v.toString() : "";
    }

    private static byte[] hexToRgb(String hex) {
        int r = Integer.parseInt(hex.substring(0, 2), 16);
        int g = Integer.parseInt(hex.substring(2, 4), 16);
        int b = Integer.parseInt(hex.substring(4, 6), 16);
        return new byte[]{(byte) r, (byte) g, (byte) b};
    }
}