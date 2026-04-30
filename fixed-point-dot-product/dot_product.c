/*
 * Fixed-Point Dot Product - C Implementation
 * Q8.8 format: scale factor = 256 (2^8)
 * Compile: gcc -o dot_product dot_product.c -lm
 */

#include <stdio.h>
#include <stdint.h>   /* int32_t, int64_t — explicit bit-width types */
#include <math.h>     /* fabs() */

#define N         8
#define SCALE   256   /* 2^8 - fixed-point scaling factor */

int main(void) {

    /* Input vectors - real values */
    float A[N] = {1.5f, 2.25f, 0.75f, 3.0f, 1.125f, 2.5f, 0.5f, 1.75f};
    float B[N] = {2.0f, 1.5f,  3.25f, 0.5f, 2.75f,  1.0f, 3.5f, 2.25f};

    int32_t A_fx[N], B_fx[N];   /* Q8.8 encoded integers */
    int i;

    /* Encode: multiply by 256, round to nearest integer */
    for (i = 0; i < N; i++) {
        A_fx[i] = (int32_t)(A[i] * SCALE + 0.5f);
        B_fx[i] = (int32_t)(B[i] * SCALE + 0.5f);
    }

    /* --- METHOD 1: Naive floating-point --- */
    float fp_result = 0.0f;
    for (i = 0; i < N; i++)
        fp_result += A[i] * B[i];   /* ~2000 gates per multiply in hardware */

    /* --- METHOD 2: Fixed-point Q8.8 --- */
    int64_t acc = 0;   /* 64-bit accumulator — sized to prevent overflow */

    for (i = 0; i < N; i++) {
        /* Multiply two Q8.8 values → Q16.16 result, accumulate */
        acc += (int64_t)A_fx[i] * (int64_t)B_fx[i];   /* ~200 gates per multiply */
    }

    /* Right-shift by 8: Q16.16 → Q8.8. Free in hardware — just rewiring. */
    int32_t fx_raw    = (int32_t)(acc >> 8);
    float   fx_result = (float)fx_raw / (float)SCALE;

    /* Overflow check - mirrors hardware status flag behaviour */
    if (acc > (int64_t)0x7FFFFFFF)
        printf("WARNING: overflow — widen accumulator register\n");

    /* Results */
    float error = (fabs(fp_result - fx_result) / fp_result) * 100.0f;

    printf("Floating-point result : %.6f  (gate cost ~%d)\n", fp_result, N * 2000);
    printf("Fixed-point result    : %.6f  (gate cost ~%d)\n", fx_result, N * 200);
    printf("Precision loss        : %.4f%%\n", error);
    printf("Gate reduction        : ~10x\n");

    return 0;
}
