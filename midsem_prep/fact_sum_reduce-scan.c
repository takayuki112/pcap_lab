#include <stdio.h>
#include <string.h>

#include "mpi.h"

#define MAX 100

int fact(int n){
    int f = 1;
    for(int i=2; i<=n; i++) f*=i;
    return f;
}

int main(int argc, char* argv[]){
    int rank, size, nums[MAX], ni, ri, total;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    MPI_Comm_set_errhandler(MPI_COMM_WORLD, MPI_ERRORS_RETURN);

    if(rank==0){
        printf("Enter %d numbers: ", size);
        fflush(stdout);
        for(int i=0; i<size; i++){
            scanf("%d", &nums[i]);
        }
    }

    MPI_Scatter(nums, 1, MPI_INT, &ni, 1, MPI_INT, 0, MPI_COMM_WORLD);

    ri = fact(ni);

    MPI_Scan(&ri, &total, 1, MPI_INT, MPI_SUM, MPI_COMM_WORLD);
    
    printf("\n Fact of %d at P%d is = %d   and sum so far = %d", ni, rank, ri, total);
    fflush(stdout);
    if(rank==size-1){
        printf("\n Total = %d", total);
        fflush(stdout);
    }


    MPI_Finalize();
}