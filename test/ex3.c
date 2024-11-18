#include <stdio.h>

void Permute(int* a, int* b, int* c){
   int t = *a;
   *a = *c;
   *c = *b;
   *b = t;
}

int main(void){
    int a = 12;
    int b = 3;
    int c = 4;
    printf("%d%d%d\n", a, b, c);
    Permute(&a,&b,&c);
    printf("%d%d%d\n", a, b, c);
    Permute(&a,&b,&c);
    printf("%d%d%d\n", a, b, c);
}
