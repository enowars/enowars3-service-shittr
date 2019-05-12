all: run

run:
	socat TCP4-LISTEN:8080,fork,reuseaddr EXEC:./bash0r