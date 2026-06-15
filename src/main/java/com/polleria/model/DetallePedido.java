package com.polleria.model;
import java.util.List;
public class DetallePedido {
    private int id;
    private int pedidoId;
    private Integer productoId;
    private Integer promocionId;
    private String productoNombre;
    private double precio;
    private int cantidad;
    private double subtotal;
    private String tipo;
    private List<DetallePedidoOpcion> opciones;
    public DetallePedido() {}
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getPedidoId() { return pedidoId; }
    public void setPedidoId(int pedidoId) { this.pedidoId = pedidoId; }
    public Integer getProductoId() { return productoId; }
    public void setProductoId(Integer productoId) { this.productoId = productoId; }
    public Integer getPromocionId() { return promocionId; }
    public void setPromocionId(Integer promocionId) { this.promocionId = promocionId; }
    public String getProductoNombre() { return productoNombre; }
    public void setProductoNombre(String productoNombre) { this.productoNombre = productoNombre; }
    public double getPrecio() { return precio; }
    public void setPrecio(double precio) { this.precio = precio; }
    public int getCantidad() { return cantidad; }
    public void setCantidad(int cantidad) { this.cantidad = cantidad; }
    public double getSubtotal() { return subtotal; }
    public void setSubtotal(double subtotal) { this.subtotal = subtotal; }
    public String getTipo() { return tipo; }
    public void setTipo(String tipo) { this.tipo = tipo; }
    public List<DetallePedidoOpcion> getOpciones() { return opciones; }
    public void setOpciones(List<DetallePedidoOpcion> opciones) { this.opciones = opciones; }
}