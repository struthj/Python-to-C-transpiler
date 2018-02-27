#!/bin/bash
./parser-push < ./testing_code/p1.py > p1.cpp
./parser-push < ./testing_code/p2.py > p2.cpp
./parser-push < ./testing_code/p3.py > p3.cpp

echo  "-----  Parsing ------"
echo ""
echo "./parser-push < ./testing_code/p1.py > p1.cpp" 
echo "./parser-push < ./testing_code/p2.py > p2.cpp"
echo "./parser-push < ./testing_code/p3.py > p3.cpp"


g++ p1.cpp -o p1
g++ p2.cpp -o p2
g++ p3.cpp -o p3

echo "----- Compiling ------"
echo ""
echo "g++ p1.cpp -o p1"
echo "g++ p2.cpp -o p2"
echo "g++ p3.cpp -o p3"

echo "------ Running -------"
echo ""
echo "./p1"
./p1
echo "./p2"
./p2
echo "./p3"
./p3



echo "------ Parsing error files ------ "
echo ""
echo "./parser-push < ./testing_code/error1.py"
./parser-push < ./testing_code/error1.py

echo "./parser-push < ./testing_code/error2.py"
./parser-push < ./testing_code/error2.py

echo "./parser-push < ./testing_code/error3.py"
./parser-push < ./testing_code/error3.py

