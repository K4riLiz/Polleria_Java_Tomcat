package com.polleria.dao;

import com.polleria.model.PromocionOpcion;
import com.polleria.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PromocionOpcionDAO {

    public List<PromocionOpcion> listarPorPromocion(int promocionId) throws SQLException {
        List<PromocionOpcion> lista = new ArrayList<>();
        String sql = "SELECT * FROM promocion_opciones WHERE promocion_id = ? ORDER BY grupo, precio_adicional";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, promocionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) lista.add(mapear(rs));
            }
        }
        return lista;
    }
    
    // Para el cliente — solo activas
    public List<PromocionOpcion> listarActivasPorPromocion(int promocionId) throws SQLException {
        List<PromocionOpcion> lista = new ArrayList<>();
        String sql = "SELECT * FROM promocion_opciones WHERE promocion_id = ? AND activo = 1 ORDER BY grupo, precio_adicional";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, promocionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.add(mapear(rs));
                }
            }
        }
        return lista;
    }

    public PromocionOpcion obtenerPorId(int id) throws SQLException {
        String sql = "SELECT * FROM promocion_opciones WHERE id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapear(rs);
            }
        }
        return null;
    }

    public boolean crear(PromocionOpcion o) throws SQLException {
        String sql = "INSERT INTO promocion_opciones (promocion_id, nombre, grupo, precio_adicional, activo) VALUES (?, ?, ?, ?, 1)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, o.getPromocionId());
            ps.setString(2, o.getNombre());
            ps.setString(3, o.getGrupo());
            ps.setDouble(4, o.getPrecioAdicional());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean actualizar(PromocionOpcion o) throws SQLException {
        String sql = "UPDATE promocion_opciones SET nombre=?, grupo=?, precio_adicional=? WHERE id=?";
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
        String sql = "UPDATE promocion_opciones SET activo=? WHERE id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setBoolean(1, activo);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        }
    }

    private PromocionOpcion mapear(ResultSet rs) throws SQLException {
        PromocionOpcion o = new PromocionOpcion();
        o.setId(rs.getInt("id"));
        o.setPromocionId(rs.getInt("promocion_id"));
        o.setNombre(rs.getString("nombre"));
        o.setGrupo(rs.getString("grupo"));
        o.setPrecioAdicional(rs.getDouble("precio_adicional"));
        o.setActivo(rs.getBoolean("activo"));
        return o;
    }
}