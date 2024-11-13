#include <stdio.h>
#include <stdlib.h>


int armstrongTest(int i, int* array){
    if(i<10){
        return array[i];
    }
    return array[i%10] + armstrongTest(i/10, array);
}

int main(void){
    int *array = (int*) malloc(10*sizeof(int));
    for (int i = 0; i<10; i++){
        array[i] = i*i*i;
    }
    for(int i=100; i<1000; i++){
        if(armstrongTest(i, array)==i){
            printf("%d\n", i);
        }
    }
    free(array);
}