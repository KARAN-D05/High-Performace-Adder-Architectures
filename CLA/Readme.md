# Carry Lookahead Adder (CLA)
A parameterized 64-bit Carry Lookahead Adder using hierarchical lookahead blocks. Each block computes carry signals directly from propagate and generate terms, reducing the carry dependency compared to a Ripple-Carry Adder.

## Synthesis Results

**Technology:** Sky130 HD  
**Synthesis Tool:** Yosys

| Metric | Value |
|---|---|
| Width | 64-bit |
| Block Size | 32-bit |
| Number of Blocks | 2 |
| Area | 7204.4096 µm² |

## Static Timing Analysis (OpenSTA)

| Metric | Value |
|---|---|
| Maximum Combinational Delay | 3.22 ns |
| Estimated Fmax | ~310.6 MHz |

## Power Analysis
| Metric | Value | 
|---|---| 
| Total Power | 2.59 mW |

## Block Width Study

<p align="center">
  <img src="images/width_vs_timing.png" width="900"/>
  <br>
  <sub>Maximum combinational delay vs. Area vs. CLA block width</sub>
</p>

To determine a suitable lookahead block size for the 64-bit Carry Lookahead Adder, the design was synthesized and analyzed with different CLA block widths while maintaining the same overall 64-bit adder architecture.

The tested configurations were 4, 8, 16, 32, and 64-bit lookahead blocks.

### Experimental Results

**Timing Analysis:** OpenSTA  
**Adder Width:** 64-bit

| Block Width | Number of Blocks | Area (µm²) | Max Delay (ns) | Est. Fmax |
|---|---|---|---|---|
| 4-bit | 16 | 1959.38 | 11.90 | ~84.0 MHz |
| 8-bit | 8 | 2262.17 | 9.77 | ~102.4 MHz |
| 16-bit | 4 | 3578.43 | 3.89 | ~257.1 MHz |
| **32-bit** | **2** | **7204.41** | **3.22** | **~310.6 MHz** |
| 64-bit | 1 | 16146.74 | 3.66 | ~273.2 MHz |

### Observations

Increasing the CLA block width significantly reduced the maximum combinational delay up to 32-bit blocks. However, the area increased rapidly as larger lookahead networks were constructed.
The timing improvements between configurations were:

- **4 → 8 bits:** 11.90 → 9.77 ns (**−2.13 ns, −17.9%**)
- **8 → 16 bits:** 9.77 → 3.89 ns (**−5.88 ns, −60.2%**)
- **16 → 32 bits:** 3.89 → 3.22 ns (**−0.67 ns, −17.2%**)
- **32 → 64 bits:** 3.22 → 3.66 ns (**+0.44 ns, +13.7%**)

The **8 → 16-bit transition provides the largest practical timing improvement**, reducing the critical path by approximately 60% while increasing area from 2262.17 µm² to 3578.43 µm².
In comparison, moving from **16 → 32-bit blocks** provides only a further 17.2% reduction in delay while approximately doubling the area:

**16-bit → 32-bit:**

- Area: 3578.43 → 7204.41 µm² (**~2.01×**)
- Delay: 3.89 → 3.22 ns (**17.2% lower**)
- Fmax: ~257.1 → ~310.6 MHz (**20.8% higher**)

Increasing the block width to 64-bit further demonstrates the diminishing returns of a large flat lookahead network:

**32-bit → 64-bit:**

- Area: 7204.41 → 16146.74 µm² (**~2.24×**)
- Delay: 3.22 → 3.66 ns (**13.7% worse**)
- Fmax: ~310.6 → ~273.2 MHz (**12.0% lower**)

A larger lookahead network reduces the logical carry dependency, but introduces substantially more combinational hardware, routing, fanout, and complex gate structures. At 64-bit block width, these physical effects outweigh the theoretical reduction in carry dependency.

### PPA Tradeoff

Although the **32-bit configuration achieves the lowest measured critical path**, the **16-bit configuration represents a more balanced practical choice when considering PPA (Power, Performance, and Area)**.
The 8 → 16-bit transition provides a very large timing improvement with a comparatively moderate area increase. In contrast, moving from 16 → 32-bit blocks results in approximately **2× the area for only a 17.2% reduction in critical-path delay**.
Therefore, for a design where area and power are important alongside timing, **16-bit CLU blocks would be the preferred practical configuration**. The 32-bit configuration is more appropriate when timing is the primary optimization objective.

### Selected Configuration

For this study, **32-bit blocks were selected for the final 64-bit CLA implementation** because the primary objective of the design is **timing optimization and timing closure**.

The 32-bit configuration achieved the **lowest measured maximum combinational delay of 3.22 ns**, corresponding to an estimated maximum frequency of approximately **310.6 MHz**.
However, the experimental results indicate that **16-bit blocks are arguably the PPA-optimal configuration**. They achieve 3.89 ns timing at 3578.43 µm², avoiding the large area increase associated with the 32-bit lookahead network while retaining most of its timing benefit.

This distinction highlights an important architectural tradeoff:

> **16-bit CLU → better PPA balance**  
> **32-bit CLU → better timing**

For comparison, the corresponding 64-bit RCA implementation had a maximum delay of approximately **25.00 ns**. The selected 32-bit CLA therefore provides approximately:

**87.1% reduction in maximum combinational delay**

compared with the RCA implementation.

The study demonstrates the practical area-timing tradeoff of Carry Lookahead Adders and motivates the use of **hierarchical lookahead rather than a single extremely large flat lookahead network**.
