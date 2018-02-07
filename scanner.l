/*
 * Lexer definition for simplified Python syntax.
 */

/*
 * Since we're only parsing 1 file, we don't need to have yywrap() (plus,
 * having it included messes up compilation).
 */
%option noyywrap

%option yylineno

%{
#include <iostream>
#include <stack>
#include <cstdlib>

/*
 * We'll use this stack to keep track of indentation level, as described in
 * the Python docs:
 *
 * https://docs.python.org/3/reference/lexical_analysis.html#indentation
 */
std::stack<int> _indent_stack;
%}

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
                std::cout << "INDENT" << std::endl;
                _indent_stack.push(yyleng);
              } else {
                /*
                 * If the current indentation level is less than or equal to
                 * the previous indentation level, pop indentation levels off
                 * the stack until the top is equal to the current indentation
                 * level.  Emit a DEDENT for each element popped from the stack.
                 */
                while (!_indent_stack.empty() && _indent_stack.top() != yyleng) {
                  _indent_stack.pop();
                  std::cout << "DEDENT" << std::endl;
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
                std::cout << "DEDENT" << std::endl;
              }
              REJECT;
            }

\r?\n       {
              std::cout << "NEWLINE" << std::endl;
            }

<<EOF>>     {
              /*
               * If we reach the end of the file, pop all indentation levels
               * off the stack, and emit a DEDENT for each one.
               */
              while(_indent_stack.top() != 0) {
                _indent_stack.pop();
                std::cout << "DEDENT" << std::endl;
              }
              yyterminate();
            }

[ \t]       { /* Ignore spaces that haven't been handled above. */ }

"and"       { std::cout << "AND\t\t" << yytext << std::endl; }
"break"     { std::cout << "BREAK\t\t" << yytext << std::endl; }
"def"       { std::cout << "DEF\t\t" << yytext << std::endl; }
"elif"      { std::cout << "ELIF\t\t" << yytext << std::endl; }
"else"      { std::cout << "ELSE\t\t" << yytext << std::endl; }
"for"       { std::cout << "FOR\t\t" << yytext << std::endl; }
"if"        { std::cout << "IF\t\t" << yytext << std::endl; }
"not"       { std::cout << "NOT\t\t" << yytext << std::endl; }
"or"        { std::cout << "OR\t\t" << yytext << std::endl; }
"return"    { std::cout << "RETURN\t\t" << yytext << std::endl; }
"while"     { std::cout << "WHILE\t\t" << yytext << std::endl; }

"True"      { std::cout << "BOOLEAN\t\t" << true << std::endl; }
"False"     { std::cout << "BOOLEAN\t\t" << false << std::endl; }

[a-zA-Z_][a-zA-Z0-9_]*  {
                          std::cout << "IDENTIFIER\t" << yytext << std::endl;
                        }

-?[0-9]*"."[0-9]+       {
                          std::cout << "FLOAT\t\t" << atof(yytext) << std::endl;
                        }

-?[0-9]+    {
              std::cout << "INTEGER\t\t" << atoi(yytext) << std::endl;
            }

"="         { std::cout << "ASSIGN\t\t" << yytext << std::endl; }
"+"         { std::cout << "PLUS\t\t" << yytext << std::endl; }
"-"         { std::cout << "MINUS\t\t" << yytext << std::endl; }
"*"         { std::cout << "TIMES\t\t" << yytext << std::endl; }
"/"         { std::cout << "DIVIDEDBY\t" << yytext << std::endl; }

"=="        { std::cout << "EQ\t\t" << yytext << std::endl; }
"!="        { std::cout << "NEQ\t\t" << yytext << std::endl; }
">"         { std::cout << "GT\t\t" << yytext << std::endl; }
">="        { std::cout << "GTE\t\t" << yytext << std::endl; }
"<"         { std::cout << "LT\t\t" << yytext << std::endl; }
"<="        { std::cout << "LTE\t\t" << yytext << std::endl; }

"("         { std::cout << "LPAREN\t\t" << yytext << std::endl; }
")"         { std::cout << "RPAREN\t\t" << yytext << std::endl; }

","         { std::cout << "COMMA\t\t" << yytext << std::endl; }
":"         { std::cout << "COLON\t\t" << yytext << std::endl; }

.           {
              std::cerr << "Unrecognized token on line " << yylineno << ": "
                << yytext << std::endl;
              return 1;
            }

%%
