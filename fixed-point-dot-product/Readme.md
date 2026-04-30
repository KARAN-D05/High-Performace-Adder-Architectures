# Fixed-Point Dot Product

## Dot Product

The dot product takes two lists of numbers of equal length and produces one number. You multiply each pair and add all the results together.

```
A = [2, 3, 4]
B = [1, 5, 2]

dot(A, B) = (2×1) + (3×5) + (4×2)
          =   2   +   15  +   8
          = 25
```

Another example:

```
A = [1, 0, 0]
B = [7, 3, 9]

dot(A, B) = (1×7) + (0×3) + (0×9)
          =   7   +   0   +   0
          = 7
```

Notice: when A is [1, 0, 0], the dot product just picks out the first element of B. This is useful in signal processing we can "select" parts of a signal using a crafted A vector.

One more:

```
A = [0.5, 0.5]
B = [4.0, 6.0]

dot(A, B) = (0.5×4.0) + (0.5×6.0)
          =     2.0   +     3.0
          = 5.0
```

This is the weighted average of B with equal weights 0.5 each. A neuron in a neural network does exactly this it computes a weighted sum of its inputs, where the weights are learned values stored in the hardware.

### Where the dot product lives in real hardware

Every time you use any of these, silicon is computing dot products millions of times per second:

**Neural network inference** - A neuron receives inputs [x₁, x₂, x₃, ...] and has learned weights [w₁, w₂, w₃, ...]. Its output before activation is `x₁w₁ + x₂w₂ + x₃w₃ + ...` - a dot product. A single inference pass through a large model performs billions of these.

**FIR digital filter** - A filter has coefficients [h₀, h₁, h₂, ...]. To produce each output sample, it computes the dot product of those coefficients with the most recent input samples. Every audio chip, every radio receiver, every 5G modem does this continuously.

**Matrix multiplication** - To compute element [i][j] of the output matrix, you take the dot product of row i of the left matrix with column j of the right matrix. Matrix multiply is just dot products arranged in a loop.

## How Computers Store Numbers (Building Up to the Problem)

Before we can talk about what is expensive in hardware, we need to understand how numbers are stored in binary.

### Integers in binary

In binary, each bit position represents a power of 2. The rightmost bit is 2⁰ = 1, the next is 2¹ = 2, then 2² = 4, and so on.

```
Decimal 13 in binary:

  Bit position:  3   2   1   0
  Power of 2:    8   4   2   1
  Bits:          1   1   0   1

  Value: (1×8) + (1×4) + (0×2) + (1×1) = 8 + 4 + 0 + 1 = 13  ✓
```

More examples:

```
Decimal  5  →  binary  0101  →  (0×8)+(1×4)+(0×2)+(1×1) = 5
Decimal 10  →  binary  1010  →  (1×8)+(0×4)+(1×2)+(0×1) = 10
Decimal 15  →  binary  1111  →  (1×8)+(1×4)+(1×2)+(1×1) = 15
Decimal  1  →  binary  0001  →  1
Decimal  8  →  binary  1000  →  8
```

Integers are stored exactly. No approximation. 5 is always 5. Multiplication of integers by the hardware is also exact and crucially, **integer multipliers are cheap in hardware**.

### Fractions in binary

What about 0.5, or 1.75, or 3.14159?

In decimal, fractions use negative powers of 10: 0.1 means 1/10, 0.01 means 1/100, etc.

In binary, fractions use negative powers of 2: the first bit after the binary point is 2⁻¹ = 0.5, the next is 2⁻² = 0.25, then 2⁻³ = 0.125, and so on.

```
Binary  0.1    →  2⁻¹         = 0.5
Binary  0.01   →  2⁻²         = 0.25
Binary  0.001  →  2⁻³         = 0.125
Binary  0.11   →  2⁻¹ + 2⁻²  = 0.5 + 0.25 = 0.75
Binary  0.101  →  2⁻¹ + 2⁻³  = 0.5 + 0.125 = 0.625
```

Let us verify 1.75:

```
1.75 in binary:

  Integer part 1:   binary 1
  Fraction 0.75:    0.5 + 0.25 = 2⁻¹ + 2⁻² = binary .11

  So 1.75 = binary 1.11

  Verify: 1×2⁰ + 1×2⁻¹ + 1×2⁻² = 1 + 0.5 + 0.25 = 1.75  ✓
```

And 2.625:

