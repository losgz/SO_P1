#include <stdio.h>
#include <assert.h>

int verify(int* array, size_t size){
    assert(size>2);
    int comparations = 0;
    int count = 0;
    for (int k=2; k < size; k++){
        for (int j=1; j<k; j++){
            for (int i=0; i < j; i++){
                comparations++;
                if (array[k] == array[i] + array[j]){
                    count++;
                }
            }
        }
    }
    printf("Operações: %d\n", comparations);
    return count;
}


int main(void){
    int array1[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    size_t size = 10;
    int result = verify(array1, size);
    printf("%d\n", result);
    int array2[] = {1, 2, 1, 4, 5, 6, 7, 8, 9, 10};
    result = verify(array2, size);
    printf("%d\n", result);
    int array3[] = {1, 2, 1, 3, 2, 6, 7, 8, 9, 10};
    result = verify(array3, size);
    printf("%d\n", result);
    int array4[] = {0, 2, 2, 0, 3, 3, 0, 4, 4, 0};
    result = verify(array4, size);
    printf("%d\n", result);
    int array5[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    result = verify(array5, size);
    printf("%d\n", result);
}