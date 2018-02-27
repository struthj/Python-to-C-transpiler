#include <iostream>
int main(){

double y;
double z;
double x;
double b;
double a;

/* Begin program */ 

a = true; 
b = false; 
x = 7; 
if(a) {
x = 5; 
if(b) {
y = 4; 
} else {
y = 2; 
}
}
z = (x * 3 * 7) / y; 
if(z > 10) {
y = 5; 
}
/* End program */ 

std::cout << "y:" << y << std::endl;
std::cout << "z:" << z << std::endl;
std::cout << "x:" << x << std::endl;
std::cout << "b:" << b << std::endl;
std::cout << "a:" << a << std::endl;
}
