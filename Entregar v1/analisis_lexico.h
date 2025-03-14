#ifndef P1_COMPGO_ANALISIS_LEXICO_H
#define P1_COMPGO_ANALISIS_LEXICO_H

#include "definiciones.h"

/**
 * Inicia el análisis léxico mediante la asignación de yyin
 * @param fichero con el código fuente
 * @return 1 si hay error
 * @return 0 en otro caso
 */
int iniciar_analisis_lexico(char* fichero);

/**
 * Termina el análisis léxico cerrando yyin y liberando el buffer
 */
void terminar_analisis_lexico();

/**
 * Consume un componente léxico (contenedor)
 * @return contenedor con componente léxico y lexema asociado
 */
contenedor sig_comp_lexico();

#endif //P1_COMPGO_ANALISIS_LEXICO_H
