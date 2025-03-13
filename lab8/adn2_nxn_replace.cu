#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>

__device__ int fact(int n){
    if(n<=1) return 1;
    return n*fact(n-1);
}

__device__ int sum_digits(int n){
    int sum = 0;
    while(n!=0){
        sum += n%10;
        n/=10;
    }
    return sum;
}

__global__ void raplace(int *a, int *b, int n){
    int r = threadIdx.x;
    int c = threadIdx.y;

    if(r==c) b[n*r + c] = 0;                        //principal diagonal = 0
    if(r>c) b[n*r + c] = sum_digits(b[n*r + c]);    //below diagonal
    if(r<c) b[n*r + c] = fact(b[n*r + c]);          //above diag

}

int main(void){
    int *a, *b, *da, *db;
    int n, i, j; // m rows, n columns

    printf("Enter the dimension of the sqr matrix: ");
    scanf("%d", &n);

    a = (int*) malloc(sizeof(int) * n*n);
    b = (int*) malloc(sizeof(int) * n*n);

    printf("\nEnter %d x %d elements of matrix a: \n", n, n);
    for(i=0; i<n*n; i++) scanf("%d", &a[i]);

    cudaMalloc((void**)&da, sizeof(int)*n*n);
    cudaMalloc((void**)&db, sizeof(int)*n*n);

    cudaMemcpy(da, a, sizeof(int)*n*n, cudaMemcpyHostToDevice);
    cudaMemcpy(db, da, sizeof(int)*n*n, cudaMemcpyDeviceToDevice);

    
    int blocksPerGrid = 1;
    dim3 threadsPerBlock(n, n, 1);

    raplace<<<blocksPerGrid, threadsPerBlock>>>(da, db, n);

    cudaMemcpy(b, db, sizeof(int)*n*n, cudaMemcpyDeviceToHost);

    printf("\nResultant Matrix B: \n");
    for(i=0; i<n; i++){
        for(j=0; j<n; j++) printf("%d\t", b[i*n + j]);
        printf("\n");
    }

}