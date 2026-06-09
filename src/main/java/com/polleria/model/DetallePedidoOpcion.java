package com.polleria.model;
public class DetallePedidoOpcion {
    private int id;
    private int detallePedidoId;
    private Integer opcionProductoId;
    private Integer opcionPromocionId;
    private String nombreOpcion;
    private double precioCobrado;
    public DetallePedidoOpcion() {}
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getDetallePedidoId() { return detallePedidoId; }
    public void setDetallePedidoId(int detallePedidoId) { this.detallePedidoId = detallePedidoId; }
    public Integer getOpcionProductoId() { return opcionProductoId; }
    public void setOpcionProductoId(Integer opcionProductoId) { this.opcionProductoId = opcionProductoId; }
    public Integer getOpcionPromocionId() { return opcionPromocionId; }
    public void setOpcionPromocionId(Integer opcionPromocionId) { this.opcionPromocionId = opcionPromocionId; }
    public String getNombreOpcion() { return nombreOpcion; }
    public void setNombreOpcion(String nombreOpcion) { this.nombreOpcion = nombreOpcion; }
    public double getPrecioCobrado() { return precioCobrado; }
    public void setPrecioCobrado(double precioCobrado) { this.precioCobrado = precioCobrado; }
}