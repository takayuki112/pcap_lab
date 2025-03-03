#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <cuda_runtime.h>

#define MAX_STRING_LENGTH 1024

__global__ void constructRS(char *S, char *RS, int len) {
    int idx = threadIdx.x + blockIdx.x * blockDim.x;
    int startPos = idx * len - (idx * (idx - 1)) / 2;

    for (int i = 0; i < len - idx; i++) {
        RS[startPos + i] = S[i];
    }
}

int main(void) {
    char S[MAX_STRING_LENGTH];
    char *d_S, *d_RS;
    int len;

    printf("Enter a string: ");
    scanf("%s", S);
    len = strlen(S);

    int rsLen = (len * (len + 1)) / 2;

    char *RS = (char *)malloc(sizeof(char) * (rsLen + 1));
    RS[rsLen] = '\0';

    cudaMalloc((void**)&d_S, sizeof(char) * (len + 1));
    cudaMalloc((void**)&d_RS, sizeof(char) * (rsLen + 1));

    cudaMemcpy(d_S, S, sizeof(char) * (len + 1), cudaMemcpyHostToDevice);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start, 0);

    int blockSize = 256;
    int gridSize = (len + blockSize - 1) / blockSize;
    constructRS<<<gridSize, blockSize>>>(d_S, d_RS, len);

    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);

    float elapsedTime;
    cudaEventElapsedTime(&elapsedTime, start, stop);

    cudaError_t error = cudaGetLastError();
    if (error != cudaSuccess) {
        printf("CUDA Error: %s\n", cudaGetErrorString(error));
    }

    cudaMemcpy(RS, d_RS, sizeof(char) * (rsLen + 1), cudaMemcpyDeviceToHost);

    printf("Input S: %s\n", S);
    printf("Output RS: %s\n", RS);
    printf("Time taken: %f milliseconds\n", elapsedTime);

    cudaFree(d_S);
    cudaFree(d_RS);
    free(RS);

    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    return 0;
}