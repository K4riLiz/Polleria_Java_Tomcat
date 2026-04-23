 /*function marcarPaginaActual() {
    const currentPath = window.location.pathname;
    const navLinks = document.querySelectorAll('#navbar ul li a');

    navLinks.forEach(link => {
        const href = link.getAttribute('href');
        
        // Si el href coincide con la ruta actual
        if (href && href !== "" && currentPath.includes(href)) {
            link.classList.add('current');
        } 
        // Manejo especial para Inicio
        else if ((currentPath === "/" || currentPath.includes("../vista/home.html")) && href && href.includes("../vista/home.html")) {
            link.classList.add('current');
        }
    });
}

// Ejecutar con un pequeño retraso para asegurar que el header ya cargó
window.addEventListener("load", () => {
    setTimeout(marcarPaginaActual, 100); 
});*/
// Función para cargar los archivos HTML externos (header y footer)
async function cargarComponentes() {
    try {
        // Cargamos el Header (subimos un nivel para ir a components)
        const resHeader = await fetch('../components/header.html');
        const htmlHeader = await resHeader.text();
        document.getElementById('header').innerHTML = htmlHeader;

        // Cargamos el Footer
        const resFooter = await fetch('../components/footer.html');
        const htmlFooter = await resFooter.text();
        document.getElementById('footer').innerHTML = htmlFooter;

        // Una vez cargados, recién ejecutamos la función de marcar página actual
        marcarPaginaActual();

    } catch (error) {
        console.error("Error cargando los componentes:", error);
    }
}

function marcarPaginaActual() {
    const currentPath = window.location.pathname;
    // OJO: Cambié el selector porque en tu header.html no hay un id="navbar"
    const navLinks = document.querySelectorAll('header ul li a');

    navLinks.forEach(link => {
        const href = link.getAttribute('href');
        
        if (href && href !== "" && currentPath.includes(href)) {
            link.classList.add('current');
        } 
        else if ((currentPath === "/" || currentPath.includes("home.html")) && href && href.includes("home.html")) {
            link.classList.add('current');
        }
    });
}

// Iniciamos la carga cuando el DOM esté listo
document.addEventListener("DOMContentLoaded", cargarComponentes);