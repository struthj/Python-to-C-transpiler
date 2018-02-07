all: scan

scan: main.cpp scanner.cpp
	g++ main.cpp scanner.cpp -o scan

scanner.cpp: scanner.l
	flex -o scanner.cpp scanner.l

clean:
	rm -f scan scanner.cpp
