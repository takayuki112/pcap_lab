#include <stdio.h>
#include <math.h>
#include "cuda_runtime.h"

__global__ void swapMinAheadOfMe(int* a, int N){
    int i = threadIdx.x + blockIdx.x * blockDim.x;
    
    if (i <= N) {
        int minidx = i;
        for (int j = i + 1; j < N; j++) {
            if (a[j] < a[minidx]) {
                minidx = j;
            }
        }
        
        if (minidx != i) {
            int temp = a[i];
            a[i] = a[minidx];
            a[minidx] = temp;
        }
        
        printf("Thread %d: Swapped %d with %d, coz i = %d and minidx = %d\n", i, a[i], a[minidx], i, minidx);
    }
}

int main() {
    int N = 10;
    int h_a[N] = {29, 10, 14, 37, 13, 6, 23, 12, 44, 19};
    for (int i = 0; i < N; i++) {
        printf("%d ", h_a[i]);
    }
    printf("\n");

    int* d_a;
    cudaMalloc(&d_a, N * sizeof(int));
    cudaMemcpy(d_a, h_a, N * sizeof(int), cudaMemcpyHostToDevice);

    int blockSize = N;
    int gridSize = 1;
    swapMinAheadOfMe<<<gridSize, blockSize>>>(d_a, N);

    cudaMemcpy(h_a, d_a, N * sizeof(int), cudaMemcpyDeviceToHost);

    printf("Sorted array: ");
    for (int i = 0; i < N; i++) {
        printf("%d ", h_a[i]);
    }
    printf("\n");

    cudaFree(d_a);

    return 0;
}
