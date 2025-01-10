#include "mpi.h"
#include <stdio.h>
#include <math.h>

int main(int argc, char *argv[]){
    const int x = 2;
    printf("This is a line before MPI-Init. All the threads do this indipendently...\n");

    int rank;
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    printf("X=%d Raised to the power of rank = %d is %lf\n", x, rank, pow(x, rank));
    MPI_Finalize();
    return 0;
}