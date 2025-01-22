#include <stdio.h>
#include "mpi.h"

int main(int argc, char* argv[]){
    int rank, size;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    MPI_Status status;
    if (rank==0){//master node
        int r=1;
        while(r < size){
            int num = r*100;
            MPI_Send(&num, 1, MPI_INT, r, r, MPI_COMM_WORLD);
            r++;
        }
    }

    int r=1;
    int recieve;
    while(r < size){
        if(rank == r){
            MPI_Recv(&recieve, 1, MPI_INT, 0, r, MPI_COMM_WORLD, &status);
            fprintf(stdout, "Process %d recieved number = %d\n", r, recieve);
            fflush(stdout);
        }
        r++;
    }

    MPI_Finalize();


}