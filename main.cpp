#include <iostream>
#include <map>

extern int yylex();

extern std::map<std::string, float> symbols;

int main(int argc, char const *argv[]) {
  if (!yylex()) {
    std::map<std::string, float>::iterator it;
    for (it = symbols.begin(); it != symbols.end(); it++) {
      std::cout << it->first << ":\t" << it->second << std::endl;
    }
    return 0;
  } else {
    return 1;
  }
}