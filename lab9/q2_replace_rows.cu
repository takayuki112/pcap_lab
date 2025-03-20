#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>
#include <math.h>

__device__ int power(int a, int b){
    int r = 1;
    for(int i=0; i<b; i++) r*=a;
    return r;
}

__global__ void rep_row(int *a, int m, int n){

    int row_idx = blockIdx.x * blockDim.x + threadIdx.x;

    if(row_idx < m){
        for(int col = 0; col<n; col++) 
            a[n * row_idx + col] = power(a[n * row_idx + col], row_idx+1) ;            
    }
}

int main(void){
    int *a, *da;
    int m, n, i, j; // m rows, n columns

    printf("Enter the dimensions of the matrices: ");
    scanf("%d%d", &m, &n);

    a = (int*) malloc(sizeof(int) * m*n);

    printf("\nEnter %d x %d elements of matrix a: \n", m, n);
    for(i=0; i<m*n; i++) scanf("%d", &a[i]);


    cudaMalloc((void**)&da, sizeof(int)*m*n);
    cudaMemcpy(da, a, sizeof(int)*m*n, cudaMemcpyHostToDevice);

    int threadsPerBlock = 16;
    int blocksPerGrid = (m + threadsPerBlock - 1)/threadsPerBlock;

    rep_row<<<threadsPerBlock, blocksPerGrid>>>(da, m, n);

    cudaMemcpy(a, da, sizeof(int)*m*n, cudaMemcpyDeviceToHost);
    printf("\nResultant Matrix: \n");
    for(i=0; i<m; i++){
        for(j=0; j<n; j++) printf("%d\t", a[i*n + j]);
        printf("\n");
    }

}