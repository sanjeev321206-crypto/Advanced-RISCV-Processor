# Advanced RISC-V Processor

## 1. Project Overview
A Verilog-based pipelined RISC-V processor with hazard detection,
data forwarding, memory operations, cache modules and branch prediction.

## 2. Processor Architecture
- ALU
- Register File
- Control Unit
- Immediate Generator
- Instruction Memory
- Data Memory
- Fetch Stage
- Decode Stage
- Execute Stage
- Memory Stage
- Writeback Stage
- Pipeline Registers
- Hazard Detection Unit
- Forwarding Unit
- Branch Comparator
- Next PC Logic

## 3. Additional Components
### Cache
- Instruction Cache
- Data Cache

### Branch Predictor
- 16-entry prediction table
- 2-bit saturating counters
- Weakly-not-taken initialization

Note: Cache and branch predictor modules are standalone components
and are not integrated into the processor datapath.

## 4. Verification Results

| Metric | Result |
|---|---:|
| Testbenches | 17 |
| Passed | 17 |
| Failed | 0 |
| Success Rate | 100% |

## 5. Processor Performance

| Metric | Result |
|---|---:|
| Executed Instructions | 10 |
| Execution Cycles | 16 |
| CPI | 1.60 |
| Clock Period | 10 ns |
| Execution Time | 160 ns |

These measurements correspond to the specific processor test program.

## 6. Cache Performance

| Metric | Result |
|---|---:|
| Hit Rate | 54.20% |
| Miss Rate | 45.80% |
| AMAT | 23.90 ns |

These are from the standalone cache performance simulation.

## 7. Branch Predictor Performance

| Metric | Result |
|---|---:|
| Predictions | 32 |
| Correct | 25 |
| Incorrect | 7 |
| Accuracy | 78.12% |

## 8. Tools Used
- Verilog HDL
- Icarus Verilog
- Python
- Google Colab
- Matplotlib
- VCD waveform generation

## 9. Project Structure

- rtl/ : Processor RTL modules
- testbench/ : Verification testbenches
- cache/ : Cache implementations
- branch_prediction/ : Branch predictor
- waveforms/ : Simulation waveforms
- results/ : Performance graphs
- docs/ : Project documentation

## 10. Current Status
- Processor implementation completed.
- Standalone cache modules tested.
- Standalone branch predictor tested.
- 17/17 regression tests passed.
- Performance analysis completed.
- Documentation prepared.

## 11. Scope
The cache and branch predictor are separately implemented and verified.
The measured processor CPI does not represent an integrated cache or
branch-prediction implementation.
