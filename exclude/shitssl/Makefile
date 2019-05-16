all: compile

compile:
	gcc  shitssl.c -z execstack -O0 -o shitssl -static -fno-stack-protector -no-pie
	mkdir -p ../../service/ro/bin
	cp shitssl ../../service/ro/bin/openssl
