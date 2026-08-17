# Asynchronous FIFO with Clock Domain Crossing (CDC)

A parameterized, synthesizable Asynchronous FIFO implemented in Verilog. Designed using the Cliff Cummings architecture to safely transfer data between two independent, unsynchronized clock domains.

## Architecture Highlights
* **Clock Domain Crossing:** Implements 2-stage D-Flip-Flop synchronizers (`sync_r2w` and `sync_w2r`) to mitigate metastability across domains.
* **Gray Code Pointer Logic:** Converts binary address pointers to Gray Code before crossing clock boundaries, guaranteeing only 1-bit transitions per clock cycle.
* **Dual-Port RAM:** Parameterized dual-clock memory buffer supporting simultaneous read and write operations.
* **Full & Empty Flags:** Precise condition checking avoiding data corruption or illegal reads.

## Module Hierarchy
* `async_fifo.v` — Top-level structural wrapper
  * `fifomem.v` — Dual-port RAM array
  * `sync_r2w.v` — Read-to-write domain 2-flop synchronizer
  * `sync_w2r.v` — Write-to-read domain 2-flop synchronizer
  * `rptr_empty.v` — Read pointer & empty flag generation
  * `wptr_full.v` — Write pointer & full flag generation

## Verification Waveform
Simulation conducted in Xilinx Vivado using a 100MHz Write Clock and 33.3MHz Read Clock.

![Simulation Waveform](waveform.png)
