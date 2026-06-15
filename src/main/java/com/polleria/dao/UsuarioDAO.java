package com.polleria.dao;

import com.polleria.model.Usuario;
import com.polleria.util.DBConnection;
import org.mindrot.jbcrypt.BCrypt;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UsuarioDAO {

    // ── LOGIN ──────────────────────────────────────────────
    public Usuario login(String email, String password) throws SQLException {
        String sql = "SELECT u.*, r.nombre as rol_nombre FROM usuarios u " +
                     "JOIN roles r ON u.rol_id = r.id " +
                     "WHERE u.email = ? AND u.activo = 1";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            try(ResultSet rs = ps.executeQuery()){
            if (rs.next()) {
                if (BCrypt.checkpw(password, rs.getString("password"))) {
                    return mapear(rs);
                }
            }}
        }
        return null;
    }

    // ── REGISTRAR ──────────────────────────────────────────
    public boolean registrar(Usuario u) throws SQLException {
        String sql = "INSERT INTO usuarios (nombre, email, password, telefono, rol_id) VALUES (?, ?, ?, ?, 2)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, u.getNombre());
            ps.setString(2, u.getEmail());
            ps.setString(3, BCrypt.hashpw(u.getPassword(), BCrypt.gensalt()));
            ps.setString(4, u.getTelefono());
            return ps.executeUpdate() > 0;
        }
    }

    // ── EMAIL EXISTE ───────────────────────────────────────
    public boolean emailExiste(String email) throws SQLException {
        String sql = "SELECT id FROM usuarios WHERE email = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            return ps.executeQuery().next();
        }
    }

    // ── LISTAR TODOS (ADMIN) ───────────────────────────────
    public List<Usuario> listarTodos() throws SQLException {
        List<Usuario> lista = new ArrayList<>();
        String sql = "SELECT u.*, r.nombre as rol_nombre FROM usuarios u " +
                     "JOIN roles r ON u.rol_id = r.id ORDER BY u.id DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) lista.add(mapear(rs));
        }
        return lista;
    }

    // ── OBTENER POR ID ─────────────────────────────────────
    public Usuario obtenerPorId(int id) throws SQLException {
        String sql = "SELECT u.*, r.nombre as rol_nombre FROM usuarios u " +
                     "JOIN roles r ON u.rol_id = r.id WHERE u.id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapear(rs);
        }
        return null;
    }

    // ── ACTUALIZAR ─────────────────────────────────────────
    public boolean actualizar(Usuario u) throws SQLException {
        String sql = "UPDATE usuarios SET nombre=?, email=?, telefono=?, rol_id=?, activo=? WHERE id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, u.getNombre());
            ps.setString(2, u.getEmail());
            ps.setString(3, u.getTelefono());
            ps.setInt(4, u.getRolId());
            ps.setBoolean(5, u.isActivo());
            ps.setInt(6, u.getId());
            return ps.executeUpdate() > 0;
        }
    }

    // ── ELIMINAR ───────────────────────────────────────────
    public boolean eliminar(int id) throws SQLException {
        String sql = "DELETE FROM usuarios WHERE id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    // ── MAPEAR ResultSet → Usuario ─────────────────────────
    private Usuario mapear(ResultSet rs) throws SQLException {
        Usuario u = new Usuario();
        u.setId(rs.getInt("id"));
        u.setNombre(rs.getString("nombre"));
        u.setEmail(rs.getString("email"));
        u.setTelefono(rs.getString("telefono"));
        u.setRolId(rs.getInt("rol_id"));
        u.setRolNombre(rs.getString("rol_nombre"));
        u.setActivo(rs.getBoolean("activo"));
        return u;
    }
    
    public boolean actualizarNombre(int id, String nombre) throws SQLException {
        String sql = "UPDATE usuarios SET nombre = ? WHERE id = ?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, nombre);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        }
    }
    
    public Usuario obtenerPorEmail(String email) throws SQLException {
        String sql = "SELECT u.*, r.nombre as rol_nombre FROM usuarios u "
                + "JOIN roles r ON u.rol_id = r.id WHERE u.email = ?";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapear(rs);
                }
            }
        }
        return null;
    }
}