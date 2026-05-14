package com.polleria.dao;

import com.polleria.model.Promocion;
import com.polleria.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PromocionDAO {

    public List<Promocion> listarTodas() throws SQLException {
        List<Promocion> lista = new ArrayList<>();
        String sql = "SELECT * FROM promociones WHERE activo = 1";
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

    private Promocion mapear(ResultSet rs) throws SQLException {
        Promocion p = new Promocion();
        p.setId(rs.getInt("id"));
        p.setNombre(rs.getString("nombre"));
        p.setDescripcion(rs.getString("descripcion"));
        p.setPrecio(rs.getDouble("precio"));
        p.setImagen(rs.getString("imagen"));
        p.setActivo(rs.getBoolean("activo"));
        return p;
    }

    public List<Promocion> buscar(String query) throws SQLException {
    List<Promocion> lista = new ArrayList<>();
    String sql = "SELECT * FROM promociones WHERE activo = 1 AND (nombre LIKE ? OR descripcion LIKE ?)";
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
}