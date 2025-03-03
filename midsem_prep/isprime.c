#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

bool isprime(int n){

    if(n<=1) return false;

    if(n==2) return true;

    if(n%2 == 0) return false;

    for(int i=3; i*i <= n; i+=2) if(n%i == 0) return false;
    
    return true;

}

int main() {
    // Test cases
    printf("2 is prime: %s\n", isprime(2) ? "true" : "false");   // true
    printf("3 is prime: %s\n", isprime(3) ? "true" : "false");   // true
    printf("4 is prime: %s\n", isprime(4) ? "true" : "false");   // false
    printf("9 is prime: %s\n", isprime(9) ? "true" : "false");   // false
    printf("11 is prime: %s\n", isprime(11) ? "true" : "false");  // true
    printf("15 is prime: %s\n", isprime(15) ? "true" : "false");  // false
    printf("25 is prime: %s\n", isprime(25) ? "true" : "false");  // false
    printf("97 is prime: %s\n", isprime(97) ? "true" : "false"); //true
    printf("1 is prime: %s\n", isprime(1) ? "true" : "false"); //false
    printf("0 is prime: %s\n", isprime(0) ? "true" : "false"); //false
    printf("-3 is prime: %s\n", isprime(-3) ? "true" : "false"); //false

    return 0;
}