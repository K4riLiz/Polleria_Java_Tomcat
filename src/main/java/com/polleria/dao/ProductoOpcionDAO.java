package com.polleria.dao;

import com.polleria.model.ProductoOpcion;
import com.polleria.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductoOpcionDAO {

    public List<ProductoOpcion> listarPorProducto(int productoId) throws SQLException {
        List<ProductoOpcion> lista = new ArrayList<>();
        String sql = "SELECT * FROM producto_opciones WHERE producto_id = ? ORDER BY grupo, precio_adicional";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productoId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) lista.add(mapear(rs));
            }
        }
        return lista;
    }

    // Para el cliente — solo activas
    public List<ProductoOpcion> listarActivasPorProducto(int productoId) throws SQLException {
        List<ProductoOpcion> lista = new ArrayList<>();
        String sql = "SELECT * FROM producto_opciones WHERE producto_id = ? AND activo = 1 ORDER BY grupo, precio_adicional";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productoId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.add(mapear(rs));
                }
            }
        }
        return lista;
    }
    
    public ProductoOpcion obtenerPorId(int id) throws SQLException {
        String sql = "SELECT * FROM producto_opciones WHERE id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapear(rs);
            }
        }
        return null;
    }

    public boolean crear(ProductoOpcion o) throws SQLException {
        String sql = "INSERT INTO producto_opciones (producto_id, nombre, grupo, precio_adicional, activo) VALUES (?, ?, ?, ?, 1)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, o.getProductoId());
            ps.setString(2, o.getNombre());
            ps.setString(3, o.getGrupo());
            ps.setDouble(4, o.getPrecioAdicional());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean actualizar(ProductoOpcion o) throws SQLException {
        String sql = "UPDATE producto_opciones SET nombre=?, grupo=?, precio_adicional=? WHERE id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, o.getNombre());
            ps.setString(2, o.getGrupo());
            ps.setDouble(3, o.getPrecioAdicional());
            ps.setInt(4, o.getId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean toggleActivo(int id, boolean activo) throws SQLException {
        String sql = "UPDATE producto_opciones SET activo=? WHERE id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setBoolean(1, activo);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        }
    }

    private ProductoOpcion mapear(ResultSet rs) throws SQLException {
        ProductoOpcion o = new ProductoOpcion();
        o.setId(rs.getInt("id"));
        o.setProductoId(rs.getInt("producto_id"));
        o.setNombre(rs.getString("nombre"));
        o.setGrupo(rs.getString("grupo"));
        o.setPrecioAdicional(rs.getDouble("precio_adicional"));
        o.setActivo(rs.getBoolean("activo"));
        return o;
    }
}