# Fixed-Point Dot Product

## The Problem

Given two vectors A and B of n numbers, compute:

```
result = A[0]×B[0] + A[1]×B[1] + ... + A[n-1]×B[n-1]
```

This operation is called the **dot product** (also inner product). It is the single most executed operation in:

- Neural networks - every neuron computes a dot product of inputs and weights
- Digital FIR filters - output sample is dot product of input samples and filter coefficients
- Matrix multiplication - every output element is a dot product of a row and a column
- Graphics - lighting calculations, projections, every geometric transformation

If hardware can do this fast and cheap, all of the above become fast and cheap. This is why the dot product is the central operation that chip architects optimize for.

## What is Floating-Point and Why is it Expensive

A **floating-point number** (like C's `float` or `double`) stores a number in scientific notation in binary:

```
value = mantissa × 2^exponent
```

For example, the number 6.5 in 32-bit IEEE 754 floating point:
- Sign bit: 0 (positive)
- Exponent: 129 (stored as 10000001)
- Mantissa: 1.101 in binary (the leading 1 is implicit)

This representation can store a huge range of values (from ~10⁻³⁸ to ~10³⁸) with consistent relative precision. That flexibility is powerful but it has a cost.

**What a floating-point multiplier requires in hardware:**

To multiply two floating-point numbers, hardware must:
1. Add the exponents together
2. Multiply the mantissas (a large integer multiply)
3. Normalize the result (shift mantissa, adjust exponent)
4. Round to fit back in 23 bits
5. Handle special cases: zero, infinity, NaN

Each of these steps requires logic gates. A 32-bit floating-point multiplier costs approximately **1,000–3,000 logic gates** and takes **3–7 clock cycles** of latency. It is one of the most expensive arithmetic blocks in a processor.

For historical perspective: Intel's 8087 FPU (1980) was a separate chip entirely because the floating-point unit was too large to fit alongside the 8086 CPU. The FPU had 45,000 transistors.

## Fixed-Point Arithmetic - The Hardware-Efficient Alternative

**Fixed-point** represents numbers as plain integers, with a shared agreement that the binary point sits at a fixed position.

### The Q8.8 Format

Q8.8 means: 8 bits for the integer part, 8 bits for the fractional part. Total: 16 bits.

```
Bit layout:
[ 15 | 14 | 13 | 12 | 11 | 10 | 9 | 8 || 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 ]
[         integer part (8 bits)       ||     fractional part (8 bits)  ]
                                       ^
                               implied binary point
```

The scaling factor is 2⁸ = **256**. To encode a real number, multiply by 256 and round to integer:

| Real Value | × 256 | Stored Integer | Binary |
|---|---|---|---|
| 1.5 | 384 | 384 | 0000 0001 1000 0000 |
| 2.25 | 576 | 576 | 0000 0010 0100 0000 |
| 0.75 | 192 | 192 | 0000 0000 1100 0000 |
| 3.0 | 768 | 768 | 0000 0011 0000 0000 |

To decode: divide stored integer by 256.

**Hardware never actually divides.** The binary point is just an agreement between the designer and the circuit. The hardware operates on plain integers. The interpretation of where the decimal point sits is a human convention baked into the design.

### What Fixed-Point Multiplication Produces

When you multiply two Q8.8 numbers:

```
A_fixed × B_fixed = (A_real × 256) × (B_real × 256) = (A_real × B_real) × 256²
```

The result is in **Q16.16 format** - 16 fractional bits instead of 8. To get back to Q8.8, you right-shift by 8:

```
result_Q8.8 = (A_fixed × B_fixed) >> 8
```

Right-shifting by 8 divides by 256 — it moves the binary point back to its original position.

**Example:**
```
A = 1.5  →  A_fixed = 384
B = 2.0  →  B_fixed = 512

product = 384 × 512 = 196,608       (Q16.16)
>> 8:   196,608 / 256 = 768         (Q8.8)
decode: 768 / 256 = 3.0  ✓         (correct: 1.5 × 2.0 = 3.0)
```

### Why the Right Shift is Free in Hardware

In floating-point, after multiplication the result must be **normalized** — the mantissa shifted left or right by a variable amount, and the exponent adjusted accordingly. This requires:
- A leading zero counter (LZC) to detect how much to shift
- A barrel shifter to perform the variable shift
- Exponent adder/subtractor
- Rounding logic

Total cost: hundreds of gates, multiple cycles.

In fixed-point, the shift is always the same amount — it's **hardwired**. You connect bit[k] of the source wire to bit[k−8] of the destination wire. No logic gates. No clock cycles. Just routing.

This is one of the deepest insights in computer arithmetic: **a fixed shift costs nothing in hardware**.

---

## The MAC Unit — Hardware Implementation of Dot Product

In hardware, dot product is implemented as a **MAC unit** (Multiply-Accumulate):

```
result = result + (A[i] × B[i])
```

The hardware structure:

```
       A[i]        B[i]
        |            |
        v            v
    [MULTIPLIER — integer, ~200 gates]
              |
              v
         [ADDER]
              |
              +<————————————————— feedback
              |
         [REGISTER]  ← accumulator, holds running sum
              |
              v
           result
```

One MAC unit, clocked n times, computes the full dot product. This is the fundamental compute primitive in:

- **Google TPU** — a 256×256 array of INT8 MAC units (65,536 MACs)
- **NVIDIA Tensor Cores** — arrays of FP16/BFloat16 MAC units
- **DSP chips** — single-cycle MAC units, optimized for filter computations
- **Your Gate-Level Perceptron** — the weighted sum computation is a dot product

---

## Accumulator Width — A Real Design Constraint

When you accumulate N products in Q16.16 format, the accumulator must be wide enough to hold the maximum possible sum without overflow.

**Calculation for this module:**
- Max input value ≈ 3.5 → max Q8.8 encoding = 896
- Max single product = 896 × 896 = 802,816
- For N = 8 elements: max accumulator = 8 × 802,816 = 6,422,528
- This fits in 32 bits (max ~2.1 billion) — safe for these inputs
- But if N = 1000 and max input = 10.0: max accumulator = 1000 × 2560² = 6.5 billion → needs 64-bit

In hardware, you calculate this bound before choosing your register width. Too narrow: silent overflow, wrong answers. Too wide: wasted silicon area. This is the kind of arithmetic your hardware architect does before writing a single line of RTL.

---

## Overflow — What Hardware Does

When arithmetic overflow occurs, hardware sets a flag bit in a status register. In ARM processors this is the **V flag** (oVerflow) in the CPSR register. In x86, it's the **OF flag** in EFLAGS. The programmer (or hardware FSM) checks this flag and handles the error.

This module explicitly detects and reports overflow — mimicking that hardware behavior.

---

## Quantified Result

Running on 8-element vectors with values in [0.5, 3.5]:

| | Floating-Point | Fixed-Point Q8.8 |
|---|---|---|
| Result | 21.593750 | 21.593750 |
| Gate cost (per multiply) | ~2,000 gates | ~200 gates |
| Total gate cost (N=8) | ~16,000 gates | ~1,600 gates |
| Precision loss | reference | 0.0000% |

**10× gate reduction at 0% precision loss** for inputs that encode exactly in Q8.8.

For inputs with irrational fractions (like 1.3, 2.7), you will see a small quantization error — typically under 0.4% for values in [0, 4]. This is the fundamental tradeoff: range and precision are fixed at design time, but you gain massive hardware savings.

This tradeoff is why Google designed the TPU around INT8 arithmetic, accepting slight precision loss in exchange for a chip that delivers far more operations per watt per mm² than a floating-point design.

---

## Files

| File | Purpose |
|---|---|
| `c/dot_product.c` | C implementation — bit operations and types map directly to hardware |
| `fortran/dot_product.f90` | Fortran implementation — arithmetic reads close to mathematical notation |

Both implementations: no external libraries, fixed-point from scratch, overflow detection, comparison against floating-point reference.
