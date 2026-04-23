package com.polleria.dao;

import com.polleria.model.Producto;
import com.polleria.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductoDAO {

    // Todos los productos activos
    public List<Producto> listarTodos() throws SQLException {
        List<Producto> lista = new ArrayList<>();
        String sql = "SELECT p.*, c.nombre as cat_nombre FROM productos p " +
                     "JOIN categorias c ON p.categoria_id = c.id WHERE p.activo = 1";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(mapear(rs));
            }
        }
        return lista;
    }

    // Productos por categoría
    public List<Producto> listarPorCategoria(int categoriaId) throws SQLException {
        List<Producto> lista = new ArrayList<>();
        String sql = "SELECT p.*, c.nombre as cat_nombre FROM productos p " +
                     "JOIN categorias c ON p.categoria_id = c.id " +
                     "WHERE p.categoria_id = ? AND p.activo = 1";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, categoriaId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                lista.add(mapear(rs));
            }
        }
        return lista;
    }

    // Detalle de un producto
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