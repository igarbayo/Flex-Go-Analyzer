#include <stdio.h>

// Colores para la impresión
#define RED     "\x1b[31m"
#define YELLOW  "\x1b[33m"
#define RESET   "\x1b[0m"

// ERRORES LÉXICOS //////////////////////////////////

/**
 * Función privada para la impresión parametrizada de los errores
 * @param mensaje tipo de componente léxico que presenta el error
 * @param linea del error
 * @param columna del error
 * @param lexema erróneo
 */
void _imprimir_error_lexico(const char* mensaje, int linea, int columna, char* lexema, char* sugerencia) {
    printf(RED "\tError léxico: %s\n" RESET, mensaje);
    printf(RED "\tLínea %d, columna %d: " RESET, linea, columna);
    printf(YELLOW "%s\n" RESET, lexema);
    printf(RED "\tSugerencia: %s.\n" RESET, sugerencia);
}

void error_string(int linea, int columna, char* lexema, char* sugerencia) {
    _imprimir_error_lexico("String", linea, columna, lexema, sugerencia);
}

void error_entero(int linea, int columna, char* lexema, char* sugerencia) {
    _imprimir_error_lexico("Integer", linea, columna, lexema, sugerencia);
}

void error_float(int linea, int columna, char* lexema, char* sugerencia) {
    _imprimir_error_lexico("Float", linea, columna, lexema, sugerencia);
}

// ERRORES DE EJECUCIÓN ///////////////////////////////////////////

void error_fichero() {
    printf(RED "\tError de ejecución: no se puede leer el fichero.\n" RESET);
}

void error_parametros(char* programa) {
    printf(RED "\tError de ejecución: número de parámetros incorrecto. Usar %s <código_fuente>.\n" RESET, programa);
}
