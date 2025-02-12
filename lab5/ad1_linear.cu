#include <stdio.h>
#include "cuda_runtime.h"

__global__ void applyLinearFunction(float *x, float *y, float w, float b, int N) {
    int index = threadIdx.x + blockIdx.x * blockDim.x;
    if (index < N) {
        y[index] = w * x[index] + b;  
    }
}

int main(void) {
    int N = 1024;  
    int size = N * sizeof(float);

    float *x, *y;      
    float *d_x, *d_y;  

    // Define w and b
    float w = 2.0f;  
    float b = 1.0f;  

    x = (float*)malloc(size);
    y = (float*)malloc(size);

    // Initialize input array
    for (int i = 0; i < N; i++) {
        x[i] = i * 0.01;  
    }

    cudaMalloc((void**)&d_x, size);
    cudaMalloc((void**)&d_y, size);

    cudaMemcpy(d_x, x, size, cudaMemcpyHostToDevice);

    int threadsPerBlock = 256;
    int blocksPerGrid = (N + threadsPerBlock - 1) / threadsPerBlock;

    applyLinearFunction<<<blocksPerGrid, threadsPerBlock>>>(d_x, d_y, w, b, N);

    cudaMemcpy(y, d_y, size, cudaMemcpyDeviceToHost);

    printf("First few results...\n");
    printf("Index \t x \t\t y = wx + b\n");
    printf("---------------------------------------------\n");
    for (int i = 0; i < 16; i++) {  
        printf("%d \t %f \t %f\n", i, x[i], y[i]);
    }

    // Free memory
    cudaFree(d_x);
    cudaFree(d_y);
    free(x);
    free(y);

    return 0;
}
