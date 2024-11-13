#include <stdio.h>
#include <stdlib.h>

void DisplayArray(double* a, size_t n) {
    if(a==NULL){
        return;
    }
    if(n<=0){
        return;
    }
    printf("[");
    for(int i=0; i < n-1; i++){
        printf(" %.2f,", a[i]);
    }
    printf(" %.2f ]\n", a[n-1]);
}

double* ReadArray(size_t* size_p){
    if(size_p==NULL){
        return NULL;
    }
    if(*size_p<=0){
        return NULL;
    }
    double *array = (double*) malloc(*size_p*sizeof(double));
    if (array == NULL){
        *size_p = 0;
        return NULL;
    }
    printf("Enter the elements:\n");
    for(int i=0; i<*size_p; i++){
        scanf("%lf", &array[i]);
    }
    return array;
}

double* Append(double* array_1, size_t size_1, double* array_2, size_t size_2){
    if (array_1 == NULL){
        return NULL;
    }
    if (array_2 == NULL){
        return NULL;
    }
    double *array = (double*) malloc((size_1 + size_2)*sizeof(double));
    if (array == NULL){
        return NULL;
    }
    for(int i = 0; i<size_1; i++){
        array[i]=array_1[i];
    }
    for(int i = 0; i<size_2; i++){
        array[i+size_1]=array_2[i];
    }
    return array;
}

int main(void){
    size_t size = 3;
    double* array1 = ReadArray(&size);
    double* array2 = ReadArray(&size);
    double* array3 = Append(array1, size, array2, size);
    DisplayArray(array3, 2*size);
    free(array1);
    free(array2);
    free(array3);
}