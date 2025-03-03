#include <stdio.h>
#include <stdlib.h>
#include "mpi.h"

#define MATRIX_SIZE 3

int main(int argc, char* argv[]) {
    int rank, size, i, j, search_element;
    int matrix[MATRIX_SIZE][MATRIX_SIZE];
    int local_count = 0, total_count = 0;
    int local_row[MATRIX_SIZE];

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (size != 3) {
        if (rank == 0) 
            printf("This program requires exactly 3 processes.\n");
        MPI_Finalize();
        return 1;
    }

    if (rank == 0) {
        printf("Enter the 3x3 matrix:\n");
        fflush(stdout);
        for (i = 0; i < MATRIX_SIZE; i++) {
            for (j = 0; j < MATRIX_SIZE; j++) 
                scanf("%d", &matrix[i][j]);
        }
        printf("Enter the element to search: ");
        fflush(stdout);
        scanf("%d", &search_element);
    }

    MPI_Bcast(&search_element, 1, MPI_INT, 0, MPI_COMM_WORLD);
    MPI_Scatter(matrix, MATRIX_SIZE, MPI_INT, local_row, MATRIX_SIZE, MPI_INT, 0, MPI_COMM_WORLD);

    for (i = 0; i < MATRIX_SIZE; i++) {
        if (local_row[i] == search_element) 
            local_count++;
    }

    printf("Process %d found %d occurrences of %d.\n", rank, local_count, search_element);
    fflush(stdout);

    MPI_Reduce(&local_count, &total_count, 1, MPI_INT, MPI_SUM, 0, MPI_COMM_WORLD);

    if (rank == 0) 
        printf("The element %d occurred %d times in the matrix.\n", search_element, total_count);
    
    MPI_Finalize();
    return 0;
}
