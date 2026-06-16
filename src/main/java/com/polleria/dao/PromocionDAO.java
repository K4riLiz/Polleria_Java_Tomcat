package com.polleria.dao;

import com.polleria.model.Promocion;
import com.polleria.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class PromocionDAO {

    /** Cliente: activas con stock disponible */
    public List<Promocion> listarTodas() throws SQLException {
        return listarConFiltro("WHERE activo = 1 AND stock > 0");
    }

    /** Admin: todas las promociones (incluye agotadas e inactivas) */
    public List<Promocion> listarTodosAdmin() throws SQLException {
        return listarConFiltro("");
    }

    private List<Promocion> listarConFiltro(String where) throws SQLException {
        List<Promocion> lista = new ArrayList<>();
        String sql = "SELECT * FROM promociones " + where + " ORDER BY nombre";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) lista.add(mapear(rs));
        }
        return lista;
    }

    public Promocion obtenerPorId(int id) throws SQLException {
        String sql = "SELECT * FROM promociones WHERE id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapear(rs);
        }
        return null;
    }

    public int obtenerStock(int id) throws SQLException {
        String sql = "SELECT stock FROM promociones WHERE id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("stock");
            }
        }
        return 0;
    }

    public boolean crear(Promocion p) throws SQLException {
        String sql = "INSERT INTO promociones (nombre, descripcion, precio, imagen, stock, activo) " +
                       "VALUES (?, ?, ?, ?, ?, 1)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, p.getNombre());
            ps.setString(2, p.getDescripcion());
            ps.setDouble(3, p.getPrecio());
            ps.setString(4, p.getImagen());
            ps.setInt(5, Math.max(0, p.getStock()));
            return ps.executeUpdate() > 0;
        }
    }

    public boolean actualizar(Promocion p) throws SQLException {
        String sql = "UPDATE promociones SET nombre=?, descripcion=?, precio=?, imagen=?, activo=?, stock=? WHERE id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, p.getNombre());
            ps.setString(2, p.getDescripcion());
            ps.setDouble(3, p.getPrecio());
            ps.setString(4, p.getImagen());
            ps.setBoolean(5, p.isActivo());
            ps.setInt(6, Math.max(0, p.getStock()));
            ps.setInt(7, p.getId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean actualizarStock(int id, int stock) throws SQLException {
        String sql = "UPDATE promociones SET stock = ? WHERE id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, Math.max(0, stock));
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean descontarStock(Connection con, int promocionId, int cantidad) throws SQLException {
        String sql = "UPDATE promociones SET stock = stock - ? WHERE id = ? AND stock >= ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, cantidad);
            ps.setInt(2, promocionId);
            ps.setInt(3, cantidad);
            return ps.executeUpdate() == 1;
        }
    }

    public boolean eliminar(int id) throws SQLException {
        String sql = "UPDATE promociones SET activo = 0 WHERE id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    public List<Promocion> buscar(String query) throws SQLException {
        List<Promocion> lista = new ArrayList<>();
        String sql = "SELECT * FROM promociones WHERE activo = 1 AND stock > 0 " +
                     "AND (nombre LIKE ? OR descripcion LIKE ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            String like = "%" + query + "%";
            ps.setString(1, like);
            ps.setString(2, like);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) lista.add(mapear(rs));
        }
        return lista;
    }

    public Map<Integer, Integer> obtenerStocks(List<Integer> ids) throws SQLException {
        Map<Integer, Integer> map = new HashMap<>();
        if (ids == null || ids.isEmpty()) return map;

        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < ids.size(); i++) {
            placeholders.append(i == 0 ? "?" : ",?");
        }
        String sql = "SELECT id, stock FROM promociones WHERE id IN (" + placeholders + ")";
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

    private Promocion mapear(ResultSet rs) throws SQLException {
        Promocion p = new Promocion();
        p.setId(rs.getInt("id"));
        p.setNombre(rs.getString("nombre"));
        p.setDescripcion(rs.getString("descripcion"));
        p.setPrecio(rs.getDouble("precio"));
        p.setImagen(rs.getString("imagen"));
        p.setActivo(rs.getBoolean("activo"));
        p.setStock(rs.getInt("stock"));
        return p;
    }
}
