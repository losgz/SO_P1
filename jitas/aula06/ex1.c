#include <stdio.h>

#define SIZE 100
long unsigned int DMemo[SIZE][SIZE];

int D(int m, int n){
    if (m==0 || n==0){
        return 1;
    }
    return D(m-1, n) + D(m-1, n-1) + D(m, n-1);
}

int D2(int m, int n){
    long unsigned int D[m+1][n+1];
    for (unsigned int i = 0; i<=m; i++){
        D[0][i]=1;
    }
    for(unsigned int i=1; i<=m; i++){
        D[i][0]=1;
        for(unsigned int j=1; j<=n; j++){
            D[i][j]= D[i-1][j] + D[i-1][j-1] + D[i][j-1];
        }
    }
    return D[m][n];
}

void initializeCache(void){
    for(unsigned int i=0; i<=SIZE; i++){
        for(unsigned int j=0; j<=SIZE; j++){
            if (i==0 || j==0){
                DMemo[i][j]=1;
            }
            else{
                DMemo[i][j]=0;
            }
        }
    }
}

int DMemofunc(int m, int n){
    if (DMemo[m][n]!=0){
        return DMemo[m][n];
    }
    DMemo[m][n]= DMemofunc(m-1, n) + DMemofunc(m-1, n-1) + DMemofunc(m, n-1);
    return DMemo[m][n];
}

int main(void){
    int i=0;
    initializeCache();
    while(i<20){
        int result = DMemofunc(i, i);
        printf("D(%d, %d) = %d\n", i, i, result);
        i++;
    }
}