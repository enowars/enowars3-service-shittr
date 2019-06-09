#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <alloca.h>

long xd(void* ptr, int argc, char** argv) {
    long x;
    memcpy(&x, ptr, 8);
    long (*xor_x)(int, char**) = (long (*)(int, char**)) x;
    xor_x(argc, argv);
}

int xor(int argc, char** argv) {
    char key[512]; 
    char buf[2048];
    char c[1];
    
    int i;
    for(i=0; i<argc;i++) {
        if(strlen(argv[i]) < 16)
            continue;
        strcpy(key, argv[i]);
        break;
    }
    for(i=0; read(STDIN_FILENO, c, sizeof c); i++) {
        buf[i] = c[0] ^ key[i%16];
        fwrite(&buf[i], sizeof(char), 1, stdout);
    }
}

int main(int argc, char **argv) {
    char key[512]; 
    char buf[2048];
    char c[1];
    
    void** ptr = malloc(8);
    long (*xor_ptr)(int, char**) = (long (*)(int, char**)) xor;
    memcpy(ptr, &xor_ptr, 8);
    void* code = alloca(256);
    long (*func_ptr)(void*, int, char**) = (long (*)(void*, int, char**)) code;
    memcpy(code, xd, 255);
    func_ptr(ptr, argc, argv);

    return 0;

}