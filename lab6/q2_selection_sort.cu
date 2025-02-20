#include <stdio.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>

__global__ void sort_step(int *A, int *R, int N){
    int i = threadIdx.x + blockIdx.x * blockDim.x;
    if(i<N){
        // count the number of elements smaller than A[i], and put it in the correct place in R[i]
        int smaller = 0;
        for(int j= 0; j<N; j++){
            if(A[j] < A[i] || (A[j] == A[i] && j<i)) //extra logic for duplicate case
                smaller++;
        }
        R[smaller] = A[i];
    }
}

int main(void){
    int N;
    int *A, *R, *dA, *dR;

    printf("Enter size of the input array to be sorted: ");
    scanf("%d", &N);

    int size = N*sizeof(int);
    A = (int*)malloc(size);
    R = (int*)malloc(size);

    printf("Enter %d elements to sort: \n", N);
    for(int i=0; i<N; i++) scanf("%d", &A[i]);

    cudaMalloc((void**)&dA, size);
    cudaMalloc((void**)&dR, size);
    cudaMemcpy(dA, A, size, cudaMemcpyHostToDevice);

    int threadsPerBlock = 8;
    int blocksPerGrid = (N + threadsPerBlock - 1) / threadsPerBlock;

    sort_step<<<blocksPerGrid, threadsPerBlock>>>(dA, dR, N);

    cudaMemcpy(R, dR, size, cudaMemcpyDeviceToHost);

    printf("Sorted array:\n");
    for(int i=0; i<N; i++) printf("%d  ", R[i]);
    printf("\n");

    cudaFree(dA);
    cudaFree(dR);
    free(A);
    free(R);
    
}