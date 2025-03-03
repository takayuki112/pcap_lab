#include <stdio.h>
#include <string.h>

#include "mpi.h"

int main(int argc, char* argv[]){

    int rank, size, num, recv;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    MPI_Status status;
    if(rank == 0){
        printf("Enter a number: ");
        fflush(stdout);
        scanf("%d", &num);

        MPI_Ssend(&num, 1, MPI_INT, 1, 1, MPI_COMM_WORLD);
        printf("\nProcess 0 sent %d over to Process 1", num);
        fflush(stdout);
    }

    if(rank == 1){
        MPI_Recv(&recv, 1, MPI_INT, 0, 1, MPI_COMM_WORLD, &status);
        printf("\nProcess 1 recieved %d from 0", recv);   
        fflush(stdout);

    }

    MPI_Finalize();
    return 0;

}