package com.polleria.dao;

import com.polleria.model.ProductoOpcion;
import com.polleria.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductoOpcionDAO {

    public List<ProductoOpcion> listarPorProducto(int productoId) throws SQLException {
        List<ProductoOpcion> lista = new ArrayList<>();
        String sql = "SELECT * FROM producto_opciones WHERE producto_id = ? AND activo = 1 ORDER BY grupo, precio_adicional";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productoId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                ProductoOpcion o = new ProductoOpcion();
                o.setId(rs.getInt("id"));
                o.setProductoId(rs.getInt("producto_id"));
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