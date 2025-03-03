#include <stdio.h>
#include <string.h>

#include "mpi.h"

#define MAX 100

void toggle_case(char* str){
    printf("\n Before toggle %s = ", str);
    int i = 0;
    while(str[i]!='\0'){
        if(str[i] < 'Z')
            str[i] += 'a' - 'A';
        else    
            str[i] -= 'a' - 'A';
        
        i++;        
    }
    printf("\n After toggle %s = ", str);

}

int main(int argc, char* argv[]){
    int rank, size, len;
    char str1[MAX], str2[MAX];

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    MPI_Status status;
    if(rank == 0){
        printf("Enter a string: ");
        fflush(stdout);
        scanf("%s", str1); 

        len = strlen(str1)+1;

        MPI_Ssend(str1, len, MPI_CHAR, 1, 1, MPI_COMM_WORLD);
        printf("\nProcess 0 sent %s over to Process 1", str1);
        fflush(stdout);
        
        MPI_Recv(str1, len, MPI_CHAR, 1, 2, MPI_COMM_WORLD, &status);
        printf("\n\n After toggle recieved = %s", str1);

    }

    if(rank == 1){
        // Note you can't use len here, coz this might happen first - like parallel - so len is kinda uninitialzed so far
        MPI_Recv(str2, MAX, MPI_CHAR, 0, 1, MPI_COMM_WORLD, &status);
        printf("\nProcess 1 recieved %s from 0", str2);   
        fflush(stdout);

        toggle_case(str2);

        MPI_Send(str2, strlen(str2)+1, MPI_CHAR, 0, 2, MPI_COMM_WORLD);


    }

    MPI_Finalize();
    return 0;

}