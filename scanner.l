/*
 * Lexer definition for simplified Python syntax.
 */

/*
 * Since we're only parsing 1 file, we don't need to have yywrap() (plus,
 * having it included messes up compilation).
 */


%{
#include <iostream>
#include <stack>
#include <cstdlib>
#include <string.h>
#include "parser-push.hpp"
YYSTYPE yylval;
YYLTYPE yylloc;

yypstate* pstate = yypstate_new();

#define PUSH_TOKEN(token) do {  \
  int s = yypush_parse(pstate, token, &yylval, &yylloc);  \
  if (s != YYPUSH_MORE) {                                 \
    yypstate_delete(pstate);                              \
    return s;                                             \
  }                                                       \
} while(0)


std::stack<int> _indent_stack;
%}

%option noyywrap

%option yylineno

%%

%{
  /*
   * These lines go at the top of the lexing function.  We only want to
   * initialize the indentation level stack once by pushing a 0 onto it (the
   * indentation stack should never be empty, except immediately after it is
   * created).
   */
  if (_indent_stack.empty()) {
    _indent_stack.push(0);
  }
%}

^[ \t]*\r?\n   { /* Skip blank lines */ }

^[ \t]*#.*\r?\n    { /* Skip whole-line comments. */ }

#.*$        { /* Skip comments on the same line as a statement. */ }

^[ \t]+     {
              /*
               * Handle indentation as described in Python docs linked above.
               * Note that this pattern treats leading spaces and leading tabs
               * equivalently, which could cause some unexpected behavior if
               * they're combined in a single line.  For the purposes of this
               * project, that's OK.
               */
              if (_indent_stack.top() < yyleng) {
                /*
                 * If the current indentation level is greater than the
                 * previous indentation level (stored at the top of the stack),
                 * then emit an INDENT and push the new indentation level onto
                 * the stack.
                 */
                //std::cout << "INDENT" << std::endl;
                _indent_stack.push(yyleng);
                PUSH_TOKEN((yylval.token = INDENT));
              } else {
                /*
                 * If the current indentation level is less than or equal to
                 * the previous indentation level, pop indentation levels off
                 * the stack until the top is equal to the current indentation
                 * level.  Emit a DEDENT for each element popped from the stack.
                 */
                while (!_indent_stack.empty() && _indent_stack.top() != yyleng) {
                  _indent_stack.pop();
                  //std::cout << "DEDENT" << std::endl;
                  PUSH_TOKEN((yylval.token = DEDENT));
                }

                /*
                 * If we popped everythin g off the stack, that means the
                 * current indentation level didn't match any on the stack,
                 * which is an indentation error.
                 */
                if (_indent_stack.empty()) {
                  std::cerr << "Error: Incorrect indentation on line "
                    << yylineno << std::endl;
                  return 1;
                  exit(1);
                }
              }
            }

^[^ \t\n]+  {
              /*
               * If we find a line that's not indented, pop all indentation
               * levels off the stack, and emit a DEDENT for each one.  Then,
               * call REJECT, so the next rule matching this token is also
               * applied.
               */
              while(_indent_stack.top() != 0) {
                _indent_stack.pop();
                //std::cout << "DEDENT" << std::endl;
                PUSH_TOKEN((yylval.token = DEDENT));
              }
              REJECT;
            }

\r?\n       {
                PUSH_TOKEN((yylval.token = NEWLINE)); 
                //std::cout << "NEWLINE" << std::endl;
            }

<<EOF>>     {
              /*
               * If we reach the end of the file, pop all indentation levels
               * off the stack, and emit a DEDENT for each one.
               */
              while(_indent_stack.top() != 0) {
                _indent_stack.pop();
                //std::cout << "DEDENT" << std::endl;
                PUSH_TOKEN((yylval.token = DEDENT));
              }

              int s = yypush_parse(pstate, 0, NULL, NULL);
                yypstate_delete(pstate);
                return s;
              //yyterminate();
            }

[ \t]       { /* Ignore spaces that haven't been handled above. */ }

"and"       {  PUSH_TOKEN((yylval.token = AND));
            //std::cout << "AND\t\t" << yytext << std::endl; 
            }

"break"     { PUSH_TOKEN((yylval.token = BREAK));
              //std::cout << "BREAK\t\t" << yytext << std::endl;
               }

"def"       { PUSH_TOKEN((yylval.token = DEF));
              //std::cout << "DEF\t\t" << yytext << std::endl;
               }

"elif"      { PUSH_TOKEN((yylval.token = ELIF));
              //std::cout << "ELIF\t\t" << yytext << std::endl;
               }

