# 🚀 Math-Accelerators

> A growing library of parameterized arithmetic RTL implementations, progressing from fundamental arithmetic units to an integrated mathematical co-processor.

A general-purpose processor can execute almost any algorithm, but it does so by repeatedly fetching, decoding, and executing instructions. For computationally intensive workloads such as signal processing, scientific computing, computer graphics, and machine learning, this approach quickly becomes inefficient.

Modern systems solve this problem using **hardware accelerators** - specialized datapaths designed to execute specific mathematical operations far more efficiently than software running on a CPU.

# 🛠️ Tools & Technologies

![Icarus Verilog](https://img.shields.io/badge/Icarus_Verilog-Simulation-1E88E5?style=flat-square)
![Verilator](https://img.shields.io/badge/Verilator-Linting-00897B?style=flat-square)
![Cocotb](https://img.shields.io/badge/Cocotb-Verification-D81B60?style=flat-square)
![GTKWave](https://img.shields.io/badge/GTKWave-Waveforms-F57C00?style=flat-square)
![Yosys](https://img.shields.io/badge/Yosys-Synthesis-43A047?style=flat-square)
![OpenSTA](https://img.shields.io/badge/OpenSTA-Static_Timing_Analysis-8E24AA?style=flat-square)

# 🧩 Hardware Accelerators

A simple processor computing a single element of a dot product
executes something conceptually like:

```asm
LOOP:
    LDB 0x06          ; Load constant 1
    LDA 0x08          ; Load multiplier (loop counter)

    PASS A            ; Check if counter is zero
    JZ DONE           ; Jump if counter is zero

    SUB               ; Decrement counter
    STA 0x08          ; Store updated counter

    LDA 0x09          ; Load accumulated result
    LDB 0x07          ; Load multiplicand
    ADD               ; Add multiplicand to result
    STA 0x09          ; Store updated result

    LDA 0x08          ; Reload counter
    PASS A            ; Update status flags
    JNZ LOOP          ; Repeat until counter becomes zero

DONE:
    LDA 0x09          ; Load final product
```

repeating these instructions for every element.
Although completely programmable, the processor performs every operation sequentially.
A hardware accelerator instead implements the computation directly in hardware.

```asm
Vector A
      \
        --> Dot Product Engine --> Result
      /
Vector B
```

Rather than executing instructions one at a time, the hardware itself performs the mathematical operation through dedicated datapaths, parallel arithmetic units, and optimized data movement.

# 🔬 Physical Characterization
The following table summarizes post-synthesis implementation results obtained using the Sky130 HD standard-cell library.

| Module | Width | Area | Critical Path | Estimated Fmax | Total Power |
|---|---|---|---|---|---|
| [Ripple-Carry Adder](./RCA) | 64-bit | 1761.6896 µm² | 25.00 ns | ~40 MHz | 925 µW |

# 📊 Roadmap

## Phase 0 - Motivation

Understanding why accelerators exist.

- [Multi-Cycle Harvard Processor (Reference Architecture)](https://github.com/KARAN-D05/Harvard-Processor)
- Sequential instruction execution
- Architectural bottlenecks
- Why specialized datapaths outperform software loops

## Phase 1 - Arithmetic Foundations

Fundamental arithmetic building blocks used throughout digital systems.

| # | Module | Why It Matters | Status |
|---|---------|----------------|--------|
| 01 | Ripple Carry Adder | Baseline area and delay | ✅ |
| 02 | Carry Lookahead Adder | Faster carry computation | Planned |
| 03 | Brent-Kung Prefix Adder | Scalable logarithmic carry propagation | Planned |
| 04 | Leading Zero Counter (LZC) | Floating-point normalization | Planned |
| 05 | Barrel Shifter | Alignment and fast shifting | Planned |

> Additional architectures: Implemented as encountered during study of arithmetic algorithms and architecture literature.

## Phase 2 - Arithmetic Units

Constructing reusable computational hardware.

| # | Module | Used In | Status |
|---|---------|---------|--------|
| 06 | Booth Multiplier | Signed multiplication | Planned |
| 07 | Wallace Tree Reduction | High-speed multipliers | Planned |
| 08 | Fixed-Point Multiply-Accumulate (MAC) | DSP and AI | Planned |

## Phase 3 - Computational Kernels

Mapping mathematical algorithms directly into hardware.

| # | Module | Used In | Status |
|---|---------|---------|--------|
| 09 | Fixed-Point Dot Product | DSP, Neural Networks | Planned |
| 10 | Horner's Method | Polynomial Evaluation | Planned |
| 11 | CORDIC Engine | Trigonometry, Vector Rotation | Planned |
| 12 | Jacobi Iterative Solver | Scientific Computing | Planned |

## Phase 4 - Floating-Point Arithmetic

Building floating-point computation hardware.

| # | Module | Used In | Status |
|---|---------|---------|--------|
| 13 | Floating-Point Normalization | IEEE Arithmetic | Planned |
| 14 | BFloat16 Multiplier | Machine Learning | Planned |
| 15 | BFloat16 MAC | AI Accelerators | Planned |

## Phase 5 - Integrated Math Accelerator

The final objective is to combine the reusable modules into a configurable mathematical co-processor containing:

- Parameterized arithmetic units
- Shared datapath
- Register file
- Operation decoder
- Control logic
- Standard hardware interface
- Reusable accelerator IP

# 📜License
- Source code and HDL files are licensed under the MIT License.
- Documentation, diagrams, images, and PDFs are licensed under Creative Commons Attribution 4.0 (CC BY 4.0).
