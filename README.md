# 🧩 algo-to-silicon
- Implementations of algorithms that directly map to hardware, studying how arithmetic units and compute primitives work from first principles, and why algorithm choice determines gate count, silicon area, and speed.

## 💡 The Core Idea
- Before a single line of RTL is written, the algorithm is already deciding the hardware cost.
- The same computation implemented with two different algorithms can differ by 10x in gate count, critical path delay, and power consumption.
- A binary-to-BCD converter using a truth table synthesis approach costs 352 gates. The same converter using the Double Dabble algorithm costs 133 gates. Same function, different algorithm, 62% gate count reduction .
- This repository documents that relationship systematically. Each module takes one algorithm that real hardware executes, implements it from scratch in verilog, and connects every design decision back to what it costs on silicon.

## 🛠️ Tools & Technologies
![Icarus Verilog](https://img.shields.io/badge/Icarus_Verilog-Simulation-1E88E5?style=flat-square)
![Verilator](https://img.shields.io/badge/Verilator-Linting-00897B?style=flat-square)
![Cocotb](https://img.shields.io/badge/Cocotb-Verification-D81B60?style=flat-square)
![GTKWave](https://img.shields.io/badge/GTKWave-Waveforms-F57C00?style=flat-square)
![Yosys](https://img.shields.io/badge/Yosys-Synthesis-43A047?style=flat-square)
![OpenSTA](https://img.shields.io/badge/OpenSTA-Static_Timing_Analysis-8E24AA?style=flat-square)

## 📦 Modules

| # | Algorithm | Where It Lives in Hardware | Status |
|---|---|---|---|
| 01 | Fixed-Point Dot Product | MAC units, neural network accelerators, DSP | 🔜 In Progress |
| 02 | Booth's Multiplier | Hardware multipliers, ALUs |  Planned |
| 03 | Carry-Lookahead Adder | Fast adder design, ALU critical path | Planned |
| 04 | CORDIC | Transcendental FPUs, DSP processors | Planned |
| 05 | Horner's Method | DSP filters, FPU polynomial approximation | Planned |
| 06 | LZC + Normalization | Floating-point normalization hardware | Planned |
| 07 | BFloat16 MAC | ML accelerators, TPU, NVIDIA Tensor Cores | Planned |
| 08 | Jacobi Iterative Solver | HPC accelerators, solver ASICs | Planned |

## 📜License:
- Source code, HDL, and Logisim circuit files are licensed under the MIT License.
- Documentation, diagrams, images, and PDFs are licensed under Creative Commons Attribution 4.0 (CC BY 4.0).
