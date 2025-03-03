#include <stdio.h>
#include <string.h>
#include "mpi.h"

#define MAX 30


int count_vowels(char* str){
    int i=0;
    int vow = 0;
    while(str[i]!='\0'){
        if(strchr("aeiouAEIOU", str[i])) vow++;
        i++;
    }
    return vow;
}


int main(int argc, char* argv[]){
    int rank, size, unit_len, mvow;
    int all_rows[MAX];
    char str1[MAX], recv[MAX];

    MPI_Init(&argc, &argv);
    
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if(rank==0){
        printf("Enter a string of length divisible by %d: ", size);
        fflush(stdout);
        scanf("%s", str1);
        unit_len = strlen(str1)/size;
    }
    MPI_Bcast(&unit_len, 1, MPI_INT, 0, MPI_COMM_WORLD);
    MPI_Scatter(str1, unit_len, MPI_CHAR, recv, unit_len, MPI_CHAR, 0, MPI_COMM_WORLD);
    recv[unit_len] = '\0';

    printf("\nProcess %d now has %s", rank, recv);
    fflush(stdout);

    mvow = count_vowels(recv);
    //MPI_Gather
    MPI_Gather(&mvow, 1, MPI_INT, all_rows, 1, MPI_INT, 0, MPI_COMM_WORLD);

    if(rank==0){
        printf("\n Summing up Gathered values - \n");
        int total = 0;
        for(int i=0; i<size; i++){
            printf("%d + ", all_rows[i]);
            total += all_rows[i];
        }
        printf("\n Total = %d\n\n\n", total);
    }


    MPI_Finalize();

}