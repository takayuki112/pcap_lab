#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>

__global__ void calc_rowsums(int *a, int *b, int m, int n){

    int row_idx = blockIdx.x * blockDim.x + threadIdx.x;

    if(row_idx < m){
        int sum = 0;
        for(int col = 0; col<n; col++) sum+= a[n * row_idx + col];

        //replace all even numbered elements with rowsum
        for(int col = 0; col<n; col++){
            int ele_no = n*row_idx + col;
            if(ele_no %2 != 0) b[ele_no] = sum;
        }
    }
}

__global__ void calc_colsums(int *a, int *b, int m, int n){

    int col_idx = blockIdx.x * blockDim.x + threadIdx.x;

    if(col_idx < n){
        int sum = 0;
        for(int row = 0; row<m; row++) sum+= a[n * row + col_idx];

        //replace all odd numbered elements with colsum !
        for(int row = 0; row<m; row++){
            int ele_no = n*row + col_idx;
            if(ele_no %2 == 0) b[ele_no] = sum;
        }
    }
}

int main(void){
    int *a, *b, *da, *db;
    int m, n, i, j; // m rows, n columns

    printf("Enter the dimensions of the matrices: ");
    scanf("%d%d", &m, &n);

    a = (int*) malloc(sizeof(int) * m*n);
    b = (int*) malloc(sizeof(int) * m*n);

    printf("\nEnter %d x %d elements of matrix a: \n", m, n);
    for(i=0; i<m*n; i++) scanf("%d", &a[i]);

    cudaMalloc((void**)&da, sizeof(int)*m*n);
    cudaMalloc((void**)&db, sizeof(int)*m*n);

    cudaMemcpy(da, a, sizeof(int)*m*n, cudaMemcpyHostToDevice);
    cudaMemcpy(db, da, sizeof(int)*m*n, cudaMemcpyDeviceToDevice);

    int threadsPerBlock = 16;

    int blocksPerGrid = (m + threadsPerBlock - 1)/threadsPerBlock;
    calc_rowsums<<<threadsPerBlock, blocksPerGrid>>>(da, db, m, n);

    blocksPerGrid = (n + threadsPerBlock - 1)/threadsPerBlock;
    calc_colsums<<<threadsPerBlock, blocksPerGrid>>>(da, db, m, n);

    cudaMemcpy(b, db, sizeof(int)*m*n, cudaMemcpyDeviceToHost);

    printf("\nResultant Matrix B: \n");
    for(i=0; i<m; i++){
        for(j=0; j<n; j++) printf("%d\t", b[i*n + j]);
        printf("\n");
    }

}