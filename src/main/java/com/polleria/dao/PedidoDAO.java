package com.polleria.dao;

import com.polleria.model.DetallePedido;
import com.polleria.model.ItemCarrito;
import com.polleria.model.Pedido;
import com.polleria.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PedidoDAO {

    // Crear pedido y sus detalles, retorna el ID generado
    public int crear(Pedido pedido, List<ItemCarrito> items) throws SQLException {
        Connection con = DBConnection.getConnection();
        con.setAutoCommit(false);
        try {
            // Insertar pedido
            String sqlPedido = "INSERT INTO pedidos (usuario_id, total, estado, direccion) VALUES (?, ?, 'Pendiente', ?)";
            PreparedStatement psPedido = con.prepareStatement(sqlPedido, Statement.RETURN_GENERATED_KEYS);
            psPedido.setInt(1, pedido.getUsuarioId());
            psPedido.setDouble(2, pedido.getTotal());
            psPedido.setString(3, pedido.getDireccion());
            psPedido.executeUpdate();

            ResultSet rs = psPedido.getGeneratedKeys();
            int pedidoId = 0;
            if (rs.next()) pedidoId = rs.getInt(1);

            // Insertar detalles
            String sqlDetalle = "INSERT INTO detalle_pedido (pedido_id, producto_nombre, precio, cantidad, opciones, tipo, subtotal) VALUES (?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement psDetalle = con.prepareStatement(sqlDetalle);
            for (ItemCarrito item : items) {
                psDetalle.setInt(1, pedidoId);
                psDetalle.setString(2, item.getNombre());
                psDetalle.setDouble(3, item.getPrecio());
                psDetalle.setInt(4, item.getCantidad());
                psDetalle.setString(5, item.getOpciones());
                psDetalle.setString(6, item.getTipo());
                psDetalle.setDouble(7, item.getSubtotal());
                psDetalle.addBatch();
            }
            psDetalle.executeBatch();

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

    // Obtener pedido por ID
    public Pedido obtenerPorId(int id) throws SQLException {
        String sql = "SELECT * FROM pedidos WHERE id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Pedido p = new Pedido();
                p.setId(rs.getInt("id"));
                p.setUsuarioId(rs.getInt("usuario_id"));
                p.setTotal(rs.getDouble("total"));
                p.setEstado(rs.getString("estado"));
                p.setDireccion(rs.getString("direccion"));
                p.setFecha(rs.getString("fecha"));
                return p;
            }
        }
        return null;
    }

    // Listar pedidos de un usuario
    public List<Pedido> listarPorUsuario(int usuarioId) throws SQLException {
        List<Pedido> lista = new ArrayList<>();
        String sql = "SELECT * FROM pedidos WHERE usuario_id = ? ORDER BY fecha DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, usuarioId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Pedido p = new Pedido();
                p.setId(rs.getInt("id"));
                p.setUsuarioId(rs.getInt("usuario_id"));
                p.setTotal(rs.getDouble("total"));
                p.setEstado(rs.getString("estado"));
                p.setFecha(rs.getString("fecha"));
                lista.add(p);
            }
        }
        return lista;
    }

    // Listar detalles de un pedido
    public List<DetallePedido> listarDetalles(int pedidoId) throws SQLException {
        List<DetallePedido> lista = new ArrayList<>();
        String sql = "SELECT * FROM detalle_pedido WHERE pedido_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, pedidoId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                DetallePedido d = new DetallePedido();
                d.setId(rs.getInt("id"));
                d.setPedidoId(rs.getInt("pedido_id"));
                d.setProductoNombre(rs.getString("producto_nombre"));
                d.setPrecio(rs.getDouble("precio"));
                d.setCantidad(rs.getInt("cantidad"));
                d.setOpciones(rs.getString("opciones"));
                d.setTipo(rs.getString("tipo"));
                d.setSubtotal(rs.getDouble("subtotal"));
                lista.add(d);
            }
        }
        return lista;
    }

    // Listar todos los pedidos (admin)
    public List<Pedido> listarTodos() throws SQLException {
        List<Pedido> lista = new ArrayList<>();
        String sql = "SELECT p.*, u.nombre as usuario_nombre FROM pedidos p " +
                     "JOIN usuarios u ON p.usuario_id = u.id ORDER BY p.fecha DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Pedido p = new Pedido();
                p.setId(rs.getInt("id"));
                p.setUsuarioId(rs.getInt("usuario_id"));
                p.setTotal(rs.getDouble("total"));
                p.setEstado(rs.getString("estado"));
                p.setFecha(rs.getString("fecha"));
                lista.add(p);
            }
        }
        return lista;
    }

    // Actualizar estado del pedido (admin/cocinero)
    public boolean actualizarEstado(int pedidoId, String estado) throws SQLException {
        String sql = "UPDATE pedidos SET estado = ? WHERE id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, estado);
            ps.setInt(2, pedidoId);
            return ps.executeUpdate() > 0;
        }
    }
}