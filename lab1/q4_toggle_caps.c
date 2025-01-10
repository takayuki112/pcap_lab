#include <stdio.h>
#include "mpi.h"

int main(int argc, char* argv[]){
    char str[] = "hello";
    int rank;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    if(str[rank] < 97) str[rank] += 'a' - 'A';
    else str[rank] -= 'a' - 'A';
    printf("Rank %d toggled %c\n", rank, str[rank]);
    MPI_Finalize();
    return 0;
}