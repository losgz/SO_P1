#include <stdio.h>
#include <assert.h>

int verifyPG(int* array, size_t size){
    assert(size>2);
    float r = array[1]/array[0];
    int oper = 1;
    for (int i=2; i < size; i++){
        oper++;
        if (array[i] != array[i-1] * r){
            printf("Operações: %d\n", oper);
            return 0;
        }
    }
    printf("Operações: %d\n", oper);
    return 1;
}


int main(void){
    int array1[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    size_t size = 10;
    int result = verifyPG(array1, size);
    printf("%d\n", result);
    int array2[] = {1, 2, 4, 4, 5, 6, 7, 8, 9, 10};
    result = verifyPG(array2, size);
    printf("%d\n", result);
    int array3[] = {1, 2, 4, 8, 16, 6, 7, 8, 9, 10};
    result = verifyPG(array3, size);
    printf("%d\n", result);
    int array4[] = {1, 2, 4, 8, 16, 32, 7, 8, 9, 10};
    result = verifyPG(array4, size);
    printf("%d\n", result);
    int array5[] = {1, 2, 4, 8, 16, 32, 64, 8, 9, 10};
    result = verifyPG(array5, size);
    printf("%d\n", result);
    int array6[] = {1, 2, 4, 8, 16, 32, 64, 128, 9, 10};
    result = verifyPG(array6, size);
    printf("%d\n", result);
    int array7[] = {1, 2, 4, 8, 16, 32, 64, 128, 256, 10};
    result = verifyPG(array7, size);
    printf("%d\n", result);
    int array8[] = {1, 2, 4, 8, 16, 32, 64, 128, 256, 512};
    result = verifyPG(array8, size);
    printf("%d\n", result);
}