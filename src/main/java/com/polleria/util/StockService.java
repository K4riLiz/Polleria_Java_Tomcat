package com.polleria.util;

import com.polleria.dao.ProductoDAO;
import com.polleria.model.ItemCarrito;
import com.polleria.model.Producto;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Validaciones de stock para productos terminados (platos).
 * Las promociones no descuentan stock de productos individuales.
 */
public class StockService {

    private StockService() {}

    /** Valida agregar cantidad al carrito (suma lo que ya hay en carrito). */
    public static String validarAgregar(int productoId, int cantidadAgregar, List<ItemCarrito> carrito)
            throws SQLException {
        ProductoDAO dao = new ProductoDAO();
        Producto p = dao.obtenerPorId(productoId);
        if (p == null || !p.isActivo()) {
            return "El producto no está disponible.";
        }
        if (p.getStock() <= 0) {
            return "\"" + p.getNombre() + "\" está agotado.";
        }

        int enCarrito = cantidadEnCarrito(productoId, carrito);
        int total = enCarrito + cantidadAgregar;
        if (total > p.getStock()) {
            int disponible = p.getStock() - enCarrito;
            if (disponible <= 0) {
                return "Ya tienes el máximo disponible de \"" + p.getNombre() + "\" en tu carrito.";
            }
            return "Solo quedan " + disponible + " unidad(es) de \"" + p.getNombre() + "\".";
        }
        return null;
    }

    /** Valida fijar una cantidad exacta en el carrito. */
    public static String validarCantidad(int productoId, int cantidad, List<ItemCarrito> carrito)
            throws SQLException {
        if (cantidad <= 0) return null;

        ProductoDAO dao = new ProductoDAO();
        Producto p = dao.obtenerPorId(productoId);
        if (p == null || !p.isActivo()) {
            return "El producto no está disponible.";
        }
        if (p.getStock() <= 0) {
            return "\"" + p.getNombre() + "\" está agotado.";
        }
        if (cantidad > p.getStock()) {
            return "Solo hay " + p.getStock() + " unidad(es) de \"" + p.getNombre() + "\".";
        }
        return null;
    }

    /** Valida todo el carrito antes del checkout. */
    public static String validarCarrito(List<ItemCarrito> carrito) throws SQLException {
        if (carrito == null || carrito.isEmpty()) return "El carrito está vacío.";

        Map<Integer, Integer> totales = new HashMap<>();
        for (ItemCarrito item : carrito) {
            if ("producto".equals(item.getTipo())) {
                totales.merge(item.getProductoId(), item.getCantidad(), Integer::sum);
            }
        }

        ProductoDAO dao = new ProductoDAO();
        for (Map.Entry<Integer, Integer> entry : totales.entrySet()) {
            Producto p = dao.obtenerPorId(entry.getKey());
            if (p == null || !p.isActivo()) {
                return "Un producto de tu carrito ya no está disponible.";
            }
            if (p.getStock() <= 0) {
                return "\"" + p.getNombre() + "\" se agotó. Elimínalo del carrito para continuar.";
            }
            if (entry.getValue() > p.getStock()) {
                return "Stock insuficiente para \"" + p.getNombre() + "\". Disponible: " + p.getStock() + ".";
            }
        }
        return null;
    }

    private static int cantidadEnCarrito(int productoId, List<ItemCarrito> carrito) {
        if (carrito == null) return 0;
        for (ItemCarrito item : carrito) {
            if (item.getProductoId() == productoId && "producto".equals(item.getTipo())) {
                return item.getCantidad();
            }
        }
        return 0;
    }
}
