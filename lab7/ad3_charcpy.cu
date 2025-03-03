#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <cuda_runtime.h>

#define MAX_STRING_LENGTH 1024

__global__ void copyCharacter(char *input, char *output, int inputLength, int *outputOffsets) {
    int idx = threadIdx.x + blockIdx.x * blockDim.x;

    if (idx < inputLength) {
        char currentChar = input[idx];
        int startPos = outputOffsets[idx];

        for (int i = 0; i < idx + 1; i++) {
            output[startPos + i] = currentChar;
        }
    }
}

int main(void) {
    char input[MAX_STRING_LENGTH];
    char *d_input, *d_output;
    int *d_outputOffsets;

    printf("Enter a string: ");
    scanf("%s", input);

    int inputLength = strlen(input);

    int outputLength = 0;
    for (int i = 0; i < inputLength; i++) {
        outputLength += (i + 1);
    }

    char *output = (char *)malloc(sizeof(char) * (outputLength + 1)); 
    output[outputLength] = '\0'; 

    int *outputOffsets = (int *)malloc(sizeof(int) * inputLength);
    outputOffsets[0] = 0;
    for (int i = 1; i < inputLength; i++) {
        outputOffsets[i] = outputOffsets[i - 1] + i;
    }

    cudaMalloc((void**)&d_input, sizeof(char) * (inputLength + 1));
    cudaMalloc((void**)&d_output, sizeof(char) * (outputLength + 1));
    cudaMalloc((void**)&d_outputOffsets, sizeof(int) * inputLength);

    cudaMemcpy(d_input, input, sizeof(char) * (inputLength + 1), cudaMemcpyHostToDevice);
    cudaMemcpy(d_outputOffsets, outputOffsets, sizeof(int) * inputLength, cudaMemcpyHostToDevice);

    int blockSize = 256;
    int gridSize = (inputLength + blockSize - 1) / blockSize;
    copyCharacter<<<gridSize, blockSize>>>(d_input, d_output, inputLength, d_outputOffsets);

    cudaError_t error = cudaGetLastError();
    if (error != cudaSuccess) {
        printf("CUDA Error: %s\n", cudaGetErrorString(error));
    }

    cudaMemcpy(output, d_output, sizeof(char) * (outputLength + 1), cudaMemcpyDeviceToHost);

    printf("Output: %s\n", output);

    cudaFree(d_input);
    cudaFree(d_output);
    cudaFree(d_outputOffsets);

    free(output);
    free(outputOffsets);

    return 0;
}