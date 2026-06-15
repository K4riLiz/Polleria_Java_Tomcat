package com.polleria.model;
public class Cliente {
    private int id;
    private int usuarioId;
    private String apellido;
    private String telefono;
    private String direccion;
    private Double latitud;
    private Double longitud;
    private int fidelidad;
    private int distritoId;
    private String distritoNombre;
    public Cliente() {}
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getUsuarioId() { return usuarioId; }
    public void setUsuarioId(int usuarioId) { this.usuarioId = usuarioId; }
    public String getApellido() { return apellido; }
    public void setApellido(String apellido) { this.apellido = apellido; }
    public String getTelefono() { return telefono; }
    public void setTelefono(String telefono) { this.telefono = telefono; }
    public String getDireccion() { return direccion; }
    public void setDireccion(String direccion) { this.direccion = direccion; }
    public Double getLatitud() { return latitud; }
    public void setLatitud(Double latitud) { this.latitud = latitud; }
    public Double getLongitud() { return longitud; }
    public void setLongitud(Double longitud) { this.longitud = longitud; }
    public int getFidelidad() { return fidelidad; }
    public void setFidelidad(int fidelidad) { this.fidelidad = fidelidad; }
    public int getDistritoId() { return distritoId; }
    public void setDistritoId(int distritoId) { this.distritoId = distritoId; }
    public String getDistritoNombre() { return distritoNombre; }
    public void setDistritoNombre(String distritoNombre) { this.distritoNombre = distritoNombre; }
}
