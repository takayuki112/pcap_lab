#include <stdio.h>
#include <stdlib.h>
#include "mpi.h"

int MAX = 10;

int main(int argc, char* argv[]){
    int rank, size, A[MAX], B[MAX], N, c, i;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if(rank==0){
        N = size;
        printf("Enter %d numbers: \n", N);
        fflush(stdout);
        for(i=0; i<N; i++)
            scanf("%d", &A[i]);        
    }
    MPI_Scatter(A, 1, MPI_INT, &c, 1, MPI_INT, 0, MPI_COMM_WORLD);
    printf("I have recieved %d in process %d\n", c, rank);
    fflush(stdout);

    c *= c;

    MPI_Gather(&c, 1, MPI_INT, B, 1, MPI_INT, 0, MPI_COMM_WORLD);

    if(rank==0){
        printf("\nThe result gathered in the root ~\n");
        fflush(stdout);
        for(i=0; i<N; i++)
            printf("%d\t", B[i]);
        printf("\n");
        fflush(stdout);
    }

    MPI_Finalize();
    return 0;
    
}