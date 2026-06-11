package com.polleria.dao;

import com.polleria.model.DetallePedido;
import com.polleria.model.DetallePedidoOpcion;
import com.polleria.model.ItemCarrito;
import com.polleria.model.Pedido;
import com.polleria.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PedidoDAO {

    public int crear(Pedido pedido, List<ItemCarrito> items) throws SQLException {
        Connection con = DBConnection.getConnection();
        con.setAutoCommit(false);
        try {
            // 1. Insertar pedido
            String sqlPedido = "INSERT INTO pedidos (usuario_id, total, estado, direccion, latitud, longitud) VALUES (?, ?, 'Pendiente', ?, ?, ?)";
            int pedidoId;
            try (PreparedStatement ps = con.prepareStatement(sqlPedido, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, pedido.getUsuarioId());
                ps.setDouble(2, pedido.getTotal());
                ps.setString(3, pedido.getDireccion());
                ps.setObject(4, pedido.getLatitud());
                ps.setObject(5, pedido.getLongitud());
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (!rs.next()) throw new SQLException("No se generó ID para el pedido");
                    pedidoId = rs.getInt(1);
                }
            }

            // 2. Insertar detalles
            String sqlDetalle = "INSERT INTO detalle_pedido (pedido_id, producto_id, promocion_id, producto_nombre, precio, cantidad, subtotal, tipo) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            for (ItemCarrito item : items) {
                int detalleId;
                try (PreparedStatement ps = con.prepareStatement(sqlDetalle, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setInt(1, pedidoId);
                    if ("promocion".equals(item.getTipo())) {
                        ps.setNull(2, Types.INTEGER);
                        ps.setInt(3, item.getProductoId());
                    } else {
                        ps.setInt(2, item.getProductoId());
                        ps.setNull(3, Types.INTEGER);
                    }
                    ps.setString(4, item.getNombre());
                    ps.setDouble(5, item.getPrecio());
                    ps.setInt(6, item.getCantidad());
                    ps.setDouble(7, item.getSubtotal());
                    ps.setString(8, item.getTipo());
                    ps.executeUpdate();
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (!rs.next()) throw new SQLException("No se generó ID para el detalle");
                        detalleId = rs.getInt(1);
                    }
                }

                // 3. Insertar opciones del detalle
                if (item.getOpciones() != null && !item.getOpciones().isEmpty()) {
                    String sqlOpcion = "INSERT INTO detalle_pedido_opciones (detalle_pedido_id, nombre_opcion, precio_cobrado) VALUES (?, ?, 0)";
                    String[] opciones = item.getOpciones().split(",");
                    try (PreparedStatement ps = con.prepareStatement(sqlOpcion)) {
                        for (String opcion : opciones) {
                            ps.setInt(1, detalleId);
                            ps.setString(2, opcion.trim());
                            ps.addBatch();
                        }
                        ps.executeBatch();
                    }
                }
            }

            con.commit();
            return pedidoId;
        } catch (SQLException e) {
            con.rollback();
            throw e;
        } finally {
            con.setAutoCommit(true);
            con.close();
        }
    }

    public Pedido obtenerPorId(int id) throws SQLException {
        String sql = "SELECT * FROM pedidos WHERE id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapear(rs);
            }
        }
        return null;
    }

    public List<Pedido> listarPorUsuario(int usuarioId) throws SQLException {
        List<Pedido> lista = new ArrayList<>();
        String sql = "SELECT * FROM pedidos WHERE usuario_id = ? ORDER BY fecha DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, usuarioId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) lista.add(mapear(rs));
            }
        }
        return lista;
    }

    public List<DetallePedido> listarDetalles(int pedidoId) throws SQLException {
        List<DetallePedido> lista = new ArrayList<>();
        String sql = "SELECT * FROM detalle_pedido WHERE pedido_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, pedidoId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) lista.add(mapearDetalle(rs));
            }
        }
        return lista;
    }

    public List<Pedido> listarTodos() throws SQLException {
        List<Pedido> lista = new ArrayList<>();
        String sql = "SELECT p.*, u.nombre as usuario_nombre FROM pedidos p " +
                     "JOIN usuarios u ON p.usuario_id = u.id ORDER BY p.fecha DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) lista.add(mapear(rs));
        }
        return lista;
    }

    public boolean actualizarEstado(int pedidoId, String estado) throws SQLException {
        String sql = "UPDATE pedidos SET estado = ? WHERE id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, estado);
            ps.setInt(2, pedidoId);
            return ps.executeUpdate() > 0;
        }
    }

    private Pedido mapear(ResultSet rs) throws SQLException {
        Pedido p = new Pedido();
        p.setId(rs.getInt("id"));
        p.setUsuarioId(rs.getInt("usuario_id"));
        p.setTotal(rs.getDouble("total"));
        p.setEstado(rs.getString("estado"));
        p.setDireccion(rs.getString("direccion"));
        p.setLatitud((Double) rs.getObject("latitud"));
        p.setLongitud((Double) rs.getObject("longitud"));
        p.setFecha(rs.getString("fecha"));
        // usuarioNombre solo viene cuando hay JOIN con usuarios
        try {
            p.setUsuarioNombre(rs.getString("usuario_nombre"));
        } catch (SQLException e) {
        }
        return p;
    }

    private DetallePedido mapearDetalle(ResultSet rs) throws SQLException {
        DetallePedido d = new DetallePedido();
        d.setId(rs.getInt("id"));
        d.setPedidoId(rs.getInt("pedido_id"));
        d.setProductoId((Integer) rs.getObject("producto_id"));
        d.setPromocionId((Integer) rs.getObject("promocion_id"));
        d.setProductoNombre(rs.getString("producto_nombre"));
        d.setPrecio(rs.getDouble("precio"));
        d.setCantidad(rs.getInt("cantidad"));
        d.setSubtotal(rs.getDouble("subtotal"));
        d.setTipo(rs.getString("tipo"));
        return d;
    }
    
    // ── NUEVO: historial solo entregados del cliente ───────
    public List<Pedido> listarEntregadosPorUsuario(int usuarioId) throws SQLException {
        List<Pedido> lista = new ArrayList<>();
        String sql = "SELECT * FROM pedidos WHERE usuario_id = ? AND estado = 'Entregado' ORDER BY fecha DESC";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, usuarioId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.add(mapear(rs));
                }
            }
        }
        return lista;
    }

// ── NUEVO: listar por estado (chef / delivery) ─────────
    public List<Pedido> listarPorEstado(String estado) throws SQLException {
        List<Pedido> lista = new ArrayList<>();
        String sql = "SELECT p.*, u.nombre as usuario_nombre FROM pedidos p "
                + "JOIN usuarios u ON p.usuario_id = u.id "
                + "WHERE p.estado = ? ORDER BY p.fecha ASC";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, estado);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.add(mapear(rs));
                }
            }
        }
        return lista;
    }

// ── NUEVO: listar por múltiples estados ───────────────
    public List<Pedido> listarPorEstados(String... estados) throws SQLException {
        List<Pedido> lista = new ArrayList<>();
        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < estados.length; i++) {
            placeholders.append(i == 0 ? "?" : ",?");
        }
        String sql = "SELECT p.*, u.nombre as usuario_nombre FROM pedidos p "
                + "JOIN usuarios u ON p.usuario_id = u.id "
                + "WHERE p.estado IN (" + placeholders + ") ORDER BY p.fecha ASC";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            for (int i = 0; i < estados.length; i++) {
                ps.setString(i + 1, estados[i]);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.add(mapear(rs));
                }
            }
        }
        return lista;
    }
}