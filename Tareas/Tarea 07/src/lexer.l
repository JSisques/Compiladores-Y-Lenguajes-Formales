%{
#include "parser.tab.h"
#include <stdio.h>
%}

%%

(<)                             { return ELEMENT_START; }
(>)                             { return ELEMENT_END; }
(=)                             { return '='; }
([a-zA-Z_:][a-zA-Z0-9_.:-])     { yylval.str = strdup(yytext); return ATTRIBUTE; }
(\"[^\"]*\")                    { yylval.str = strdup(yytext); return VALUE; }
([ \t\n]+)                      { /* skip whitespace */ }
.                               { /* ignore bad characters */ }

%%

int yywrap(void) {
    return 1;
}
