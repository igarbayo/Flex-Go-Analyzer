%{
#include <stdio.h>
#include <stdlib.h>
#include "definiciones.h"
#include "tabla_simbolos.h"
#include "errores.h"

#define RED     "\x1b[31m"
#define YELLOW  "\x1b[33m"
#define RESET   "\x1b[0m"

// Contadores globales para impresión de errores
int i = 0;
int linea = 1;
int columna = 0;
int columna_antigua = 0;

// Variables globales para manejar semicolon (;)
short insertarSemicolon = 0;
char semicolon[2];

// Variable global para el fin de fichero
char end[4];

// Retornar un semicolon
void _devolverSemicolon() {
    // Guarda el componente léxico
    semicolon[0] = ';';
    semicolon[1] = '\0';
    yytext = semicolon;
    yyleng = 1;
    
    // Ponemos a 0
    insertarSemicolon = 0;
}


// Sumar una línea
void _sumar_linea() {
    linea++;
    columna_antigua = columna;
    columna = 0;
}

// Restar una línea
void _restar_linea() {
    linea--;
    columna = columna_antigua;
}

// Sumar una columna
void _sumar_columna(char caracter) {
    if (caracter == '\n') {
        // si se cambia de línea
        _sumar_linea();
    } else {
        columna++;
    }
}

// Restar una columna
void _restar_columna(char caracter) {
    if (caracter == '\n') {
        // si se cambia de línea
        _restar_linea();
    } else {
        columna--;
    }
}


// Al reconocer un identificador
int _buscar_insertar_identificador(char* lexema) {
    //Si no ha habido un error, se continua
    int busqueda = buscar_elemento(lexema);
    //Si no está, lo introducimos en la tabla.
    if (busqueda == -1) {
    	contenedor token = {-1, NULL};
    	token.comp_lexico = ID;
    	token.lexema = lexema;
        insertar_elemento(token);
        return ID;
    } else {
        //Si ya estaba, le asignamos el componente que hay en la tabla.
        return busqueda;
    }
}


%}

%x COMMENT_BLOCK 

underscore_no_digits		{decimal_digit}+[_]([^0-9 ,])*|{decimal_digit}+[_](\.[0-9]+)|{decimal_digit}+\.[_][0-9]+|({decimal_digits}\.?{decimal_digits}?[_]{decimal_exponent}?)|\.({decimal_digits}+[_]{decimal_exponent}?)|{decimal_float_lit}[_]{decimal_digits}*
consecutive_underscores		{decimal_digit}+[_][_]+{decimal_digit}*
mantissa_int_no_digits		0[xX]{hex_exponent}
mantissa_float_no_digits	0[xX]\.{hex_exponent}
p_exponent			{hex_mantissa}{hex_exponent}
e_exponent			0[xX]{hex_mantissa}{decimal_exponent}

letter        		[a-zA-Z_]
decimal_digit 		[0-9]
binary_digit  		[01]
octal_digit   		[0-7]
hex_digit     		[0-9a-fA-F]

identifier    		{letter}({letter}|{decimal_digit})*

decimal_lit   		0|([1-9][_]?{decimal_digit}*)
binary_lit    		0[bB]{binary_digit}+
octal_lit     		0[oO]?{octal_digit}+
hex_lit       		0[xX]{hex_digit}+

int_lit       		{decimal_lit}|{binary_lit}|{octal_lit}|{hex_lit}

decimal_digits 		{decimal_digit}([_]?[decimal_digit])*
binary_digits  		{binary_digit}([_]?[binary_digit])*
octal_digits   		{octal_digit}([_]?[octal_digit])*
hex_digits     		{hex_digit}([_]?[hex_digit])*

decimal_exponent 	[eE][+-]?{decimal_digits}+
decimal_float_lit 	({decimal_digits}\.?{decimal_digits}?{decimal_exponent}?)|\.({decimal_digits}+{decimal_exponent}?)

hex_mantissa 		[_]?{hex_digits}\.?{hex_digits}?
hex_exponent 		[pP][+-]?{decimal_digits}
hex_float_lit 		0[xX]{hex_mantissa}{hex_exponent}

float_lit 		{decimal_float_lit}|{hex_float_lit}

imaginary_lit 		({decimal_digits}|{int_lit}|{float_lit})i

