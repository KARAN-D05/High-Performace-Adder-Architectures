# algo-to-silicon

A living compendium of algorithms that hardware actually implements - studied in software first.

## The Idea

Every algorithm in this repository has a direct hardware counterpart. Silicon area, gate count, propagation delay, and power consumption are all determined - before a single line of RTL is written by the algorithm chosen. This repo documents that connection systematically.

Each module:
- Explains the problem and the naive approach
- Implements the optimized algorithm from scratch 
- Implements it twice: **Fortran** (math visible, numerical clarity) and **C** (bit-level reality, hardware proximity)
- Quantifies the result - a number that proves the point
- Connects the algorithm to its hardware manifestation

## Why Both Languages

Fortran makes the mathematics visible. C makes the hardware mechanics visible. The same algorithm in both languages reveals what changes between mathematical formulation and hardware-level implementation. When the RTL comes later, both serve as reference models.

## The Through-Line

Algorithm choice *is* hardware cost. The same function implemented with two different algorithms can differ by 2x in gate count, critical path delay, and power. This repo is a documented record of understanding that boundary - from algorithm down to silicon.

## Algorithms

| # | Algorithm | Hardware Home | Language |
|---|---|---|---|
| 01 | Fixed-Point Dot Product | MAC units, perceptron hardware | Fortran + C |
