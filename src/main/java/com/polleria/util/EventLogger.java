package com.polleria.util;

import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * EventLogger — Registra eventos Info, Warning y Error del sistema.
 * Los eventos se guardan en logs y se muestran en consola.
 */
public class EventLogger {

    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    private static final String LOG_FILE = System.getProperty("user.home") + "/polleria_eventos.log";

    public enum Nivel { INFO, WARNING, ERROR }

    // ── Métodos principales ──────────────────────────────────

    public static void info(String modulo, String mensaje) {
        registrar(Nivel.INFO, modulo, mensaje, null);
    }

    public static void warning(String modulo, String mensaje) {
        registrar(Nivel.WARNING, modulo, mensaje, null);
    }

    public static void error(String modulo, String mensaje, Exception e) {
        registrar(Nivel.ERROR, modulo, mensaje, e);
    }

    public static void error(String modulo, String mensaje) {
        registrar(Nivel.ERROR, modulo, mensaje, null);
    }

    // ── Registro interno ─────────────────────────────────────

    private static void registrar(Nivel nivel, String modulo, String mensaje, Exception e) {
        // Logger de Java para que aparezca en NetBeans
        java.util.logging.Logger logger = java.util.logging.Logger.getLogger("Polleria." + modulo);

        switch (nivel) {
            case INFO    -> logger.info(mensaje);
            case WARNING -> logger.warning(mensaje);
            case ERROR   -> logger.severe(mensaje + (e != null ? " | " + e.getMessage() : ""));
        }

        String timestamp = LocalDateTime.now().format(FMT);
        String linea = String.format("[%s] [%s] [%s] %s", timestamp, nivel, modulo, mensaje);

        // Consola NetBeans (sin colores ANSI)
        if (nivel == Nivel.ERROR) {
            System.err.println(linea);
            if (e != null) System.err.println("  Causa: " + e.getMessage());
        } else {
            System.out.println(linea);
            if (e != null) System.out.println("  Causa: " + e.getMessage());
        }

        // Archivo de log
        try (PrintWriter pw = new PrintWriter(new FileWriter(LOG_FILE, true))) {
            pw.println(linea);
            if (e != null) pw.println("  Causa: " + e.getMessage());
        } catch (IOException ignored) {}
    }
}