```
2.625 in binary:

  Integer part 2:   binary 10
  Fraction 0.625:   0.5 + 0.125 = 2⁻¹ + 2⁻³ = binary .101

  So 2.625 = binary 10.101

  Verify: 1×2¹ + 0×2⁰ + 1×2⁻¹ + 0×2⁻² + 1×2⁻³ = 2 + 0 + 0.5 + 0 + 0.125 = 2.625  ✓
```

**The problem:** some fractions cannot be represented exactly in binary no matter how many bits you use. 0.1 in decimal is one example in binary it is 0.000110011001100... repeating forever. This is similar to 1/3 in decimal being 0.3333... forever. When you store 0.1 in a computer as a float, you are storing an approximation. This causes the tiny errors in floating-point arithmetic.

## What Floating-Point Is

Integers handle whole numbers perfectly but cannot represent the full range we need, very large numbers (like 999999999999.0) or very small ones (like 0.000000001) would need an impractical number of bits.

The solution engineers invented is **floating-point**, which is binary scientific notation.

### Scientific notation refresher

In decimal scientific notation, you write any number as a coefficient times a power of 10:

```
6500000  =  6.5 × 10⁶
0.00043  =  4.3 × 10⁻⁴
-123.45  = -1.2345 × 10²
```

The advantage: you can represent both enormous and tiny numbers with a fixed number of digits. You just move the decimal point (hence "floating" point).

### IEEE 754 single-precision (32-bit float)

A 32-bit float stores three things:

```
[ S | EEEEEEEE | MMMMMMMMMMMMMMMMMMMMMMM ]
  1     8 bits           23 bits
 sign  exponent         mantissa
```

The value is: `(-1)^S × 1.MMMMM... × 2^(E-127)`

The exponent has 127 subtracted from it (this is called the bias, it allows storing negative exponents without a sign bit).

The mantissa always starts with 1 (since in binary, any non-zero number starts with 1 when normalized). That leading 1 is implicit and not stored, giving you an extra free bit of precision.

### Walking through an example: storing 6.5

Step 1 - Convert 6.5 to binary:
```
6   = 110  in binary
0.5 = .1   in binary
6.5 = 110.1 in binary
```

Step 2 - Normalize (move the binary point so only one 1 is to the left):
```
110.1  →  1.101 × 2²
```
The exponent is 2.

Step 3 - Store the exponent with bias:
```
Stored exponent = 2 + 127 = 129 = 10000001 in binary
```

Step 4 - Store the mantissa (the digits after the leading 1):
```
Mantissa = 101 followed by 20 zeros = 10100000000000000000000
```

Step 5 - Assemble the 32-bit float:
```
Sign:     0         (positive)
Exponent: 10000001  (129)
Mantissa: 10100000000000000000000

Full 32 bits: 0 10000001 10100000000000000000000
```

Let us verify by decoding: `(-1)⁰ × 1.101 × 2^(129-127) = 1 × 1.101 × 2² = 110.1 = 6.5` ✓

Another example: storing -0.75

Step 1 - 0.75 in binary: 0.11 (since 0.5 + 0.25 = 0.75)

Step 2 - Normalize: 1.1 × 2⁻¹ (we moved the point right once, so exponent is -1)

Step 3 - Stored exponent: -1 + 127 = 126 = 01111110

Step 4 - Mantissa: 10000000000000000000000

Step 5 - Assembled: `1 01111110 10000000000000000000000` (sign=1 because negative)

Verify: `(-1)¹ × 1.1 × 2^(126-127) = -1 × 1.1 × 2⁻¹ = -0.11 binary = -0.75` ✓

### What floating-point multiplication requires in hardware

To multiply two floats together, the hardware must do all of the following:

**Step 1 - XOR the sign bits** to get the result sign. one gate required.

**Step 2 - Add the exponents:**
```
(A_exponent - 127) + (B_exponent - 127) = result_exponent - 127
result_exponent = A_exp + B_exp - 127
```
This requires an integer adder for 8-bit values plus a subtractor for the bias. About 50 gates.

**Step 3 - Multiply the mantissas:**
The mantissas are 24-bit integers (23 stored bits + the implicit leading 1). Multiplying two 24-bit integers gives a 48-bit result. This is the expensive part, a 24×24 bit integer multiplier requires approximately 1,000-2,000 gates.

**Step 4 - Normalize the result:**
The product of two numbers of the form 1.xxx may be either 1.xxx or 10.xxx (if both mantissas were close to 2). If 10.xxx, you shift right by 1 and increment the exponent. This requires detecting the leading bit and conditionally shifting - a few hundred gates.

**Step 5 - Round to 23 bits:**
The 48-bit product must be rounded back to 23 bits. IEEE 754 specifies several rounding modes. The rounding logic is around 50–100 gates.

