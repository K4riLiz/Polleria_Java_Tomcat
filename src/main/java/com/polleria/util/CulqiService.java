package com.polleria.util;

import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Scanner;

public class CulqiService {

    public static String cobrar(String token, double monto,
                                 String email, int pedidoId) throws Exception {
        String privateKey   = ConfigLoader.get("culqi.private_key");
        int montoCentavos   = (int) Math.round(monto * 100);

        String json = "{"
            + "\"amount\": "          + montoCentavos + ","
            + "\"currency_code\": \"PEN\","
            + "\"email\": \""          + email + "\","
            + "\"source_id\": \""      + token + "\","
            + "\"description\": \"Pedido #" + pedidoId + " - Polleria El Dorado\""
            + "}";

        String respuesta = postCulqi(
            "https://api.culqi.com/v2/charges", json, privateKey
        );

        // Verificar que el outcome sea "venta_exitosa"
        if (!respuesta.contains("\"outcome\"") ||
            !respuesta.contains("\"venta_exitosa\"")) {
            // Extraer mensaje de error
            String msg = extraerCampo(respuesta, "user_message");
            if (msg == null) msg = extraerCampo(respuesta, "merchant_message");
            if (msg == null) msg = "Pago no aprobado";
            throw new Exception(msg);
        }

        // Extraer charge ID
        String chargeId = extraerCampo(respuesta, "id");
        if (chargeId == null) chargeId = "CHR-" + System.currentTimeMillis();
        return chargeId;
    }

    public static String cobrarYape(String numeroYape, String otp,
                                     double monto, int pedidoId) throws Exception {
        String privateKey = ConfigLoader.get("culqi.private_key");
        int montoCentavos = (int) Math.round(monto * 100);

        // Paso 1: crear token Yape
        String jsonToken = "{"
            + "\"amount\": "        + montoCentavos + ","
            + "\"phone_number\": "  + numeroYape + ","
            + "\"number_token\": \"" + otp + "\""
            + "}";

        String tokenResp = postCulqi(
            "https://secure.culqi.com/v2/tokens/yape",
            jsonToken, ConfigLoader.get("culqi.public_key")
        );

        String tokenId = extraerCampo(tokenResp, "id");
        if (tokenId == null) {
            String msg = extraerCampo(tokenResp, "user_message");
            throw new Exception(msg != null ? msg : "No se pudo generar token Yape");
        }

        // Paso 2: cargo con ese token
        String jsonCargo = "{"
            + "\"amount\": "         + montoCentavos + ","
            + "\"currency_code\": \"PEN\","
            + "\"email\": \"yape@polleriaeldorado.com\","
            + "\"source_id\": \""    + tokenId + "\","
            + "\"description\": \"Pedido #" + pedidoId + " - Polleria El Dorado\""
            + "}";

        String cargoResp = postCulqi(
            "https://api.culqi.com/v2/charges", jsonCargo, privateKey
        );

        if (!cargoResp.contains("\"venta_exitosa\"")) {
            String msg = extraerCampo(cargoResp, "user_message");
            if (msg == null) msg = "Pago Yape no aprobado";
            throw new Exception(msg);
        }

        String chargeId = extraerCampo(cargoResp, "id");
        return chargeId != null ? chargeId : "YPE-" + System.currentTimeMillis();
    }

    // ── HTTP POST a Culqi ─────────────────────────────────────────────────────
    private static String postCulqi(String endpoint, String json,
                                     String key) throws Exception {
        URL url = new URL(endpoint);
        HttpURLConnection con = (HttpURLConnection) url.openConnection();
        con.setRequestMethod("POST");
        con.setRequestProperty("Authorization", "Bearer " + key);
        con.setRequestProperty("Content-Type", "application/json");
        con.setDoOutput(true);

        try (OutputStream os = con.getOutputStream()) {
            os.write(json.getBytes("UTF-8"));
        }

        int status = con.getResponseCode();
        Scanner sc = new Scanner(
            status >= 400 ? con.getErrorStream() : con.getInputStream()
        );
        String respuesta = sc.useDelimiter("\\A").next();
        sc.close();

        System.out.println("Culqi response [" + status + "]: " + respuesta);

        if (status >= 400) {
            String msg = extraerCampo(respuesta, "user_message");
            if (msg == null) msg = extraerCampo(respuesta, "merchant_message");
            if (msg == null) msg = "Error " + status;
            throw new Exception(msg);
        }

        return respuesta;
    }

    // ── Extrae un campo simple de JSON ────────────────────────────────────────
    private static String extraerCampo(String json, String campo) {
        // Busca "campo":"valor"
        String buscar = "\"" + campo + "\":\"";
        int idx = json.indexOf(buscar);
        if (idx >= 0) {
            int inicio = idx + buscar.length();
            int fin    = json.indexOf("\"", inicio);
            if (fin > inicio) return json.substring(inicio, fin);
        }
        return null;
    }
}