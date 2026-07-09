package com.polleria.dao;

import com.polleria.model.LibroReclamacion;
import com.polleria.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Acceso a datos del Libro de Reclamaciones.
 * Métodos nuevos: crear (retorna ID), obtenerPorId, listarPorUsuario,
 * marcarEnProceso, responder.
 */
public class LibroReclamacionDAO {

    /**
     * Inserta un reclamo y retorna el ID generado.
     */
    public int crear(LibroReclamacion l) throws SQLException {
        String sql = "INSERT INTO libro_reclamaciones "
                + "(nombre, email, telefono, tipo_documento, numero_documento, "
                + "tipo_reclamo, asunto, descripcion, pedido_id, usuario_id, estado) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, l.getNombre());
            ps.setString(2, l.getEmail());
            ps.setString(3, l.getTelefono());
            ps.setString(4, l.getTipoDocumento());
            ps.setString(5, l.getNumeroDocumento());
            ps.setString(6, l.getTipoReclamo());
            ps.setString(7, l.getAsunto());
            ps.setString(8, l.getDescripcion());
            ps.setString(9, l.getPedidoId());
            ps.setObject(10, l.getUsuarioId());
            ps.setString(11, LibroReclamacion.ESTADO_PENDIENTE);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return -1;
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

    /**
     * Lista reclamos de un cliente específico.
     */
    public List<LibroReclamacion> listarPorUsuario(int usuarioId) throws SQLException {
        List<LibroReclamacion> lista = new ArrayList<>();
        String sql = "SELECT * FROM libro_reclamaciones WHERE usuario_id = ? ORDER BY fecha DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, usuarioId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) lista.add(mapear(rs));
            }
        }
        return lista;
    }

    /**
     * Obtiene un reclamo por su ID.
     */
    public LibroReclamacion obtenerPorId(int id) throws SQLException {
        String sql = "SELECT * FROM libro_reclamaciones WHERE id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapear(rs);
            }
        }
        return null;
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

    /**
     * Marca el reclamo como "En proceso" solo si está Pendiente.
     */
    public boolean marcarEnProceso(int id) throws SQLException {
        String sql = "UPDATE libro_reclamaciones SET estado = ? "
                + "WHERE id = ? AND estado = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, LibroReclamacion.ESTADO_EN_PROCESO);
            ps.setInt(2, id);
            ps.setString(3, LibroReclamacion.ESTADO_PENDIENTE);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Guarda la respuesta del administrador y cambia el estado a Respondido.
     */
    public boolean responder(int id, String respuestaAdmin) throws SQLException {
        String sql = "UPDATE libro_reclamaciones "
                + "SET respuesta_admin = ?, fecha_respuesta = NOW(), estado = ? "
                + "WHERE id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, respuestaAdmin);
            ps.setString(2, LibroReclamacion.ESTADO_RESPONDIDO);
            ps.setInt(3, id);
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
        l.setAsunto(getColumnSafe(rs, "asunto"));
        l.setDescripcion(rs.getString("descripcion"));
        l.setRespuestaAdmin(getColumnSafe(rs, "respuesta_admin"));
        l.setFechaRespuesta(getColumnSafe(rs, "fecha_respuesta"));
        l.setPedidoId(rs.getString("pedido_id"));
        l.setFecha(rs.getString("fecha"));
        l.setEstado(rs.getString("estado"));
        Object uid = rs.getObject("usuario_id");
        l.setUsuarioId(uid != null ? (Integer) uid : 0);
        return l;
    }

    /** Lee columna opcional sin fallar si la migración aún no se ejecutó. */
    private String getColumnSafe(ResultSet rs, String column) {
        try {
            return rs.getString(column);
        } catch (SQLException e) {
            return null;
        }
    }
}
