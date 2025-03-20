#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>

__device__ int comp(int n) {
    int b = 0;
    int t = n;
    while (t > 0) {
        b++;
        t >>= 1;
    }
    
    if (b == 0) return 0;
    
    int m = (1 << b) - 1;
    return n ^ m;
}

__global__ void repNB(int *m, int r, int c) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= r * c) return;
    
    int row = i / c;
    int col = i % c;
    
    if (row == 0 || row == r - 1 || col == 0 || col == c - 1) {
        return;
    }
    
    m[i] = comp(m[i]);
}

int main(void) {
    int *m, *d;
    int r, c;
    
    printf("Enter the number of rows and columns: ");
    scanf("%d %d", &r, &c);
    
    m = (int*)malloc(r * c * sizeof(int));
    
    printf("Enter the matrix elements (%d x %d):\n", r, c);
    for (int i = 0; i < r * c; i++) {
        scanf("%d", &m[i]);
    }
    
    cudaMalloc((void**)&d, r * c * sizeof(int));
    cudaMemcpy(d, m, r * c * sizeof(int), cudaMemcpyHostToDevice);
    
    int tpb = 16;
    int bpg = (r * c + tpb - 1) / tpb;
    
    repNB<<<bpg, tpb>>>(d, r, c);
    
    cudaMemcpy(m, d, r * c * sizeof(int), cudaMemcpyDeviceToHost);
    
    printf("\nResultant Matrix:\n");
    for (int i = 0; i < r; i++) {
        for (int j = 0; j < c; j++) {
            int v = m[i * c + j];
            
            if (i == 0 || i == r - 1 || j == 0 || j == c - 1) {
                printf("%d\t", v);
            } else {
                int t = v;
                int b = 0;
                while (t > 0) {
                    b++;
                    t >>= 1;
                }
                b = (b == 0) ? 1 : b;
                
                for (int k = b - 1; k >= 0; k--) {
                    printf("%d", (v >> k) & 1);
                }
                printf("\t");
            }
        }
        printf("\n");
    }
    
    cudaFree(d);
    free(m);
    
    return 0;
}