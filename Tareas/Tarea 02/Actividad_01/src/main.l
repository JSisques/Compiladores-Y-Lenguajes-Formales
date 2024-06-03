%{
#include <stdio.h>
#include <stdlib.h>

int line_number = 1;
void report_error(const char *msg);

%}

%option noyywrap

%%
(<([^\/>]+)[\/]*>)  { printf("TOKEN TAG %s LINE %d\n", yytext, line_number); }
(<\/.*?>)           { printf("TOKEN END TAG %s LINE %d\n", yytext, line_number); }
[^<>\n]+            { printf("TOKEN CONTENT %s LINE %d\n", yytext, line_number); }
\n                  { line_number++; }
[ \t]+              /* Ignorar espacios y tabulaciones */
.                   { /* Ignorar otros caracteres */ }

%%

void report_error(const char *msg) {
    fprintf(stderr, "Error: %s at line %d\n", msg, line_number);
    exit(1);
}

int main(int argc, char **argv) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <inputfile>\n", argv[0]);
        exit(1);
    }

    FILE *input_file = fopen(argv[1], "r");
    if (!input_file) {
        perror("fopen");
        exit(1);
    }

    yyin = input_file;
    yylex();
    fclose(input_file);

    return 0;
}