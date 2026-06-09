package com.polleria.dao;

import com.polleria.model.Distrito;
import com.polleria.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DistritoDAO {

    public List<Distrito> listarTodos() throws SQLException {
        List<Distrito> lista = new ArrayList<>();
        String sql = "SELECT * FROM distrito ORDER BY distrito";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) lista.add(mapear(rs));
        }
        return lista;
    }

    public Distrito obtenerPorId(int id) throws SQLException {
        String sql = "SELECT * FROM distrito WHERE id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapear(rs);
            }
        }
        return null;
    }

    private Distrito mapear(ResultSet rs) throws SQLException {
        Distrito d = new Distrito();
        d.setId(rs.getInt("id"));
        d.setProvincia(rs.getString("provincia"));
        d.setDistrito(rs.getString("distrito"));
        return d;
    }
}