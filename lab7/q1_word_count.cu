#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <cuda_runtime.h>

#define MAX_S 1024
#define MAX_W 64

__global__ void countWord(char *s, char *w, int sLen, int wLen, unsigned int *cnt) {
    int i = threadIdx.x + blockIdx.x * blockDim.x;
    if (i <= sLen - wLen) {
        bool match = true;
        for (int j = 0; j < wLen; j++) {
            if (s[i + j] != w[j]) {
                match = false;
                break;
            }
        }
        if (match) atomicAdd(cnt, 1);
    }
}

int main(void) {
    char s[MAX_S];
    char w[MAX_W];
    char *d_s, *d_w;
    unsigned int cnt = 0;
    unsigned int *d_cnt;

    printf("Enter a sentence: ");
    fgets(s, MAX_S, stdin);
    printf("Enter the word to count: ");
    scanf("%s", w);

    s[strcspn(s, "\n")] = '\0';

    int sLen = strlen(s);
    int wLen = strlen(w);

    cudaMalloc((void**)&d_s, sizeof(char) * (sLen + 1));
    cudaMalloc((void**)&d_w, sizeof(char) * (wLen + 1));
    cudaMalloc((void**)&d_cnt, sizeof(unsigned int));

    cudaMemcpy(d_s, s, sizeof(char) * (sLen + 1), cudaMemcpyHostToDevice);
    cudaMemcpy(d_w, w, sizeof(char) * (wLen + 1), cudaMemcpyHostToDevice);
    cudaMemcpy(d_cnt, &cnt, sizeof(unsigned int), cudaMemcpyHostToDevice);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start, 0);

    int bSize = 256;
    int gSize = (sLen + bSize - 1) / bSize;
    countWord<<<gSize, bSize>>>(d_s, d_w, sLen, wLen, d_cnt);

    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);

    float time;
    cudaEventElapsedTime(&time, start, stop);

    cudaError_t err = cudaGetLastError();
    if (err != cudaSuccess) {
        printf("CUDA Error: %s\n", cudaGetErrorString(err));
    }

    cudaMemcpy(&cnt, d_cnt, sizeof(unsigned int), cudaMemcpyDeviceToHost);

    printf("The word '%s' occurs %u times in the sentence.\n", w, cnt);
    printf("Time taken: %f milliseconds\n", time);

    cudaFree(d_s);
    cudaFree(d_w);
    cudaFree(d_cnt);

    cudaEventDestroy(start);
    cudaEventDestroy(stop);

    return 0;
}