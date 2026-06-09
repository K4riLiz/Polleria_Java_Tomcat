package com.polleria.dao;

import com.polleria.model.DetallePedidoOpcion;
import com.polleria.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DetallePedidoOpcionDAO {

    public boolean crear(DetallePedidoOpcion o) throws SQLException {
        String sql = "INSERT INTO detalle_pedido_opciones (detalle_pedido_id, opcion_producto_id, opcion_promocion_id, nombre_opcion, precio_cobrado) VALUES (?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, o.getDetallePedidoId());
            ps.setObject(2, o.getOpcionProductoId());
            ps.setObject(3, o.getOpcionPromocionId());
            ps.setString(4, o.getNombreOpcion());
            ps.setDouble(5, o.getPrecioCobrado());
            return ps.executeUpdate() > 0;
        }
    }

    public List<DetallePedidoOpcion> listarPorDetalle(int detallePedidoId) throws SQLException {
        List<DetallePedidoOpcion> lista = new ArrayList<>();
        String sql = "SELECT * FROM detalle_pedido_opciones WHERE detalle_pedido_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, detallePedidoId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) lista.add(mapear(rs));
            }
        }
        return lista;
    }

    private DetallePedidoOpcion mapear(ResultSet rs) throws SQLException {
        DetallePedidoOpcion o = new DetallePedidoOpcion();
        o.setId(rs.getInt("id"));
        o.setDetallePedidoId(rs.getInt("detalle_pedido_id"));
        o.setOpcionProductoId((Integer) rs.getObject("opcion_producto_id"));
        o.setOpcionPromocionId((Integer) rs.getObject("opcion_promocion_id"));
        o.setNombreOpcion(rs.getString("nombre_opcion"));
        o.setPrecioCobrado(rs.getDouble("precio_cobrado"));
        return o;
    }
}