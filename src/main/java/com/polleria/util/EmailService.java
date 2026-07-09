package com.polleria.util;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.Base64;
import java.util.List;

public class EmailService {

    private static final String API_KEY         = "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";
    private static final String REMITENTE_EMAIL = "992485707kari@gmail.com";
    private static final String REMITENTE_NOMBRE = "Pollería El Dorado";
    private static final HttpClient client = HttpClient.newHttpClient();

    // ── Método base ───────────────────────────────────────────────────────────
    private static void enviar(String destinatario, String asunto,
                                String html, byte[] pdfBytes, String pdfNombre) {
        try {
            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"sender\":{\"name\":\"").append(REMITENTE_NOMBRE)
                .append("\",\"email\":\"").append(REMITENTE_EMAIL).append("\"},");
            json.append("\"to\":[{\"email\":\"").append(destinatario).append("\"}],");
            json.append("\"subject\":\"").append(escaparJson(asunto)).append("\",");
            json.append("\"htmlContent\":\"").append(escaparJson(html)).append("\"");

            // Adjunto PDF si viene
            if (pdfBytes != null && pdfNombre != null) {
                String b64 = Base64.getEncoder().encodeToString(pdfBytes);
                json.append(",\"attachment\":[{");
                json.append("\"name\":\"").append(pdfNombre).append("\",");
                json.append("\"content\":\"").append(b64).append("\"");
                json.append("}]");
            }

            json.append("}");

            HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create("https://api.brevo.com/v3/smtp/email"))
                .header("api-key", API_KEY)
                .header("Content-Type", "application/json")
                .header("Accept", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(json.toString()))
                .build();

