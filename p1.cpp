#include <iostream>
int main(){

double sphere_surf_area;
double sphere_vol;
double circle_circum;
double circle_area;
double r;
double pi;

/* Begin program */ 

pi = 3.1415; 
r = 8.0; 
circle_area = pi * r * r; 
circle_circum = pi * 2 * r; 
sphere_vol = (4.0 / 3.0) * pi * r * r * r; 
sphere_surf_area = 4 * pi * r * r; 

/* End program */ 

std::cout << "sphere_surf_area:" << sphere_surf_area << std::endl;
std::cout << "sphere_vol:" << sphere_vol << std::endl;
std::cout << "circle_circum:" << circle_circum << std::endl;
std::cout << "circle_area:" << circle_area << std::endl;
std::cout << "r:" << r << std::endl;
std::cout << "pi:" << pi << std::endl;
}
