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
    private static final byte[] COLOR_ROJO   = hexToRgb("B91C1C");
    private static final byte[] COLOR_BLANCO = hexToRgb("FFFFFF");
    private static final byte[] COLOR_GRIS   = hexToRgb("F9FAFB");
    private static final byte[] COLOR_TEXTO  = hexToRgb("111827");

    // ── Columnas del reporte ────────────────────────────────────────────────
    private static final String[] COLUMNAS = {
        "ID Pedido", "ID Cliente", "Nombre Cliente",
        "Producto / Pedido", "Opciones", "Total (S/)", "Fecha", "Estado"
    };

    private static final int[] ANCHOS = {
        12 * 256, 12 * 256, 28 * 256,
        35 * 256, 38 * 256, 14 * 256, 22 * 256, 15 * 256
    };

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

            // ── 1. Título ───────────────────────────────────────────────────
            Row rowTitulo = sheet.createRow(0);
            rowTitulo.setHeightInPoints(28);
            Cell cTitulo = rowTitulo.createCell(0);
            cTitulo.setCellValue("Pollería El Dorado — Reporte de Ventas");
            cTitulo.setCellStyle(estiloTitulo(wb));
            sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, COLUMNAS.length - 1));

            // ── 2. Subtítulo ────────────────────────────────────────────────
            Row rowSub = sheet.createRow(1);
            rowSub.setHeightInPoints(18);
            Cell cSub = rowSub.createCell(0);
            cSub.setCellValue("Generado el: " + fechaHoy
                    + "    |    Total de registros: " + pedidos.size());
            cSub.setCellStyle(estiloSubtitulo(wb));
            sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, COLUMNAS.length - 1));

            // ── 3. Fila vacía ───────────────────────────────────────────────
            sheet.createRow(2).setHeightInPoints(6);

            // ── 4. Cabecera ─────────────────────────────────────────────────
            Row rowHeader = sheet.createRow(3);
            rowHeader.setHeightInPoints(20);
            CellStyle stHeader = estiloHeader(wb);
            for (int c = 0; c < COLUMNAS.length; c++) {
                Cell cell = rowHeader.createCell(c);
                cell.setCellValue(COLUMNAS[c]);
                cell.setCellStyle(stHeader);
                sheet.setColumnWidth(c, ANCHOS[c]);
            }

            // ── 5. Estilos creados UNA sola vez fuera del bucle ─────────────
            CellStyle stIdPar      = estiloId(wb, true);
            CellStyle stIdImpar    = estiloId(wb, false);
            CellStyle stDatoPar    = estiloDato(wb, true);
            CellStyle stDatoImpar  = estiloDato(wb, false);
            CellStyle stTotalPar   = estiloTotalNumerico(wb, true);
            CellStyle stTotalImpar = estiloTotalNumerico(wb, false);
            CellStyle stEstadoEnt  = estiloEstado(wb, true);
            CellStyle stEstadoCan  = estiloEstado(wb, false);

            // ── 6. Filas de datos ───────────────────────────────────────────
            int rowNum = 4;
            for (Map<String, Object> p : pedidos) {
                Row row = sheet.createRow(rowNum);
                row.setHeightInPoints(16);

                boolean esEntregado = "Entregado".equals(str(p, "estado"));
                boolean par         = rowNum % 2 == 0;

                CellStyle stId     = par ? stIdPar    : stIdImpar;
                CellStyle stDato   = par ? stDatoPar  : stDatoImpar;
                CellStyle stTotal  = par ? stTotalPar : stTotalImpar;
                CellStyle stEstado = esEntregado ? stEstadoEnt : stEstadoCan;

                // IDs como números enteros
                setCellNumeric(row, 0, toDouble(p, "id"),        stId);
                setCellNumeric(row, 1, toDouble(p, "idCliente"), stId);

                // Texto normal
                setCell(row, 2, str(p, "cliente"),  stDato);
                setCell(row, 3, str(p, "pedido"),   stDato);
                setCell(row, 4, str(p, "opciones"), stDato);

                // Total como número decimal
                setCellNumeric(row, 5, toDouble(p, "total"), stTotal);

                setCell(row, 6, str(p, "fecha"),  stDato);
                setCell(row, 7, str(p, "estado"), stEstado);

                rowNum++;
            }

            // ── 7. Fila de total general ────────────────────────────────────
            Row rowTotalGen = sheet.createRow(rowNum + 1);
            rowTotalGen.setHeightInPoints(18);

            CellStyle stTotLabel = estiloTotalGeneral(wb);
            // Clonar el estilo del label y agregarle formato numérico
            XSSFCellStyle stTotValor = wb.createCellStyle();
            stTotValor.cloneStyleFrom(stTotLabel);
            stTotValor.setDataFormat(wb.createDataFormat().getFormat("#,##0.00"));

            Cell cLabelTot = rowTotalGen.createCell(4);
            cLabelTot.setCellValue("TOTAL GENERAL:");
            cLabelTot.setCellStyle(stTotLabel);

            // SUMIF sobre columna H (Estado) y F (Total) — base 1 en Excel
            int primeraDato = 5;       // fila Excel donde empiezan los datos (rowNum 4 → fila 5)
            int ultimaDato  = rowNum;  // rowNum apunta justo después de la última fila
            Cell cValTot = rowTotalGen.createCell(5);
            cValTot.setCellFormula(
                "SUMIF(H" + primeraDato + ":H" + ultimaDato
                + ",\"Entregado\""
                + ",F" + primeraDato + ":F" + ultimaDato + ")"
            );
            cValTot.setCellStyle(stTotValor);

            // ── 8. Autofilter y freeze ──────────────────────────────────────
            sheet.setAutoFilter(new CellRangeAddress(3, rowNum - 1, 0, COLUMNAS.length - 1));
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
        setFill(st, hexToRgb("7F1D1D"));
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
        setFill(st, hexToRgb("991B1B"));
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

    private static CellStyle estiloDato(XSSFWorkbook wb, boolean par) {
        XSSFCellStyle st = wb.createCellStyle();
        setFill(st, par ? COLOR_GRIS : COLOR_BLANCO);
        XSSFFont f = wb.createFont();
        f.setFontHeightInPoints((short) 10);
        f.setColor(new XSSFColor(COLOR_TEXTO, null));
        st.setFont(f);
        st.setVerticalAlignment(VerticalAlignment.CENTER);
        st.setWrapText(true);
        setBorderLight(st);
        return st;
    }

    private static CellStyle estiloId(XSSFWorkbook wb, boolean par) {
        XSSFCellStyle st = wb.createCellStyle();
        setFill(st, par ? COLOR_GRIS : COLOR_BLANCO);
        XSSFFont f = wb.createFont();
        f.setFontHeightInPoints((short) 10);
        f.setColor(new XSSFColor(COLOR_TEXTO, null));
        st.setFont(f);
        st.setVerticalAlignment(VerticalAlignment.CENTER);
        setBorderLight(st);
        // Entero sin decimales ni separador de miles
        st.setDataFormat(wb.createDataFormat().getFormat("0"));
        return st;
    }

    private static CellStyle estiloTotalNumerico(XSSFWorkbook wb, boolean par) {
        XSSFCellStyle st = wb.createCellStyle();
        setFill(st, par ? COLOR_GRIS : COLOR_BLANCO);
        XSSFFont f = wb.createFont();
        f.setBold(true);
        f.setFontHeightInPoints((short) 10);
        f.setColor(new XSSFColor(hexToRgb("166534"), null));
        st.setFont(f);
        st.setAlignment(HorizontalAlignment.RIGHT);
        st.setVerticalAlignment(VerticalAlignment.CENTER);
        setBorderLight(st);
        // Decimal con 2 cifras y separador de miles
        st.setDataFormat(wb.createDataFormat().getFormat("#,##0.00"));
        return st;
    }

    private static CellStyle estiloEstado(XSSFWorkbook wb, boolean esEntregado) {
        XSSFCellStyle st = wb.createCellStyle();
        if (esEntregado) {
            setFill(st, hexToRgb("DCFCE7"));
            XSSFFont f = wb.createFont();
            f.setBold(true);
            f.setFontHeightInPoints((short) 10);
            f.setColor(new XSSFColor(hexToRgb("166534"), null));
            st.setFont(f);
        } else {
            setFill(st, hexToRgb("FEE2E2"));
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

    private static void setCellNumeric(Row row, int col, double value, CellStyle style) {
        Cell cell = row.createCell(col);
        cell.setCellValue(value);
        cell.setCellStyle(style);
    }

    private static String str(Map<String, Object> map, String key) {
        Object v = map.get(key);
        return v != null ? v.toString() : "";
    }

    /**
     * Convierte el valor del mapa a double de forma segura.
     * Maneja tanto Number directamente como String con coma o punto decimal.
     */
    private static double toDouble(Map<String, Object> map, String key) {
        Object v = map.get(key);
        if (v == null) return 0.0;
        if (v instanceof Number) return ((Number) v).doubleValue();
        try {
            return Double.parseDouble(v.toString().replace(",", "."));
        } catch (NumberFormatException e) {
            return 0.0;
        }
    }

    private static byte[] hexToRgb(String hex) {
        int r = Integer.parseInt(hex.substring(0, 2), 16);
        int g = Integer.parseInt(hex.substring(2, 4), 16);
        int b = Integer.parseInt(hex.substring(4, 6), 16);
        return new byte[]{(byte) r, (byte) g, (byte) b};
    }
}