all: parser-push

parser-push.cpp parser-push.hpp: parser.y
	bison -d -o parser-push.cpp parser.y

scanner-push.cpp: scanner.l
	flex -o scanner-push.cpp scanner.l

parser-push: main.cpp parser-push.cpp scanner-push.cpp
	g++ main.cpp parser-push.cpp scanner-push.cpp -o parser-push


clean:
	rm -f parser.cpp parser-push scanner-push.cpp parser-push.cpp
