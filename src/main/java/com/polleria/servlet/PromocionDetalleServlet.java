package com.polleria.servlet;

import com.polleria.dao.PromocionDAO;
import com.polleria.dao.PromocionOpcionDAO;
import com.polleria.model.ItemCarrito;
import com.polleria.model.Promocion;
import com.polleria.model.PromocionOpcion;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.*;

public class PromocionDetalleServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String idParam = req.getParameter("id");
        if (idParam == null) {
            resp.sendRedirect(req.getContextPath() + "/promociones");
            return;
        }
        try {
            int id = Integer.parseInt(idParam);
            PromocionDAO dao = new PromocionDAO();
            Promocion promocion = dao.obtenerPorId(id);

            if (promocion == null || !promocion.isActivo() || promocion.getStock() <= 0) {
                resp.sendRedirect(req.getContextPath() + "/promociones");
                return;
            }

            // Cargar opciones y agrupar
            PromocionOpcionDAO opcionDAO = new PromocionOpcionDAO();
            List<PromocionOpcion> opciones = opcionDAO.listarActivasPorPromocion(id);

            Map<String, List<PromocionOpcion>> opcionesPorGrupo = new LinkedHashMap<>();
            for (PromocionOpcion op : opciones) {
                opcionesPorGrupo
                    .computeIfAbsent(op.getGrupo(), k -> new ArrayList<>())
                    .add(op);
            }

            // Colores por grupo
            Map<String, String> coloresPorGrupo = new LinkedHashMap<>();
            coloresPorGrupo.put("Pollo",       "bg-red-600");
            coloresPorGrupo.put("Complemento", "bg-orange-500");
            coloresPorGrupo.put("Guarnición",  "bg-yellow-500");
            coloresPorGrupo.put("Bebida",      "bg-blue-500");

            // ── Cantidad ya en carrito ────────────────────────────────────────
            List<ItemCarrito> carrito = (List<ItemCarrito>) req.getSession().getAttribute("carrito");
            if (carrito != null) {
                for (ItemCarrito item : carrito) {
                    if (item.getProductoId() == id && "promocion".equals(item.getTipo())) {
                        req.setAttribute("cantidadEnCarrito", item.getCantidad());
                        break;
                    }
                }
            }

            req.setAttribute("promocion", promocion);
            req.setAttribute("opcionesPorGrupo", opcionesPorGrupo);
            req.setAttribute("coloresPorGrupo", coloresPorGrupo);
            req.getRequestDispatcher("/vista/detalle-promocion.jsp").forward(req, resp);

        } catch (NumberFormatException | SQLException e) {
            resp.sendRedirect(req.getContextPath() + "/promociones");
        }
    }
}