#include <stdio.h>
#include "mpi.h"

int MAX = 10;

int fact(int n){
    if(n == 0) return 1;
    return n*fact(n-1);
}

int main(int argc, char* argv[]){
    int rank, size, N, A[MAX], B[MAX], c, i;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if(rank==0){
        printf("Enter %d elements: \n", size);
        fflush(stdout);
        N = size;
        for(i=0; i<N; i++) scanf("%d", &A[i]);
    }

    MPI_Scatter(A, 1, MPI_INT, &c, 1, MPI_INT, 0, MPI_COMM_WORLD);


    printf("Recieved %d in process %d\n", c, rank);
    fflush(stdout);

    c = fact(c);

    MPI_Gather(&c, 1, MPI_INT, B, 1, MPI_INT, 0, MPI_COMM_WORLD);

    if(rank==0){
        printf("\nThe result gathered in the root ~\n");
        int sum = 0;
        for(i=0; i<N; i++){ 
            printf("%d\t", B[i]);
            sum += B[i];
        }
        printf("\nThe sum = %d\n\n", sum);
        fflush(stdout);

    }

    MPI_Finalize();
}