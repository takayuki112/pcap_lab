#include <stdio.h>
#include <math.h>
#include "mpi.h"

int main(int argc, char* argv[]){
    const int a = 10;
    const int b = 5;
    int rank;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    if(rank==0) printf("Rank = %d \t A + B = %d\n", rank, a+b);
    if(rank==1) printf("Rank = %d \t A - B = %d\n", rank, a-b);
    if(rank==2) printf("Rank = %d \t A * B = %d\n", rank, a*b);
    if(rank==3) printf("Rank = %d \t A / B = %d\n", rank, a/b);
    if(rank==4) printf("Rank = %d \t A ^ B = %d\n", rank, pow(a, b));
    MPI_Finalize();
    return 0;
}