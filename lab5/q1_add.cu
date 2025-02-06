#include <stdio.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

__global__ void add(int *a, int *b, int *c, int N){
    int index = threadIdx.x + blockIdx.x * blockDim.x; // Calculate index
    if(index < N) {
        c[index] = a[index] + b[index];  // Element-wise addition
    }
}

int main(void){
    int N = 2048;  
    int size = N * sizeof(int);
    
    int *a, *b, *c;  
    int *da, *db, *dc;  

    a = (int*)malloc(size);
    b = (int*)malloc(size);
    c = (int*)malloc(size);

    // Initialize (host) vectors
    for (int i = 0; i < N; i++) {
        a[i] = i;
        b[i] = i * 2;
    }

    // Allocate device memory
    cudaMalloc((void**)&da, size);
    cudaMalloc((void**)&db, size);
    cudaMalloc((void**)&dc, size);

    // Copy data from host to device
    cudaMemcpy(da, a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(db, b, size, cudaMemcpyHostToDevice);

    // Set up kernel launch parameters
    // a.
    // int threadsPerBlock = N;
    // int blocksPerGrid = 1; 

    //b.
    int threadsPerBlock = 1;
    int blocksPerGrid = N;    //Fun fact - if you put a number less than N, then the remaining values in C will remain 0

    // Launch the add kernel - a single grid
    add<<<blocksPerGrid, threadsPerBlock>>>(da, db, dc, N);

    // Copy the result back to host
    cudaMemcpy(c, dc, size, cudaMemcpyDeviceToHost);

    printf("First few Results in c...\n");
    printf(" a  \t + \t b  \t = \t c \n");
    printf("------------------------------------\n");
    for (int i = 0; i < 16; i++) {  
        printf(" %d \t + \t %d \t = \t %d\n", a[i], b[i], c[i]);
    }

    // Free memory
    cudaFree(da);
    cudaFree(db);
    cudaFree(dc);
    free(a);
    free(b);
    free(c);
    
    return 0;
}
