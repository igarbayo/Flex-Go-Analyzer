#include <stdio.h>
#include "analisis_sintactico.h"
#include "analisis_lexico.h"

extern int yylex();  // Declarar la función generada por Flex
extern char* yytext; // Contiene el texto del token actual
extern FILE *yyin;  // Declaración de la variable global de Flex

void iniciar_analisis(char *nombre_fichero) {
    contenedor c;
    int i=0, j=0;

    // Inicio
    iniciar_analisis_lexico(nombre_fichero);

    // Consumo de componentes léxicos
    do {
        c = sig_comp_lexico();
        if (c.comp_lexico != FINFICHERO) {
           printf("%d\t\t<%d, \"%s\">\n", i, c.comp_lexico, c.lexema);
        }
        i++;
    } while (i<170);

    // Fin
    terminar_analisis_lexico();

}