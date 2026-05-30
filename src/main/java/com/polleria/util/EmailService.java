package com.polleria.util;

import javax.mail.*;
import javax.mail.internet.*;
import java.util.Properties;

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
}