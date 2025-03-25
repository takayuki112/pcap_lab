#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

#define MAX_K 256
#define THREADS_PER_BLOCK 256

__constant__ int dk[MAX_K];

__global__ void conv1d(int* in, int* out, int n, int k) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    
    if (i < n) {
        int r = 0;
        int ks = max(0, k - 1 - i);
        int ke = min(k, n - i + k - 1);
        
        for (int j = ks; j < ke; j++) {
            r += in[i - k + 1 + j] * dk[j];
        }
        out[i] = r;
    }
}

int main() {
    int n, k;
    
    printf("Input size: ");
    scanf("%d", &n);
    printf("Kernel size (max %d): ", MAX_K);
    scanf("%d", &k);
    
    if (k > MAX_K) {
        printf("Error: Kernel too big\n");
        return 1;
    }

    int *hi = (int*)malloc(n * sizeof(int));
    int *ho = (int*)malloc(n * sizeof(int));
    int *hk = (int*)malloc(k * sizeof(int));
    
    printf("Enter %d input values:\n", n);
    for (int i = 0; i < n; i++) scanf("%d", &hi[i]);
    
    printf("Enter %d kernel values:\n", k);
    for (int i = 0; i < k; i++) scanf("%d", &hk[i]);
    
    int *di, *dout;
    cudaMalloc(&di, n * sizeof(int));
    cudaMalloc(&dout, n * sizeof(int));
    
    cudaMemcpyToSymbol(dk, hk, k * sizeof(int));
    cudaMemcpy(di, hi, n * sizeof(int), cudaMemcpyHostToDevice);
    
    int blks = (n + THREADS_PER_BLOCK - 1) / THREADS_PER_BLOCK;
    conv1d<<<blks, THREADS_PER_BLOCK>>>(di, dout, n, k);
    
    cudaMemcpy(ho, dout, n * sizeof(int), cudaMemcpyDeviceToHost);
    
    printf("\nResult:\n");
    for (int i = 0; i < n; i++) {
        printf("%d ", ho[i]);
        if ((i+1) % 10 == 0) printf("\n");
    }
    printf("\n");
    
    free(hi); free(ho); free(hk);
    cudaFree(di); cudaFree(dout);
    
    return 0;
}