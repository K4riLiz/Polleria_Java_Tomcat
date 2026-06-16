package com.polleria.servlet.admin;

import com.polleria.dao.CategoriaDAO;
import com.polleria.dao.ProductoDAO;
import com.polleria.dao.PromocionDAO;
import com.polleria.model.Categoria;
import com.polleria.model.Producto;
import com.polleria.model.Promocion;
import com.polleria.model.Usuario;
import com.polleria.util.CloudinaryService;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

public class AdminProductoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!esAdmin(req, resp)) return;

        String action = req.getParameter("action");

        try {
            ProductoDAO prodDAO = new ProductoDAO();
            CategoriaDAO catDAO = new CategoriaDAO();
            PromocionDAO promoDAO = new PromocionDAO();

            if ("editar".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                req.setAttribute("productoEditar", prodDAO.obtenerPorId(id));
            } else if ("editarCategoria".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                req.setAttribute("categoriaEditar", catDAO.obtenerPorId(id));
                req.setAttribute("tabActivo", "categorias");
            } else if ("editarPromocion".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                req.setAttribute("promocionEditar", promoDAO.obtenerPorId(id));
                req.setAttribute("tabActivo", "promociones");
            }

            req.setAttribute("productos",   prodDAO.listarTodosAdmin());
            req.setAttribute("categorias",  catDAO.listarTodas());
            req.setAttribute("promociones", promoDAO.listarTodosAdmin());
            req.getRequestDispatcher("/vista/admin/productos.jsp").forward(req, resp);

        } catch (SQLException e) {
            req.setAttribute("error", "Error: " + e.getMessage());
            req.getRequestDispatcher("/vista/admin/productos.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!esAdmin(req, resp)) return;

        String actionParam = req.getParameter("action");

        // ── Stock rápido producto (no multipart) ──────────────────────────────
        if ("actualizarStock".equals(actionParam)) {
            try {
                int id    = Integer.parseInt(req.getParameter("id"));
                int stock = parseStock(req.getParameter("stock"));
                new ProductoDAO().actualizarStock(id, stock);
                req.getSession().setAttribute("exito", "Stock actualizado correctamente.");
            } catch (Exception e) {
                req.getSession().setAttribute("error", "Error al actualizar stock: " + e.getMessage());
            }
            resp.sendRedirect(req.getContextPath() + "/admin/productos");
            return;
        }

        // ── Stock rápido promoción (no multipart) ─────────────────────────────
        if ("actualizarStockPromocion".equals(actionParam)) {
            try {
                int id    = Integer.parseInt(req.getParameter("id"));
                int stock = parseStock(req.getParameter("stock"));
                new PromocionDAO().actualizarStock(id, stock);
                req.getSession().setAttribute("exito", "Stock de promoción actualizado.");
            } catch (Exception e) {
                req.getSession().setAttribute("error", "Error al actualizar stock: " + e.getMessage());
            }
            resp.sendRedirect(req.getContextPath() + "/admin/productos?tab=promociones");
            return;
        }

        // ── Acciones de categoría (no multipart) ──────────────────────────────
        if ("crearCategoria".equals(actionParam) || "actualizarCategoria".equals(actionParam)
                || "eliminarCategoria".equals(actionParam)) {
            try {
                CategoriaDAO catDAO = new CategoriaDAO();
                if ("crearCategoria".equals(actionParam)) {
                    Categoria c = new Categoria();
                    c.setNombre(req.getParameter("catNombre"));
                    c.setDescripcion(req.getParameter("catDescripcion"));
                    c.setImagen("");
                    catDAO.crear(c);
                    req.getSession().setAttribute("exito", "Categoría creada correctamente.");
                } else if ("actualizarCategoria".equals(actionParam)) {
                    Categoria c = new Categoria();
                    c.setId(Integer.parseInt(req.getParameter("catId")));
                    c.setNombre(req.getParameter("catNombre"));
                    c.setDescripcion(req.getParameter("catDescripcion"));
                    c.setImagen(req.getParameter("catImagenActual") != null ? req.getParameter("catImagenActual") : "");
                    catDAO.actualizar(c);
                    req.getSession().setAttribute("exito", "Categoría actualizada correctamente.");
                } else {
                    int id = Integer.parseInt(req.getParameter("catId"));
                    boolean ok = catDAO.eliminar(id);
                    if (ok) req.getSession().setAttribute("exito", "Categoría eliminada.");
                    else    req.getSession().setAttribute("error", "No se puede eliminar: tiene productos asociados.");
                }
                // Limpiar cache de categorías del header
                req.getSession().removeAttribute("categoriasNav");
            } catch (Exception e) {
                req.getSession().setAttribute("error", "Error: " + e.getMessage());
            }
            resp.sendRedirect(req.getContextPath() + "/admin/productos?tab=categorias");
            return;
        }

        // ── Multipart (productos y promociones con imagen) ────────────────────
        if (!ServletFileUpload.isMultipartContent(req)) {
            req.getSession().setAttribute("error", "Formulario inválido.");
            resp.sendRedirect(req.getContextPath() + "/admin/productos");
            return;
        }

        try {
            DiskFileItemFactory factory = new DiskFileItemFactory();
            ServletFileUpload upload = new ServletFileUpload(factory);
            List<FileItem> items = upload.parseRequest(req);

            String action = "", nombre = "", descripcion = "", imagen = "";
            String id = "", precio = "", categoriaId = "", activo = "1", stock = "0", tab = "productos";

            for (FileItem item : items) {
                if (item.isFormField()) {
                    switch (item.getFieldName()) {
                        case "action"       -> action      = item.getString("UTF-8");
                        case "id"           -> id          = item.getString("UTF-8");
                        case "nombre"       -> nombre      = item.getString("UTF-8");
                        case "descripcion"  -> descripcion = item.getString("UTF-8");
                        case "precio"       -> precio      = item.getString("UTF-8");
                        case "categoriaId"  -> categoriaId = item.getString("UTF-8");
                        case "activo"       -> activo      = item.getString("UTF-8");
                        case "stock"        -> stock       = item.getString("UTF-8");
                        case "imagenActual" -> imagen      = item.getString("UTF-8");
                        case "tab"          -> tab         = item.getString("UTF-8");
                    }
                } else {
                    // Subir imagen a Cloudinary (tu implementación)
                    if ("imagenFile".equals(item.getFieldName()) && item.getSize() > 0) {
                        byte[] datos = item.get();
                        String urlImagen = CloudinaryService.subirImagen(datos);
                        imagen = urlImagen;
                    }
                }
            }

            // ── Promociones ───────────────────────────────────────────────────
            if ("promociones".equals(tab) || action.contains("Promocion")) {
                PromocionDAO dao = new PromocionDAO();
                switch (action) {
                    case "crearPromocion" -> {
                        Promocion p = new Promocion();
                        p.setNombre(nombre);
                        p.setDescripcion(descripcion);
                        p.setPrecio(Double.parseDouble(precio));
                        p.setImagen(imagen.isEmpty() ? "pollobrasa.png" : imagen);
                        p.setStock(parseStock(stock));
                        p.setActivo(true);
                        dao.crear(p);
                        req.getSession().setAttribute("exito", "Promoción creada correctamente.");
                    }
                    case "actualizarPromocion" -> {
                        Promocion p = new Promocion();
                        p.setId(Integer.parseInt(id));
                        p.setNombre(nombre);
                        p.setDescripcion(descripcion);
                        p.setPrecio(Double.parseDouble(precio));
                        p.setImagen(imagen.isEmpty() ? "pollobrasa.png" : imagen);
                        p.setActivo("1".equals(activo));
                        p.setStock(parseStock(stock));
                        dao.actualizar(p);
                        req.getSession().setAttribute("exito", "Promoción actualizada correctamente.");
                    }
                    case "eliminarPromocion" -> {
                        dao.eliminar(Integer.parseInt(id));
                        req.getSession().setAttribute("exito", "Promoción eliminada correctamente.");
                    }
                }
                resp.sendRedirect(req.getContextPath() + "/admin/productos?tab=promociones");
                return;
            }

            // ── Productos ─────────────────────────────────────────────────────
            ProductoDAO dao = new ProductoDAO();
            switch (action) {
                case "crear" -> {
                    Producto p = new Producto();
                    p.setNombre(nombre);
                    p.setDescripcion(descripcion);
                    p.setPrecio(Double.parseDouble(precio));
                    p.setImagen(imagen.isEmpty() ? "" : imagen);
                    p.setCategoriaId(Integer.parseInt(categoriaId));
                    p.setStock(parseStock(stock));
                    p.setActivo(true);
                    dao.crear(p);
                    req.getSession().setAttribute("exito", "Producto creado correctamente.");
                }
                case "actualizar" -> {
                    Producto p = new Producto();
                    p.setId(Integer.parseInt(id));
                    p.setNombre(nombre);
                    p.setDescripcion(descripcion);
                    p.setPrecio(Double.parseDouble(precio));
                    p.setImagen(imagen.isEmpty() ? "" : imagen);
                    p.setCategoriaId(Integer.parseInt(categoriaId));
                    p.setActivo("1".equals(activo));
                    p.setStock(parseStock(stock));
                    dao.actualizar(p);
                    req.getSession().setAttribute("exito", "Producto actualizado correctamente.");
                }
                case "eliminar" -> {
                    dao.eliminar(Integer.parseInt(id));
                    req.getSession().setAttribute("exito", "Producto eliminado correctamente.");
                }
            }

        } catch (Exception e) {
            req.getSession().setAttribute("error", "Error: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/admin/productos");
    }

    private boolean esAdmin(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return false;
        }
        Usuario u = (Usuario) session.getAttribute("usuario");
        if (!"ADMIN".equals(u.getRolNombre())) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return false;
        }
        return true;
    }

    private int parseStock(String stock) {
        try { return Math.max(0, Integer.parseInt(stock.trim())); }
        catch (NumberFormatException e) { return 0; }
    }
}