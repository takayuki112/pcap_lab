// write a cuda program to perform sparse matrix-vector multiplication, using csr storage format. 
// represent the input matrix as csr in the host code.

#include <cuda.h>
#include <stdio.h>
#include <stdlib.h>

void matrix_csr(int *A, int m, int n, int** data, int** col_idx, int** row_ptr, int* n_non0) {
    int nz_count = 0;
    for(int i=0; i<m*n; i++) if(A[i]!=0) nz_count++;
    
    *data = (int*)malloc(sizeof(int)*nz_count);
    *col_idx = (int*)malloc(sizeof(int)*nz_count);
    *row_ptr = (int*)malloc(sizeof(int)*(m+1)); 
    
    (*row_ptr)[0] = 0;
    nz_count = 0;
    for(int i=0; i<m; i++) {
        for(int j=0; j<n; j++) {
            int ele = A[n*i + j];
            if(ele != 0) {
                (*data)[nz_count] = ele;
                (*col_idx)[nz_count] = j;
                nz_count++;
            }
        }
        (*row_ptr)[i+1] = nz_count;
    }
    
    *n_non0 = nz_count;
}

__global__ void spmv_csr_kernel(int m, int *row_ptr, int *col_idx, int *data, int *x, int *y) {
    int row = blockIdx.x * blockDim.x + threadIdx.x;
    
    if (row < m) {
        int sum = 0;
        int row_start = row_ptr[row];
        int row_end = row_ptr[row + 1];
        
        for (int i = row_start; i < row_end; i++) {
            sum += data[i] * x[col_idx[i]];
        }
        
        y[row] = sum;
    }
}

int main(void){
    int m, n, i, j;
    printf("Enter dimensions m and n: ");
    scanf("%d%d", &m, &n);

    int *A = (int*)malloc(m*n*sizeof(int));
    int *v = (int*)malloc(n*sizeof(int));

    printf("Enter the %d x %d entries of the matrix A:\n", m, n);
    for(i=0; i<m; i++){
        for(j=0; j<n; j++) scanf("%d", &A[n*i + j]);
    }

    printf("Enter the %d dimensional vector:\n", n);
    for(i=0; i<n; i++) scanf("%d", &v[i]);

    int *data, *col_idx, *row_ptr, n_non0;
    matrix_csr(A, m, n, &data, &col_idx, &row_ptr, &n_non0);

    int *d_data, *d_col_idx, *d_row_ptr, *d_v, *d_result;
    cudaMalloc((void**)&d_data, n_non0 * sizeof(int));
    cudaMalloc((void**)&d_col_idx, n_non0 * sizeof(int));
    cudaMalloc((void**)&d_row_ptr, (m+1) * sizeof(int));
    cudaMalloc((void**)&d_v, n * sizeof(int));
    cudaMalloc((void**)&d_result, m * sizeof(int));
    
    cudaMemcpy(d_data, data, n_non0 * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_col_idx, col_idx, n_non0 * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_row_ptr, row_ptr, (m+1) * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_v, v, n * sizeof(int), cudaMemcpyHostToDevice);
    
    int *result = (int*)malloc(m * sizeof(int));

    int blockSize = 256;
    int numBlocks = (m + blockSize - 1) / blockSize;
    spmv_csr_kernel<<<numBlocks, blockSize>>>(m, d_row_ptr, d_col_idx, d_data, d_v, d_result);
    
    cudaMemcpy(result, d_result, m * sizeof(int), cudaMemcpyDeviceToHost);
    
    printf("Result vector:\n");
    for (i = 0; i < m; i++) {
        printf("%d ", result[i]);
    }
    printf("\n");
    
    free(A); free(v); free(data); free(col_idx); free(row_ptr); free(result);
    cudaFree(d_data); cudaFree(d_col_idx); cudaFree(d_row_ptr); cudaFree(d_v); cudaFree(d_result);
    
    return 0; 

}