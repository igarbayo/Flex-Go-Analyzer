#include <stdio.h>
#include "definiciones.h"
#include "analisis_lexico.h"
#include "errores.h"

// Variable global (se le asignan valores iniciales)
contenedor c = {-1, NULL};

// Variables globales
extern int linea;
extern int columna;

extern int yylex();  // Declarar la función generada por Flex
extern char* yytext; // Contiene el texto del token actual
extern FILE *yyin;  // Declaración de la variable global de Flex
extern void liberar_recursos();


// FUNCIONES PÚBLICAS /////////////////////////////////////////

void iniciar_analisis_lexico(char* fichero) {
    // Abrir el archivo en modo lectura
    yyin = fopen(fichero, "r");
    if (!yyin) {
        error_fichero();
    }
}

void terminar_analisis_lexico() {
    fclose(yyin);
    liberar_recursos();
}

contenedor sig_comp_lexico() {
    if ((c.comp_lexico = yylex()) != 0) {
        c.lexema = yytext;
    }
    return c;
}


