# Source provenance

## Academic source

The original coursework materials identify **João Victor Lima and Ícaro Alves** as authors. João's full name is **João Victor de Sousa Lima**. Both authors are credited in this repository.

The processor modules in `rtl/` are copied from the available June 12, 2026 source snapshot. The one-bit full adder, `FA.v`, comes from the earlier May 23, 2026 simulation archive. No RTL functionality was changed during this preparation.

| Original filename | Repository filename |
| --- | --- |
| `processador(2).v` | `rtl/processador.v` |
| `controle(1).v` | `rtl/controle.v` |
| `aluControl(1).v` | `rtl/aluControl.v` |
| `bancoReg(1).v` | `rtl/bancoReg.v` |
| `memInst(1).v` | `rtl/memInst.v` |
| `memDados(1).v` | `rtl/memDados.v` |
| `ula(3).v` | `rtl/ula.v` |
| `pc(1).v` | `rtl/pc.v` |
| `extensor(2).v` | `rtl/extensor.v` |
| `somador(2).v` | `rtl/somador.v` |
| `modelsim_sim/FA.v` | `rtl/FA.v` |

An earlier report describes a manually controlled fetch/decode/execute demonstration. This package uses the later source snapshot, which adds automatic instruction control, data memory, register writeback, BEQ and J. The later source still has a single-cycle datapath; a five-stage pipeline is not present.

## Portfolio preparation

On September 9, 2026, the source files were organized, and self-checking testbenches, a Makefile and English documentation were added with AI assistance. These additions are separate from the original academic implementation.

The earlier board wrapper and seven-segment display wiring are not part of this simulation package. The package therefore makes no claim of a verified FPGA build.

No open-source license was present in the recovered source snapshot, and no new license grant has been added by this preparation.