**Step 6 - Handle special cases:**
Zero, infinity, NaN (Not a Number) each need detection and special handling. Another ~200 gates.

**Total: a 32-bit floating-point multiplier costs roughly 1,500–3,000 gates and takes 3–7 clock cycles.**

For comparison, a 16-bit integer multiplier costs about 150–300 gates and runs combinationally in 1 cycle.

**Historical note:** The Intel 8087 (1980) was a dedicated floating-point coprocessor chip, it existed as a separate physical chip because the FPU was too large (45,000 transistors) to fit on the same die as the 8086 CPU (29,000 transistors). The FPU was literally bigger than the main processor.

##  Fixed-Point Arithmetic, Built from Scratch

The key idea is this: **what if we agreed in advance where the decimal point sits, and then just used integers?**

If we know our numbers will always be between 0 and 255.999, we can use integers and agree "the last 8 bits are always the fractional part." We never move the point - it is fixed. Hence fixed-point.

### The scaling trick

To store the real number 1.5 as an integer, multiply by a power of 2 and round:

```
1.5 × 256 = 384   →   store the integer 384
```

To get back the real number, divide by 256:

```
384 / 256 = 1.5   ✓
```

More examples with scale factor 256 (= 2⁸):

```
Real 0.5    →  0.5  × 256 =  128   →  store 128   →  128/256 = 0.5    ✓
Real 1.0    →  1.0  × 256 =  256   →  store 256   →  256/256 = 1.0    ✓
Real 1.5    →  1.5  × 256 =  384   →  store 384   →  384/256 = 1.5    ✓
Real 2.25   →  2.25 × 256 =  576   →  store 576   →  576/256 = 2.25   ✓
Real 3.75   →  3.75 × 256 =  960   →  store 960   →  960/256 = 3.75   ✓
Real 0.125  →  0.125× 256 =   32   →  store 32    →   32/256 = 0.125  ✓
```

### The Q notation

Q8.8 means: 8 bits for the integer part, 8 bits for the fractional part. Scale factor = 2⁸ = 256.

Q4.4 would mean: 4 bits integer, 4 bits fractional. Scale factor = 2⁴ = 16.

Q16.16 means: 16 bits integer, 16 bits fractional. Scale factor = 2¹⁶ = 65536.

Here is what Q8.8 looks like at the bit level:

```
16-bit Q8.8 number - stores the real value 2.75:

  2.75 × 256 = 704

  704 in binary = 0000 0010 1100 0000

  Bit positions:
  [ 15  14  13  12  11  10   9   8 |  7   6   5   4   3   2   1   0 ]
  [  0   0   0   0   0   0   1   0 |  1   1   0   0   0   0   0   0 ]
  [        integer part = 2        |      fractional part = 0.75    ]
                                   ^
                          implied binary point

  Integer bits:    0000 0010  = 2
  Fractional bits: 1100 0000  = 0.75  (bit7=0.5, bit6=0.25, rest=0)

  Total: 2 + 0.75 = 2.75  ✓
```

Another example: 1.125 in Q8.8:

```
  1.125 × 256 = 288

  288 in binary = 0000 0001 0010 0000

  [ 0   0   0   0   0   0   0   1 |  0   0   1   0   0   0   0   0 ]
  [       integer part = 1        |    fractional part = 0.125      ]

  Integer bits:    0000 0001  = 1
  Fractional bits: 0010 0000  = 0.125  (bit5 = 2⁻³ = 0.125)

  Total: 1 + 0.125 = 1.125  ✓
```

### What you cannot represent exactly

Some fractions do not map to exact powers of 2. For example, 1.3:

```
1.3 × 256 = 332.8  →  round to 333

333 / 256 = 1.30078125  (not exactly 1.3)

Error: 1.30078125 - 1.3 = 0.00078125
Relative error: 0.00078125 / 1.3 ≈ 0.06%
```

This is quantization error, the price you pay for fixed-point. For most hardware applications (neural network weights, filter coefficients), errors under 0.5% are completely acceptable.

## Fixed-Point Multiplication, Step by Step

This is the core of the module. When you multiply two Q8.8 integers, something specific happens to the scale factor.

### The algebra

```
A_real = A_fixed / 256
B_real = B_fixed / 256

A_real × B_real = (A_fixed / 256) × (B_fixed / 256)
                = (A_fixed × B_fixed) / (256 × 256)
                = (A_fixed × B_fixed) / 65536
```

So: `A_fixed × B_fixed` gives you the real product scaled up by 65536 (= 256²), not 256.

The result is in Q16.16 format, it has 16 fractional bits instead of 8.

