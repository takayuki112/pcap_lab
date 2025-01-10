#include <stdio.h>
#include "mpi.h"

int main(int argc, char* argv[]){
    int rank; // So every thread will initialize it's own rank variable

    MPI_Init(&argc, &argv); // In this section the threads can communicate and all...
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    if(rank%2 == 0) printf("Hello (rank = %d)\n", rank);
    else printf("World! (rank = %d)\n", rank);
    MPI_Finalize();
    return 0;
}