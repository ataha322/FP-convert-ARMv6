#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
int main(int argc, char **argv){
    // convert the input hex to a binary number
    if (argc != 3){
        fprintf(stderr, "usage: %s %s %s\n",
                argv[0], "<file of hex numbers>", "<output bin file>");
        exit(-1);
    }
    FILE *fin;
    FILE *fout;

    if ((fin = fopen(argv[1], "r")) == NULL){
        fprintf(stderr, "couldn't open file %s\n", argv[1]);
        exit(-1);
    }

    if ((fout = fopen(argv[2], "w")) == NULL){
        fprintf(stderr, "couldn't open file %s\n", argv[2]);
        exit(-1);
    }

    unsigned int uint;
    while(fscanf(fin, "%x%*[^\n]", &uint) > 0){
        printf("got %x\n", uint);
        fflush(stdout);
        uint16_t u14int = (uint16_t)uint;
        fwrite(&u14int, sizeof(uint16_t), 1, fout);
    }
    fclose(fin);
    fclose(fout);
}