            HttpResponse<String> response = client.send(request,
                HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() != 200 && response.statusCode() != 201) {
                System.err.println("Brevo error " + response.statusCode() + ": " + response.body());
            }

        } catch (Exception e) {
            System.err.println("Error enviando email: " + e.getMessage());
        }
    }

    // ── Código de verificación (registro) ─────────────────────────────────────
    public static void enviarCodigo(String destinatario, String codigo) throws Exception {
        String html = "<div style='font-family:Arial,sans-serif;max-width:480px;margin:0 auto;'>"
            + "<div style='background:#c0392b;padding:28px 32px;text-align:center;border-radius:8px 8px 0 0;'>"
            + "<span style='color:white;font-size:24px;font-weight:bold;'>Pollería El Dorado</span>"
            + "</div>"
            + "<div style='background:white;padding:32px;border:1px solid #eee;'>"
            + "<h2 style='color:#1a1a1a;font-size:18px;'>Verifica tu cuenta</h2>"
            + "<p style='color:#666;font-size:14px;line-height:1.6;'>Hola! Gracias por registrarte en "
            + "<strong>Pollería El Dorado</strong>. Para completar tu registro, ingresa el siguiente código:</p>"
            + "<div style='background:#fdecea;border:2px dashed #c0392b;border-radius:10px;"
            + "padding:20px;text-align:center;margin:24px 0;'>"
            + "<p style='color:#a93226;font-size:12px;margin:0 0 8px;'>TU CÓDIGO DE VERIFICACIÓN</p>"
            + "<span style='font-size:36px;font-weight:bold;color:#c0392b;letter-spacing:10px;'>"
            + codigo + "</span>"
            + "<p style='color:#999;font-size:12px;margin:10px 0 0;'>Expira en 5 minutos</p>"
            + "</div>"
            + "<p style='color:#888;font-size:13px;'>Si no solicitaste este registro, ignora este correo.</p>"
            + "<p style='color:#888;font-size:13px;'>Por seguridad, nunca compartas este código con nadie.</p>"
            + "</div>"
            + "<div style='background:#f9f9f9;border:1px solid #eee;border-top:none;padding:16px;"
            + "text-align:center;border-radius:0 0 8px 8px;'>"
            + "<p style='color:#aaa;font-size:12px;margin:0;'>© 2026 Pollería El Dorado · Lima, Perú</p>"
            + "</div></div>";

        enviar(destinatario, "Código de verificación - Pollería El Dorado", html, null, null);
    }

    // ── Código de recuperación de contraseña ──────────────────────────────────
    public static void enviarCodigoRecuperacion(String destinatario, String codigo,
                                                 long expiracionMs) {
        long minutosRestantes  = (expiracionMs - System.currentTimeMillis()) / 60000;
        long segundosRestantes = ((expiracionMs - System.currentTimeMillis()) % 60000) / 1000;

        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("HH:mm:ss");
        String horaExpiracion = sdf.format(new java.util.Date(expiracionMs));

        String html = "<div style='font-family:Arial,sans-serif;max-width:480px;margin:0 auto;'>"
            + "<div style='background:#c0392b;padding:28px 32px;text-align:center;border-radius:8px 8px 0 0;'>"
            + "<span style='color:white;font-size:24px;font-weight:bold;'>Pollería El Dorado</span>"
            + "</div>"
            + "<div style='background:white;padding:32px;border:1px solid #eee;'>"
            + "<h2 style='color:#1a1a1a;font-size:18px;'>Recuperar contraseña</h2>"
            + "<p style='color:#666;font-size:14px;line-height:1.6;'>Ingresa el siguiente código "
            + "en la ventana de recuperación de contraseña:</p>"
            + "<div style='background:#fdecea;border:2px dashed #c0392b;border-radius:10px;"
            + "padding:20px;text-align:center;margin:24px 0;'>"
            + "<p style='color:#a93226;font-size:12px;margin:0 0 8px;'>TU CÓDIGO DE RECUPERACIÓN</p>"
            + "<span style='font-size:36px;font-weight:bold;color:#c0392b;letter-spacing:10px;'>"
            + codigo + "</span>"
            + "<p style='color:#a93226;font-size:14px;margin:14px 0 6px;font-weight:bold;'>"
            + "Tiempo restante: " + minutosRestantes + " min " + segundosRestantes + " seg</p>"
            + "<p style='color:#999;font-size:12px;margin:0;'>Válido hasta las "
            + horaExpiracion + " (5 minutos)</p>"
            + "</div>"
            + "<p style='color:#888;font-size:13px;'>Si no solicitaste esto, ignora este correo.</p>"
            + "<p style='color:#888;font-size:13px;'>Por seguridad, nunca compartas este código con nadie.</p>"
            + "</div>"
            + "<div style='background:#f9f9f9;border:1px solid #eee;border-top:none;padding:16px;"
            + "text-align:center;border-radius:0 0 8px 8px;'>"
            + "<p style='color:#aaa;font-size:12px;margin:0;'>© 2026 Pollería El Dorado · Lima, Perú</p>"
            + "</div></div>";

        enviar(destinatario, "Código de recuperación - Pollería El Dorado", html, null, null);
    }

    // ── Boleta con PDF adjunto ────────────────────────────────────────────────
    public static void enviarBoletaPDF(String destinatario, String nombre,
                                        int pedidoId, byte[] pdfBytes) {
        String html = "<div style='font-family:Arial;max-width:600px;margin:auto;'>"
            + "<div style='background:#c0392b;padding:20px;text-align:center;'>"
            + "<h1 style='color:white;margin:0;'>Pollería El Dorado</h1>"
            + "<p style='color:#ffcccc;margin:5px 0 0;'>¡Tu pedido fue entregado!</p></div>"
            + "<div style='padding:30px;'>"
            + "<h2 style='color:#333;'>Hola, " + nombre + "</h2>"
            + "<p>Tu pedido <strong>#" + pedidoId + "</strong> ha sido entregado exitosamente.</p>"
            + "<p>Adjuntamos tu boleta en PDF. ¡Gracias por elegirnos!</p>"
            + "<div style='background:#f0fdf4;border:1px solid #bbf7d0;border-radius:8px;"
            + "padding:16px;margin:20px 0;'>"
            + "<p style='color:#166534;margin:0;font-size:14px;'>"
            + "&#10003; Pedido #" + pedidoId + " entregado correctamente</p>"
            + "</div></div>"
            + "<div style='background:#f9f9f9;padding:15px;text-align:center;'>"
            + "<p style='color:#aaa;font-size:12px;margin:0;'>"
            + "© 2026 Pollería El Dorado · Lima, Perú</p>"
            + "</div></div>";

        enviar(destinatario, "Tu boleta - Pedido #" + pedidoId + " - Pollería El Dorado",
               html, pdfBytes, "Boleta_Pedido_" + pedidoId + ".pdf");
    }

    // ── Confirmación de reclamo registrado ────────────────────────────────────
    public static void enviarConfirmacionReclamo(String destinatario, String nombre,
                                                  int reclamoId, String tipo,
                                                  String asunto, String fecha) {
        String html = plantillaBase(
            "Hemos recibido su reclamo",
            "<p style='color:#666;font-size:14px;line-height:1.6;'>Estimado(a) <strong>"
                + escaparHtml(nombre) + "</strong>:</p>"
            + "<p style='color:#666;font-size:14px;line-height:1.6;'>"
                + "Su reclamo fue registrado correctamente.</p>"
            + bloqueDetalle(
                "Número de reclamo", "#" + reclamoId,
                "Tipo", tipo,
                "Asunto", asunto,
                "Fecha", fecha,
                "Estado", "Pendiente")
            + "<p style='color:#666;font-size:14px;line-height:1.6;'>"
                + "Nos comunicaremos con usted lo antes posible.</p>"
            + "<p style='color:#666;font-size:14px;'>Gracias por confiar en nosotros.</p>"
        );
        enviar(destinatario, "Hemos recibido su reclamo - Pollería El Dorado", html, null, null);
    }

    // ── Respuesta del administrador al reclamo ────────────────────────────────
    public static void enviarRespuestaReclamo(String destinatario, String nombre,
                                               int reclamoId, String tipo, String asunto,
                                               String fecha, String respuesta) {
        String html = plantillaBase(
            "Respuesta a su Libro de Reclamaciones",
            "<p style='color:#666;font-size:14px;line-height:1.6;'>Estimado(a) <strong>"
                + escaparHtml(nombre) + "</strong>:</p>"
            + "<p style='color:#666;font-size:14px;line-height:1.6;'>"
                + "Su reclamo ha sido atendido.</p>"
            + bloqueDetalle(
                "Número de reclamo", "#" + reclamoId,
                "Fecha", fecha,
                "Tipo", tipo,
                "Asunto", asunto,
                "Estado", "Respondido")
            + "<div style='background:#f0fdf4;border:1px solid #bbf7d0;border-radius:8px;"
                + "padding:16px;margin:16px 0;'>"
            + "<p style='color:#166534;font-size:13px;margin:0 0 6px;font-weight:bold;'>"
                + "Respuesta del administrador:</p>"
            + "<p style='color:#333;font-size:14px;line-height:1.6;margin:0;'>"
                + escaparHtml(respuesta) + "</p></div>"
            + "<p style='color:#666;font-size:14px;'>Gracias por comunicarse con nosotros.</p>"
            + "<p style='color:#666;font-size:14px;font-weight:bold;'>Pollería El Dorado.</p>"
        );
        enviar(destinatario, "Respuesta a su Libro de Reclamaciones - Pollería El Dorado",
               html, null, null);
    }

    // ── Plantilla HTML reutilizable ───────────────────────────────────────────
    private static String plantillaBase(String titulo, String cuerpo) {
        return "<div style='font-family:Arial,sans-serif;max-width:480px;margin:0 auto;'>"
            + "<div style='background:#c0392b;padding:28px 32px;text-align:center;border-radius:8px 8px 0 0;'>"
            + "<span style='color:white;font-size:24px;font-weight:bold;'>Pollería El Dorado</span>"
            + "</div>"
            + "<div style='background:white;padding:32px;border:1px solid #eee;'>"
            + "<h2 style='color:#1a1a1a;font-size:18px;'>" + escaparHtml(titulo) + "</h2>"
            + cuerpo
            + "</div>"
            + "<div style='background:#f9f9f9;border:1px solid #eee;border-top:none;padding:16px;"
            + "text-align:center;border-radius:0 0 8px 8px;'>"
            + "<p style='color:#aaa;font-size:12px;margin:0;'>© 2026 Pollería El Dorado · Lima, Perú</p>"
            + "</div></div>";
    }

    private static String bloqueDetalle(String k1, String v1, String k2, String v2,
                                        String k3, String v3, String k4, String v4, 
                                        String k5, String v5) {
        StringBuilder sb = new StringBuilder();
        sb.append("<div style='background:#f9f9f9;border-radius:8px;padding:16px;margin:16px 0;'>");
        if (k1 != null) sb.append(filaDetalle(k1, v1));
        if (k2 != null) sb.append(filaDetalle(k2, v2));
        if (k3 != null) sb.append(filaDetalle(k3, v3));
        if (k4 != null) sb.append(filaDetalle(k4, v4));
        if (k5 != null) sb.append(filaDetalle(k5, v5));
        sb.append("</div>");
        return sb.toString();
    }

    private static String filaDetalle(String clave, String valor) {
        return "<p style='color:#666;font-size:13px;margin:4px 0;'>"
            + "<strong>" + escaparHtml(clave) + ":</strong> " + escaparHtml(valor) + "</p>";
    }

    private static String escaparHtml(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;");
    }

    // ── Compatibilidad con código existente ───────────────────────────────────
    public static void enviarBoleta(String destinatario, String nombre, int pedidoId,
            List<com.polleria.model.DetallePedido> detalles,
            com.polleria.model.Pedido pedido,
            com.polleria.model.Pago pago) {
        enviarBoletaPDF(destinatario, nombre, pedidoId, null);
    }

    // ── Escapa caracteres especiales para JSON ────────────────────────────────
    private static String escaparJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}