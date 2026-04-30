package com.polleria.dao;

import com.polleria.model.LibroReclamacion;
import com.polleria.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class LibroReclamacionDAO {

    public boolean registrar(LibroReclamacion r) throws SQLException {
        String sql = "INSERT INTO libro_reclamaciones (nombre, email, telefono, tipo_documento, " +
                     "numero_documento, tipo_reclamo, descripcion, pedido_id) VALUES (?,?,?,?,?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, r.getNombre());
            ps.setString(2, r.getEmail());
            ps.setString(3, r.getTelefono());
            ps.setString(4, r.getTipoDocumento());
            ps.setString(5, r.getNumeroDocumento());
            ps.setString(6, r.getTipoReclamo());
            ps.setString(7, r.getDescripcion());
            ps.setString(8, r.getPedidoId());
            return ps.executeUpdate() > 0;
        }
    }

    public List<LibroReclamacion> listarTodos() throws SQLException {
        List<LibroReclamacion> lista = new ArrayList<>();
        String sql = "SELECT * FROM libro_reclamaciones ORDER BY fecha DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                LibroReclamacion r = new LibroReclamacion();
                r.setId(rs.getInt("id"));
                r.setNombre(rs.getString("nombre"));
                r.setEmail(rs.getString("email"));
                r.setTelefono(rs.getString("telefono"));
                r.setTipoDocumento(rs.getString("tipo_documento"));
                r.setNumeroDocumento(rs.getString("numero_documento"));
                r.setTipoReclamo(rs.getString("tipo_reclamo"));
                r.setDescripcion(rs.getString("descripcion"));
                r.setPedidoId(rs.getString("pedido_id"));
                r.setFecha(rs.getString("fecha"));
                r.setEstado(rs.getString("estado"));
                lista.add(r);
            }
        }
        return lista;
    }
}