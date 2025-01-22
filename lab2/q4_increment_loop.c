#include <stdio.h>
#include "mpi.h"

int main(int argc, char* argv[]) {
    int rank, size;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    int num;
    MPI_Status status;

    if (rank == 0) {
        fprintf(stdout, "Enter an integer: ");
        fflush(stdout);
        scanf("%d", &num);
        MPI_Send(&num, 1, MPI_INT, 1, 0, MPI_COMM_WORLD);
        printf("Process 0 sent %d to Process 1\n", num);
        MPI_Recv(&num, 1, MPI_INT, size - 1, 0, MPI_COMM_WORLD, &status);
        printf("Process 0 received %d from Process %d\n", num, size - 1);
    } 
    else {
        MPI_Recv(&num, 1, MPI_INT, rank - 1, 0, MPI_COMM_WORLD, &status);
        printf("Process %d received %d from Process %d\n", rank, num, rank - 1);
        num++;
        if (rank == size - 1) {
            MPI_Send(&num, 1, MPI_INT, 0, 0, MPI_COMM_WORLD);
            printf("Process %d sent %d to Process 0\n", rank, num);
        } 
        else {
            MPI_Send(&num, 1, MPI_INT, rank + 1, 0, MPI_COMM_WORLD);
            printf("Process %d sent %d to Process %d\n", rank, num, rank + 1);
        }
    }

    MPI_Finalize();
    return 0;
}
