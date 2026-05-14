package com.polleria.model;

public class ItemCarrito {
    private int productoId;
    private String nombre;
    private double precio;
    private String imagen;
    private int cantidad;
    private String tipo; // "producto" o "promocion"
    private String opciones;

    public ItemCarrito() {}

    public ItemCarrito(int productoId, String nombre, double precio, String imagen, int cantidad, String tipo, String opciones) {
    this.productoId = productoId;
    this.nombre = nombre;
    this.precio = precio;
    this.imagen = imagen;
    this.cantidad = cantidad;
    this.tipo = tipo;
    this.opciones = opciones;
}

    public double getSubtotal() {
        return precio * cantidad;
    }

    public int getProductoId() { return productoId; }
    public void setProductoId(int productoId) { this.productoId = productoId; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public double getPrecio() { return precio; }
    public void setPrecio(double precio) { this.precio = precio; }

    public String getImagen() { return imagen; }
    public void setImagen(String imagen) { this.imagen = imagen; }

    public int getCantidad() { return cantidad; }
    public void setCantidad(int cantidad) { this.cantidad = cantidad; }

    public String getTipo() { return tipo; }
    public void setTipo(String tipo) { this.tipo = tipo; }

    public String getOpciones() { return opciones; }
    public void setOpciones(String opciones) { this.opciones = opciones; }
}