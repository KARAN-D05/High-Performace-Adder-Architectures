# 🧩 algo-to-silicon
- Software implementations of algorithms that directly map to hardware, studying how arithmetic units and compute primitives work from first principles, and why algorithm choice determines gate count, silicon area, and speed.

## 💡 The Core Idea
- Before a single line of RTL is written, the algorithm is already deciding the hardware cost.
- The same computation implemented with two different algorithms can differ by 10x in gate count, critical path delay, and power consumption. This is not theory. A binary-to-BCD converter using a truth table synthesis approach costs 352 gates. The same converter using the Double Dabble algorithm costs 133 gates. Same function, different algorithm, 62% gate count reduction .
- This repository documents that relationship systematically. Each module takes one algorithm that real hardware executes, implements it from scratch in software, and connects every design decision back to what it costs on silicon.

## ⚙️ Implementation Stack
![C](https://img.shields.io/badge/C-EFAA00?style=for-the-badge&logoColor=black)
![Fortran](https://img.shields.io/badge/Fortran-WAC873?style=for-the-badge)

## 🏗️ What Each Module Contains

- **README** is the primary learning document. It explains the problem from first principles, walks through the naive approach and why it is expensive, derives the optimized algorithm with worked examples, and connects every step to its hardware cost in gates, cycles, and area.

- **Two implementations** of the same algorithm:
  - `Fortran` : arithmetic reads close to mathematical notation, numerical clarity
  - `C` : bit-level mechanics visible, register widths explicit, maps directly to RTL thinking

- Both implementations use no external libraries. Every operation is written from scratch. The code is short and readable. The README is where the learning lives.

## 🧠 The Hardware Connection
- A fixed-point multiplier is what lives inside every MAC unit in every TPU, tensor core, and DSP chip. Booth's algorithm is how hardware multipliers reduce partial products to cut gate count. The carry-lookahead adder is why modern processors can add in 1 cycle instead of 32. CORDIC is how hardware computes sin and cos using only shifts and adds, with zero multipliers.
- Understanding these algorithms in software first means that when the RTL comes, we are not learning the concept and the syntax simultaneously. The algorithm is already understood. The HDL is just expression.

## 📦 Modules

| # | Algorithm | Where It Lives in Hardware | Status |
|---|---|---|---|
| 01 | Fixed-Point Dot Product | MAC units, neural network accelerators, DSP | ✅ Complete |
| 02 | Booth's Multiplier | Hardware multipliers, ALUs | 🔜 Next |
| 03 | Carry-Lookahead Adder | Fast adder design, ALU critical path | Planned |
| 04 | CORDIC | Transcendental FPUs, DSP processors | Planned |
| 05 | Horner's Method | DSP filters, FPU polynomial approximation | Planned |
| 06 | LZC + Normalization | Floating-point normalization hardware | Planned |
| 07 | BFloat16 MAC | ML accelerators, TPU, NVIDIA Tensor Cores | Planned |
| 08 | Jacobi Iterative Solver | HPC accelerators, solver ASICs | Planned |

One module added per month alongside primary RTL and architecture study.

## ⚙️ Languages Used

**C** for algorithms where bit-level mechanics matter: explicit integer widths (`int32_t`, `int64_t`), bitwise shifts, overflow detection. The hardware proximity is intentional.

**Fortran 90** for algorithms where the arithmetic structure matters: array operations, numerical accumulation, mathematical clarity. Fortran is the language scientific computation was built on, and it shows in how cleanly numerical algorithms read.

## 📜License:
- Source code, HDL, and Logisim circuit files are licensed under the MIT License.
- Documentation, diagrams, images, and PDFs are licensed under Creative Commons Attribution 4.0 (CC BY 4.0).
