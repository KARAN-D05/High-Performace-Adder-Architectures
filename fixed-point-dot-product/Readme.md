# Module 01 — Fixed-Point Dot Product

## What Problem Does This Solve

Given two vectors A and B of n numbers, the dot product is:

```
result = A[0]*B[0] + A[1]*B[1] + ... + A[n-1]*B[n-1]
```

This single operation is the heartbeat of:
- Neural networks (every neuron computes a dot product)
- Digital filters (FIR filter output is a dot product of signal and coefficients)
- Matrix multiplication (every output element is a dot product of a row and column)
- Graphics (lighting, projection, every geometric operation)

If you can do dot product fast and cheap in hardware, you can do all of the above fast and cheap.

---

## The Naive Way — Floating Point

The obvious implementation uses floating-point numbers (float or double in C, REAL in Fortran).

**What floating point costs in hardware:**

A 32-bit floating-point multiplier requires approximately:
- ~1,000–3,000 logic gates
- 3–5 clock cycles latency
- Significant power consumption
- Large silicon area

An entire FPU (Floating Point Unit) is one of the most expensive blocks in a processor. Intel's FPU in early x86 chips was a separate co-processor chip entirely — it was too large to fit with the main CPU.

For a dot product of n elements, you need n floating-point multiplications and n-1 floating-point additions. At hardware cost of ~2000 gates per multiplier, even a length-8 dot product demands ~16,000 gates just for the multiplications.

---

## The Optimized Way — Fixed-Point Arithmetic

Fixed-point arithmetic represents numbers as integers, with an implied decimal point at a fixed position.

**Example with Q8.8 format** (8 bits integer, 8 bits fractional):
- The number 3.75 is stored as integer 960 (= 3.75 × 256)
- The number 1.5 is stored as integer 384 (= 1.5 × 256)
- Multiply: 960 × 384 = 368,640 — then shift right 8 bits → 1440 = 5.625 ✓

**What this costs in hardware:**

A fixed-point integer multiplier:
- ~100–300 logic gates (10x cheaper than floating point)
- 1 clock cycle latency (combinational, or 1 pipeline stage)
- Fraction of the power
- Fraction of the silicon area

The trade-off: you must manage the range and precision manually. Numbers can overflow. Precision is fixed. But for known-range inputs (neural network weights, filter coefficients), this is acceptable — and the hardware savings are enormous.

**This is exactly why:**
- Google TPU uses INT8 (8-bit integer) arithmetic
- NVIDIA Tensor Cores operate in FP16/BFloat16 (reduced precision)
- DSP chips have dedicated fixed-point MACs (Multiply-Accumulate units)
- Your Gate-Level Perceptron operates on binary/integer weights

---

## Hardware Connection — The MAC Unit

In hardware, dot product is implemented as a **MAC unit**:
**Multiply-Accumulate: result = result + (A[i] × B[i])**

One MAC unit, running n times, computes the full dot product.

```
         A[i]  B[i]
           |    |
           v    v
        [MULTIPLIER]
               |
               v
        [ADDER/ACCUMULATOR] <--- feedback loop (result so far)
               |
               v
            result
```

Every systolic array (Google TPU), every tensor core (NVIDIA GPU), every FIR filter hardware block is fundamentally an array of MAC units. The algorithm running inside each MAC is fixed-point arithmetic.

---

## Overflow — The Hardware Reality

When you multiply two Q8.8 numbers, the result needs 16 fractional bits. If your accumulator isn't wide enough, bits overflow and your result is silently wrong.

In hardware this is a real design constraint — you must size your accumulator register to handle worst-case accumulation without overflow. This module detects and reports overflow explicitly, the same way hardware status registers report it.

---

## Quantified Result

Running both implementations on vectors of length 8 with values in range [0.0, 4.0]:

| Method | Approximate Gate Cost (per multiply) | Precision Loss |
|---|---|---|
| Floating-point (naive) | ~2,000 gates | None |
| Fixed-point Q8.8 (optimized) | ~200 gates | < 0.4% for this range |

**~10x gate reduction** for < 0.4% precision loss on bounded inputs.

This is the algorithm-to-silicon tradeoff in one number.

---

## Files

- `fortran/dot_product.f90` — Fortran 90 implementation, math-forward
- `c/dot_product.c` — C implementation, bit-level detail visible

Both implementations:
- Use no external libraries
- Implement fixed-point from scratch using integer arithmetic
- Implement floating-point naive version for comparison
- Detect and report overflow
- Print quantified error between fixed and floating point results