To get back to Q8.8, divide by 256 - which is a right-shift by 8.

### Three worked examples

**Example 1: 1.5 × 2.0**

```
Encode:
  1.5 × 256 = 384
  2.0 × 256 = 512

Multiply the integers:
  384 × 512 = 196,608

This is Q16.16. Verify:
  196,608 / 65536 = 3.0  ✓  (that is the correct answer: 1.5 × 2.0 = 3.0)

Right-shift by 8 to get Q8.8:
  196,608 >> 8 = 196,608 / 256 = 768

Decode:
  768 / 256 = 3.0  ✓
```

**Example 2: 2.25 × 1.5**

```
Encode:
  2.25 × 256 = 576
  1.5  × 256 = 384

Multiply:
  576 × 384 = 221,184

Verify as Q16.16:
  221,184 / 65536 = 3.375  ✓  (2.25 × 1.5 = 3.375)

Right-shift by 8:
  221,184 >> 8 = 864

Decode:
  864 / 256 = 3.375  ✓
```

**Example 3: 0.75 × 3.25**

```
Encode:
  0.75 × 256 = 192
  3.25 × 256 = 832

Multiply:
  192 × 832 = 159,744

Verify as Q16.16:
  159,744 / 65536 = 2.4375  ✓  (0.75 × 3.25 = 2.4375)

Right-shift by 8:
  159,744 >> 8 = 624

Decode:
  624 / 256 = 2.4375  ✓
```

### Why right-shift is free in hardware

Right-shifting by 8 means: discard the bottom 8 bits, move everything else down by 8 positions.

In software this is the `>>` operator. In hardware it is **just wiring** we connect the output of bit position k+8 to the input of bit position k. There are no gates involved. No logic. No clock cycles. No power consumed. It is a physical rewiring of connections.

Compare this to what floating-point normalization needs:

A floating-point multiplier must figure out *how much* to shift because the exponent of the result is not known in advance. To do this it needs:

```
  Leading Zero Counter (LZC):
    Scans the 48-bit mantissa product to find the first 1.
    Tells the shifter how far to shift.
    Cost: ~100 gates, 1-2 clock cycles.

  Barrel Shifter:
    Can shift by any amount from 0 to 47 in one step.
    Implemented as a series of multiplexers.
    Cost: ~500-800 gates.

  Exponent Adder:
    Adjusts the stored exponent based on how much was shifted.
    Cost: ~50 gates.

  Rounding logic:
    Rounds the result based on the discarded bits.
    Cost: ~100 gates.
```

Total for floating-point normalization: ~800 gates, 2-3 cycles.
Total for fixed-point shift: 0 gates, 0 cycles.

**This is the central insight of this module.** The fixed-point dot product is not faster because of some clever trick, it is faster because it permanently eliminates the most expensive part of floating-point arithmetic by accepting a constraint (fixed range and precision) that is acceptable in most real hardware applications.

## Accumulating a Dot Product and the Overflow Problem

For a dot product, we multiply N pairs and add them all. The running sum is called the **accumulator**.

### How the accumulation works

For our 8-element vectors:

```
acc = 0
acc += A_fixed[0] × B_fixed[0]  =  384 × 512  = 196,608      acc = 196,608
acc += A_fixed[1] × B_fixed[1]  =  576 × 384  = 221,184      acc = 417,792
acc += A_fixed[2] × B_fixed[2]  =  192 × 832  = 159,744      acc = 577,536
acc += A_fixed[3] × B_fixed[3]  =  768 × 128  =  98,304      acc = 675,840
acc += A_fixed[4] × B_fixed[4]  =  288 × 704  = 202,752      acc = 878,592
acc += A_fixed[5] × B_fixed[5]  =  640 × 256  = 163,840      acc = 1,042,432
acc += A_fixed[6] × B_fixed[6]  =  128 × 896  = 114,688      acc = 1,157,120
acc += A_fixed[7] × B_fixed[7]  =  448 × 576  = 258,048      acc = 1,415,168

Final: acc >> 8 = 1,415,168 / 256 = 5,528  (Q8.8)
Decode: 5,528 / 256 = 21.59375  ✓
```

### Why overflow matters

After multiplying two Q8.8 integers, the product is in Q16.16 format. The accumulator holds the sum of N such products. If that sum exceeds what your register can store, the top bits are silently discarded and your answer is wrong. There is no error message — the hardware just gives you garbage.

This is called **overflow** and it is a silent failure.

**Calculating the maximum safe accumulator value:**

Suppose each input is at most 4.0. In Q8.8 that is `4.0 × 256 = 1024`.

