package com.polleria.dao;

import com.polleria.model.Boleta;
import com.polleria.util.DBConnection;

import java.sql.*;

public class BoletaDAO {

    public boolean crear(Boleta b) throws SQLException {
        String sql = "INSERT INTO boleta (pedido_id, costo_delivery, descuento, impuesto, total_pagar) VALUES (?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, b.getPedidoId());
            ps.setDouble(2, b.getCostoDelivery());
            ps.setDouble(3, b.getDescuento());
            ps.setDouble(4, b.getImpuesto());
            ps.setDouble(5, b.getTotalPagar());
            return ps.executeUpdate() > 0;
        }
    }

    public Boleta obtenerPorPedido(int pedidoId) throws SQLException {
        String sql = "SELECT * FROM boleta WHERE pedido_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, pedidoId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapear(rs);
            }
        }
        return null;
    }

    private Boleta mapear(ResultSet rs) throws SQLException {
        Boleta b = new Boleta();
        b.setId(rs.getInt("id"));
        b.setPedidoId(rs.getInt("pedido_id"));
        b.setCostoDelivery(rs.getDouble("costo_delivery"));
        b.setDescuento(rs.getDouble("descuento"));
        b.setImpuesto(rs.getDouble("impuesto"));
        b.setTotalPagar(rs.getDouble("total_pagar"));
        return b;
    }
}