package com.polleria.dao;

import com.polleria.model.Rol;
import com.polleria.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RolDAO {

    public List<Rol> listarTodos() throws SQLException {
        List<Rol> lista = new ArrayList<>();
        String sql = "SELECT * FROM roles";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Rol r = new Rol();
                r.setId(rs.getInt("id"));
                r.setNombre(rs.getString("nombre"));
                lista.add(r);
            }
        }
        return lista;
    }

    public Rol obtenerPorId(int id) throws SQLException {
        String sql = "SELECT * FROM roles WHERE id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Rol r = new Rol();
                r.setId(rs.getInt("id"));
                r.setNombre(rs.getString("nombre"));
                return r;
            }
        }
        return null;
    }

    public boolean crear(String nombre) throws SQLException {
        String sql = "INSERT INTO roles (nombre) VALUES (?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, nombre);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean actualizar(int id, String nombre) throws SQLException {
        String sql = "UPDATE roles SET nombre = ? WHERE id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, nombre);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean eliminar(int id) throws SQLException {
        String sql = "DELETE FROM roles WHERE id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }
}