#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>

__global__ void add_ele(int *a, int *b, int *r, int m, int n){

    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if(idx < m*n) r[idx] = a[idx] + b[idx];            
}

int main(void){
    int *a, *b, *c, *da, *db, *dc;
    int m, n, i, j; // m rows, n columns

    printf("Enter the dimensions of the matrices: ");
    scanf("%d%d", &m, &n);

    a = (int*) malloc(sizeof(int) * m*n);
    b = (int*) malloc(sizeof(int) * m*n);
    c = (int*) malloc(sizeof(int) * m*n);

    printf("\nEnter %d x %d elements of matrix a: \n", m, n);
    for(i=0; i<m*n; i++) scanf("%d", &a[i]);

    printf("\nEnter %d x %d elements of matrix b: \n", m, n);
    for(i=0; i<m*n; i++) scanf("%d", &b[i]);

    cudaMalloc((void**)&da, sizeof(int)*m*n);
    cudaMalloc((void**)&db, sizeof(int)*m*n);
    cudaMalloc((void**)&dc, sizeof(int)*m*n);

    cudaMemcpy(da, a, sizeof(int)*m*n, cudaMemcpyHostToDevice);
    cudaMemcpy(db, b, sizeof(int)*m*n, cudaMemcpyHostToDevice);

    int threadsPerBlock = 16;
    int blocksPerGrid = (m*n + threadsPerBlock - 1)/threadsPerBlock;

    add_ele<<<threadsPerBlock, blocksPerGrid>>>(da, db, dc, m, n);

    cudaMemcpy(c, dc, sizeof(int)*m*n, cudaMemcpyDeviceToHost);

    printf("\nResultant Matrix: \n");
    for(i=0; i<m; i++){
        for(j=0; j<n; j++) printf("%d\t", c[i*n + j]);
        printf("\n");
    }

}