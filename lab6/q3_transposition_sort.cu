#include <stdio.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>
#include <stdbool.h>

__global__ void swap_step(int *A, int N, bool even){ 
    int i = threadIdx.x + blockIdx.x * blockDim.x;
    if(i<N-1 && (i%2==0) == even){
        if(A[i] > A[i+1]){
            int t = A[i];
            A[i] = A[i+1];
            A[i+1] = t;
        }
    }
}

int main(void){
    int N;
    int *A, *dA;

    printf("Enter size of the input array to be sorted: ");
    scanf("%d", &N);

    int size = N*sizeof(int);
    A = (int*)malloc(size);

    printf("Enter %d elements to sort: \n", N);
    for(int i=0; i<N; i++) scanf("%d", &A[i]);

    cudaMalloc((void**)&dA, size);
    cudaMemcpy(dA, A, size, cudaMemcpyHostToDevice);

    int threadsPerBlock = 8;
    int blocksPerGrid = (N + threadsPerBlock - 1) / threadsPerBlock;

    //even-odd sorting logic
    for(int i=0; i<=N/2; i++){
        //check_swap_all_evens
        swap_step<<<threadsPerBlock, blocksPerGrid>>>(dA, N, true);
        //check_swap_all_odds
        swap_step<<<threadsPerBlock, blocksPerGrid>>>(dA, N, false);
    }
    cudaMemcpy(A, dA, size, cudaMemcpyDeviceToHost);

    printf("Sorted array:\n");
    for(int i=0; i<N; i++) printf("%d  ", A[i]);
    printf("\n");

    cudaFree(dA);
    free(A);
    
}