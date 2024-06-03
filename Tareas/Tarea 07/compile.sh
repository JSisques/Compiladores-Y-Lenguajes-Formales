# COMPILADOR PARA MACOS
# Compilar flex
flex src/lexer.l;
mv lex.yy.c src/lex.yy.c;

# Compilar bison
bison -d src/parser.y; 
mv parser.tab.c src/parser.tab.c;
mv parser.tab.h src/parser.tab.h;

# Generar el archivo exe
gcc -o main src/lex.yy.c src/parser.tab.c -I /usr/local/opt/flex/include -L /usr/local/opt/flex/lib -lfl -lxml2