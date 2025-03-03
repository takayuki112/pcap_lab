#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <cuda_runtime.h>

#define MAX_STRING_LENGTH 1024

__global__ void concatenateString(char *input, char *output, int inputLength, int n) {
    int idx = threadIdx.x + blockIdx.x * blockDim.x;

    if (idx < n) {
        int startPos = idx * inputLength;
        for (int i = 0; i < inputLength; i++) {
            output[startPos + i] = input[i];
        }
    }
}

int main(void) {
    char input[MAX_STRING_LENGTH];
    char *d_input, *d_output;
    int n;

    printf("Enter a string: ");
    scanf("%s", input);
    printf("Enter the number of times to concatenate: ");
    scanf("%d", &n);

    int inputLength = strlen(input);
    int outputLength = inputLength * n;

    char *output = (char *)malloc(sizeof(char) * (outputLength + 1)); 
    output[outputLength] = '\0'; 

    cudaMalloc((void**)&d_input, sizeof(char) * (inputLength + 1));
    cudaMalloc((void**)&d_output, sizeof(char) * (outputLength + 1));

    cudaMemcpy(d_input, input, sizeof(char) * (inputLength + 1), cudaMemcpyHostToDevice);

    int blockSize = 256;
    int gridSize = (n + blockSize - 1) / blockSize;
    concatenateString<<<gridSize, blockSize>>>(d_input, d_output, inputLength, n);

    cudaError_t error = cudaGetLastError();
    if (error != cudaSuccess) {
        printf("CUDA Error: %s\n", cudaGetErrorString(error));
    }

    cudaMemcpy(output, d_output, sizeof(char) * (outputLength + 1), cudaMemcpyDeviceToHost);

    printf("Output: %s\n", output);

    cudaFree(d_input);
    cudaFree(d_output);

    free(output);

    return 0;
}