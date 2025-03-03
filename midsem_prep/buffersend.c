//Q3 in lab manual Lab 2 - Point to Point

#include <string.h>
#include <stdio.h>
#include <stdlib.h> 
#include "mpi.h"

# define NMAX 10

int main(int argc, char* argv[]){
    int rank, size, buff_size, nums[NMAX], recv[NMAX];
    char* buffer;   //generic buffer

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    MPI_Status status;

    buff_size = MPI_BSEND_OVERHEAD + NMAX * sizeof(int);
    buffer = (char*) malloc(buff_size);

    MPI_Buffer_attach(buffer, buff_size);

    if(rank==0){
        printf("Enter %d numbers: ", NMAX);
        fflush(stdout);
        for(int i=0; i<NMAX; i++){
            scanf("%d", &nums[i]);
        }
        MPI_Bsend(nums, NMAX, MPI_INT, 1, 1, MPI_COMM_WORLD);
    }
    if(rank==1){
        MPI_Recv(recv, NMAX, MPI_INT, 0, 1, MPI_COMM_WORLD, &status);
        printf("\nRecieved by Bsend: ");
        fflush(stdout);
        for(int i=0; i<NMAX; i++){
            printf("%d ", recv[i]);
        }
        printf("\n");
    }

    MPI_Buffer_detach(&buffer, &buff_size); 
    MPI_Finalize();
}