package com.polleria.dao;

import com.polleria.model.Producto;
import com.polleria.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ProductoDAO {

    private static final String SELECT_BASE =
            "SELECT p.*, c.nombre AS categoria_nombre FROM productos p " +
            "JOIN categorias c ON p.categoria_id = c.id ";

    /** Cliente: activos con stock disponible */
    public List<Producto> listarTodos() throws SQLException {
        return listarConFiltro("WHERE p.activo = 1 AND p.stock > 0");
    }

    /** Cliente: por categoría con stock */
    public List<Producto> listarPorCategoria(int categoriaId) throws SQLException {
        List<Producto> lista = new ArrayList<>();
        String sql = SELECT_BASE + "WHERE p.categoria_id = ? AND p.activo = 1 AND p.stock > 0";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, categoriaId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) lista.add(mapear(rs));
            }
        }
        return lista;
    }

    /** Admin: todos los productos (incluye agotados e inactivos) */
    public List<Producto> listarTodosAdmin() throws SQLException {
        return listarConFiltro("");
    }

    private List<Producto> listarConFiltro(String where) throws SQLException {
        List<Producto> lista = new ArrayList<>();
        String sql = SELECT_BASE + where + " ORDER BY c.nombre, p.nombre";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) lista.add(mapear(rs));
        }
        return lista;
    }

    public Producto obtenerPorId(int id) throws SQLException {
        String sql = SELECT_BASE + "WHERE p.id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapear(rs);
            }
        }
        return null;
    }

    public int obtenerStock(int id) throws SQLException {
        String sql = "SELECT stock FROM productos WHERE id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("stock");
            }
        }
        return 0;
    }

    public boolean crear(Producto p) throws SQLException {
        String sql = "INSERT INTO productos (nombre, descripcion, precio, imagen, categoria_id, stock, activo) " +
                     "VALUES (?, ?, ?, ?, ?, ?, 1)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, p.getNombre());
            ps.setString(2, p.getDescripcion());
            ps.setDouble(3, p.getPrecio());
            ps.setString(4, p.getImagen());
            ps.setInt(5, p.getCategoriaId());
            ps.setInt(6, Math.max(0, p.getStock()));
            return ps.executeUpdate() > 0;
        }
    }

    public boolean actualizar(Producto p) throws SQLException {
        String sql = "UPDATE productos SET nombre=?, descripcion=?, precio=?, imagen=?, " +
                     "categoria_id=?, activo=?, stock=? WHERE id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, p.getNombre());
            ps.setString(2, p.getDescripcion());
            ps.setDouble(3, p.getPrecio());
            ps.setString(4, p.getImagen());
            ps.setInt(5, p.getCategoriaId());
            ps.setBoolean(6, p.isActivo());
            ps.setInt(7, Math.max(0, p.getStock()));
            ps.setInt(8, p.getId());
            return ps.executeUpdate() > 0;
        }
    }

    /** Reabastecer stock diario desde el panel admin */
    public boolean actualizarStock(int id, int stock) throws SQLException {
        String sql = "UPDATE productos SET stock = ? WHERE id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, Math.max(0, stock));
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Descuenta stock dentro de una transacción.
     * @return false si no hay stock suficiente
     */
    public boolean descontarStock(Connection con, int productoId, int cantidad) throws SQLException {
        String sql = "UPDATE productos SET stock = stock - ? WHERE id = ? AND stock >= ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, cantidad);
            ps.setInt(2, productoId);
            ps.setInt(3, cantidad);
            return ps.executeUpdate() == 1;
        }
    }

    public boolean eliminar(int id) throws SQLException {
        String sql = "UPDATE productos SET activo = 0 WHERE id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    /** Cliente: búsqueda solo productos con stock */
    public List<Producto> buscar(String query) throws SQLException {
        List<Producto> lista = new ArrayList<>();
        String sql = SELECT_BASE +
                     "WHERE p.activo = 1 AND p.stock > 0 AND (p.nombre LIKE ? OR p.descripcion LIKE ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            String like = "%" + query + "%";
            ps.setString(1, like);
            ps.setString(2, like);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) lista.add(mapear(rs));
            }
        }
        return lista;
    }

    /** Mapa productoId -> stock (para vista del carrito) */
    public Map<Integer, Integer> obtenerStocks(List<Integer> ids) throws SQLException {
        Map<Integer, Integer> map = new HashMap<>();
        if (ids == null || ids.isEmpty()) return map;

        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < ids.size(); i++) {
            placeholders.append(i == 0 ? "?" : ",?");
        }
        String sql = "SELECT id, stock FROM productos WHERE id IN (" + placeholders + ")";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            for (int i = 0; i < ids.size(); i++) {
                ps.setInt(i + 1, ids.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    map.put(rs.getInt("id"), rs.getInt("stock"));
                }
            }
        }
        return map;
    }

    private Producto mapear(ResultSet rs) throws SQLException {
        Producto p = new Producto();
        p.setId(rs.getInt("id"));
        p.setNombre(rs.getString("nombre"));
        p.setDescripcion(rs.getString("descripcion"));
        p.setPrecio(rs.getDouble("precio"));
        p.setImagen(rs.getString("imagen"));
        p.setActivo(rs.getBoolean("activo"));
        p.setStock(rs.getInt("stock"));
        p.setCategoriaId(rs.getInt("categoria_id"));
        p.setCategoriaNombre(rs.getString("categoria_nombre"));
        return p;
    }
}
