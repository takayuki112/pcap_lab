#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>

#define TILE_WIDTH 2

__global__ void matmul_shared(int *a, int *b, int *c, int ha, int wahb, int wb) {
    __shared__ int sharedA[TILE_WIDTH][TILE_WIDTH];
    __shared__ int sharedB[TILE_WIDTH][TILE_WIDTH];

    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    
    int sum = 0;

    for (int t = 0; t < (wahb + TILE_WIDTH - 1) / TILE_WIDTH; ++t) {
        int a_col = t * TILE_WIDTH + threadIdx.x;
        int b_row = t * TILE_WIDTH + threadIdx.y;
        
        sharedA[threadIdx.y][threadIdx.x] = (row < ha && a_col < wahb) ? a[row * wahb + a_col] : 0;
        sharedB[threadIdx.y][threadIdx.x] = (b_row < wahb && col < wb) ? b[b_row * wb + col] : 0;

        __syncthreads();

        for (int k = 0; k < TILE_WIDTH; ++k) {
            sum += sharedA[threadIdx.y][k] * sharedB[k][threadIdx.x];
        }

        __syncthreads();
    }

    if (row < ha && col < wb) {
        c[row * wb + col] = sum;
    }
}

int main(void) {
    int ha, wahb, wb, i;
    int *a, *b, *c, *da, *db, *dc;

    printf("Enter 3 dimensions ha, wa=hb, wb: \n");
    scanf("%d%d%d", &ha, &wahb, &wb);

    a = (int*)malloc(sizeof(int) * ha * wahb);
    b = (int*)malloc(sizeof(int) * wahb * wb);
    c = (int*)malloc(sizeof(int) * ha * wb);

    printf("Enter Matrix A (%d elements): \n", ha * wahb);
    for (i = 0; i < ha * wahb; i++) scanf("%d", &a[i]);

    printf("Enter Matrix B (%d elements): \n", wahb * wb);
    for (i = 0; i < wahb * wb; i++) scanf("%d", &b[i]);

    cudaMalloc((void**)&da, sizeof(int) * ha * wahb);
    cudaMalloc((void**)&db, sizeof(int) * wahb * wb);
    cudaMalloc((void**)&dc, sizeof(int) * ha * wb);

    cudaMemcpy(da, a, sizeof(int) * ha * wahb, cudaMemcpyHostToDevice);
    cudaMemcpy(db, b, sizeof(int) * wahb * wb, cudaMemcpyHostToDevice);

    dim3 blockSize(TILE_WIDTH, TILE_WIDTH);
    dim3 gridSize((wb + blockSize.x - 1) / blockSize.x,
                  (ha + blockSize.y - 1) / blockSize.y);

    matmul_shared<<<gridSize, blockSize>>>(da, db, dc, ha, wahb, wb);

    cudaMemcpy(c, dc, sizeof(int) * ha * wb, cudaMemcpyDeviceToHost);

    printf("Resultant matrix: \n");
    for (i = 0; i < ha * wb; i++) {
        if (i % wb == 0) printf("\n");
        printf("%d \t", c[i]);
    }
    printf("\n");

    cudaFree(da);
    cudaFree(db);
    cudaFree(dc);
    free(a);
    free(b);
    free(c);

    return 0;
}