#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#define N 1024

__global__ void cudacount(char *A, unsigned int *d_count) {
    int i = threadIdx.x;
    if (A[i] == 'a') atomicAdd(d_count, 1);
}

int main(void) {
    char A[N];
    char *dA;

    unsigned int count = 0;
    unsigned int *d_count, *result = (unsigned int*)malloc(sizeof(unsigned int));

    printf("Enter a string: ");
    scanf("%s", A);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start, 0);

    cudaMalloc((void**)&dA, sizeof(char) * (strlen(A) + 1)); 
    cudaMalloc((void**)&d_count, sizeof(unsigned int));

    cudaMemcpy(dA, A, (strlen(A) + 1) * sizeof(char), cudaMemcpyHostToDevice);
    cudaMemcpy(d_count, &count, sizeof(unsigned int), cudaMemcpyHostToDevice);

    cudaError_t error = cudaGetLastError();
    if (error != cudaSuccess)
        printf("CUDA Error1: %s\n", cudaGetErrorString(error));

    cudacount<<<1, N>>>(dA, d_count);
    error = cudaGetLastError();
    if (error != cudaSuccess)
        printf("CUDA Error2: %s\n", cudaGetErrorString(error));

    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);

    float elapsedTime;
    cudaEventElapsedTime(&elapsedTime, start, stop);

    cudaMemcpy(result, d_count, sizeof(unsigned int), cudaMemcpyDeviceToHost);
    printf("Total occurrences of 'a' = %u\n", *result); 
    printf("Time taken = %f\n", elapsedTime);

    cudaFree(dA);
    cudaFree(d_count);
    free(result);

    return 0;
}