#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

__global__ void oddEvenSortStep(float *arr, int N, int phase) {
    int index = threadIdx.x + blockIdx.x * blockDim.x;
    int i = index * 2 + phase;  

    if (i < N - 1 && arr[i] > arr[i + 1]) {
        float temp = arr[i];
        arr[i] = arr[i + 1];
        arr[i + 1] = temp;
    }
}

void oddEvenSort(float *arr, int N) {
    float *d_arr;
    size_t size = N * sizeof(float);
    
    cudaMalloc((void **)&d_arr, size);
    cudaMemcpy(d_arr, arr, size, cudaMemcpyHostToDevice);

    int threadsPerBlock = 256;
    int blocksPerGrid = (N / 2 + threadsPerBlock - 1) / threadsPerBlock;

    for (int step = 0; step < N; step++) {
        oddEvenSortStep<<<blocksPerGrid, threadsPerBlock>>>(d_arr, N, step % 2);
        cudaDeviceSynchronize();
    }

    cudaMemcpy(arr, d_arr, size, cudaMemcpyDeviceToHost);
    cudaFree(d_arr);
}

int main() {
    int N = 16;
    float arr[N];

    printf("\nUnsorted array:\n");
    for (int i = 0; i < N; i++) {
        arr[i] = (float)(rand() % 100);
        printf("%.1f ", arr[i]);
    }
    printf("\n");

    oddEvenSort(arr, N);

    printf("\nSorted array:\n");
    for (int i = 0; i < N; i++) {
        printf("%.1f ", arr[i]);
    }
    printf("\n");

    return 0;
}
