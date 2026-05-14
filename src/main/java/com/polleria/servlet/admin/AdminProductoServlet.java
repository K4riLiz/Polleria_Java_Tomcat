package com.polleria.servlet.admin;

import com.polleria.dao.CategoriaDAO;
import com.polleria.dao.ProductoDAO;
import com.polleria.model.Producto;
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

    // Carpeta donde se guardarán las imágenes
    private static final String IMG_DIR = "img";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!esAdmin(req, resp)) return;

        String action = req.getParameter("action");

        try {
            ProductoDAO prodDAO = new ProductoDAO();
            CategoriaDAO catDAO = new CategoriaDAO();

            if ("editar".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                req.setAttribute("productoEditar", prodDAO.obtenerPorId(id));
            }

            req.setAttribute("productos", prodDAO.listarTodos());
            req.setAttribute("categorias", catDAO.listarTodas());
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

        // Verificar si es multipart (subida de archivo)
        if (!ServletFileUpload.isMultipartContent(req)) {
            req.getSession().setAttribute("error", "Formulario inválido.");
            resp.sendRedirect(req.getContextPath() + "/admin/productos");
            return;
        }

        try {
            // Configurar directorio de subida
            String uploadPath = getServletContext().getRealPath("") + File.separator + IMG_DIR;
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdirs();

            // Procesar el formulario multipart
            DiskFileItemFactory factory = new DiskFileItemFactory();
            ServletFileUpload upload = new ServletFileUpload(factory);
            List<FileItem> items = upload.parseRequest(req);

            // Variables del formulario
            String action = "", nombre = "", descripcion = "", imagen = "";
            String id = "", precio = "", categoriaId = "", activo = "1";

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
                        case "imagenActual"-> imagen      = item.getString("UTF-8");
                    }
                } else {
                    // Es un archivo
                    if (item.getFieldName().equals("imagenFile") && item.getSize() > 0) {
                        String fileName = System.currentTimeMillis() + "_" +
                                new File(item.getName()).getName();
                        File file = new File(uploadDir + File.separator + fileName);
                        item.write(file);
                        imagen = fileName;
                    }
                }
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
}
