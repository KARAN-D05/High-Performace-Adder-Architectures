# 🚀 High-Performance Adder Architectures

A study and implementation of high-performance binary adder architectures, focusing on how different carry-computation strategies translate into hardware.

The project implements and characterizes six 64-bit adder architectures:
- Ripple-Carry Adder (RCA)
- Carry-Select Adder (CSA)
- Carry-Bypass Adder (CBA)
- Carry-Lookahead Adder (CLA)
- Kogge-Stone Adder (KSA)
- Brent-Kung Adder (BKA)

The primary characterization uses the `Sky130 HD` standard-cell library, with `Nangate45` used for cross-library comparison. Design-space exploration is also performed on selected architectures to study the trade-off between hardware area and timing. 

## 🛠️ Tools & Technologies

![Icarus Verilog](https://img.shields.io/badge/Icarus_Verilog-Simulation-1E88E5?style=flat-square)
![Verilator](https://img.shields.io/badge/Verilator-Linting-00897B?style=flat-square)
![Cocotb](https://img.shields.io/badge/Cocotb-Verification-D81B60?style=flat-square)
![GTKWave](https://img.shields.io/badge/GTKWave-Waveforms-F57C00?style=flat-square)
![Yosys](https://img.shields.io/badge/Yosys-Synthesis-43A047?style=flat-square)
![OpenSTA](https://img.shields.io/badge/OpenSTA-Static_Timing_Analysis-8E24AA?style=flat-square)

## 🔬 Physical Characterization
The following table summarizes post-synthesis implementation results obtained using the Sky130 HD standard-cell library.

> Width: 64-Bit

| Module       | Area          | Critical Path | Estimated Fmax | Power    | ADP                 | PDP               |
| ------------ | ------------- | ------------- | -------------- | -------- | ------------------- | ----------------- |
| [RCA](./RCA) | 1761.6896 µm² | 25.00 ns      | ~40 MHz        | 925 µW   | 44042.24 µm²·ns     | 23125 µW·ns       |
| [CSA](./CSA) | 2635.0272 µm² | 7.23 ns       | ~138.3 MHz     | 1580 µW  | 19051.25 µm²·ns     | 11423.4 µW·ns     |
| [CBA](./CBA) | 2875.2576 µm² | 24.09 ns      | ~41.5 MHz      | 1400 µW  | 69264.96 µm²·ns     | 33726 µW·ns       |
| [CLA](./CLA) | 7204.4096 µm² | 3.22 ns       | ~310.6 MHz     | 2590 µW  | 23198.20 µm²·ns     | 8339.8 µW·ns      |
| [KSA](./KSA) | 3080.4544 µm² | 3.88 ns       | ~257.7 MHz     | 1620 µW  | 11952.16 µm²·ns     | 6285.6 µW·ns      |
| [BKA](./BKA) | 2058.2240 µm² | 12.89 ns      | ~77.6 MHz      | 1020 µW  | 26530.51 µm²·ns     | 13147.8 µW·ns     |

> ADP (Area-Delay Product): Area × critical-path delay; lower values indicate better area-timing efficiency.
>
> PDP (Power-Delay Product): Power × critical-path delay; lower values indicate better power-timing efficiency.

### Relative Performance

| Module                | Area vs. RCA | Fmax vs. RCA | Power vs. RCA | ADP vs. RCA | PDP vs. RCA |
| --------------------- | ------------ | ------------ | ------------- | ----------- | ----------- |
| Ripple-Carry Adder    | 1.00×        | 1.00×        | 1.00×         | 1.00×       | 1.00×       |
| Carry-Select Adder    | **1.50×**    | **3.46×**    | **1.71×**     | **0.43×**   | **0.49×**   |
| Carry-Bypass Adder    | 1.63×        | 1.04×        | 1.51×         | 1.57×       | 1.46×       |
| Carry-Lookahead Adder | 4.09×        | **7.77×**    | 2.80×         | **0.53×**   | **0.36×**   |
| Kogge-Stone Adder     | 1.75×        | **6.44×**    | 1.75×         | **0.27×**   | **0.27×**   |
| Brent-Kung Adder      | 1.17×        | **1.94×**    | 1.10×         | **0.60×**   | **0.57×**   |

### Architecture Characterization

The 64-bit adder architectures were synthesized and analyzed across different
architectural parameters to study area, timing, and PPA tradeoffs.

- [CLA Block Width Study](https://github.com/KARAN-D05/Math-Accelerators/tree/main/CLA#block-width-study)
- [CSA Block Width Study](https://github.com/KARAN-D05/Math-Accelerators/tree/main/CSA#block-width-study)
- [CBA Block Width Study](https://github.com/KARAN-D05/Math-Accelerators/tree/main/CBA#block-width-study)

<p align="center">
  <img src="CLA/images/width_vs_timing.png" width="900"/>
  <br>
  <sub>Maximum combinational delay vs. Area vs. CLA block width</sub>
</p>

# 📜License
- Source code and HDL files are licensed under the MIT License.
- Documentation, diagrams, images, and PDFs are licensed under Creative Commons Attribution 4.0 (CC BY 4.0).
