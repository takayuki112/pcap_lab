#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

#define THREADS_PER_BLOCK 256

__global__ void scan_kernel(int* d_in, int* d_out, int n) {
    extern __shared__ int temp[];
    int tid = threadIdx.x;
    int gid = blockIdx.x * blockDim.x + tid;
    
    temp[tid] = (gid < n) ? d_in[gid] : 0;
    __syncthreads();
    
    for (int stride = 1; stride < blockDim.x; stride *= 2) {
        int val = (tid >= stride) ? temp[tid - stride] : 0;
        __syncthreads();
        if (tid >= stride) temp[tid] += val;
        __syncthreads();
    }
    
    if (gid < n) d_out[gid] = temp[tid];
}

int main() {
    int n;
    printf("Enter array size: ");
    scanf("%d", &n);
    
    int* h_in = (int*)malloc(n * sizeof(int));
    int* h_out = (int*)malloc(n * sizeof(int));
    
    printf("Enter %d integers:\n", n);
    for (int i = 0; i < n; i++) scanf("%d", &h_in[i]);
    
    int *d_in, *d_out;
    cudaMalloc(&d_in, n * sizeof(int));
    cudaMalloc(&d_out, n * sizeof(int));
    
    cudaMemcpy(d_in, h_in, n * sizeof(int), cudaMemcpyHostToDevice);
    
    dim3 block(THREADS_PER_BLOCK);
    dim3 grid((n + THREADS_PER_BLOCK - 1) / THREADS_PER_BLOCK);
    scan_kernel<<<grid, block, THREADS_PER_BLOCK * sizeof(int)>>>(d_in, d_out, n);
    
    cudaMemcpy(h_out, d_out, n * sizeof(int), cudaMemcpyDeviceToHost);
    
    printf("\nInclusive scan result:\n");
    for (int i = 0; i < n; i++) {
        printf("%d ", h_out[i]);
    }
    printf("\n");
    
    free(h_in); free(h_out);
    cudaFree(d_in); cudaFree(d_out);
    
    return 0;
}