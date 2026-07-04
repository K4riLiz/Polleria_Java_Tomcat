package com.polleria.dao;

import com.polleria.model.Pago;
import com.polleria.util.DBConnection;

import java.sql.*;

public class PagoDAO {

    public boolean registrar(Pago pago) throws SQLException {
        String sql = "INSERT INTO pagos (pedido_id, metodo, monto, estado, referencia) VALUES (?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, pago.getPedidoId());
            ps.setString(2, pago.getMetodo());
            ps.setDouble(3, pago.getMonto());
            ps.setString(4, pago.getEstado() != null ? pago.getEstado() : "Aprobado");
            ps.setString(5, pago.getReferencia());
            return ps.executeUpdate() > 0;
        }
    }

    public Pago obtenerPorPedido(int pedidoId) throws SQLException {
        String sql = "SELECT * FROM pagos WHERE pedido_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, pedidoId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapear(rs);
            }
        }
        return null;
    }

    private Pago mapear(ResultSet rs) throws SQLException {
        Pago p = new Pago();
        p.setId(rs.getInt("id"));
        p.setPedidoId(rs.getInt("pedido_id"));
        p.setMetodo(rs.getString("metodo"));
        p.setMonto(rs.getDouble("monto"));
        p.setEstado(rs.getString("estado"));
        p.setReferencia(rs.getString("referencia"));
        p.setFecha(rs.getString("fecha"));
        return p;
    }
}