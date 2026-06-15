package com.polleria.dao;

import com.polleria.util.DBConnection;

import java.sql.*;
import java.util.LinkedHashMap;
import java.util.Map;

public class DashboardDAO {

    // ── Pedidos hoy ───────────────────────────────────────
    public int pedidosHoy() throws SQLException {
        String sql = "SELECT COUNT(*) FROM pedidos WHERE DATE(fecha) = CURDATE()";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    // ── Pedidos ayer (para comparar) ──────────────────────
    public int pedidosAyer() throws SQLException {
        String sql = "SELECT COUNT(*) FROM pedidos WHERE DATE(fecha) = CURDATE() - INTERVAL 1 DAY";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    // ── Ingresos hoy ──────────────────────────────────────
    public double ingresosHoy() throws SQLException {
        String sql = "SELECT COALESCE(SUM(total), 0) FROM pedidos WHERE DATE(fecha) = CURDATE()";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getDouble(1) : 0;
        }
    }

    // ── Ingresos ayer ─────────────────────────────────────
    public double ingresosAyer() throws SQLException {
        String sql = "SELECT COALESCE(SUM(total), 0) FROM pedidos WHERE DATE(fecha) = CURDATE() - INTERVAL 1 DAY";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getDouble(1) : 0;
        }
    }

    // ── Pedidos en proceso ────────────────────────────────
    public int pedidosEnProceso() throws SQLException {
        String sql = "SELECT COUNT(*) FROM pedidos WHERE estado IN ('Pendiente','En cocina','Por despachar')";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    // ── Reclamaciones pendientes ──────────────────────────
    public int reclamacionesPendientes() throws SQLException {
        String sql = "SELECT COUNT(*) FROM libro_reclamaciones WHERE estado = 'Pendiente'";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    // ── Pedidos pendientes > 25 min ───────────────────────
    public int pedidosPendientesViejos() throws SQLException {
        String sql = "SELECT COUNT(*) FROM pedidos WHERE estado = 'Pendiente' " +
                     "AND TIMESTAMPDIFF(MINUTE, fecha, NOW()) > 25";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    // ── IDs de pedidos pendientes viejos ──────────────────
    public String idsPedidosPendientesViejos() throws SQLException {
        String sql = "SELECT id FROM pedidos WHERE estado = 'Pendiente' " +
                     "AND TIMESTAMPDIFF(MINUTE, fecha, NOW()) > 25 LIMIT 5";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            StringBuilder sb = new StringBuilder();
            while (rs.next()) {
                if (sb.length() > 0) sb.append(", ");
                sb.append("#").append(rs.getInt("id"));
            }
            return sb.toString();
        }
    }

    // ── Pedidos por estado ────────────────────────────────
    public Map<String, Integer> pedidosPorEstado() throws SQLException {
        Map<String, Integer> mapa = new LinkedHashMap<>();
        mapa.put("Pendiente", 0);
        mapa.put("En cocina", 0);
        mapa.put("Por despachar", 0);
        mapa.put("Entregado", 0);
        mapa.put("Cancelado", 0);
        String sql = "SELECT estado, COUNT(*) as total FROM pedidos GROUP BY estado";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                mapa.put(rs.getString("estado"), rs.getInt("total"));
            }
        }
        return mapa;
    }

    // ── Ventas últimos 7 días ─────────────────────────────
    public Map<String, Double> ventasUltimos7Dias() throws SQLException {
        Map<String, Double> mapa = new LinkedHashMap<>();
        String sql = "SELECT DATE(fecha) as dia, COALESCE(SUM(total), 0) as total " +
                     "FROM pedidos " +
                     "WHERE fecha >= CURDATE() - INTERVAL 6 DAY " +
                     "GROUP BY DATE(fecha) ORDER BY dia ASC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                mapa.put(rs.getString("dia"), rs.getDouble("total"));
            }
        }
        return mapa;
    }

    // ── Productos más vendidos (top 5 por cantidad) ───────
    public Map<String, Integer> productosMasVendidos() throws SQLException {
        Map<String, Integer> mapa = new LinkedHashMap<>();
        String sql = "SELECT producto_nombre, SUM(cantidad) as total " +
                     "FROM detalle_pedido WHERE tipo = 'producto' " +
                     "GROUP BY producto_nombre ORDER BY total DESC LIMIT 5";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                mapa.put(rs.getString("producto_nombre"), rs.getInt("total"));
            }
        }
        return mapa;
    }

    // ── Promociones más vendidas (top 5 por cantidad) ─────
    public Map<String, Integer> promocionesMasVendidas() throws SQLException {
        Map<String, Integer> mapa = new LinkedHashMap<>();
        String sql = "SELECT producto_nombre, SUM(cantidad) as total " +
                     "FROM detalle_pedido WHERE tipo = 'promocion' " +
                     "GROUP BY producto_nombre ORDER BY total DESC LIMIT 5";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                mapa.put(rs.getString("producto_nombre"), rs.getInt("total"));
            }
        }
        return mapa;
    }

    // ── Últimos 5 pedidos ─────────────────────────────────
    public ResultSet ultimosPedidos() throws SQLException {
        String sql = "SELECT p.id, u.nombre as cliente, p.total, p.estado, p.fecha " +
                     "FROM pedidos p JOIN usuarios u ON p.usuario_id = u.id " +
                     "ORDER BY p.fecha DESC LIMIT 5";
        Connection con = DBConnection.getConnection();
        PreparedStatement ps = con.prepareStatement(sql);
        return ps.executeQuery();
    }
}