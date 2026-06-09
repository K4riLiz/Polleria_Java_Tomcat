package com.polleria.model;
public class Boleta {
    private int id;
    private int pedidoId;
    private double costoDelivery;
    private double descuento;
    private double impuesto;
    private double totalPagar;
    public Boleta() {}
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getPedidoId() { return pedidoId; }
    public void setPedidoId(int pedidoId) { this.pedidoId = pedidoId; }
    public double getCostoDelivery() { return costoDelivery; }
    public void setCostoDelivery(double costoDelivery) { this.costoDelivery = costoDelivery; }
    public double getDescuento() { return descuento; }
    public void setDescuento(double descuento) { this.descuento = descuento; }
    public double getImpuesto() { return impuesto; }
    public void setImpuesto(double impuesto) { this.impuesto = impuesto; }
    public double getTotalPagar() { return totalPagar; }
    public void setTotalPagar(double totalPagar) { this.totalPagar = totalPagar; }
}