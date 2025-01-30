#include <stdio.h>
#include <stdlib.h>
#include "mpi.h"

#define SIZE 4

int main(int argc, char* argv[]) {
    int rank, size;
    int matrix[SIZE][SIZE], new_row[SIZE], prev_row[SIZE];

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (size != SIZE) {
        if (rank == 0) 
            printf("This program requires exactly 4 processes.\n");
        MPI_Finalize();
        return 1;
    }

    if (rank == 0) {
        printf("Enter the 4x4 matrix:\n");
        for (int i = 0; i < SIZE; i++) {
            for (int j = 0; j < SIZE; j++) 
                scanf("%d", &matrix[i][j]);
        }
    }

    MPI_Scatter(matrix, SIZE, MPI_INT, new_row, SIZE, MPI_INT, 0, MPI_COMM_WORLD);

    if (rank == 0) {
        for (int j = 0; j < SIZE; j++) 
            prev_row[j] = new_row[j];
    }

    MPI_Barrier(MPI_COMM_WORLD);

    if (rank > 0) {
        MPI_Recv(prev_row, SIZE, MPI_INT, rank - 1, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        for (int j = 0; j < SIZE; j++) 
            new_row[j] += prev_row[j];
    }

    if (rank < SIZE - 1) 
        MPI_Send(new_row, SIZE, MPI_INT, rank + 1, 0, MPI_COMM_WORLD);

    MPI_Gather(new_row, SIZE, MPI_INT, matrix, SIZE, MPI_INT, 0, MPI_COMM_WORLD);

    if (rank == 0) {
        printf("Transformed Matrix:\n");
        for (int i = 0; i < SIZE; i++) {
            for (int j = 0; j < SIZE; j++) 
                printf("%d ", matrix[i][j]);

            printf("\n");
        }
    }

    MPI_Finalize();
    return 0;
}
