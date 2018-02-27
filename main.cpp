#include <iostream>
#include <map>
#include <vector>
#include <algorithm>
extern int yylex();


extern std::vector<std::string> characters;
extern std::string* goalStr;
std::vector<std::string> identifiers;

int main(int argc, char const *argv[]) {

  //run yylex
   if (!yylex()) {
   //print headers
     std::cout<< "#include <iostream>" << std::endl;
     std::cout<< "int main(){\n" << std::endl;
   
     
    //print and initialize identifiers    
    for(std::vector<std::string>::reverse_iterator i = characters.rbegin(); i != characters.rend(); ++i) {
      //check for duplicate identifiers
      if (std::find(identifiers.begin(), identifiers.end(), *i) == identifiers.end()){
        identifiers.push_back(*i);
        std::cout << "double " + *i + ";" << std::endl;
      }
    }
   
   std::cout<< "\n/* Begin program */ \n" << std::endl;
 
   //print main code
   std::cout << *goalStr << std::endl;
   //ending comment
   std::cout<< "/* End program */ \n" << std::endl;
   
   //print identifier statements
   
      for(std::vector<std::string>::iterator i = identifiers.begin(); i != identifiers.end(); ++i) {
      std::cout << "std::cout << \"" + *i + ":\" << " + *i + " << std::endl;" << std::endl;
    }
    std::cout << "}" << std::endl;
    return 0;
  } else {
    return 1;
  }
}