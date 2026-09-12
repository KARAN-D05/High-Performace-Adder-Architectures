# 🚀 Math-Accelerators

A general-purpose processor can execute almost any algorithm, but it does so by repeatedly fetching, decoding, and executing instructions. For computationally intensive workloads such as signal processing, scientific computing, computer graphics, and machine learning, this approach quickly becomes inefficient.

Modern systems solve this problem using **hardware accelerators** - specialized datapaths designed to execute specific mathematical operations far more efficiently than software running on a CPU.

## 🛠️ Tools & Technologies

![Icarus Verilog](https://img.shields.io/badge/Icarus_Verilog-Simulation-1E88E5?style=flat-square)
![Verilator](https://img.shields.io/badge/Verilator-Linting-00897B?style=flat-square)
![Cocotb](https://img.shields.io/badge/Cocotb-Verification-D81B60?style=flat-square)
![GTKWave](https://img.shields.io/badge/GTKWave-Waveforms-F57C00?style=flat-square)
![Yosys](https://img.shields.io/badge/Yosys-Synthesis-43A047?style=flat-square)
![OpenSTA](https://img.shields.io/badge/OpenSTA-Static_Timing_Analysis-8E24AA?style=flat-square)

## 🧩 Accelerators

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
An accelerator instead implements the computation directly in hardware.

```
Vector A
      \
        --> Dot Product Engine --> Result
      /
Vector B
```

Rather than executing instructions one at a time, the hardware itself performs the mathematical operation through dedicated datapaths, parallel arithmetic units, and optimized data movement.

## 🔬 Physical Characterization
The following table summarizes post-synthesis implementation results obtained using the Sky130 HD standard-cell library.

| Module | Width | Area | Critical Path | Estimated Fmax | Total Power |
|---|---|---|---|---|---|
| [Ripple-Carry Adder](./RCA) | 64-bit | 1761.6896 µm² | 25.00 ns | ~40 MHz | 925 µW |
| [Carry-Select Adder](./CSA) | 64-bit | 2317.2224 µm² | 14.24 ns | ~70.2 MHz | 1250 µW |
| [Carry-Bypass Adder](./CBA) | 64-bit | 2875.2576 µm² | 24.09 ns | ~41.5 MHz | 1400 µW |

## 📊 Roadmap

> Architectures: Implemented as encountered during the study of arithmetic algorithms and architecture literature.

- [Multi-Cycle Harvard Processor (Reference Architecture)](https://github.com/KARAN-D05/Harvard-Processor)
- Sequential instruction execution
- Architectural bottlenecks
- Why specialized datapaths can outperform software loops

### 🧮 Mathematical Co-Processor

The long-term objective is a configurable mathematical co-processor built from
the arithmetic and computational architectures developed throughout the project.

# 📜License
- Source code and HDL files are licensed under the MIT License.
- Documentation, diagrams, images, and PDFs are licensed under Creative Commons Attribution 4.0 (CC BY 4.0).
