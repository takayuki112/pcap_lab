#include <stdio.h>
#include <mpi.h>

int main(int argc, char *argv[]) {
    int rank, size;
    
    // Initialize MPI
    MPI_Init(&argc, &argv);
    
    // Get the rank and size of the communicator
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    // Array A (data to be sent)
    int A[9] = {12, 34, 56, 32, 15, 20, 17, 31, 21};
    
    // Array B (to hold the gathered data)
    int B[9 * size];  // Each process will receive 9 elements
    
    // Perform the MPI_Allgather operation
    MPI_Allgather(&A[rank * 3], 3, MPI_INT, B, 3, MPI_INT, MPI_COMM_WORLD);
    
    // Print the contents of array B at process 2
    if (rank == 2) {
        printf("Contents of array B in process 2:\n");
        for (int i = 0; i < 9 * size; i++) {
            printf("%d ", B[i]);
        }
        printf("\n");
    }

    // Finalize MPI
    MPI_Finalize();
    
    return 0;
}
