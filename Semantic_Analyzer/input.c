#include<stdio.h>

int add(int a, int b){
    return a + b;
}

int main() {
    // main function
    char c = 'a';
    signed short int i = 1, j;
    unsigned long int k = 2, l;
    float d = 4.5E+6;

	int sum = 0, tot = 0;
    
    for(j = 1 ; j <= 10 ; j++){
        if((i + j) % 2 == 0){
            if(j & 1)
                sum += i;
            else
                sum -= i;
        }
        else{
            if(j | 1)
                sum *= i;
            else
                sum /= i;
        }
        tot = add(tot, sum);
    }

    int count = 0;

    /*
        If sum is between [10, 100)
        increase count.
    */
    
    if(sum >= 10 && sum < 100){
        count++;
    }
    
    if(count != 0){
        count--;
    }

	int cc = 0;

    return 0;
}