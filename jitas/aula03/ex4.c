#include <stdio.h>
#include <stdlib.h>


int factorialTest(int i, int* array){
    if(i<10){
        return array[i];
    }
    return array[i%10] + factorialTest(i/10, array);
}

int main(void){
    int *array = (int*) malloc(10*sizeof(int));
    array[0] = 1;
    for (int i = 1; i<10; i++){
        array[i] = array[i-1] * i;
    }
    for(int i=1; i<1000000; i++){
        if(factorialTest(i, array)==i){
            printf("%d\n", i);
        }
    }
    free(array);
}