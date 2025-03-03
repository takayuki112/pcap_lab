//Q3 in lab manual Lab 2 - Point to Point

#include <string.h>
#include <stdio.h>
#include <stdlib.h> 
#include <math.h>
#include "mpi.h"


int main(int argc, char* argv[]){
    int rank, size, buff_size, num, recv;
    char* buffer;   //generic buffer

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    MPI_Status status;

    buff_size = MPI_BSEND_OVERHEAD + 1 * sizeof(int);
    buffer = (char*) malloc(buff_size);

    MPI_Buffer_attach(buffer, buff_size); //buffer size of 1 integer for everyone...

    if(rank == 0){
        printf("\nEnter %d numbers: ", size);
        fflush(stdout);
        for(int i=0; i<size; i++){
            scanf("%d", &num);
            MPI_Bsend(&num, 1, MPI_INT, i, i, MPI_COMM_WORLD);
            printf("\nSent %d to Process %d", num, i);
            fflush(stdout);
        }
    }
    MPI_Recv(&recv, 1, MPI_INT, 0, rank, MPI_COMM_WORLD, &status);

    if(rank%2==0)
        printf("\nProcess %d recieved %d. Even, so sqr = %f", rank, recv, pow(recv, 2));
    
    else
        printf("\nProcess %d recieved %d. Odd, so cube = %f", rank, recv, pow(recv, 3));
    
    fflush(stdout);

    MPI_Buffer_detach(&buffer, &buff_size); 
    MPI_Finalize();
}