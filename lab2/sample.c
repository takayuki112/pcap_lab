#include "mpi.h"
#include <stdio.h>

int main(int argc, char* argv[]){

    int rank, size, x, x2;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    MPI_Status status; //variable declaration for status - used by MPI_Recv & MPI_wait

    if(rank==0){
        printf("Enter a value in master process: ");
        scanf("%d", &x);
        MPI_Send(&x, 1, MPI_INT, 1, 1, MPI_COMM_WORLD);
        fprintf(stdout, "I have sent %d from process 0 \n", x); //fprintf allows you to specify stream/file //printf default is also stout only
        fflush(stdout);
    }
    else{
        MPI_Recv(&x2, 1, MPI_INT, 0, 1, MPI_COMM_WORLD, &status);
        fprintf(stdout, "I have recieved %d in process 1\n", x2);
        fflush(stdout);
    }

    MPI_Finalize();
    return 0;

}