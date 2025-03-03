#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <ctype.h>

#include "mpi.h"

#define N 10

int main(int argc, char* argv[]){
    int rank, size, buffer_size, num_bsend, rec_num, partition_count, tot_rec, gather[N];
    char str1[N], recv[N];
    char* buffer;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Comm_set_errhandler(MPI_COMM_WORLD, MPI_ERRORS_RETURN);
    MPI_Status status;

    buffer_size = MPI_BSEND_OVERHEAD + N*sizeof(int);
    buffer = (char*) malloc(buffer_size);
    MPI_Buffer_attach(buffer, buffer_size);

    if(rank==0){
        scanf("%s", str1);

        MPI_Bsend(&num_bsend, 1, MPI_INT, 1, 12, MPI_COMM_WORLD);

    }
    if(rank==1){
        MPI_Recv(&rec_num, 1, MPI_INT, 0, 12, MPI_COMM_WORLD);
    }
    MPI_Bcast(&num_bsend, 1, MPI_INT, 0, MPI_COMM_WORLD);
    
    MPI_Scatter(str1, partition_count, MPI_CHAR, recv, partition_count, MPI_CHAR, 0, MPI_COMM_WORLD);

    MPI_Gather(&rec_num, 1, MPI_INT, gather, 1, MPI_INT, 0, MPI_COMM_WORLD);

    MPI_Redcuce(rec_num, tot_rec, 1, MPI_INT, MPI_SUM, 0, MPI_COMM_WORLD);
    MPI_Scan(rec_num, tot_rec, 1, MPI_INT, MPI_SUM, MPI_COMM_WORLD);

    MPI_Buffer_detach(&buffer, &buffer_size);

    MPI_Finalize();
}