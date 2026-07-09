package com.polleria.servlet;

import com.polleria.dao.UsuarioDAO;
import com.polleria.model.Usuario;
import com.polleria.util.EmailService;
import com.polleria.util.PasswordValidator;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Random;

public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/vista/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Asegurar encoding UTF-8 para ñ y tildes
        req.setCharacterEncoding("UTF-8");

        String action = req.getParameter("action");

        if ("login".equals(action)) {
            handleLogin(req, resp);
        } else if ("registro".equals(action)) {
            handleRegistro(req, resp);
        }
    }

    // ── CAPTCHA V3 ──────────────────────────────────────────────────────────────────
    private boolean verificarCaptcha(String token) {
      
        try {
            String secretKey = "6LcthQQtAAAAAI2EqzSF_4VOyEW3ydK1SncOt8JS";
            java.net.URL url = new java.net.URL("https://www.google.com/recaptcha/api/siteverify");
            java.net.HttpURLConnection con = (java.net.HttpURLConnection) url.openConnection();
            con.setRequestMethod("POST");
            con.setDoOutput(true);
            String params = "secret=" + secretKey + "&response=" + token;
            con.getOutputStream().write(params.getBytes());
            java.util.Scanner sc = new java.util.Scanner(con.getInputStream());
            String response = sc.useDelimiter("\\A").next();
            return response.contains("\"success\": true") && !response.contains("\"score\": 0.0");
        } catch (Exception e) {
            return false;
        }
    }
    
    // ── LOGIN ──────────────────────────────────────────────────────────────────
    private void handleLogin(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        // Verificar captcha
        String captchaToken = req.getParameter("g-recaptcha-response");
        if (!verificarCaptcha(captchaToken)) {
            req.setAttribute("error", "Verificación de seguridad fallida. Intenta de nuevo.");
            req.getRequestDispatcher("/vista/login.jsp").forward(req, resp);
            return;
        }
        
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        try {
            UsuarioDAO dao = new UsuarioDAO();
            Usuario usuario = dao.login(email, password);

            if (usuario != null) {
                // Guardar usuario en sesión
                HttpSession session = req.getSession();
                session.setAttribute("usuario", usuario);
                session.setAttribute("rolNombre", usuario.getRolNombre());

                // Toast de bienvenida solo para clientes (una vez por login)
                if ("CLIENTE".equals(usuario.getRolNombre())) {
                    session.setAttribute("mostrarBienvenida", true);
                }

                // Redirigir según rol
                switch (usuario.getRolNombre()){
                    case "ADMIN":
                        resp.sendRedirect(req.getContextPath()+"/admin/dashboard");
                        break;
                    case "CHEF":
                        resp.sendRedirect(req.getContextPath() + "/chef/pedidos");
                        break;
                    case "DELIVERY":
                        resp.sendRedirect(req.getContextPath() + "/delivery/pedidos");
                        break;
                    default:
                        resp.sendRedirect(req.getContextPath()+"/home");
                        break;
                        
                }
                
                
                //termina
               
            } else {
                req.setAttribute("error", "Correo o contraseña incorrectos");
                req.getRequestDispatcher("/vista/login.jsp").forward(req, resp);
            }
        } catch (SQLException e) {
            req.setAttribute("error", "Error del servidor: " + e.getMessage());
            req.getRequestDispatcher("/vista/login.jsp").forward(req, resp);
        }
    }

    // ── REGISTRO ───────────────────────────────────────────────────────────────
    private void handleRegistro(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        // Verificar captcha
        String captchaToken = req.getParameter("g-recaptcha-response");
        if (!verificarCaptcha(captchaToken)) {
            req.setAttribute("errorRegistro", "Verificación de seguridad fallida. Intenta de nuevo.");
            req.getRequestDispatcher("/vista/login.jsp").forward(req, resp);
            return;
        }
        
        String nombre   = req.getParameter("nombre");
        String apellido = req.getParameter("apellido");
        String email    = req.getParameter("email");
        String password = req.getParameter("password");
        String telefono = req.getParameter("telefono");

        try {
            // Validación: solo letras y espacios en el nombre
            if (!nombre.matches("^[a-zA-ZáéíóúÁÉÍÓÚñÑ ]+$")) {
                req.setAttribute("errorRegistro", "El nombre solo debe contener letras");
                req.getRequestDispatcher("/vista/login.jsp").forward(req, resp);
                return;
            }
            
            // Validar apellido igual que nombre
            if (!apellido.matches("^[a-zA-ZáéíóúÁÉÍÓÚñÑ ]+$") || apellido.length() < 2 || apellido.length() > 50) {
                req.setAttribute("errorRegistro", "El apellido solo debe contener letras (2-50 caracteres)");
                req.getRequestDispatcher("/vista/login.jsp").forward(req, resp);
                return;
            }

            // Validación: longitud del nombre
            if (nombre.length() < 3 || nombre.length() > 50) {
                req.setAttribute("errorRegistro", "El nombre debe tener entre 3 y 50 caracteres");
                req.getRequestDispatcher("/vista/login.jsp").forward(req, resp);
                return;
            }

            // Validación: formato de email
            if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
                req.setAttribute("errorRegistro", "Formato de correo inválido");
                req.getRequestDispatcher("/vista/login.jsp").forward(req, resp);
                return;
            }

            // Validación: solo dominios conocidos y reales
            String[] dominiosValidos = {
                "gmail.com", "hotmail.com", "outlook.com", "yahoo.com", "icloud.com"
            };
            boolean valido = false;
            for (String dominio : dominiosValidos) {
                if (email.toLowerCase().endsWith("@" + dominio)) {
                    valido = true;
                    break;
                }
            }
            if (!valido) {
                req.setAttribute("errorRegistro", "Debes usar un correo válido");
                req.getRequestDispatcher("/vista/login.jsp").forward(req, resp);
                return;
            }

            // Validación: correo no duplicado en BD
            UsuarioDAO dao = new UsuarioDAO();
            if (dao.emailExiste(email)) {
                req.setAttribute("errorRegistro", "El correo ya está registrado");
                req.getRequestDispatcher("/vista/login.jsp").forward(req, resp);
                return;
            }

            String confirmPassword = req.getParameter("confirmPassword");
            if (!PasswordValidator.esValida(password)) {
                req.setAttribute("errorRegistro", PasswordValidator.MENSAJE_ERROR);
                req.getRequestDispatcher("/vista/login.jsp").forward(req, resp);
                return;
            }
            if (confirmPassword == null || !PasswordValidator.coinciden(password, confirmPassword)) {
                req.setAttribute("errorRegistro", "Las contraseñas no coinciden.");
                req.getRequestDispatcher("/vista/login.jsp").forward(req, resp);
                return;
            }

            // Guardar datos del usuario en sesión (aún NO se registra en BD)
            Usuario u = new Usuario();
            u.setNombre(nombre);
            u.setEmail(email);
            u.setPassword(password);
            u.setTelefono(telefono);

            // Generar código de 6 dígitos aleatorio
            String codigo = String.valueOf(100000 + new Random().nextInt(900000));

            // Guardar en sesión para verificar después
            HttpSession session = req.getSession();
            session.setAttribute("usuarioPendiente", u);
            session.setAttribute("apellidoPendiente", apellido);
            session.setAttribute("codigoVerificacion", codigo);
            
            // Guardar tiempo de expiración (5 minutos)
            session.setAttribute("codigoExpiracion", System.currentTimeMillis() + (5 * 60 * 1000));

            // Enviar código al correo del usuario
            EmailService.enviarCodigo(email, codigo);

            // Redirigir a pantalla de verificación
            resp.sendRedirect(req.getContextPath() + "/verificacion");

        } catch (SQLException e) {
            req.setAttribute("errorRegistro", "Error del servidor: " + e.getMessage());
            req.getRequestDispatcher("/vista/login.jsp").forward(req, resp);
        } catch (Exception e) {
            // Error al enviar el correo
            req.setAttribute("errorRegistro", "Error al enviar el correo: " + e.getMessage());
            req.getRequestDispatcher("/vista/login.jsp").forward(req, resp);
        }
    }
}