#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "mpi.h"

#define MAX_LENGTH 100

int main(int argc, char* argv[]) {
    int rank, size, length;
    char word[MAX_LENGTH], local_result[MAX_LENGTH];
    char *expanded = NULL;
    int send_counts[MAX_LENGTH], displacements[MAX_LENGTH];

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (rank == 0) {
        printf("Enter the word: ");
        fflush(stdout);
        scanf("%s", word);
        length = strlen(word);

        if (length != size) {
            printf("Error: Number of processes must be equal to word length (%d).\n", length);
            MPI_Abort(MPI_COMM_WORLD, 1);
        }
    }

    MPI_Bcast(&length, 1, MPI_INT, 0, MPI_COMM_WORLD);
    MPI_Bcast(word, length + 1, MPI_CHAR, 0, MPI_COMM_WORLD);

    char ch = word[rank];

    for (int i = 0; i < rank + 1; i++) {
        local_result[i] = ch;
    }
    local_result[rank + 1] = '\0';

    int local_size = rank + 1;  

    if (rank == 0) {
        expanded = (char *)malloc(MAX_LENGTH * MAX_LENGTH * sizeof(char));
    }

    MPI_Gather(&local_size, 1, MPI_INT, send_counts, 1, MPI_INT, 0, MPI_COMM_WORLD);

    if (rank == 0) {
        displacements[0] = 0;
        for (int i = 1; i < size; i++) {
            displacements[i] = displacements[i - 1] + send_counts[i - 1];
        }
    }

    MPI_Gatherv(local_result, local_size, MPI_CHAR,
                expanded, send_counts, displacements, MPI_CHAR,
                0, MPI_COMM_WORLD);

    if (rank == 0) {
        expanded[displacements[size - 1] + send_counts[size - 1]] = '\0';
        printf("Output: %s\n", expanded);
        free(expanded);
    }

    MPI_Finalize();
    return 0;
}
