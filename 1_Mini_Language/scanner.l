%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <ctype.h>

    int line = 1;        
    int column = 0;      
    FILE *pifFile;
    FILE *stFile;

    typedef struct {
        char symbol[100];
        int address;
    } SymbolTable;

    typedef struct {
        char token[100];
        int line;
        int column;
    } ProgramInternalForm;

    SymbolTable symbolTable[1000];
    int stIndex = 0;

    ProgramInternalForm pif[1000];
    int pifIndex = 0;

    // Function to add a symbol to the Symbol Table
    int addToSymbolTable(char *symbol) {
        for (int i = 0; i < stIndex; i++) {
            if (strcmp(symbolTable[i].symbol, symbol) == 0) {
                return i;
            }
        }
        strcpy(symbolTable[stIndex].symbol, symbol);
        symbolTable[stIndex].address = stIndex;
        return stIndex++;
    }

    // Function to add a token to the Program Internal Form
    void addToPIF(char *token, int line, int column) {
        strcpy(pif[pifIndex].token, token);
        pif[pifIndex].line = line;
        pif[pifIndex].column = column;
        pifIndex++;
    }

    // Print Symbol Table to file
    void printSymbolTable() {
        stFile = fopen("symbol_table.txt", "w");
        for (int i = 0; i < stIndex; i++) {
            fprintf(stFile, "Symbol: %s, Address: %d\n", symbolTable[i].symbol, symbolTable[i].address);
        }
        fclose(stFile);
    }

    // Print Program Internal Form to file
    void printPIF() {
        pifFile = fopen("pif.txt", "w");
        for (int i = 0; i < pifIndex; i++) {
            fprintf(pifFile, "Token: %s, Line: %d, Column: %d\n", pif[i].token, pif[i].line, pif[i].column);
        }
        fclose(pifFile);
    }
%}

%option noyywrap

/* Regular Expressions */
DIGIT       [0-9]
LETTER      [a-zA-Z_]
IDENTIFIER  {LETTER}({LETTER}|{DIGIT})*
NUMBER      {DIGIT}+
WHITESPACE  [ \t]+

/* Keywords, Operators, Separators */
%%
"def"           { addToPIF("DEF", line, column); column += yyleng; }
"if"            { addToPIF("IF", line, column); column += yyleng; }
"else"          { addToPIF("ELSE", line, column); column += yyleng; }
"while"         { addToPIF("WHILE", line, column); column += yyleng; }
"print"         { addToPIF("PRINT", line, column); column += yyleng; }
"input"         { addToPIF("INPUT", line, column); column += yyleng; }
"return"        { addToPIF("RETURN", line, column); column += yyleng; }
"struct"        { addToPIF("STRUCT", line, column); column += yyleng; }

"+"             { addToPIF("PLUS", line, column); column += yyleng; }
"-"             { addToPIF("MINUS", line, column); column += yyleng; }
"*"             { addToPIF("MULT", line, column); column += yyleng; }
"/"             { addToPIF("DIV", line, column); column += yyleng; }
"="             { addToPIF("ASSIGN", line, column); column += yyleng; }
"=="            { addToPIF("EQ", line, column); column += yyleng; }
"<"             { addToPIF("LT", line, column); column += yyleng; }
"<="            { addToPIF("LE", line, column); column += yyleng; }
">"             { addToPIF("GT", line, column); column += yyleng; }
">="            { addToPIF("GE", line, column); column += yyleng; }

"("             { addToPIF("LPAREN", line, column); column += yyleng; }
")"             { addToPIF("RPAREN", line, column); column += yyleng; }
"{"             { addToPIF("LBRACE", line, column); column += yyleng; }
"}"             { addToPIF("RBRACE", line, column); column += yyleng; }
";"             { addToPIF("SEMICOLON", line, column); column += yyleng; }
":"             { addToPIF("COLON", line, column); column += yyleng; }
","             { addToPIF("COMMA", line, column); column += yyleng; }

{NUMBER}        {
                    int pos = addToSymbolTable(yytext);
                    addToPIF("NUMBER", line, column);
                    column += yyleng;
                }

{IDENTIFIER}    {
		    printf("Found identifier: %s at line %d, column %d\n", yytext, yylineno, column);
                    int pos = addToSymbolTable(yytext);
                    addToPIF("IDENTIFIER", line, column);
                    column += yyleng;
                }

\n              { line++; column = 0; }
{WHITESPACE}    { column += yyleng; } 

.               { fprintf(stderr, "Lexical error at line %d, column %d: Unexpected character '%s'\n", line, column, yytext); column += yyleng; }

%%
