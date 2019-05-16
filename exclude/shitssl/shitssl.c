#include<stdio.h>
#include<string.h>
#include<unistd.h>

int main(int argc, char **argv) {

    char key[512];
    char buf[2048];

    for(int i=0; i<argc;i++) {
        if(strlen(argv[i]) < 16)
            continue;
        strcpy(key, argv[i]);
        break;
    }

    read(STDIN_FILENO, buf, sizeof buf);

    for(int i=0; i<strlen(buf);i++){
        buf[i] = buf[i] ^ key[i%16];
    }
    printf("%s", buf);
}