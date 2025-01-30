#include <stdio.h>
#include <stdlib.h>
#include "mpi.h"

void size_error(MPI_Comm *comm, int *errcode, ...) {
    char err_str[MPI_MAX_ERROR_STRING];
    int res_len;

    MPI_Error_string(*errcode, err_str, &res_len);
    fprintf(stderr, "ERROR: The number of processes is too big! Max = 4!\n");
    MPI_Abort(*comm, *errcode);
}

int main(int argc, char* argv[]) {
    int rank, size, myfact = 1, factsum = 0, i, errorcode;
    int MY_MPI_ERROR_CLASS, MY_MPI_ERROR_CODE;
    MPI_Errhandler size_errhandler;

    errorcode = MPI_Init(&argc, &argv);
    if (errorcode != MPI_SUCCESS) {
        printf("\nError starting MPI program. Terminating.\n");
        MPI_Abort(MPI_COMM_WORLD, errorcode);
    }

    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    //ERROR
    // MPI_Errorhandler_set(MPI_COMM_WORLD, MPI_ERRORS_RETURN); //has been depriciated

    // MPI_Comm_set_errhandler(MPI_COMM_WORLD, MPI_ERRORS_RETURN); //MPI_ERRORS_RETURN returns the error code if any
                                                                    // MPI_ERRORS_ARE_FATAL will abort all connected MPI processes 
                                                                    // MPI_ERRORS_ABORT will abort only local process if any error occurs

    MPI_Add_error_class(&MY_MPI_ERROR_CLASS);
    MPI_Add_error_code(MY_MPI_ERROR_CLASS, &MY_MPI_ERROR_CODE);
    MPI_Add_error_string(MY_MPI_ERROR_CODE, "Custom MPI Error: Too many processes!");

    MPI_Comm_create_errhandler((MPI_Comm_errhandler_function*) size_error, &size_errhandler);
    MPI_Comm_set_errhandler(MPI_COMM_WORLD, size_errhandler);

    if (size > 4) {
        if (rank == 0) {
            fprintf(stderr, "Error: Too many processes (%d). Maximum allowed is 4.\n", size);
        }
        MPI_Comm_call_errhandler(MPI_COMM_WORLD, MY_MPI_ERROR_CODE);
    }

    for (i = 1; i <= rank + 1; i++)
        myfact *= i;

    printf("\nProcess %d; Fact = %d", rank, myfact);
    fflush(stdout);

    MPI_Reduce(&myfact, &factsum, 1, MPI_INT, MPI_SUM, 0, MPI_COMM_WORLD);

    if (rank == 0)
        printf("\nThe sum of all factorials = %d\n", factsum);

    MPI_Finalize();
    return 0;
}
