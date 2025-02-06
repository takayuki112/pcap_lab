#include <stdio.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

__global__ void add(int *a, int *b, int *c, int N){
    int index = threadIdx.x + blockIdx.x * blockDim.x; // Calculate index
    printf("Thread idx started= %d \n", index);
    if(index < N) {
        c[index] = a[index] + b[index];  // Element-wise addition
    }
    printf("Thread idx finished = %d \n", index);
}

int main(void){
    int N = 64;  
    int size = N * sizeof(int);
    
    int *a, *b, *c;  
    int *da, *db, *dc;  

    a = (int*)malloc(size);
    b = (int*)malloc(size);
    c = (int*)malloc(size);

    // Initialize (host) vectors
    for (int i = 0; i < N; i++) {
        a[i] = i;
        b[i] = i * 3;
    }

    // Allocate device memory
    cudaMalloc((void**)&da, size);
    cudaMalloc((void**)&db, size);
    cudaMalloc((void**)&dc, size);

    // Copy data from host to device
    cudaMemcpy(da, a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(db, b, size, cudaMemcpyHostToDevice);

    // Set up kernel launch parameters
    int threadsPerBlock = 64;
    // int blocksPerGrid = N / 256;        // this doesn't work if N is not divisible by 256! - some get left out
    // int blocksPerGrid = (N+255) / 256;  //that'sw why we round up N with a +255 - to make sure we have enough blocks!
    int blocksPerGrid = (N + threadsPerBlock - 1) / threadsPerBlock;

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
