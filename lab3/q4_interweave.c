#include <stdio.h>
#include <string.h>
#include <mpi.h>

#define MAX 100

int main(int argc, char *argv[]) {
    int rank, size;
    char S1[MAX], S2[MAX];
    char local_S1[MAX], local_S2[MAX];
    char local_result[MAX * 2];
    char final_result[MAX * 2];
    int str_len, local_len;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (rank == 0) {
        printf("Enter the first string (S1): ");
        fflush(stdout);
        fgets(S1, MAX, stdin);
        S1[strcspn(S1, "\n")] = '\0';

        printf("Enter the second string (S2): ");
        fflush(stdout);
        fgets(S2, MAX, stdin);
        S2[strcspn(S2, "\n")] = '\0';

        if (strlen(S1) != strlen(S2)) {
            printf("Error: Strings must be of the same length.\n");
            MPI_Abort(MPI_COMM_WORLD, 1);
        }

        str_len = strlen(S1);
        if (strlen(S1) % size != 0) {
            printf("Error: String length must be divisible by the number of processes.\n");
            MPI_Abort(MPI_COMM_WORLD, 1);
        }
    }

    MPI_Bcast(&str_len, 1, MPI_INT, 0, MPI_COMM_WORLD);

    local_len = str_len / size;

    MPI_Scatter(S1, local_len, MPI_CHAR, local_S1, local_len, MPI_CHAR, 0, MPI_COMM_WORLD);
    MPI_Scatter(S2, local_len, MPI_CHAR, local_S2, local_len, MPI_CHAR, 0, MPI_COMM_WORLD);

    for (int i = 0; i < local_len; i++) {
        local_result[2 * i] = local_S1[i];
        local_result[2 * i + 1] = local_S2[i];
    }
    local_result[2 * local_len] = '\0';

    MPI_Gather(local_result, 2 * local_len, MPI_CHAR, final_result, 2 * local_len, MPI_CHAR, 0, MPI_COMM_WORLD);

    if (rank == 0) {
        final_result[2 * str_len] = '\0';
        printf("Resultant String: %s\n", final_result);
    }
    MPI_Finalize();
    return 0;
}