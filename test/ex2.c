#include <stdio.h>
#include <string.h>
#include <ctype.h>
// 2wfdeeyuidcl
int main(void){
    char string1[32];
    char string2[32];
    char letter = 'a';
    int count = 0;
    scanf("%[^\n]%*c", string1);
    scanf("%s", string2);
    for (int i=0; letter != '\0'; i++){
        letter = string1[i];
        if (isalpha(letter)){
            count += 1;
        }
    }
    printf("%d\n", count);
    letter = 'a';
    count = 0;
    for (int i=0; letter != '\0'; i++){
        letter = string2[i];
        if (isupper(letter)){
            count += 1;
        }
    }
    printf("%d\n", count);
    letter = 'a';
    count = 0;
    for (int i=0; letter != '\0'; i++){
        letter = string1[i];
        if (isupper(letter)){
            string1[i] = tolower(letter);
        }
    }
    printf("%s\n", string1);
    letter = 'a';
    count = 0;
    for (int i=0; letter != '\0'; i++){
        letter = string2[i];
        if (isupper(letter)){
            string2[i] = tolower(letter);
        }
    }
    printf("%s\n", string2);
    count = strcmp(string1, string2);   
    if(count == 0){
        printf("As duas strings são iguais\n");
    }
    else if (count == 1){
        printf("%s\n", string1);
        printf("%s\n", string2);
    }
    else    {
        printf("%s\n", string2);
        printf("%s\n", string1);
    }
    char string3[32];
    strcpy(string3, string2);
    printf("%s\n", string3);
    strcat(string3, string2);
    printf("%s\n", string3);
}