Maximum single product: `1024 × 1024 = 1,048,576`

For N=8: `8 × 1,048,576 = 8,388,608`

A 32-bit signed integer holds up to `2,147,483,647`. So for N=8 and inputs ≤ 4.0, we are safe with 32 bits.

But for N=1000 and inputs up to 4.0: `1000 × 1,048,576 = 1,048,576,000` — still fits in 32 bits. 

For N=1000 and inputs up to 10.0: max Q8.8 = 2560, max product = `2560² = 6,553,600`, sum = `1000 × 6,553,600 = 6,553,600,000` — this exceeds 32 bits. You need a 64-bit accumulator.

**This calculation is something a hardware architect does on paper before deciding how wide to make the accumulator register in RTL.** Too narrow wastes correctness. Too wide wastes silicon area. You calculate the exact minimum width needed.

### What overflow looks like in hardware

When an integer addition overflows, hardware sets a flag bit in a status register:

```
ARM processor:   V flag in CPSR register (oVerflow)
x86 processor:   OF flag in EFLAGS register
RISC-V:          No overflow flag — the programmer must check manually
```

Your RTL designs will need to think about this. An FSM that drives a MAC unit should check this flag after accumulation and assert an error output if it is set — otherwise silent wrong answers propagate downstream.

---

## Part 7 — The MAC Unit

In hardware, a dot product unit is built as a **MAC unit** — Multiply and Accumulate:

```
result = result + (A[i] × B[i])
```

The circuit:

```
    A[i]       B[i]
      |           |
      v           v
  ┌───────────────────┐
  │   INTEGER         │   ← ~200 gates (Q8.8 multiplier)
  │   MULTIPLIER      │     output is Q16.16 (double width)
  └────────┬──────────┘
           │
           v
  ┌────────────────┐
  │  ADDER         │   ← ~50 gates
  └───────┬────────┘
          │              ┌─────────────────────┐
          └─────────────>│   ACCUMULATOR       │  ← register, holds running sum
                         │   REGISTER          │    must be wide enough (64-bit here)
                         └──────────┬──────────┘
                                    │
                                    └──────────── feedback to adder input
                                    │
                                    v (after N cycles)
                              result (Q16.16)
                                    │
                              >> 8  │   ← free: just rewiring
                                    v
                              result (Q8.8)
```

This unit, clocked N times, computes the complete dot product of N-element vectors.

**Real chips built from this idea:**

Google TPU v1 (2016) — 256×256 array of INT8 MAC units. 65,536 MACs operating simultaneously, each doing exactly this operation. The entire chip is fundamentally this circuit tiled 65,536 times.

NVIDIA Tensor Core (Ampere, 2020) — performs a 4×4 matrix multiply in one clock cycle using an array of BFloat16 MAC units. Each matrix multiply is 64 dot products.

A DSP chip like the TI TMS320 — has a single dedicated MAC unit that can do one multiply-accumulate per clock cycle with zero overhead. FIR filters, FFTs, and correlators are all implemented by feeding data through this one unit.

Your Gate-Level Perceptron — the weighted sum computation `Σ(wᵢ × xᵢ)` before the threshold comparison is a dot product. What this module implements in software is what your perceptron does in gates.

---

## Part 8 — Quantified Result

Vectors used (length 8):

```
A = [1.5, 2.25, 0.75, 3.0, 1.125, 2.5, 0.5, 1.75]
B = [2.0, 1.5,  3.25, 0.5, 2.75,  1.0, 3.5, 2.25]
```

True dot product (by hand): 21.59375

Results:

```
┌─────────────────────┬──────────────────┬──────────────────────┐
│                     │  Floating-Point  │  Fixed-Point Q8.8    │
├─────────────────────┼──────────────────┼──────────────────────┤
│ Result              │  21.593750       │  21.593750           │
│ Gates per multiply  │  ~2,000          │  ~200                │
│ Total (N=8 mults)   │  ~16,000 gates   │  ~1,600 gates        │
│ Normalization cost  │  ~800 gates      │  0 gates (free)      │
│ Precision loss      │  reference       │  0.0000%             │
└─────────────────────┴──────────────────┴──────────────────────┘

Gate reduction: 10×
Precision loss: 0% (for these inputs which encode exactly in Q8.8)
```

For inputs that do not encode exactly, the error is under 0.4% for values in [0, 4]. This is acceptable — and it is the exact tradeoff Google accepted when designing the TPU around INT8 arithmetic instead of FP32. They got a chip that delivers dramatically more operations per watt per mm² of silicon, at a precision cost their models could absorb.
