%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libxml/parser.h>
#include <libxml/xmlschemas.h>

extern int yylex(void);
void yyerror(const char *s);
int validate_xml(const char *xml_path, const char *xsd_path);
FILE *yyin;
%}

%union {
    char *str;
}

%token <str> ELEMENT_START ELEMENT_END ATTRIBUTE VALUE

%%

document:
    element
    ;

element:
    ELEMENT_START attributes ELEMENT_END element_content ELEMENT_START ELEMENT_END
    {
        printf("Parsed element: %s\n", $1);
    }
    ;

attributes:
    /* empty */
    | attributes ATTRIBUTE '=' VALUE
    {
        printf("Parsed attribute: %s=%s\n", $2, $4);
    }
    ;

element_content:
    element
    | VALUE
    {
        printf("Parsed value: %s\n", $1);
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main(int argc, char **argv) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s <xmlfile> <xsdfile>\n", argv[0]);
        return 1;
    }

    // Validate the XML file against the XSD schema
    if (validate_xml(argv[1], argv[2]) != 0) {
        fprintf(stderr, "Validation failed.\n");
        return 1;
    }

    // Parse the XML file
    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror("fopen");
        return 1;
    }

    yyparse();
    fclose(yyin);

    return 0;
}

int validate_xml(const char *xml_path, const char *xsd_path) {
    xmlDocPtr doc;
    xmlSchemaPtr schema = NULL;
    xmlSchemaParserCtxtPtr ctxt;
    xmlSchemaValidCtxtPtr valid_ctxt;
    int ret;

    xmlLineNumbersDefault(1);

    // Parse the XML schema
    ctxt = xmlSchemaNewParserCtxt(xsd_path);
    schema = xmlSchemaParse(ctxt);
    xmlSchemaFreeParserCtxt(ctxt);

    if (!schema) {
        fprintf(stderr, "Could not parse XSD schema.\n");
        return -1;
    }

    // Parse the XML document
    doc = xmlReadFile(xml_path, NULL, 0);
    if (!doc) {
        fprintf(stderr, "Could not parse XML document.\n");
        xmlSchemaFree(schema);
        return -1;
    }

    // Create a validation context and validate the document
    valid_ctxt = xmlSchemaNewValidCtxt(schema);
    ret = xmlSchemaValidateDoc(valid_ctxt, doc);
    if (ret == 0) {
        printf("XML is valid according to the schema.\n");
    } else if (ret > 0) {
        printf("XML is invalid according to the schema.\n");
    } else {
        printf("Validation generated an internal error.\n");
    }

    // Clean up
    xmlSchemaFreeValidCtxt(valid_ctxt);
    xmlFreeDoc(doc);
    xmlSchemaFree(schema);

    return (ret == 0) ? 0 : 1;
}
