# Pollería "El Dorado"

<img src="https://github.com/user-attachments/assets/057c939e-f222-4174-8b2a-1ba401c20032" width="110" alt="logoeldorado">

> **¡El mejor sabor de Lima en un solo lugar!**

## 📝 Presentación de la empresa
La pollería El Dorado, ubicada en el distrito de Carabayllo, es un negocio gastronómico dedicado a la elaboración de pollo a la brasa y platos de alta calidad. Su propuesta se basa en combinar la excelencia culinaria con un servicio eficiente, amigable y adaptado a las nuevas tendencias tecnológicas. Con una visión orientada a la innovación, la empresa busca consolidarse como referente local mediante el uso de herramientas digitales que agilicen la atención. Su enfoque principal es garantizar la satisfacción del cliente tanto en su salón como en el servicio de delivery.

## 🚩 Problemática
La pollería El Dorado sufre retrasos y errores operativos debido a una gestión de pedidos manual y desorganizada. Para solucionarlo, implementará un aplicativo web y carta digital que automatice el registro y control de ventas. Esta transformación digital optimizará los tiempos de atención y eliminará los fallos humanos en horas críticas. El resultado será un negocio más eficiente, con reportes precisos y un servicio al cliente superior.

## 🎯 Objetivo General
Desarrollar e implementar un aplicativo web integral de gestión de pedidos y carta digital para optimizar la operatividad, reducir los errores humanos y mejorar la experiencia de servicio al cliente en la pollería El Dorado.

## 📌 Objetivos Específicos

1. Diseñar e implementar una **carta digital interactiva** accesible desde dispositivos móviles y web.
2. Desarrollar un **módulo de registro y seguimiento de pedidos** en tiempo real para el personal de cocina.
3. Implementar un **sistema de control de ventas** con generación de reportes diarios, semanales y mensuales.
4. Garantizar una **interfaz intuitiva y responsiva** que minimice el tiempo de capacitación del personal.

## ✨ Características del Sistema

| Módulo | Descripción |
|---|---|
| 🍽️ Carta Digital | Menú interactivo con categorías, fotos, precios y disponibilidad en tiempo real |
| 📝 Gestión de Pedidos | Registro, seguimiento y estado de pedidos (pendiente / en cocina / listo / entregado) |
| 📊 Reportes | Dashboard con estadísticas de ventas, platos más pedidos|
| 👤 Gestión de Usuarios | Roles diferenciados: administrador, cajero, cocinero|
| 📣 Reclamos y Quejas | Registro de reclamos del cliente, seguimiento de estado y respuesta por parte del administrador |

## 🛠️ Tecnologías Utilizadas

- [Java JDK](https://www.oracle.com/java/technologies/downloads/) v21
- [Apache Tomcat](https://tomcat.apache.org/) v9 
- [Apache NetBeans IDE](https://netbeans.apache.org/) v21 
- [MySQL](https://www.mysql.com/) v8 
- [Git](https://git-scm.com/)


### JSP (JavaServer Pages) — Vistas del sistema

Se utilizó JSP para construir las páginas que el cliente ve en el navegador. Concretamente, se aplicó en la **carta digital**, donde cada plato del menú se muestra de forma dinámica consultando la base de datos, y en las **páginas de login**, donde el formulario de autenticación valida las credenciales del usuario y redirige según su rol (administrador o cajero). HTML5 y CSS3 complementan el diseño visual de cada vista.

### Java Servlets — Lógica del sistema

Los Servlets son los encargados de procesar lo que ocurre entre el usuario y la base de datos. Por ejemplo, cuando un usuario ingresa sus credenciales en el login, un Servlet recibe esos datos, consulta MySQL para verificarlos y decide si redirige al panel principal o muestra un mensaje de error. De la misma forma, cuando se carga la carta digital, un Servlet obtiene los productos disponibles y los envía a la vista JSP para mostrarlos.

### Apache Tomcat — Servidor de aplicaciones

Tomcat es el servidor sobre el cual corre toda la aplicación. Durante el desarrollo, cada integrante ejecuta el proyecto localmente desde NetBeans apuntando a Tomcat, lo que permite probar los Servlets y las páginas JSP antes de subir cambios al repositorio.

### MySQL — Base de datos

Se utiliza MySQL para almacenar la información del sistema. Hasta el momento contiene las tablas de **usuarios** (con sus roles y credenciales cifradas) y **productos** (nombre, precio, categoría y disponibilidad para la carta digital). 

### Apache NetBeans IDE — Entorno de desarrollo

Todo el equipo trabaja con NetBeans por su integración directa con proyectos Java Web y Apache Tomcat. Permite ejecutar y depurar la aplicación en un solo clic, facilitando el trabajo con Servlets y JSP sin configuración adicional.

### Git y GitHub — Control de versiones

El equipo gestiona el código con Git y lo centraliza en el repositorio **K4riLiz/Polleria_Java_Tomcat** en GitHub. Cada integrante trabaja en su propia rama y sube los cambios mediante commits, evitando conflictos y manteniendo un historial claro del avance del proyecto.

### Render - Despliegue en la nube

El equipo La aplicación ya se encuentra desplegada en **Render**. El render toma el proyecto directamente desde el repositorio de GitHub y lo pública de forma automática cada vez que se actualiza la rama principal.

---

## 👥 Autores 
**Equipo de Desarrollo**
- **👤 Susaniabr Quispe, Danna Roxanne**
- **👤 SANCHEZ PACHECO KARINA**
- **👤 ROJAS MUNAYA, XIOMARA HATSUMI**
- **👤 MAYURI MONTES, DANA PALOMA**
- **👤 FERREYRA VARGAS, DAYANNA NICOLE**
- **👤 CRUZ BUSTAMANTE, MILAGROS LIZBETH**
