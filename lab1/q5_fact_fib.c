#include <stdio.h>
#include "mpi.h"

int fact(int n){
    if(n == 0) return 1;
    return n * fact(n-1);
}

int fib(int n){
    if(n<=1) return n;
    return fib(n-1) + fib(n-2);
}

int main(int argc, char* argv[]){
    int rank; 

    MPI_Init(&argc, &argv); 
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    if(rank%2 == 0) printf("Factorial of %d is %d\n", rank, fact(rank));
    else printf("Fibonacci at %d = %d\n", rank, fib(rank));
    MPI_Finalize();
    return 0;
}