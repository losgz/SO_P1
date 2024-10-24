#include <stdio.h>

void cumSum(int a[], int b[], int arraySize) {
    int c = 0;
    for (int i=0; i< arraySize; i++) {
        c += a[i];
        b[i] = c;
    };
}

void printArray(char s[], int a[], int arraySize){
    printf("%s\n", s);
    for (int i=0; i< arraySize; i++) {
        printf("%d ", a[i]);
    }
    printf("\n");
}

int main(void){

    int a[] = {31,28,31,30,31,30,31,31,30,31,30,31};
    int arraySize = sizeof(a) / sizeof(a[0]);
    printArray("a", a, arraySize);
    int b[12];
    cumSum(a, b, arraySize);
    printArray("b", b, arraySize);



    return 0;
}
