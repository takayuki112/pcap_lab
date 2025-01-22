#include <stdio.h>
#include "mpi.h"

int factorial(int n) {
    int fact = 1;
    for (int i = 1; i <= n; i++) {
        fact *= i;
    }
    return fact;
}

int sum_upto(int n) {
    return (n * (n + 1)) / 2;
}

int main(int argc, char* argv[]) {
    int rank, size;
    int local_result = 0, final_result = 0;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (rank % 2 == 0) {
        local_result = sum_upto(rank);
    } else {
        local_result = factorial(rank);
    }

    if (rank != 0) {
        MPI_Send(&local_result, 1, MPI_INT, 0, 0, MPI_COMM_WORLD);
    } else {
        final_result += local_result;
        for (int i = 1; i < size; i++) {
            int temp_result;
            MPI_Recv(&temp_result, 1, MPI_INT, i, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
            final_result += temp_result;
        }
        printf("The final result is: %d\n", final_result);
    }

    MPI_Finalize();
    return 0;
}
