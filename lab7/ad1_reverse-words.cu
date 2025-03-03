#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <cuda_runtime.h>

#define MAX_SENTENCE_LENGTH 1024

__global__ void reverseWords(char *sentence, int *wordStarts, int *wordEnds, int wordCount) {
    int idx = threadIdx.x + blockIdx.x * blockDim.x;

    if (idx < wordCount) {
        int start = wordStarts[idx];
        int end = wordEnds[idx];

        while (start < end) {
            char temp = sentence[start];
            sentence[start] = sentence[end];
            sentence[end] = temp;
            start++;
            end--;
        }
    }
}

int main(void) {
    char sentence[MAX_SENTENCE_LENGTH];
    char *d_sentence;
    int *d_wordStarts, *d_wordEnds;
    int wordCount = 0;

    printf("Enter a sentence: ");
    fgets(sentence, MAX_SENTENCE_LENGTH, stdin);

    sentence[strcspn(sentence, "\n")] = '\0';

    int sentenceLength = strlen(sentence);

    int wordStarts[MAX_SENTENCE_LENGTH];
    int wordEnds[MAX_SENTENCE_LENGTH];

    
    for (int i = 0; i < sentenceLength; i++) {
        if (sentence[i] != ' ') {
            wordStarts[wordCount] = i;
            while (i < sentenceLength && sentence[i] != ' ') {
                i++;
            }
            wordEnds[wordCount] = i - 1;
            wordCount++;
        }
    }

    cudaMalloc((void**)&d_sentence, sizeof(char) * (sentenceLength + 1));
    cudaMalloc((void**)&d_wordStarts, sizeof(int) * wordCount);
    cudaMalloc((void**)&d_wordEnds, sizeof(int) * wordCount);

    cudaMemcpy(d_sentence, sentence, sizeof(char) * (sentenceLength + 1), cudaMemcpyHostToDevice);
    cudaMemcpy(d_wordStarts, wordStarts, sizeof(int) * wordCount, cudaMemcpyHostToDevice);
    cudaMemcpy(d_wordEnds, wordEnds, sizeof(int) * wordCount, cudaMemcpyHostToDevice);

    int blockSize = 256;
    int gridSize = (wordCount + blockSize - 1) / blockSize;
    reverseWords<<<gridSize, blockSize>>>(d_sentence, d_wordStarts, d_wordEnds, wordCount);

    cudaError_t error = cudaGetLastError();
    if (error != cudaSuccess) {
        printf("CUDA Error: %s\n", cudaGetErrorString(error));
    }

    cudaMemcpy(sentence, d_sentence, sizeof(char) * (sentenceLength + 1), cudaMemcpyDeviceToHost);

    printf("Reversed sentence: %s\n", sentence);

    cudaFree(d_sentence);
    cudaFree(d_wordStarts);
    cudaFree(d_wordEnds);

    return 0;
}