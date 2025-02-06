//write a simple cuda program to find the sine of N angles stored in an array
#include <stdio.h>
#include <math.h>
#include "cuda_runtime.h"

__global__ void calcSine(float *angles, float *sineResults, int N){
    int index = threadIdx.x + blockIdx.x * blockDim.x;
    if (index < N) {
        sineResults[index] = sinf(angles[index]);  
    }
}

int main(void) {
    int N = 1024;  
    int size = N * sizeof(float);

    float *angles, *sineResults;     
    float *d_angles, *d_sineResults; 

    // Allocate host memory
    angles = (float*)malloc(size);
    sineResults = (float*)malloc(size);

    // Initialize some angles (in radians)
    for (int i = 0; i < N; i++) {
        angles[i] = i * 0.01;  
    }

    // Allocate memory
    cudaMalloc((void**)&d_angles, size);
    cudaMalloc((void**)&d_sineResults, size);

    cudaMemcpy(d_angles, angles, size, cudaMemcpyHostToDevice);

    int threadsPerBlock = 256;
    int blocksPerGrid = (N + threadsPerBlock - 1) / threadsPerBlock;

    calcSine<<<blocksPerGrid, threadsPerBlock>>>(d_angles, d_sineResults, N);

    cudaMemcpy(sineResults, d_sineResults, size, cudaMemcpyDeviceToHost);

    printf("First few Results...\n");
    printf("Index \t Angle (radians) \t Sine of angle\n");
    printf("---------------------------------------------\n");
    for (int i = 0; i < 16; i++) {  
        printf("%d \t %f \t\t %f\n", i, angles[i], sineResults[i]);
    }

    // Free memory
    cudaFree(d_angles);
    cudaFree(d_sineResults);
    free(angles);
    free(sineResults);

    return 0;
}
