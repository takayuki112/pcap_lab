#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>
#include <device_launch_parameters.h>


__global__ void matmul_cols(int *a, int *b, int *c, int ha, int wahb, int wb){
    int colid = threadIdx.x;

    for(int rowid=0; rowid<ha; rowid++){
        int sum = 0;
        for(int k=0; k<wahb; k++) sum += a[rowid*wahb + k] * b[k*wb + colid];

        c[rowid*wb + colid] = sum;
    }
}


int main(void){
    int ha, wahb, wb, i;
    int *a, *b, *c, *da, *db, *dc;

    printf("Enter 3 dimensions ha, wa=hb, wb: \n");
    scanf("%d%d%d", &ha, &wahb, &wb);

    a = (int*)malloc(sizeof(int) * ha*wahb);
    b = (int*)malloc(sizeof(int) * wahb*wb);
    c = (int*)malloc(sizeof(int) * ha*wb);

    printf("Enter Matrix A (%d elements): \n", ha*wahb);
    for(i=0; i<ha*wahb; i++) scanf("%d", &a[i]);

    printf("Enter Matrix B (%d elements): \n", wahb*wb);
    for(i=0; i<wahb*wb; i++) scanf("%d", &b[i]);

    cudaMalloc((void**)&da, sizeof(int)*ha*wahb);
    cudaMalloc((void**)&db, sizeof(int)*wahb*wb);
    cudaMalloc((void**)&dc, sizeof(int)*ha*wb);

    cudaMemcpy(da, a, sizeof(int)*ha*wahb, cudaMemcpyHostToDevice);
    cudaMemcpy(db, b, sizeof(int)*wahb*wb, cudaMemcpyHostToDevice);

    int blocksPerGrid = 1;
    int threadsPerBlock = wb;
    
    matmul_cols<<<blocksPerGrid, threadsPerBlock>>>(da, db, dc, ha, wahb, wb);

    cudaMemcpy(c, dc, sizeof(int)*ha*wb, cudaMemcpyDeviceToHost);
    
    printf("Resultant matrix: \n");
    for(i=0; i<ha*wb; i++){
        if(i%wb==0) printf("\n");
        printf("%d \t", c[i]);
    }

    cudaFree(da); cudaFree(db); cudaFree(dc);
    free(a); free(b); free(c);


}
