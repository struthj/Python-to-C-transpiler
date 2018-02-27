all: parser-push

parser-push.cpp parser-push.hpp: parser.y
	bison -d -o parser-push.cpp parser.y --report=state

scanner-push.cpp: scanner.l
	flex -o scanner-push.cpp scanner.l

parser-push: main.cpp parser-push.cpp scanner-push.cpp
	g++ -std=c++11 -ggdb3  main.cpp parser-push.cpp scanner-push.cpp -o parser-push


clean:
	rm -f parser.cpp parser-push scanner-push.cpp parser-push.cpp p1 p2 p3 p1.cpp p2.cpp p3.cpp

