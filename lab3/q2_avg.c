#include <stdio.h>
#include "mpi.h"

int MAX = 30;

int main(int argc, char* argv[]){
    int rank, size, N, M, i;
    float A[MAX], B[MAX], C[MAX];

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    N = size;

    if(rank==0){
        printf("Enter a value for M: ");
        fflush(stdout);
        scanf("%d", &M);
        if(M*N > MAX) printf("\n!\nERROR: MAX = %d value too low!!\n\n", M*N);

        printf("\nEnter %d Elements: \n", M*N);
        fflush(stdout);
        for(i=0; i<M*N; i++){
            scanf("%f", &A[i]);
        }
    }
    MPI_Bcast(&M, 1, MPI_INT, 0, MPI_COMM_WORLD);

    MPI_Scatter(A, M, MPI_FLOAT, C, M, MPI_FLOAT, 0, MPI_COMM_WORLD);

    float avg = 0;
    for(i=0; i<M; i++) avg+=C[i];
    avg /= M;

    printf("Average computed at process %d is %f\n", rank, avg);

    MPI_Gather(&avg, 1, MPI_FLOAT, B, 1, MPI_FLOAT, 0, MPI_COMM_WORLD);

    if(rank==0){
        float tavg = 0;
        for(i=0; i<N; i++) tavg += B[i];
        tavg /= N;

        printf("\n Average computed in root = %f\n\n", tavg);
    }

    MPI_Finalize();
    return 0;
}