raw_string_lit 		`([^`]|[\n])*`
interpreted_string_lit 	\"([^\"\\]|\\.)*\"
string_lit 		{raw_string_lit}|{interpreted_string_lit}

%%

\/\/[^\n]*	{ 
			// Para cada caracter de la expresión
			for (i = 0; yytext[i] != '\0'; i++) {
        			_sumar_columna(yytext[i]);
    			}
			/* No hacer nada, solo ignorar */
		}

\/\*            { 
			BEGIN(COMMENT_BLOCK);
		}  

<COMMENT_BLOCK>{
    \*\/        {
    			// Para cada caracter de la expresión
			for (i = 0; yytext[i] != '\0'; i++) {
        			_sumar_columna(yytext[i]);
    			}
    			insertarSemicolon = 0;
    			BEGIN(INITIAL); 
    		}  	/* Salir del modo de comentario */
    		
    .|\n        {
    			_sumar_columna(yytext[0]);
    			/* No hacer nada, solo ignorar */
    		}
}


{underscore_no_digits}		{
					error_float(linea, columna, yytext, "\"_\" debe separar dos dígitos");
				}
{consecutive_underscores}	{
					error_entero(linea, columna, yytext, "no puede haber dos o más \"_\" seguidas");
				}
{mantissa_int_no_digits}	{
					error_entero(linea, columna, yytext, "la mantisa debe tener dígitos");
				}
{mantissa_float_no_digits}	{
					error_float(linea, columna, yytext, "la mantisa debe tener dígitos");
				}
{p_exponent}			{
					error_entero(linea, columna, yytext, "el exponente p necesita una mantisa hexadecimal");
				}
{e_exponent}			{
					error_entero(linea, columna, yytext, "la mantisa hexadecimal necesita un exponente p");
				}



{identifier}    {
			// Para cada caracter de la expresión
			for (i = 0; yytext[i] != '\0'; i++) {
        			_sumar_columna(yytext[i]);
    			}
			insertarSemicolon = 1;
			return _buscar_insertar_identificador(yytext);
		}
{imaginary_lit} {
			// Para cada caracter de la expresión
			for (i = 0; yytext[i] != '\0'; i++) {
        			_sumar_columna(yytext[i]);
    			}
			insertarSemicolon = 1; 
			return IMAGINARY; 
		}
{int_lit}       { 
			// Para cada caracter de la expresión
			for (i = 0; yytext[i] != '\0'; i++) {
        			_sumar_columna(yytext[i]);
    			}
			insertarSemicolon = 1;
			return INT;
		}
{float_lit}     {
			// Para cada caracter de la expresión
			for (i = 0; yytext[i] != '\0'; i++) {
        			_sumar_columna(yytext[i]);
    			}
			insertarSemicolon = 1; 
			return FLOAT; 
		}
{string_lit}   	{ 
			// Para cada caracter de la expresión
			for (i = 0; yytext[i] != '\0'; i++) {
        			_sumar_columna(yytext[i]);
    			}
			insertarSemicolon = 1;
			return STRING;
		}
		
		
"<<="   {
		// Para cada caracter de la expresión
		for (i = 0; yytext[i] != '\0'; i++) {
        		_sumar_columna(yytext[i]);
    		}
		insertarSemicolon = 0;
		return MENORDOBLEIGUAL;
	}
">>="	{
		// Para cada caracter de la expresión
		for (i = 0; yytext[i] != '\0'; i++) {
        		_sumar_columna(yytext[i]);
    		}
		insertarSemicolon = 0;
		return MAYORDOBLEIGUAL;
	}
"&^="   {
		// Para cada caracter de la expresión
		for (i = 0; yytext[i] != '\0'; i++) {
        		_sumar_columna(yytext[i]);
    		}
		insertarSemicolon = 0;
		return AMPERSANDCIRCUNFLEJOIGUAL;
	}
"..."   { 
		// Para cada caracter de la expresión
		for (i = 0; yytext[i] != '\0'; i++) {
        		_sumar_columna(yytext[i]);
    		}
		insertarSemicolon = 0;
		return TRESPUNTOS;
	}

"<<"    {
		// Para cada caracter de la expresión
		for (i = 0; yytext[i] != '\0'; i++) {
        		_sumar_columna(yytext[i]);
    		}
		insertarSemicolon = 0;
		return MENORDOBLE;
	}
">>"    { 
		// Para cada caracter de la expresión
		for (i = 0; yytext[i] != '\0'; i++) {
        		_sumar_columna(yytext[i]);
    		}
		insertarSemicolon = 0;
		return MAYORDOBLE;
	}
"&^"    {
		// Para cada caracter de la expresión
		for (i = 0; yytext[i] != '\0'; i++) {
        		_sumar_columna(yytext[i]);
    		}
		insertarSemicolon = 0;
		return AMPERSANDCIRCUNFLEJO;
	}
"+="	{
		// Para cada caracter de la expresión
		for (i = 0; yytext[i] != '\0'; i++) {
        		_sumar_columna(yytext[i]);
    		}
		insertarSemicolon = 0;
		return MASIGUAL;
	}
"-="	{
		// Para cada caracter de la expresión
		for (i = 0; yytext[i] != '\0'; i++) {
        		_sumar_columna(yytext[i]);
    		}
		insertarSemicolon = 0;
		return MENOSIGUAL;
	}
"*="	{
		// Para cada caracter de la expresión
		for (i = 0; yytext[i] != '\0'; i++) {
        		_sumar_columna(yytext[i]);
    		}
		insertarSemicolon = 0;
		return PORIGUAL;
	}
"/="	{
		// Para cada caracter de la expresión
		for (i = 0; yytext[i] != '\0'; i++) {
        		_sumar_columna(yytext[i]);
    		}
		insertarSemicolon = 0;
		return BARRAIGUAL;
	}
"%="	{
		// Para cada caracter de la expresión
		for (i = 0; yytext[i] != '\0'; i++) {
        		_sumar_columna(yytext[i]);
    		}
		insertarSemicolon = 0;
		return PORCENTAJEIGUAL;
	}
"&="	{
		// Para cada caracter de la expresión
		for (i = 0; yytext[i] != '\0'; i++) {
        		_sumar_columna(yytext[i]);
    		}
		insertarSemicolon = 0;
		return AMPERSANDIGUAL;
	}
"|="	{
		// Para cada caracter de la expresión
		for (i = 0; yytext[i] != '\0'; i++) {
        		_sumar_columna(yytext[i]);
    		}
		insertarSemicolon = 0;
		return BARRAVERTICALIGUAL;
	}
"^="	{
		// Para cada caracter de la expresión
		for (i = 0; yytext[i] != '\0'; i++) {
        		_sumar_columna(yytext[i]);
    		}
		insertarSemicolon = 0;
		return CIRCUNFLEJOIGUAL;
	}
"&&"	{
		// Para cada caracter de la expresión
		for (i = 0; yytext[i] != '\0'; i++) {
        		_sumar_columna(yytext[i]);
    		}
		insertarSemicolon = 0;
		return AMPERSANDDOBLE;
	}
"||"	{
		// Para cada caracter de la expresión
		for (i = 0; yytext[i] != '\0'; i++) {
        		_sumar_columna(yytext[i]);
    		}
		insertarSemicolon = 0;
		return BARRAVERTICALDOBLE;
	}
"<-"	{
		// Para cada caracter de la expresión
		for (i = 0; yytext[i] != '\0'; i++) {
        		_sumar_columna(yytext[i]);
    		}
		insertarSemicolon = 0;
		return MENORMENOS;
	}
"++"    {
		// Para cada caracter de la expresión
		for (i = 0; yytext[i] != '\0'; i++) {
        		_sumar_columna(yytext[i]);
    		}
		insertarSemicolon = 0;
		return MASDOBLE;
	}
"--"    {
		// Para cada caracter de la expresión
		for (i = 0; yytext[i] != '\0'; i++) {
        		_sumar_columna(yytext[i]);
    		}
		insertarSemicolon = 0;
		return MENOSDOBLE;
	}
"=="    {
		// Para cada caracter de la expresión
		for (i = 0; yytext[i] != '\0'; i++) {
        		_sumar_columna(yytext[i]);
    		}
		insertarSemicolon = 0;
		return IGUALDOBLE;
	}
"!="    { 
		// Para cada caracter de la expresión
		for (i = 0; yytext[i] != '\0'; i++) {
        		_sumar_columna(yytext[i]);
    		}
		insertarSemicolon = 0;
		return EXCLAMACIONIGUAL;
	}
"<="    {
		// Para cada caracter de la expresión
		for (i = 0; yytext[i] != '\0'; i++) {
        		_sumar_columna(yytext[i]);
    		}
		insertarSemicolon = 0;
		return MENORIGUAL;
	}
">="    {
		// Para cada caracter de la expresión
		for (i = 0; yytext[i] != '\0'; i++) {
        		_sumar_columna(yytext[i]);
    		}
		insertarSemicolon = 0;
		return MAYORIGUAL;
	}
":="    {
		// Para cada caracter de la expresión
		for (i = 0; yytext[i] != '\0'; i++) {
        		_sumar_columna(yytext[i]);
    		}
		insertarSemicolon = 0;
		return DOSPUNTOSIGUAL;
	}

"+"     {
		_sumar_columna(yytext[0]);
		insertarSemicolon = 0;
		return (int) '+';
	}
"-"     {
		_sumar_columna(yytext[0]);
		insertarSemicolon = 0;
		return (int) '-';
	}
"*"     {
		_sumar_columna(yytext[0]);
		insertarSemicolon = 0;
		return (int) '*';
	}
"/"	{
		_sumar_columna(yytext[0]);
		insertarSemicolon = 0;
		return (int) '/';
	}
"%"     {
		_sumar_columna(yytext[0]);
		insertarSemicolon = 0;
		return (int) '%';
	}
"&"     { 
		_sumar_columna(yytext[0]);
		insertarSemicolon = 0;
		return (int) '&';
	}
"|"     {
		_sumar_columna(yytext[0]);
		insertarSemicolon = 0;
		return (int) '|';
	}
"^"     {
		_sumar_columna(yytext[0]);
		insertarSemicolon = 0; 
		return (int) '^';
	}
"<"     {
		_sumar_columna(yytext[0]);
		insertarSemicolon = 0;
		return (int) '<';
	}
">"     {
		_sumar_columna(yytext[0]);
		insertarSemicolon = 0; 
		return (int) '>';
	}
"="     {
		_sumar_columna(yytext[0]);
		insertarSemicolon = 0; 
		return (int) '='; 
	}
"!"     {
		_sumar_columna(yytext[0]);
		insertarSemicolon = 0; 
		return (int) '!'; 
	}
"~"     {
		_sumar_columna(yytext[0]);
		insertarSemicolon = 0; 
		return (int) '~'; 
	}
"."	{
		_sumar_columna(yytext[0]);
		insertarSemicolon = 0;
		return (int) '.';
	}
":"     {
		_sumar_columna(yytext[0]);
		insertarSemicolon = 0; 
		return (int) ':'; 
	}
","     {
		_sumar_columna(yytext[0]);
		insertarSemicolon = 0; 
		return (int) ','; 
	}
";"     {
		_sumar_columna(yytext[0]);
		insertarSemicolon = 0; 
		return (int) ';'; 
	}
"("     {
		_sumar_columna(yytext[0]);
		insertarSemicolon = 0; 
		return (int) '('; 
	}
")"     { 
		_sumar_columna(yytext[0]);
		insertarSemicolon = 1;
		return (int) ')';
	}
"["     { 
		_sumar_columna(yytext[0]);
		insertarSemicolon = 0; 
		return (int) '['; 
	}
"]"     { 
		_sumar_columna(yytext[0]);
		insertarSemicolon = 1;
		return (int) ']';
	}
"{"     { 
		_sumar_columna(yytext[0]);
		insertarSemicolon = 0; 
		return (int) '{'; 
	}
"}"     { 
		_sumar_columna(yytext[0]);
		insertarSemicolon = 1;
		return (int) '}';
	}

\n	{
		_sumar_columna(yytext[0]);
		if (insertarSemicolon == 1) {
                	// Si hay que insertar semicolon
                	_devolverSemicolon();
                	return (int) ';' ;
                	;
                }
	}

[ \t]+  {
		_sumar_columna(yytext[0]);
        	;  /* Ignorar espacios y tabulados */
	}

<<EOF>>	{
		_sumar_columna(yytext[0]);
		if (insertarSemicolon == 1) {
                	// Si hay que insertar semicolon
                	_devolverSemicolon();
                	return (int) ';' ;
                } else {
                	// En otro caso, devolvemos el último componente léxico
            		end[0] = 'E';
            		end[1] = '0';
            		end[2] = 'F';
            		end[3] = '\0';
            		yytext = end;
            		return FINFICHERO;
                }
        }

.                     { printf(RED "UNKNOWN: %s\n" RESET, yytext); }

%%

int yywrap() {
    return 1;
}

/* Código adicional después de la sección de reglas */
void liberar_recursos() {
    yy_delete_buffer(YY_CURRENT_BUFFER);
    yylex_destroy();
}