"else"      { PUSH_TOKEN((yylval.token = ELSE));
              //std::cout << "ELSE\t\t" << yytext << std::endl;
               }

"for"       { PUSH_TOKEN((yylval.token = FOR));
              //std::cout << "FOR\t\t" << yytext << std::endl;
               }

"if"        { PUSH_TOKEN((yylval.token = IF));
              //std::cout << "IF\t\t" << yytext << std::endl;
               }

"not"       { PUSH_TOKEN((yylval.token = NOT));
              //std::cout << "NOT\t\t" << yytext << std::endl;
               }

"or"        { PUSH_TOKEN((yylval.token = OR));
              //std::cout << "OR\t\t" << yytext << std::endl;
               }

"return"    { PUSH_TOKEN((yylval.token = RETURN));
              //std::cout << "RETURN\t\t" << yytext << std::endl;
               }

"while"     { PUSH_TOKEN((yylval.token = WHILE));
              //std::cout << "WHILE\t\t" << yytext << std::endl;
               }

"True"      { 
             yylval.str = new std::string("true", yyleng);
              PUSH_TOKEN(BOOLEAN);
              //std::cout << "BOOLEAN\t\t" << true << std::endl;
               }

"False"     { 
              yylval.str = new std::string("false", yyleng);
              PUSH_TOKEN(BOOLEAN);
              //std::cout << "BOOLEAN\t\t" << false << std::endl;
               }

[a-zA-Z_][a-zA-Z0-9_]*  {
                yylval.str = new std::string(yytext, yyleng);
                PUSH_TOKEN(IDENTIFIER);
                //std::cout << "IDENTIFIER\t\t" << yytext << std::endl; 
              }

-?[0-9]*"."[0-9]+   {
                     yylval.str = new std::string(yytext, yyleng);
                     PUSH_TOKEN(FLOAT);
                     //std::cout << "FLOAT\t\t" << atof(yytext) << std::endl; 
                   }

-?[0-9]+    {
                     yylval.str = new std::string(yytext, yyleng);
                     PUSH_TOKEN(INTEGER);
                     //std::cout << "INTEGER\t\t" << atoi(yytext) << std::endl; 
                   }

"="         { PUSH_TOKEN((yylval.token = EQUALS));
            //std::cout << "ASSIGN\t\t" << yytext << std::endl;
              } 

"+"         { PUSH_TOKEN((yylval.token = PLUS)); 
            //std::cout << "PLUS\t\t" << yytext << std::endl;
            }

"-"         {  PUSH_TOKEN((yylval.token = MINUS));
            //std::cout << "MINUS\t\t" << yytext << std::endl; 
            }

"*"         {  PUSH_TOKEN((yylval.token = TIMES));
            //std::cout << "TIMES\t\t" << yytext << std::endl;
             }

"/"         {  PUSH_TOKEN((yylval.token = DIVIDEDBY));
            //std::cout << "DIVIDEDBY\t" << yytext << std::endl;
             }

"=="        { PUSH_TOKEN((yylval.token = EQ));
            //std::cout << "EQ\t\t" << yytext << std::endl;
             }

"!="        { PUSH_TOKEN((yylval.token = NEQ));
            //std::cout << "NEQ\t\t" << yytext << std::endl;
             }

">"         { 
            PUSH_TOKEN((yylval.token = GT));
            //std::cout << "GT\t\t" << yytext << std::endl;
             }

">="        { PUSH_TOKEN((yylval.token = GTE));
            //std::cout << "GTE\t\t" << yytext << std::endl;
             }

"<"         { PUSH_TOKEN((yylval.token = LT));
            //std::cout << "LT\t\t" << yytext << std::endl;
             }

"<="        { PUSH_TOKEN((yylval.token = LTE));
            //std::cout << "LTE\t\t" << yytext << std::endl;
             }

"("         { PUSH_TOKEN((yylval.token = LPAREN));
            //std::cout << "LPAREN\t\t" << yytext << std::endl;
             }

")"         { PUSH_TOKEN((yylval.token = RPAREN));
            //std::cout << "RPAREN\t\t" << yytext << std::endl;
             }

","         {  PUSH_TOKEN((yylval.token = COMMA));
            //std::cout << "COMMA\t\t" << yytext << std::endl; 
            }

":"         { 
              PUSH_TOKEN((yylval.token = COLON));
              //std::cout << "COLON\t\t" << yytext << std::endl;
               }

.           {
              std::cerr << "Unrecognized token on line " << yylineno << ": "
                << yytext << std::endl;
              return 1;
            }

%%
