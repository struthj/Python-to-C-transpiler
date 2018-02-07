#include <iostream>
int main() {
double f;
double f0;
double f1;
double fi;
double i;
double n;

/* Begin program */

n = 6;
f0 = 0;
f1 = 1;
i = 0;
while (true) {
fi = f0 + f1;
f0 = f1;
f1 = fi;
i = i + 1;
if (i >= n) {
break;
}
}
f = f0;

/* End program */

std::cout << "f: " << f << std::endl;
std::cout << "f0: " << f0 << std::endl;
std::cout << "f1: " << f1 << std::endl;
std::cout << "fi: " << fi << std::endl;
std::cout << "i: " << i << std::endl;
std::cout << "n: " << n << std::endl;
}
