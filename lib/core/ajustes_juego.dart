// Valores del juego, reunidos en un solo lugar para ajustarlos durante la demo.

// Nivel 3 de la demo: cambia este valor (por ejemplo a 600) y guarda.
// Con hot reload el salto se vuelve lento al instante, sin reiniciar el juego.
const double gravedad = 1800; // píxeles por segundo al cuadrado
const double fuerzaSalto = 700; // velocidad inicial del salto
const double velocidadSuelo = 320; // píxeles por segundo

// Cada pixel del dibujo se ve como un cuadro de 3 x 3 en pantalla.
const double escala = 3;

// El juego "finge" una pantalla de 800 x 400 para verse igual
// en el emulador y en Chrome.
const double anchoMundo = 800;
const double altoMundo = 400;
const double alturaSuelo = 352; // coordenada y donde empieza el suelo
