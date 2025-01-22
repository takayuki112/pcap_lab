#include <stdio.h>
#include <stdlib.h>
#include "mpi.h"

int is_prime(int n) {
    if (n <= 1) return 0;
    for (int i = 2; i * i <= n; i++) {
        if (n % i == 0) return 0;
    }
    return 1;
}

int main(int argc, char* argv[]) {
    int rank, size;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    int* arr = NULL;

    if (rank == 0) {
        printf("Enter %d elements:\n", size);
        arr = (int*)malloc(size * sizeof(int));
        for (int i = 0; i < size; i++) {
            scanf("%d", &arr[i]);
        }

        for (int i = 1; i < size; i++) {
            MPI_Send(&arr[i], 1, MPI_INT, i, 0, MPI_COMM_WORLD);
        }

        if (is_prime(arr[0])) {
            printf("Process 0: %d is prime\n", arr[0]);
        } else {
            printf("Process 0: %d is not prime\n", arr[0]);
        }

        free(arr);
    } else {
        int num;
        MPI_Recv(&num, 1, MPI_INT, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);

        if (is_prime(num)) {
            printf("Process %d: %d is prime\n", rank, num);
        } else {
            printf("Process %d: %d is not prime\n", rank, num);
        }
    }

    MPI_Finalize();
    return 0;
}
