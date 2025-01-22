#include "mpi.h"
#include <stdio.h>
#include <string.h>

void toggle_case(char* str){
    int i = 0;
    while(str[i] != '\0'){
        if(str[i] < 97) str[i] += 'a' - 'A';
        else str[i] -= 'a' - 'A';
        i++;
    }
}

int main(int argc, char* argv[]){
    int rank;
    
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    MPI_Status status;

    if(rank == 0){ //client process
        fprintf(stdout, "Enter a string to toggle cases: ");
        fflush(stdout);
        char str1[20];
        scanf("%s", str1);
        MPI_Ssend(str1, 20, MPI_CHAR, 1, 1, MPI_COMM_WORLD);
        fprintf(stdout, "I have sent %s to process 1, from process 0\n", str1);
        fflush(stdout);

        MPI_Recv(str1, 20, MPI_CHAR, 1, 2, MPI_COMM_WORLD, &status);
        fprintf(stdout, "I have recieved %s in process 0\n", str1);
    }
    else{ //toggle server
        char getstr[20];
        MPI_Recv(getstr, 20, MPI_CHAR, 0, 1, MPI_COMM_WORLD, &status);
        fprintf(stdout, "I have recieved %s in process 1\n", getstr);
        toggle_case(getstr);
        fprintf(stdout, "Sending %s to process 0 from process 1\n", getstr);
        
        MPI_Ssend(getstr, 20, MPI_CHAR, 0, 2, MPI_COMM_WORLD);
        fflush(stdout);

    }
    MPI_Finalize();
}