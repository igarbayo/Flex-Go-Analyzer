# Nombre del ejecutable
TARGET = P2_Flex

# Compilador
CC = gcc

# Flags de compilación
CFLAGS = -Wall -Wextra -g

# Archivos fuente y headers
SRCS = main.c avl.c analisis_lexico.c analisis_sintactico.c tabla_simbolos.c errores.c go.yy.c
HEADERS = definiciones.h avl.h analisis_lexico.h analisis_sintactico.h tabla_simbolos.h errores.h

# Objetos generados
OBJS = $(SRCS:.c=.o)

# Regla principal
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJS)

# Regla para compilar archivos .c a .o
%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) -c $< -o $@

# Regla para generar go.yy.c con Flex
go.yy.c: go.l
	flex -o go.yy.c go.l

# Limpiar archivos compilados
clean:
	rm -f $(OBJS) $(TARGET)

# Limpiar todo incluyendo archivos de depuración
cleanall: clean
	rm -f *~

