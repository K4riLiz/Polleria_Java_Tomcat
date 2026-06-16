package com.polleria.util;

import com.polleria.dao.ProductoDAO;
import com.polleria.dao.PromocionDAO;
import com.polleria.model.ItemCarrito;
import com.polleria.model.Producto;
import com.polleria.model.Promocion;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Validaciones de stock para productos y promociones.
 */
public class StockService {

    private StockService() {}

    public static String validarAgregar(int itemId, int cantidadAgregar, List<ItemCarrito> carrito, String tipo)
            throws SQLException {
        if ("promocion".equals(tipo)) {
            return validarAgregarPromocion(itemId, cantidadAgregar, carrito);
        }
        return validarAgregarProducto(itemId, cantidadAgregar, carrito);
    }

    public static String validarCantidad(int itemId, int cantidad, List<ItemCarrito> carrito, String tipo)
            throws SQLException {
        if (cantidad <= 0) return null;
        if ("promocion".equals(tipo)) {
            return validarCantidadPromocion(itemId, cantidad, carrito);
        }
        return validarCantidadProducto(itemId, cantidad, carrito);
    }

    /** Valida todo el carrito antes del checkout. */
    public static String validarCarrito(List<ItemCarrito> carrito) throws SQLException {
        if (carrito == null || carrito.isEmpty()) return "El carrito está vacío.";

        Map<Integer, Integer> totalesProductos = new HashMap<>();
        Map<Integer, Integer> totalesPromociones = new HashMap<>();

        for (ItemCarrito item : carrito) {
            if ("producto".equals(item.getTipo())) {
                totalesProductos.merge(item.getProductoId(), item.getCantidad(), Integer::sum);
            } else if ("promocion".equals(item.getTipo())) {
                totalesPromociones.merge(item.getProductoId(), item.getCantidad(), Integer::sum);
            }
        }

        ProductoDAO productoDAO = new ProductoDAO();
        for (Map.Entry<Integer, Integer> entry : totalesProductos.entrySet()) {
            Producto p = productoDAO.obtenerPorId(entry.getKey());
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

        PromocionDAO promocionDAO = new PromocionDAO();
        for (Map.Entry<Integer, Integer> entry : totalesPromociones.entrySet()) {
            Promocion promo = promocionDAO.obtenerPorId(entry.getKey());
            if (promo == null || !promo.isActivo()) {
                return "Una promoción de tu carrito ya no está disponible.";
            }
            if (promo.getStock() <= 0) {
                return "\"" + promo.getNombre() + "\" se agotó. Elimínala del carrito para continuar.";
            }
            if (entry.getValue() > promo.getStock()) {
                return "Stock insuficiente para \"" + promo.getNombre() + "\". Disponible: " + promo.getStock() + ".";
            }
        }

        return null;
    }

    private static String validarAgregarProducto(int productoId, int cantidadAgregar, List<ItemCarrito> carrito)
            throws SQLException {
        ProductoDAO dao = new ProductoDAO();
        Producto p = dao.obtenerPorId(productoId);
        if (p == null || !p.isActivo()) {
            return "El producto no está disponible.";
        }
        if (p.getStock() <= 0) {
            return "\"" + p.getNombre() + "\" está agotado.";
        }

        int enCarrito = cantidadEnCarrito(productoId, "producto", carrito);
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

    private static String validarAgregarPromocion(int promocionId, int cantidadAgregar, List<ItemCarrito> carrito)
            throws SQLException {
        PromocionDAO dao = new PromocionDAO();
        Promocion p = dao.obtenerPorId(promocionId);
        if (p == null || !p.isActivo()) {
            return "La promoción no está disponible.";
        }
        if (p.getStock() <= 0) {
            return "\"" + p.getNombre() + "\" está agotada.";
        }

        int enCarrito = cantidadEnCarrito(promocionId, "promocion", carrito);
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

    private static String validarCantidadProducto(int productoId, int cantidad, List<ItemCarrito> carrito)
            throws SQLException {
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

    private static String validarCantidadPromocion(int promocionId, int cantidad, List<ItemCarrito> carrito)
            throws SQLException {
        PromocionDAO dao = new PromocionDAO();
        Promocion p = dao.obtenerPorId(promocionId);
        if (p == null || !p.isActivo()) {
            return "La promoción no está disponible.";
        }
        if (p.getStock() <= 0) {
            return "\"" + p.getNombre() + "\" está agotada.";
        }
        if (cantidad > p.getStock()) {
            return "Solo hay " + p.getStock() + " unidad(es) de \"" + p.getNombre() + "\".";
        }
        return null;
    }

    private static int cantidadEnCarrito(int itemId, String tipo, List<ItemCarrito> carrito) {
        if (carrito == null) return 0;
        for (ItemCarrito item : carrito) {
            if (item.getProductoId() == itemId && tipo.equals(item.getTipo())) {
                return item.getCantidad();
            }
        }
        return 0;
    }
}
