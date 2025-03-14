#include <stdio.h>
#include "analisis_sintactico.h"
#include "analisis_lexico.h"

extern int yylex();  // Declarar la función generada por Flex
extern char* yytext; // Contiene el texto del token actual
extern FILE *yyin;  // Declaración de la variable global de Flex

void iniciar_analisis(char *nombre_fichero) {
    contenedor c;
    int i=0, inicio = 0;

    // Inicio
    inicio = iniciar_analisis_lexico(nombre_fichero);

    // Consumo de componentes léxicos
    if (inicio == 0) {
        do {
            c = sig_comp_lexico();
            printf("%d\t\t<%d, \"%s\">\n", i, c.comp_lexico, c.lexema);
            i++;
        } while (c.comp_lexico != FINFICHERO);

        // Fin
        terminar_analisis_lexico();
    }

}