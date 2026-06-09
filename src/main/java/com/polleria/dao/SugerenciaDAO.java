package com.polleria.dao;

import com.polleria.model.Sugerencia;
import com.polleria.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SugerenciaDAO {

    public boolean crear(Sugerencia s) throws SQLException {
        String sql = "INSERT INTO sugerencia (asunto, contenido, usuario_id) VALUES (?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, s.getAsunto());
            ps.setString(2, s.getContenido());
            ps.setInt(3, s.getUsuarioId());
            return ps.executeUpdate() > 0;
        }
    }

    public List<Sugerencia> listarTodas() throws SQLException {
        List<Sugerencia> lista = new ArrayList<>();
        String sql = "SELECT * FROM sugerencia ORDER BY fecha DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) lista.add(mapear(rs));
        }
        return lista;
    }

    private Sugerencia mapear(ResultSet rs) throws SQLException {
        Sugerencia s = new Sugerencia();
        s.setId(rs.getInt("id"));
        s.setAsunto(rs.getString("asunto"));
        s.setContenido(rs.getString("contenido"));
        s.setFecha(rs.getString("fecha"));
        s.setUsuarioId(rs.getInt("usuario_id"));
        return s;
    }
}