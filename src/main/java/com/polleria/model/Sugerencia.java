package com.polleria.model;
public class Sugerencia {
    private int id;
    private String asunto;
    private String contenido;
    private String fecha;
    private int usuarioId;
    public Sugerencia() {}
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getAsunto() { return asunto; }
    public void setAsunto(String asunto) { this.asunto = asunto; }
    public String getContenido() { return contenido; }
    public void setContenido(String contenido) { this.contenido = contenido; }
    public String getFecha() { return fecha; }
    public void setFecha(String fecha) { this.fecha = fecha; }
    public int getUsuarioId() { return usuarioId; }
    public void setUsuarioId(int usuarioId) { this.usuarioId = usuarioId; }
}