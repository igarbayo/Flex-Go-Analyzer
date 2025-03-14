#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include "definiciones.h"
#include "analisis_lexico.h"
#include "sistema_entrada.h"
#include "errores.h"
#include "tabla_simbolos.h"


// Definición para las implementaciones
#define FIN_COMPONENTE 100

// Variable global (se le asignan valores iniciales)
contenedor c = {-1, NULL};

// Variables globales
extern int linea;
extern int columna;

// Contadores globales para impresión de errores
int lin = 1;
int col = 0;
int col_ant = 1;

// Variables globales para manejar semicolon (;)
short insertarSemi = 0;
char* semi;

// Variable global para el lexema de EOF
char* end_of_file;

// Variable global para el resultado de la suma de strings
char* resultado;

extern int yylex();  // Declarar la función generada por Flex
extern char* yytext; // Contiene el texto del token actual
extern FILE *yyin;  // Declaración de la variable global de Flex




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
}

contenedor sig_comp_lexico() {

    // Vacía el contenedor global
    //_vaciar_contenedor();

    if ((c.comp_lexico = yylex()) != 0) {
        c.lexema = yytext;
    }

    return c;

    /*
    // Consume un carácter del sistema de entrada
    char sig = sig_caracter(); _sumar_columna(sig);

    // Vacía el contenedor global
    _vaciar_contenedor();

    // Mientras no se alcanza el final del fichero
    if (sig != EOF) {
        if (isalpha(sig) || sig == '_') {
            _procesarIdentificador();
        } else if (isdigit(sig) || sig == '.') {
            if (_procesarNumero(sig) == 1) {
                // En caso de error, continúa el análisis
                return sig_comp_lexico();
            }
        } else if (sig == '`' || sig == '"') {
            if (_procesarString(sig) == 1) {
                // En caso de error, continúa el análisis
                return sig_comp_lexico();
            }
        } else if (sig == '/') {
            if (_procesarComentario() == 0) {
                // En caso de que / se procese como un operador
                if (insertarSemicolon == 1) {
                    // En caso de que haya que insertar ;
                    _devolverSemicolon();
                    devolver_un_caracter();
                } else {
                    // Si es un comentario, continúa el análisis
                    insertarSemicolon = 0;
                    return sig_comp_lexico();
                }
            }
        } else if (sig == '+' || sig == '-' || sig == '*' || sig == '%' || sig == '&' || sig == '|' ||
                   sig == '^' || sig == '<' || sig == '>' || sig == '=' || sig == '!' || sig == '~' ||
                   sig == ':' || sig == ',' || sig == ';' || sig == '(' || sig == ')' || sig == '[' ||
                   sig == ']' || sig == '{' || sig == '}') {
            _procesarOperador(sig);
        } else if (sig == '\n') {
            // Para los saltos de línea
            if (insertarSemicolon == 1) {
                // Si hay que insertar semicolon
                _devolverSemicolon();
                ignorar_caracter();
            } else {
                ignorar_caracter();
                return sig_comp_lexico();
            }
        } else {
            // Resto de caracteres
            ignorar_caracter();
            // Recursividad al ignorar caracteres
            return sig_comp_lexico();
        }
    } else {
        // El final del archivo
        if (insertarSemicolon == 1) {
            // Si hay que insertar semicolon
            _devolverSemicolon();
            devolver_un_caracter();
        } else {
            // En otro caso, devolvemos el último componente léxico
            c.comp_lexico = FINFICHERO;
            end_of_file = (char*) malloc (4*sizeof(char));
            end_of_file[0] = 'E';
            end_of_file[1] = '0';
            end_of_file[2] = 'F';
            end_of_file[3] = '\0';
            asignar_lexema(&c, end_of_file);
        }
    }

    // Devolvemos el contenedor con el componente léxico y el lexema
    return c;
    */
}


