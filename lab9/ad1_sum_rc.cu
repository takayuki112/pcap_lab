#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>

__global__ void calcRowColSum(int *in, int *out, int r, int c) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx >= r * c) return;
    
    int row = idx / c;
    int col = idx % c;
    
    int sum = 0;
    
    for (int j = 0; j < c; j++) sum += in[row * c + j];
    for (int i = 0; i < r; i++) sum += in[i * c + col];
    
    out[idx] = sum;
}

int main(void) {
    int *a, *r, *da, *dr;
    int m, n;
    
    printf("Enter the number of rows and columns: ");
    scanf("%d %d", &m, &n);
    
    a = (int*)malloc(m * n * sizeof(int));
    r = (int*)malloc(m * n * sizeof(int));
    
    printf("Enter the matrix elements (%d x %d):\n", m, n);
    for (int i = 0; i < m * n; i++) {
        scanf("%d", &a[i]);
    }
    
    cudaMalloc((void**)&da, m * n * sizeof(int));
    cudaMalloc((void**)&dr, m * n * sizeof(int));
    
    cudaMemcpy(da, a, m * n * sizeof(int), cudaMemcpyHostToDevice);
    
    int tpb = 256;
    int bpg = (m * n + tpb - 1) / tpb;
    
    calcRowColSum<<<bpg, tpb>>>(da, dr, m, n);
    
    cudaMemcpy(r, dr, m * n * sizeof(int), cudaMemcpyDeviceToHost);
    
    printf("\nResultant Matrix (sum of row and column for each element):\n");
    for (int i = 0; i < m; i++) {
        for (int j = 0; j < n; j++) {
            printf("%d\t", r[i * n + j]);
        }
        printf("\n");
    }
    
    cudaFree(da);
    cudaFree(dr);
    free(a);
    free(r);
    
    return 0;
}