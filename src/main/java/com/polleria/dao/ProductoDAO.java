package com.polleria.dao;

import com.polleria.model.Producto;
import com.polleria.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductoDAO {

    public List<Producto> listarTodos() throws SQLException {
        List<Producto> lista = new ArrayList<>();
        String sql = "SELECT p.*, c.nombre as cat_nombre FROM productos p " +
                     "JOIN categorias c ON p.categoria_id = c.id ORDER BY p.id DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) lista.add(mapear(rs));
        }
        return lista;
    }

    public List<Producto> listarPorCategoria(int categoriaId) throws SQLException {
        List<Producto> lista = new ArrayList<>();
        String sql = "SELECT p.*, c.nombre as cat_nombre FROM productos p " +
                     "JOIN categorias c ON p.categoria_id = c.id " +
                     "WHERE p.categoria_id = ? AND p.activo = 1";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, categoriaId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) lista.add(mapear(rs));
        }
        return lista;
    }

    public Producto obtenerPorId(int id) throws SQLException {
        String sql = "SELECT p.*, c.nombre as cat_nombre FROM productos p " +
                     "JOIN categorias c ON p.categoria_id = c.id WHERE p.id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapear(rs);
        }
        return null;
    }

    public boolean crear(Producto p) throws SQLException {
        String sql = "INSERT INTO productos (nombre, descripcion, precio, imagen, activo, categoria_id) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, p.getNombre());
            ps.setString(2, p.getDescripcion());
            ps.setDouble(3, p.getPrecio());
            ps.setString(4, p.getImagen());
            ps.setBoolean(5, p.isActivo());
            ps.setInt(6, p.getCategoriaId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean actualizar(Producto p) throws SQLException {
        String sql = "UPDATE productos SET nombre=?, descripcion=?, precio=?, imagen=?, activo=?, categoria_id=? WHERE id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, p.getNombre());
            ps.setString(2, p.getDescripcion());
            ps.setDouble(3, p.getPrecio());
            ps.setString(4, p.getImagen());
            ps.setBoolean(5, p.isActivo());
            ps.setInt(6, p.getCategoriaId());
            ps.setInt(7, p.getId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean eliminar(int id) throws SQLException {
        String sql = "DELETE FROM productos WHERE id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    private Producto mapear(ResultSet rs) throws SQLException {
        Producto p = new Producto();
        p.setId(rs.getInt("id"));
        p.setNombre(rs.getString("nombre"));
        p.setDescripcion(rs.getString("descripcion"));
        p.setPrecio(rs.getDouble("precio"));
        p.setImagen(rs.getString("imagen"));
        p.setActivo(rs.getBoolean("activo"));
        p.setCategoriaId(rs.getInt("categoria_id"));
        p.setCategoriaNombre(rs.getString("cat_nombre"));
        return p;
    }
}