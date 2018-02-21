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

%token <str> IDENTIFIER NEWLINE
%token <value> FLOAT
%token <value> INTEGER
%token <token> EQUALS PLUS MINUS TIMES DIVIDEDBY
%token <token> SEMICOLON LPAREN RPAREN

%type <value> expression

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
  : IDENTIFIER EQUALS expression NEWLINE { symbols[*$1] = $3; delete $1; }
  ;

expression
  : LPAREN expression RPAREN { $$ = $2;  }
  | expression PLUS expression { $$ = $1 + $3; }
  | expression MINUS expression { $$ = $1 - $3; }
  | expression TIMES expression { $$ = $1 * $3; }
  | expression DIVIDEDBY expression { $$ = $1 / $3; }
  | INTEGER { $$ = $1; }
  | FLOAT { $$ = $1; }
  | IDENTIFIER { $$ = symbols[*$1]; delete $1; }
  ;

%%

void yyerror(YYLTYPE* loc, const char* err) {
  std::cerr << "Error: " << err << std::endl;

}