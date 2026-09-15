# Kogge-Stone Adder (KSA)

A 64-bit Kogge-Stone Adder implementing a parallel-prefix carry computation using logarithmic-depth prefix stages.

## Features

- Parallel-prefix carry computation
- Synthesizable SystemVerilog
- RTL simulation and GLS verified
- Sky130 HD synthesis and OpenSTA STA

<p align="center">
  <img src="images/ksa_synthesis.png" width="1500"/>
  <br>
  <sub>KSA Synthesis</sub>
</p>

## Synthesis Results

**Technology:** Sky130 HD  
**Tool:** Yosys

| Metric | Value |
|---|--- |
| Width | 64-bit |
| Area | 3080 µm² |

## Static Timing Analysis

| Metric | Value |
|---|---|
| Critical Path | 3.88 ns |
| Estimated Fmax | ~258 MHz |

## Power

| Metric | Value |
|---|---|
| Total Power | 1.62 mW |
