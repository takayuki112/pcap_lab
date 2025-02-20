#include <stdio.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

__global__ void conv_1d(float *N, float *M, float *P, int Mask_width, int Width){
    int i = threadIdx.x + blockIdx.x * blockDim.x;

    float Pvalue = 0;
    int N_start_point = i- (Mask_width/2);
    for(int j = 0; j < Mask_width; j++){
        if(N_start_point + j >= 0 && N_start_point + j < Width)
            Pvalue += N[N_start_point + j] * M[j];
    }
    P[i] = Pvalue;
}

int main(void){
    int Width = 7;
    int Mask_width = 5;

    printf("Enter Width and Mask-Width:\n");
    scanf("%d%d", &Width, &Mask_width);

    int sizeN = Width*sizeof(float);
    int sizeM = Mask_width*sizeof(float);

    float *N = (float*)malloc(sizeN);
    float *M = (float*)malloc(sizeM);
    float *P = (float*)malloc(sizeN);

    //Initialize values in M and N
    printf("Enter the %d elements in N\n", Width);
    for(int i=0; i<Width; i++) scanf("%f", &N[i]);

    printf("Enter the %d elements in Mask-M\n", Mask_width);
    for(int i=0; i<Mask_width; i++) scanf("%f", &M[i]);
    
    float *dN, *dM, *dP;
    cudaMalloc((void**)&dN, sizeN);
    cudaMalloc((void**)&dM, sizeM);
    cudaMalloc((void**)&dP, sizeN);

    cudaMemcpy(dN, N, sizeN, cudaMemcpyHostToDevice);
    cudaMemcpy(dM, M, sizeM, cudaMemcpyHostToDevice);

    int threadsPerBlock = 256;
    int blocksPerGrid = (Width + threadsPerBlock - 1) / threadsPerBlock;
    
    conv_1d<<<blocksPerGrid, threadsPerBlock>>>(dN, dM, dP, Mask_width, Width);

    cudaMemcpy(P, dP, sizeN, cudaMemcpyDeviceToHost);

    printf("\nResult - P : \n");
    for(int i = 0; i < Width; i++)
        printf("%.1f \t", P[i]);

    printf("\n");

    cudaFree(dN);
    cudaFree(dM);
    cudaFree(dP);
    free(N);
    free(M);
    free(P);
}