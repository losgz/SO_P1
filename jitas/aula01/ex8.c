#include <stdio.h>
#define _USE_MATH_DEFINES // for C
#include <math.h>

int main(void){
    int start;
    int end;
    int space;
    scanf("%d", &start);
    scanf("%d", &end);
    scanf("%d", &space);
    FILE *fptr;
    fptr = fopen("trignometricTable.txt", "w");
    fprintf(fptr, "ang sin(ang)     cos(ang)    \n");
    fprintf(fptr, "--- ------------ ------------\n");
    for(int i=start; i<=end; i += space){
        double rad = i*M_PI/180;
        fprintf(fptr, "%3d %1.10f %1.10f\n", i, sin(rad), cos(rad));
    }
    fclose(fptr); 
    return 0;
}