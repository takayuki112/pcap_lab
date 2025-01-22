#include <stdio.h>
#include "mpi.h"

int main(int argc, char* argv[]){
    int rank, size;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    MPI_Status status;

    if (rank == 0) {  // Master node

        // N = size - 1 
        printf("Enter %d elements: \n", size - 1);

        int arr[size - 1]; 

        for (int i = 0; i < size - 1; i++) {
            scanf("%d", &arr[i]);
        }

        //make buffer...
        int buffer_size = MPI_BSEND_OVERHEAD + sizeof(int) * (size - 1);
        void* buffer = malloc(buffer_size);
        MPI_Buffer_attach(buffer, buffer_size);

        for (int i = 1; i < size; i++) {
            MPI_Bsend(&arr[i - 1], 1, MPI_INT, i, i, MPI_COMM_WORLD);
        }

        // Detach the buffer 
        MPI_Buffer_detach(&buffer, &buffer_size);
        free(buffer);
    }

    int r=1;
    int recieve;
    while(r < size){
        if(rank == r){
            if(r%2 == 0){
                MPI_Recv(&recieve, 1, MPI_INT, 0, r, MPI_COMM_WORLD, &status);
                fprintf(stdout, "EVEN Process %d sqr of recieved number = %d\n", r, recieve*recieve);
                fflush(stdout);
            }
            else{
                MPI_Recv(&recieve, 1, MPI_INT, 0, r, MPI_COMM_WORLD, &status);
                fprintf(stdout, "ODD Process %d cube of recieved number = %d\n", r, recieve*recieve*recieve);
                fflush(stdout);
            }
        }
        r++;
    }

    MPI_Finalize();


}