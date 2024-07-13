.PHONY: clean

all: rxmsal-go rxmsal-c

rxmsal-go: rxmsal-go.go
	go build -o $@

rxmsal-c: rxmsal-c.c
	$(CC) -Wall -Wextra -pedantic -o $@ $< $(shell pkg-config --cflags --libs json-c) $(shell pkg-config --cflags --libs libcurl) $(shell pkg-config --cflags --libs openssl)

clean:
	rm -fv rxmsal-c rxmsal-go
