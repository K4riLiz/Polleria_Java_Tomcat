package com.polleria.dao;

import com.polleria.model.Calificacion;
import com.polleria.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CalificacionDAO {

    public boolean crear(Calificacion c) throws SQLException {
        String sql = "INSERT INTO calificacion (pedido_id, usuario_id, puntaje, comentario) VALUES (?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, c.getPedidoId());
            ps.setInt(2, c.getUsuarioId());
            ps.setInt(3, c.getPuntaje());
            ps.setString(4, c.getComentario());
            return ps.executeUpdate() > 0;
        }
    }

    public List<Calificacion> listarTodas() throws SQLException {
        List<Calificacion> lista = new ArrayList<>();
        String sql = "SELECT * FROM calificacion ORDER BY fecha DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) lista.add(mapear(rs));
        }
        return lista;
    }

    public boolean yaCalifico(int pedidoId, int usuarioId) throws SQLException {
        String sql = "SELECT id FROM calificacion WHERE pedido_id = ? AND usuario_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, pedidoId);
            ps.setInt(2, usuarioId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private Calificacion mapear(ResultSet rs) throws SQLException {
        Calificacion c = new Calificacion();
        c.setId(rs.getInt("id"));
        c.setPedidoId(rs.getInt("pedido_id"));
        c.setUsuarioId(rs.getInt("usuario_id"));
        c.setPuntaje(rs.getInt("puntaje"));
        c.setComentario(rs.getString("comentario"));
        c.setFecha(rs.getString("fecha"));
        return c;
    }
}