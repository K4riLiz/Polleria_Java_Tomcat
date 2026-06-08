package com.polleria.dao;

import com.polleria.model.PromocionOpcion;
import com.polleria.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PromocionOpcionDAO {

    public List<PromocionOpcion> listarPorPromocion(int promocionId) throws SQLException {
        List<PromocionOpcion> lista = new ArrayList<>();
        String sql = "SELECT * FROM promocion_opciones WHERE promocion_id = ? AND activo = 1 ORDER BY grupo, precio_adicional";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, promocionId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                PromocionOpcion o = new PromocionOpcion();
                o.setId(rs.getInt("id"));
                o.setPromocionId(rs.getInt("promocion_id"));
                o.setNombre(rs.getString("nombre"));
                o.setGrupo(rs.getString("grupo"));
                o.setPrecioAdicional(rs.getDouble("precio_adicional"));
                o.setActivo(rs.getBoolean("activo"));
                lista.add(o);
            }
        }
        return lista;
    }
}