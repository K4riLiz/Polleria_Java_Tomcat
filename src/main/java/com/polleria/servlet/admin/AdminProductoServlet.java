package com.polleria.servlet.admin;

import com.polleria.dao.CategoriaDAO;
import com.polleria.dao.ProductoDAO;
import com.polleria.dao.PromocionDAO;
import com.polleria.model.Producto;
import com.polleria.model.Promocion;
import com.polleria.model.Usuario;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.File;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

public class AdminProductoServlet extends HttpServlet {

    private static final String IMG_DIR = "img";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!esAdmin(req, resp)) return;

        String tab = req.getParameter("tab");
        if (tab == null || tab.isEmpty()) tab = "productos";
        req.setAttribute("tab", tab);

        String action = req.getParameter("action");

        try {
            if ("promociones".equals(tab)) {
                PromocionDAO promoDAO = new PromocionDAO();
                if ("editar".equals(action)) {
                    int id = Integer.parseInt(req.getParameter("id"));
                    req.setAttribute("promocionEditar", promoDAO.obtenerPorId(id));
                }
                req.setAttribute("promociones", promoDAO.listarTodosAdmin());
            } else {
                ProductoDAO prodDAO = new ProductoDAO();
                CategoriaDAO catDAO = new CategoriaDAO();
                if ("editar".equals(action)) {
                    int id = Integer.parseInt(req.getParameter("id"));
                    req.setAttribute("productoEditar", prodDAO.obtenerPorId(id));
                }
                req.setAttribute("productos", prodDAO.listarTodosAdmin());
                req.setAttribute("categorias", catDAO.listarTodas());
            }

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
        String tabParam = req.getParameter("tab");
        String redirectTab = "promociones".equals(tabParam) ? "?tab=promociones" : "";

        if ("actualizarStock".equals(actionParam)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                int stock = parseStock(req.getParameter("stock"));
                new ProductoDAO().actualizarStock(id, stock);
                req.getSession().setAttribute("exito", "Stock actualizado correctamente.");
            } catch (Exception e) {
                req.getSession().setAttribute("error", "Error al actualizar stock: " + e.getMessage());
            }
            resp.sendRedirect(req.getContextPath() + "/admin/productos");
            return;
        }

        if ("actualizarStockPromocion".equals(actionParam)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                int stock = parseStock(req.getParameter("stock"));
                new PromocionDAO().actualizarStock(id, stock);
                req.getSession().setAttribute("exito", "Stock de promoción actualizado correctamente.");
            } catch (Exception e) {
                req.getSession().setAttribute("error", "Error al actualizar stock: " + e.getMessage());
            }
            resp.sendRedirect(req.getContextPath() + "/admin/productos?tab=promociones");
            return;
        }

        if (!ServletFileUpload.isMultipartContent(req)) {
            req.getSession().setAttribute("error", "Formulario inválido.");
            resp.sendRedirect(req.getContextPath() + "/admin/productos" + redirectTab);
            return;
        }

        try {
            String uploadPath = getServletContext().getRealPath("") + File.separator + IMG_DIR;
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdirs();

            DiskFileItemFactory factory = new DiskFileItemFactory();
            ServletFileUpload upload = new ServletFileUpload(factory);
            List<FileItem> items = upload.parseRequest(req);

            String action = "", nombre = "", descripcion = "", imagen = "";
            String id = "", precio = "", categoriaId = "", activo = "1", stock = "0", tab = "productos";

            for (FileItem item : items) {
                if (item.isFormField()) {
                    switch (item.getFieldName()) {
                        case "action"      -> action      = item.getString("UTF-8");
                        case "id"          -> id          = item.getString("UTF-8");
                        case "nombre"      -> nombre      = item.getString("UTF-8");
                        case "descripcion" -> descripcion = item.getString("UTF-8");
                        case "precio"      -> precio      = item.getString("UTF-8");
                        case "categoriaId" -> categoriaId = item.getString("UTF-8");
                        case "activo"      -> activo      = item.getString("UTF-8");
                        case "stock"       -> stock       = item.getString("UTF-8");
                        case "imagenActual"-> imagen      = item.getString("UTF-8");
                        case "tab"         -> tab         = item.getString("UTF-8");
                    }
                } else {
                    if ("imagenFile".equals(item.getFieldName()) && item.getSize() > 0) {
                        String fileName = System.currentTimeMillis() + "_" +
                                new File(item.getName()).getName();
                        File file = new File(uploadDir + File.separator + fileName);
                        item.write(file);
                        imagen = fileName;
                    }
                }
            }

            if ("promociones".equals(tab)) {
                procesarPromocion(req, action, id, nombre, descripcion, precio, activo, stock, imagen);
                resp.sendRedirect(req.getContextPath() + "/admin/productos?tab=promociones");
                return;
            }

            ProductoDAO dao = new ProductoDAO();
            switch (action) {
                case "crear" -> {
                    Producto p = new Producto();
                    p.setNombre(nombre);
                    p.setDescripcion(descripcion);
                    p.setPrecio(Double.parseDouble(precio));
                    p.setImagen(imagen.isEmpty() ? "pollobrasa.png" : imagen);
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
                    p.setImagen(imagen.isEmpty() ? "pollobrasa.png" : imagen);
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

        resp.sendRedirect(req.getContextPath() + "/admin/productos" + redirectTab);
    }

    private void procesarPromocion(HttpServletRequest req, String action, String id,
                                   String nombre, String descripcion, String precio,
                                   String activo, String stock, String imagen) throws SQLException {
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
        try {
            return Math.max(0, Integer.parseInt(stock.trim()));
        } catch (NumberFormatException e) {
            return 0;
        }
    }
}
