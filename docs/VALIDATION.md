# Simulation validation

Validation date: **2026-09-09**. Simulator: **Icarus Verilog 11.0**, using `-g2012 -Wall` and `vvp -N`.

The original RTL was compiled and run without functional changes. Three independent testbench runs passed **131 explicit checks** in total. A check is an assertion about a value or flag; this is not a code-coverage percentage or an exhaustive correctness proof.

| Testbench | Checks | Coverage of behavior |
| --- | ---: | --- |
| `tb_program` | 32 | Two iterations of the original program, taken/not-taken BEQ, PC targets, SW/LW, writeback and J |
| `tb_isa` | 63 | All 11 documented instructions, signed immediates, register-zero protection, forward/backward branches and skipped writes |
| `tb_alu` | 36 | Normal and overflowing signed arithmetic, carry without signed overflow, extreme signed comparisons, zero and bitwise results |

Observed output:

```text
PASS tb_program: 32 checks
PASS tb_isa: 63 checks
PASS tb_alu: 36 checks
```

The compiler reports missing explicit time units in the original RTL. Those modules contain no delay controls; the testbenches set their own time units. The warning was retained, and did not prevent compilation or simulation.

The simulations verify only the supported educational design. There has been no synthesis, timing closure, on-board FPGA test, formal verification or exhaustive instruction-sequence test in this portfolio preparation. Reset behavior and unsupported operations remain as documented in the README.

Run `make test` to reproduce the checks. Run `make wave` to generate `build/program.vcd` for the original program.
