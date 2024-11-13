//
// TO DO : desenvolva um algoritmo para verificar se um numero inteiro positivo
//         e uma capicua
//         Exemplos: 12321 e uma capiacua, mas 123456 nao e
//         USE uma PILHA DE INTEIROS (STACK) e uma FILA DE INTEIROS (QUEUE)
//
// TO DO : design an algorithm to check if the digits of a positive decimal
//         integer number constitue a palindrome
//         Examples: 12321 is a palindrome, but 123456 is not
//         USE a STACK of integers and a QUEUE of integers
//

#include <stdio.h>

#include "IntegersQueue.h"
#include "IntegersStack.h"

int main(void) { 
    int num = 24242;
    int size = 0;
    int test=num;
    while (test>0){
        test=test/10;
        size++;
    }
    Queue* queue = QueueCreate(size);
    Stack* stack = StackCreate(size);
    for(int i=0; i<size; i++){
        int result = num%10;
        QueueEnqueue(queue, result);
        StackPush(stack, result);
        num=num/10;
    }
    for(int i=0; i<size/2+1; i++){
        int digitN=QueueDequeue(queue);
        int digitIN=StackPop(stack);
        if(digitN!=digitIN){
            printf("My guy isso não é capicua\n");
            return 1;
        }
    }
    printf("My guy isso é capicua\n");
    return 0; 
}
