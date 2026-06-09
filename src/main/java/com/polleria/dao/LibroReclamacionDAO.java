package com.polleria.dao;

import com.polleria.model.LibroReclamacion;
import com.polleria.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class LibroReclamacionDAO {

    public boolean crear(LibroReclamacion l) throws SQLException {
        String sql = "INSERT INTO libro_reclamaciones (nombre, email, telefono, tipo_documento, numero_documento, tipo_reclamo, descripcion, pedido_id, usuario_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, l.getNombre());
            ps.setString(2, l.getEmail());
            ps.setString(3, l.getTelefono());
            ps.setString(4, l.getTipoDocumento());
            ps.setString(5, l.getNumeroDocumento());
            ps.setString(6, l.getTipoReclamo());
            ps.setString(7, l.getDescripcion());
            ps.setString(8, l.getPedidoId());
            ps.setObject(9, l.getUsuarioId());
            return ps.executeUpdate() > 0;
        }
    }

    public List<LibroReclamacion> listarTodas() throws SQLException {
        List<LibroReclamacion> lista = new ArrayList<>();
        String sql = "SELECT * FROM libro_reclamaciones ORDER BY fecha DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) lista.add(mapear(rs));
        }
        return lista;
    }

    public boolean actualizarEstado(int id, String estado) throws SQLException {
        String sql = "UPDATE libro_reclamaciones SET estado = ? WHERE id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, estado);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        }
    }

    private LibroReclamacion mapear(ResultSet rs) throws SQLException {
        LibroReclamacion l = new LibroReclamacion();
        l.setId(rs.getInt("id"));
        l.setNombre(rs.getString("nombre"));
        l.setEmail(rs.getString("email"));
        l.setTelefono(rs.getString("telefono"));
        l.setTipoDocumento(rs.getString("tipo_documento"));
        l.setNumeroDocumento(rs.getString("numero_documento"));
        l.setTipoReclamo(rs.getString("tipo_reclamo"));
        l.setDescripcion(rs.getString("descripcion"));
        l.setPedidoId(rs.getString("pedido_id"));
        l.setFecha(rs.getString("fecha"));
        l.setEstado(rs.getString("estado"));
        l.setUsuarioId((Integer) rs.getObject("usuario_id"));
        return l;
    }
}