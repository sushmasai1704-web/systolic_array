# 4×4 Systolic Array (Verilog)

A 4×4 output-stationary systolic array for integer matrix multiplication (C = A × B), implemented in Verilog and verified with Icarus Verilog.

## Architecture

- **16 Processing Elements (PEs)** arranged in a 4×4 mesh
- Each PE performs a **MAC** (multiply-accumulate): `acc += a_in * w_in`
- **Activations** flow left → right (row-wise)
- **Weights** flow top → bottom (column-wise)
- **Output-stationary**: each PE holds one element of result matrix C

    w_col0  w_col1  w_col2  w_col3
      │       │       │       │
a_row0 → PE00 → PE01 → PE02 → PE03 │ │ │ │ a_row1 → PE10 → PE11 → PE12 → PE13 │ │ │ │ a_row2 → PE20 → PE21 → PE22 → PE23 │ │ │ │ a_row3 → PE30 → PE31 → PE32 → PE33
## Repository Structure

systolic_array/ 
├── rtl/ 
│ ├── pe.v # Processing element (8-bit MAC) 
│ └── systolic_4x4.v # Top-level 4×4 array 
├── tb/ 
│ ├── tb_systolic.v # Test 1: A × Identity 
│ └── tb_systolic2.v # Test 2: Non-trivial B matrix 
├── model/ 
│ ├── golden_model.py # Python reference model 
│ └── test_vectors.txt # Test vectors 
└── sim/ # VCD waveform outputs
## How to Simulate

```bash
# Test 1: A × Identity = A
iverilog -o sim/systolic_sim rtl/pe.v rtl/systolic_4x4.v tb/tb_systolic.v
vvp sim/systolic_sim

# Test 2: Non-trivial matrix
iverilog -o sim/systolic2_sim rtl/pe.v rtl/systolic_4x4.v tb/tb_systolic2.v
vvp sim/systolic2_sim
Results
Both testbenches pass 4/4 rows:

Test 1 (Identity): C = A Test 2 (Non-trivial):[ 5, 10,  7, 14]
[17, 26, 19, 30]
[29, 42, 31, 46]
[41, 58, 43, 62]
Data Format
Inputs: 8-bit unsigned (a_in, w_in)
Accumulator: 32-bit (prevents overflow for 4-element dot products of 8-bit values)
Feeding: Skewed diagonal — element A[i][j] enters row i at cycle i+j+1
Tools
Icarus Verilog (iverilog 10.3) for simulation
GTKWave for waveform viewing (sim/*.vcd)
Python 3 for golden reference model
Author
Built as part of an RTL design portfolio covering systolic arrays, AXI4, RISC-V pipelines, PWM, and formal verification. 
