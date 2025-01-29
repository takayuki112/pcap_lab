#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include "mpi.h"

int MAX = 30;

int count_vowels(char* str) {
    int count = 0;
    while (*str) {
        if (strchr("aeiouAEIOU", *str)) {
            count++;
        }
        str++;
    }
    return count;
}

int main(int argc, char* argv[]) {
    int rank, size;

    char A[MAX], B[MAX];
    int num, total_vowels = 0;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (rank == 0) {
        printf("Enter a string of length divisible by %d: \n", size);
        fflush(stdout);

        fgets(A, MAX, stdin);
        A[strcspn(A, "\n")] = '\0';  

        if (strlen(A) % size != 0) {
            printf("ERROR: String length must be divisible by %d\n", size);
            MPI_Abort(MPI_COMM_WORLD, 1);
        }
    }

    int str_len = 0;
    if (rank == 0) {
        str_len = strlen(A);
    }
    MPI_Bcast(&str_len, 1, MPI_INT, 0, MPI_COMM_WORLD);

    int num_each = str_len / size;

    MPI_Scatter(A, num_each, MPI_CHAR, B, num_each, MPI_CHAR, 0, MPI_COMM_WORLD);
    B[num_each] = '\0';
    num = count_vowels(B);

    printf("Process %d, Vowels = %d, Substring: %s\n", rank, num, B);

    int* gathered_vowels = NULL;
    if (rank == 0) {
        gathered_vowels = (int*)malloc(size * sizeof(int));
    }

    MPI_Gather(&num, 1, MPI_INT, gathered_vowels, 1, MPI_INT, 0, MPI_COMM_WORLD);

    if (rank == 0) {
        int total = 0;
        for (int i = 0; i < size; i++) {
            total += gathered_vowels[i];
        }
        
        printf("\nThe total number of vowels is: %d\n", total);
        free(gathered_vowels);
    }
    MPI_Finalize();
    return 0;
}