package com.polleria.model;

public class PromocionOpcion {
    private int id;
    private int promocionId;
    private String nombre;
    private String grupo;
    private double precioAdicional;
    private boolean activo;

    public PromocionOpcion() {}
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getPromocionId() { return promocionId; }
    public void setPromocionId(int promocionId) { this.promocionId = promocionId; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public String getGrupo() { return grupo; }
    public void setGrupo(String grupo) { this.grupo = grupo; }
    public double getPrecioAdicional() { return precioAdicional; }
    public void setPrecioAdicional(double precioAdicional) { this.precioAdicional = precioAdicional; }
    public boolean isActivo() { return activo; }
    public void setActivo(boolean activo) { this.activo = activo; }
}