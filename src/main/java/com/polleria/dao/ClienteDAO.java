package com.polleria.dao;

import com.polleria.model.Cliente;
import com.polleria.util.DBConnection;
import java.sql.*;

public class ClienteDAO {

    // ── CREAR vacío (solo usuario_id) ──────────────────────
    public boolean crear(int usuarioId) throws SQLException {
        String sql = "INSERT INTO clientes (usuario_id) VALUES (?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, usuarioId);
            return ps.executeUpdate() > 0;
        }
    }

    // ── CREAR con apellido y teléfono (al verificar registro) ─
    public boolean crearConDatos(int usuarioId, String apellido, String telefono) throws SQLException {
        String sql = "INSERT INTO clientes (usuario_id, apellido, telefono) VALUES (?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, usuarioId);
            ps.setString(2, apellido);
            ps.setString(3, telefono);
            return ps.executeUpdate() > 0;
        }
    }

    // ── OBTENER POR usuario_id ─────────────────────────────
    public Cliente obtenerPorUsuarioId(int usuarioId) throws SQLException {
        String sql = "SELECT c.*, d.distrito as distrito_nombre FROM clientes c " +
                     "LEFT JOIN distrito d ON c.distrito_id = d.id " +
                     "WHERE c.usuario_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, usuarioId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapear(rs);
            }
        }
        return null;
    }

    // ── ACTUALIZAR (perfil completo) ───────────────────────
    public boolean actualizar(Cliente c) throws SQLException {
        String sql = "UPDATE clientes SET apellido=?, telefono=?, direccion=?, " +
                     "latitud=?, longitud=?, distrito_id=? WHERE usuario_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, c.getApellido());
            ps.setString(2, c.getTelefono());
            ps.setString(3, c.getDireccion());
            ps.setObject(4, c.getLatitud());
            ps.setObject(5, c.getLongitud());
            if (c.getDistritoId() > 0) {
                ps.setInt(6, c.getDistritoId());
            } else {
                ps.setNull(6, Types.INTEGER);
            }
            ps.setInt(7, c.getUsuarioId());
            return ps.executeUpdate() > 0;
        }
    }

    // ── ACTUALIZAR apellido y teléfono ─────────────────────
    public boolean actualizarApellidoYTelefono(int usuarioId, String apellido,
                                                String telefono) throws SQLException {
        String sql = "UPDATE clientes SET apellido = ?, telefono = ? WHERE usuario_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, apellido);
            ps.setString(2, telefono);
            ps.setInt(3, usuarioId);
            return ps.executeUpdate() > 0;
        }
    }

    // ── MAPEAR ResultSet → Cliente ─────────────────────────
    private Cliente mapear(ResultSet rs) throws SQLException {
        Cliente c = new Cliente();
        c.setId(rs.getInt("id"));
        c.setUsuarioId(rs.getInt("usuario_id"));
        c.setApellido(rs.getString("apellido"));
        c.setTelefono(rs.getString("telefono"));
        c.setDireccion(rs.getString("direccion"));
        c.setLatitud(rs.getObject("latitud")   != null ? rs.getDouble("latitud")   : null);
        c.setLongitud(rs.getObject("longitud") != null ? rs.getDouble("longitud")  : null);
        c.setFidelidad(rs.getInt("fidelidad"));
        c.setDistritoId(rs.getInt("distrito_id"));
        c.setDistritoNombre(rs.getString("distrito_nombre"));
        return c;
    }
}