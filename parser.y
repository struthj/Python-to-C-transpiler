%{
#include <iostream>
#include <map>
#include <vector>
#include <cstring>

#include "parser-push.hpp"

//std::map<std::string, float> symbols;
std::vector<std::string> characters;
//std::map<std::string, float> syntax;
std::string* goalStr;

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

%token <str> IDENTIFIER INTEGER BOOLEAN FLOAT
%token <token> EQUALS PLUS MINUS TIMES DIVIDEDBY
%token <token> EQ NEQ GT GTE LT LTE RETURN
%token <token> INDENT DEDENT NEWLINE IF COLON
%token <token> AND BREAK DEF ELIF ELSE FOR NOT OR WHILE
%token <token> SEMICOLON LPAREN RPAREN COMMA

%type <str> expression statement
%type <str> conditional conditionalExpr ifelse
%type <str> flowcontrol program

%left PLUS MINUS 
%left TIMES DIVIDEDBY
/* %right */
/* %nonassoc */

%start goal



%%

goal
  : program { }

program
  : program statement {$$ = new std::string(*$1 + *$2);
                      goalStr = new std::string(*$$);
                      delete $1; delete $2; 
                      //std::cout<< *$$ <<std::endl;
                       }
  | statement { $$ = new std::string(*$1); delete $1; //std::cout<< *$$ <<std::endl;
                      }
  ;

statement
  : conditional {$$ = new std::string(*$1); delete $1; }
  | DEDENT conditional statement DEDENT DEDENT { $$ = new std::string("} " + *$2 + "\n" + *$3 + "}\n}\n"); delete $2; delete $3;}
  | DEDENT { $$ = new std::string("}"); }
  | INDENT statement {$$ = new std::string(*$2); delete $2; }
  | INDENT statement INDENT statement { std::cerr << "Error:"<< "Indentation error"<< std::endl; delete $2; delete $4; }
  | INDENT flowcontrol NEWLINE DEDENT DEDENT { $$ = new std::string(*$2 + "; \n}\n}\n"); delete $2; }
  | IDENTIFIER EQUALS expression NEWLINE { $$ = new std::string(*$1 +" = "+ *$3 + "; \n");
                                          characters.push_back(*$1);
                                          //std::cout<< *$$ <<"HERE" << std::endl;
                                          delete $1; delete $3; 
                                          }
  ; 

expression
  : INTEGER { $$ = $1; }
  | FLOAT { $$ = $1; }
  | BOOLEAN { $$ = $1; }
  | IDENTIFIER { $$ = $1; }
  | LPAREN expression RPAREN {  $$ = new std::string("(" + *$2 + ")"); delete $2;}
  | expression PLUS expression { $$ =  new std::string(*$1 + " + " + *$3); delete $1; delete $3;} 
  | expression MINUS expression { $$ =  new std::string(*$1 + " - " + *$3); delete $1; delete $3;} 
  | expression TIMES expression { $$ =  new std::string(*$1 + " * " + *$3); delete $1; delete $3;} 
  | expression DIVIDEDBY expression { $$ =  new std::string(*$1 + " / " + *$3); delete $1; delete $3;}                                 
  ;

conditionalExpr
  : IDENTIFIER { $$ = $1; }
  | INTEGER { $$ = $1; }
  | FLOAT { $$ = $1; }
  | BOOLEAN { $$ = $1; }
  | conditionalExpr LT conditionalExpr { $$ = new std::string(*$1 + " < " + *$3);  delete $1; delete $3;}
  | conditionalExpr GT conditionalExpr { 
                                        $$ = new std::string(*$1 + " > " + *$3);
                                        delete $1; delete $3;
                                      }
  | conditionalExpr LTE conditionalExpr {  $$ = new std::string(*$1 + " <= " + *$3); delete $1; delete $3;}
  | conditionalExpr GTE conditionalExpr {  $$ = new std::string(*$1 + " >= " + *$3); delete $1; delete $3;}
  | conditionalExpr NEQ conditionalExpr {  $$ = new std::string(*$1 + " != " + *$3); delete $1; delete $3;}
  | conditionalExpr EQ conditionalExpr {  $$ = new std::string(*$1 + " == " + *$3); delete $1; delete $3;}
  ;

conditional
  : ifelse
  | WHILE conditionalExpr COLON NEWLINE { $$ = new std::string("while (" + *$2 + ") {\n"); delete $2;}
  ;

ifelse
  : IF conditionalExpr COLON NEWLINE {  $$ = new std::string("if(" + *$2 + ") {\n"); delete $2;
                                }
  | ELSE COLON NEWLINE { $$ = new std::string("else {"); };
  ;

flowcontrol
  : BREAK { $$ = new std::string("break"); }
  ;

%%

void yyerror(YYLTYPE* loc, const char* err) {
  std::cerr << "Error: " << err << std::endl;

}