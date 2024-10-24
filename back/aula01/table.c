# include <stdio.h>
# include  <math.h>

int main(){
    int name;
    scanf("%d", &name);
    for(int i=0; i<name; i++){
        printf("%d\t%d\t%f\n", i, i*i, sqrt(i));
    }
    return 0;
};