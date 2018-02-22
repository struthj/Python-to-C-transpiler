%{
#include <iostream>
#include <map>

#include "parser-push.hpp"

std::map<std::string, float> symbols;

void yyerror(YYLTYPE* loc, const char* err);
extern int yylex();
%}

%union {
  float value;
  std::string* str;
  int token;
}

/* %define api.value.type { std::string* } */

%locations

%define api.pure full
%define api.push-pull push

%token <str> IDENTIFIER
%token <value> FLOAT
%token <value> INTEGER BOOLEAN
%token <token> EQUALS PLUS MINUS TIMES DIVIDEDBY NEWLINE 
%token <token> EQ NEQ GT GTE LT LTE 
%token <token> INDENT DEDENT
%token <token> AND BREAK DEF ELIF ELSE FOR IF NOT OR RETURN WHILE
%token <token> SEMICOLON LPAREN RPAREN COLON COMMA

%type <value> expression
%type <value> conditional conditionalExpr ifelse
%type <value> flowcontrol

%left PLUS MINUS
%left TIMES DIVIDEDBY
/* %right */
/* %nonassoc */
/* %precedence */

%start program

%%

program
  : program statement
  | statement
  ;

statement
  : conditional NEWLINE 
  | DEDENT conditional NEWLINE
  | INDENT statement
  | INDENT flowcontrol NEWLINE
  | DEDENT
  | IDENTIFIER EQUALS expression NEWLINE { symbols[*$1] = $3; delete $1; }
  ; 

expression
  : LPAREN expression RPAREN { $$ = $2;  }
  | expression PLUS expression { $$ = $1 + $3; }
  | expression MINUS expression { $$ = $1 - $3; }
  | expression TIMES expression { $$ = $1 * $3; }
  | expression DIVIDEDBY expression { $$ = $1 / $3; }
  | INTEGER { $$ = $1; }
  | FLOAT { $$ = $1; }
  | BOOLEAN { $$ = $1; }
  | IDENTIFIER { $$ = symbols[*$1]; delete $1; }
  ;

conditionalExpr
  : conditionalExpr LT conditionalExpr { $$ = $1 < $3; }
  | conditionalExpr GT conditionalExpr { $$ = $1 > $3; }
  | conditionalExpr LTE conditionalExpr { $$ = $1 <= $3; }
  | conditionalExpr GTE conditionalExpr { $$ = $1 >= $3; }
  | conditionalExpr NEQ conditionalExpr { $$ = $1 != $3; }
  | conditionalExpr EQ conditionalExpr { $$ = $1 == $3; }
  | IDENTIFIER { $$ = symbols[*$1]; delete $1; }
  | INTEGER { $$ = $1; }
  | FLOAT { $$ = $1; }
  | BOOLEAN { $$ = $1; }
  ;

conditional
  : ifelse conditionalExpr COLON { $$ = $2;}
  | ifelse COLON {}
  | WHILE conditionalExpr COLON {}
  ;

ifelse
  : IF {}
  | ELSE {}
  ;

flowcontrol
  : BREAK {}
  | RETURN { }
  ;

%%

void yyerror(YYLTYPE* loc, const char* err) {
  std::cerr << "Error: " << err << std::endl;

}