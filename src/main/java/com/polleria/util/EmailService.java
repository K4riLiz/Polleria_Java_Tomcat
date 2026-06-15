package com.polleria.util;

import javax.mail.*;
import javax.mail.internet.*;
import java.util.Properties;
import java.util.List;

public class EmailService {

    private static final String REMITENTE = "992485707kari@gmail.com";
    private static final String CLAVE     = "lopkwinxnvvbcnzg";

    public static void enviarCodigo(String destinatario, String codigo) throws MessagingException {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");

        Session session = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(REMITENTE, CLAVE);
            }
        });

        String htmlContent
                = "<div style='font-family:Arial,sans-serif;max-width:480px;margin:0 auto;'>"
                + "<div style='background:#c0392b;padding:28px 32px;text-align:center;border-radius:8px 8px 0 0;'>"
                + "<span style='color:white;font-size:24px;font-weight:bold;'>Pollería El Dorado</span>"
                + "</div>"
                + "<div style='background:white;padding:32px;border:1px solid #eee;'>"
                + "<h2 style='color:#1a1a1a;font-size:18px;'>Verifica tu cuenta</h2>"
                + "<p style='color:#666;font-size:14px;line-height:1.6;'>Hola! Gracias por registrarte en <strong>Pollería El Dorado</strong>. "
                + "Para completar tu registro, ingresa el siguiente código:</p>"
                + "<div style='background:#fdecea;border:2px dashed #c0392b;border-radius:10px;padding:20px;text-align:center;margin:24px 0;'>"
                + "<p style='color:#a93226;font-size:12px;margin:0 0 8px;'>TU CÓDIGO DE VERIFICACIÓN</p>"
                + "<span style='font-size:36px;font-weight:bold;color:#c0392b;letter-spacing:10px;'>" + codigo + "</span>"
                + "<p style='color:#999;font-size:12px;margin:10px 0 0;'>Expira en 5 minutos</p>"
                + "</div>"
                + "<p style='color:#888;font-size:13px;'>Si no solicitaste este registro, ignora este correo.</p>"
                + "<p style='color:#888;font-size:13px;'>Por seguridad, nunca compartas este código con nadie.</p>"
                + "</div>"
                + "<div style='background:#f9f9f9;border:1px solid #eee;border-top:none;padding:16px;text-align:center;border-radius:0 0 8px 8px;'>"
                + "<p style='color:#aaa;font-size:12px;margin:0;'>© 2026 Pollería El Dorado · Lima, Perú</p>"
                + "</div>"
                + "</div>";

        Message mensaje = new MimeMessage(session);
        mensaje.setFrom(new InternetAddress(REMITENTE));
        mensaje.setRecipients(Message.RecipientType.TO, InternetAddress.parse(destinatario));
        mensaje.setSubject("Código de verificación - Pollería El Dorado");
        mensaje.setContent(htmlContent, "text/html; charset=UTF-8");

        Transport.send(mensaje);
    }

    public static void enviarBoleta(String destinatario, String nombre, int pedidoId,
        List<com.polleria.model.DetallePedido> detalles,
        com.polleria.model.Pedido pedido,
        com.polleria.model.Pago pago) {
    try {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");

        Session session = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(REMITENTE, CLAVE);
            }
        });

        StringBuilder items = new StringBuilder();
        for (com.polleria.model.DetallePedido d : detalles) {
            items.append("<tr>")
                .append("<td style='padding:6px;border-bottom:1px solid #eee;'>")
                .append(d.getProductoNombre()).append(" x").append(d.getCantidad())
                .append("</td>")
                .append("<td style='padding:6px;border-bottom:1px solid #eee;text-align:right;'>S/ ")
                .append(String.format("%.2f", d.getSubtotal())).append("</td>")
                .append("</tr>");
        }

        String html = "<div style='font-family:Arial;max-width:600px;margin:auto;'>"
            + "<div style='background:#c0392b;padding:20px;text-align:center;'>"
            + "<h1 style='color:white;margin:0;'>Pollería El Dorado</h1>"
            + "<p style='color:#ffcccc;margin:5px 0 0;'>Gracias por tu pedido!</p></div>"
            + "<div style='padding:30px;'>"
            + "<h2 style='color:#333;'>Hola, " + nombre + "</h2>"
            + "<p>Tu pedido <strong>#" + pedidoId + "</strong> ha sido confirmado.</p>"
            + "<table style='width:100%;border-collapse:collapse;margin:20px 0;'>"
            + "<thead><tr style='background:#c0392b;color:white;'>"
            + "<th style='padding:8px;text-align:left;'>Producto</th>"
            + "<th style='padding:8px;text-align:right;'>Subtotal</th>"
            + "</tr></thead><tbody>"
            + items.toString()
            + "</tbody><tfoot>"
            + "<tr><td style='padding:8px;font-weight:bold;'>TOTAL</td>"
            + "<td style='padding:8px;font-weight:bold;text-align:right;color:#c0392b;'>S/ "
            + String.format("%.2f", pedido.getTotal()) + "</td></tr>"
            + "</tfoot></table>"
            + "<div style='background:#f9f9f9;padding:15px;border-radius:8px;margin:10px 0;'>"
            + "<p style='margin:0;'><strong>Metodo de pago:</strong> "
            + (pago != null ? pago.getMetodo() : "-") + "</p>"
            + "<p style='margin:5px 0 0;'><strong>Referencia:</strong> "
            + (pago != null ? pago.getReferencia() : "-") + "</p>"
            + "</div>"
            + "<p style='color:#999;font-size:12px;'>Puedes descargar tu boleta desde la pagina de confirmacion.</p>"
            + "</div></div>";

        Message msg = new MimeMessage(session);
        msg.setFrom(new InternetAddress(REMITENTE, "Polleria El Dorado"));
        msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(destinatario));
        msg.setSubject("Tu boleta de compra - Pedido #" + pedidoId);
        msg.setContent(html, "text/html; charset=utf-8");
        Transport.send(msg);

    } catch (Exception e) {
        System.err.println("Error enviando boleta: " + e.getMessage());
    }
    }

    public static void enviarCodigoRecuperacion(String destinatario, String codigo, long expiracionMs)
            throws MessagingException {
            Properties props = new Properties();
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.host", "smtp.gmail.com");
            props.put("mail.smtp.port", "587");

            Session session = Session.getInstance(props, new Authenticator() {
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(REMITENTE, CLAVE);
                }
            });

            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("HH:mm:ss");
            String horaExpiracion = sdf.format(new java.util.Date(expiracionMs));
            long minutosRestantes = (expiracionMs - System.currentTimeMillis()) / 60000;
            long segundosRestantes = ((expiracionMs - System.currentTimeMillis()) % 60000) / 1000;

            String html = "<div style='font-family:Arial;max-width:480px;margin:auto;'>"
                + "<div style='background:#c0392b;padding:24px;text-align:center;border-radius:8px 8px 0 0;'>"
                + "<h2 style='color:white;margin:0;'>Pollería El Dorado</h2></div>"
                + "<div style='background:white;padding:30px;border:1px solid #eee;'>"
                + "<h3 style='color:#333;'>Recuperar contraseña</h3>"
                + "<p style='color:#666;'>Tu código de recuperación es:</p>"
                + "<div style='background:#fdecea;border:2px dashed #c0392b;border-radius:10px;"
                + "padding:20px;text-align:center;margin:20px 0;'>"
                + "<span style='font-size:36px;font-weight:bold;color:#c0392b;letter-spacing:10px;'>"
                + codigo + "</span>"
                + "<p style='color:#a93226;font-size:14px;margin:14px 0 6px;font-weight:bold;'>"
                + "Tiempo restante: " + minutosRestantes + " min " + segundosRestantes + " seg</p>"
                + "<p style='color:#999;font-size:12px;margin:0;'>Válido hasta las " + horaExpiracion + " (5 minutos)</p>"
                + "</div>"
                + "<p style='color:#888;font-size:13px;'>Ingresa este código en la ventana de recuperación de contraseña de la página.</p>"
                + "<p style='color:#888;font-size:13px;'>Si no solicitaste esto, ignora este correo.</p>"
                + "</div></div>";

            Message msg = new MimeMessage(session);
            msg.setFrom(new InternetAddress(REMITENTE));
            msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(destinatario));
            msg.setSubject("Código de recuperación - Pollería El Dorado");
            msg.setContent(html, "text/html; charset=UTF-8");
            Transport.send(msg);
    }
}
