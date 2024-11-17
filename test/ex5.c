#include <stdio.h>
#include <assert.h>

void DisplayPol(double* coef, size_t degree) {
    if (coef==NULL){
        return;
    }
    // ert4rty4t4r33rt35y46y
    if (degree<0){
        return;
    }
    printf("Pol(x) =");
    for (int i=0; i<degree; i++){
        printf(" %lf * x^%d +", coef[i], (int) degree-i);
    }
    printf(" %lf\n", coef[degree]);
}

double ComputePol(double* coef, size_t degree, double x) {
    assert (coef!=NULL);
    assert (degree>=0);
    double result = coef[0];
    for (int i=1; i<=degree; i++){
        result = result*x+coef[i];
    }
    return result;
}

unsigned int GetRealRoots(double* coef, size_t degree, double* root_1, double* root_2) {
    assert (coef!=NULL);
    assert (degree==2);
    assert (coef[0]!=0);
    double pRoot1 = ComputePol(coef, degree, *root_1);
    double pRoot2 = ComputePol(coef, degree, *root_2);
    printf("%f %f\n", pRoot1, pRoot2);
    if (pRoot1 == 0 && pRoot2 == 0){
        return 2;
    }
    else if (pRoot1 == 0 || pRoot2 == 0){
        return 1;
    }
    else{
        return 0;
    }
}

int main(void){
    size_t size = 2;
    double array[] = {1,0,-1};
    DisplayPol(array, size);
    double res = ComputePol(array, size,2);
    printf("Pol(2) = %lf\n", res);
    double root1 = 3;
    double root2 = 2;
    unsigned int rootVal = GetRealRoots(array, size, &root1, &root2);
    printf("%d\n", rootVal);
}
