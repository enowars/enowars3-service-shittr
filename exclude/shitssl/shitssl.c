#include<stdio.h>
#include<string.h>
#include<unistd.h>
int main(int argc, char **argv) {
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
    }
    printf("%s", buf);
}