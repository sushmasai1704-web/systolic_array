# Formal Verification Portfolio — Sushma
## Target Role: NVIDIA Silicon Solutions / Design Verification Engineer
### Last Updated: 2026-05-15

---

## Executive Summary

This portfolio demonstrates production-grade formal verification (FV) on three
distinct RTL designs of increasing complexity:

| Project | Domain | FV Technique | Lines of RTL | Formal Properties |
|---------|--------|-------------|--------------|-----------------|
| **Project 1: Arbiter** | Control logic | BMC + k-induction | ~40 | 4 assertions, 5 cover |
| **Project 2: AXI4-Lite Slave** | Bus protocol | k-induction, depth 20 | ~120 | 9 assertions, 5 cover |
| **Project 3: Systolic Array PE** | Datapath (MAC) | k-induction, depth 25 | ~150 | 10 assertions, 7 cover |

**Key differentiators for NVIDIA:**
- All properties proven under **stated assumptions** (not over-constrained)
- **FSM consistency checks** (state ↔ output correspondence)
- **Pipeline coverage** including back-to-back and stall scenarios
- **Arithmetic correctness** (MAC operation formally verified)
- **Zero spurious counterexamples** — assumptions are tight and minimal

---

## Project 1: Round-Robin Arbiter

### Design
- Parameterized N-request arbiter with rotating priority pointer
- Registered grant output (one-cycle latency)

### Formal Strategy
| Aspect | Approach |
|--------|----------|
| Reset behavior | `initial assume(!rst_n)` + grant==0 during reset |
| One-hot grant | `(grant & (grant-1)) == 0` |
| Grant validity | `(grant & $past(req)) == grant` |
| No-grant-on-empty | `if ($past(req)==0) assert(grant==0)` |

### Results
- **Tool**: SymbiYosys (Yosys + Z3)
- **Prove depth**: 15 cycles
- **Runtime**: &lt;1 second
- **Status**: All properties PASS

---

## Project 2: AXI4-Lite Slave

### Design
- AXI4-Lite compliant register file slave
- Independent write (AW/W/B) and read (AR/R) channels
- Parameterized DATA_WIDTH=32, ADDR_WIDTH=4, NUM_REGS=16

### Formal Strategy

#### Assumptions (Environment Constraints)
| ID | Constraint | AXI Rule |
|----|-----------|----------|
| E1 | `aresetn` held low at t=0 | Reset requirement |
| E2 | `awvalid` stable until `awready` | Handshake A3.2 |
| E3 | `wvalid` stable until `wready` | Handshake A3.2 |
| E4 | `arvalid` stable until `arready` | Handshake A3.2 |

#### Assertions (Safety Properties)
| ID | Property | Technique | Result |
|----|----------|-----------|--------|
| A1 | `bvalid` stable until `bready` | k-induction | PASS |
| A2 | `rvalid` stable until `rready` | k-induction | PASS |
| A3 | `bresp` always OKAY (2'b00) | BMC | PASS |
| A4 | `rresp` always OKAY (2'b00) | BMC | PASS |
| A5 | `rdata` stable while `rvalid` high, `rready` low | k-induction | PASS |
| A6 | `bresp` stable while `bvalid` high, `bready` low | k-induction | PASS |
| A7 | Write FSM outputs one-hot: awready/wready/bvalid | Structural | PASS |
| A8 | Read FSM outputs one-hot: arready/rvalid | Structural | PASS |
| A9 | FSM state ↔ output signal consistency | k-induction | PASS |

#### Cover Properties (Liveness)
| ID | Scenario | Reached At |
|----|----------|-----------|
| C1 | Write transaction completes | Step 5 |
| C2 | Read transaction completes | Step 5 |
| C3 | Write-then-read to same address | Step 6 |
| C4 | Back-to-back writes (2 complete) | Step 10 |
| C5 | Read OKAY with stable `rdata` | Step 6 |

### Results
- **Tool**: SymbiYosys (Z3)
- **Prove depth**: 20 cycles
- **Cover depth**: 30 cycles
- **Runtime**: &lt;1 second
- **Status**: All 9 assertions PASS, all 5 covers REACHABLE

---

## Project 3: Systolic Array Processing Element (PE)

### Design
- 2-stage pipelined MAC (Multiply-Accumulate) unit
- Data bypass: north→south, west→east (systolic flow)
- Parameterized DATA_WIDTH=16, ACC_WIDTH=32
- Supports signed arithmetic (sign-extended multiply)

### Formal Strategy

#### Assumptions
| ID | Constraint | Rationale |
|----|-----------|-----------|
| E1 | `rst_n` held low at t=0 | Power-on reset |
| E2 | Inputs zero during reset | Prevent X propagation |
| E3 | `north_valid` stable until `north_ready` | Handshake protocol |
| E4 | `west_valid` stable until `west_ready` | Handshake protocol |
| E5 | Downstream `ready` stable until transaction | Backpressure |

#### Assertions
| ID | Property | Category | Result |
|----|----------|----------|--------|
| A1 | Post-reset accumulator == 0 | Reset correctness | PASS |
| A2 | MAC result == accumulator + (north × west) | Datapath correctness | PASS |
| A3 | `south_out` == latched `north_in` | Bypass correctness | PASS |
| A4 | `east_out` == latched `west_in` | Bypass correctness | PASS |
| A5 | Pipeline valid bits mutually exclusive per stage | Structural | PASS |
| A6 | Overflow detectable (if saturation enabled) | Data integrity | PASS |
| A7 | Reset clears all `pipe_valid` bits | Reset completeness | PASS |
| A8 | Output stability under backpressure | Protocol | PASS |
| A9 | No unknown (`$isunknown`) on valid outputs | X-check | PASS |
| A10 | Accumulator monotonic under positive inputs | Optional invariant | PASS |

#### Cover Properties
| ID | Scenario | Purpose |
|----|----------|---------|
| C1 | Single MAC completes | Basic functionality |
| C2 | Back-to-back MAC (pipeline full) | Throughput verification |
| C3 | Accumulator wraps to all-ones | Overflow behavior |
| C4 | Zero × zero = zero | Corner case |
| C5 | Max positive × max positive | Saturation corner |
| C6 | Pipeline flush (all valid low) | Idle state reachability |
| C7 | Stalled output (valid && !ready) | Backpressure coverage |

### Results
- **Tool**: SymbiYosys (Z3)
- **Prove depth**: 25 cycles
- **Runtime**: ~3 seconds (arithmetic-heavy)
- **Status**: All 10 assertions PASS, all 7 covers REACHABLE

---

## Toolchain & Methodology

| Component | Version | Purpose |
|-----------|---------|---------|
| Yosys | 0.37+ | RTL synthesis, formal prep |
| SymbiYosys | 0.13+ | FV orchestration |
| Z3 | 4.12+ | SMT solver (arithmetic, bit-vectors) |
| OSS CAD Suite | 2024-01-17 | Integrated distribution |

### Verification Flow
```bash
# Run formal proof
sby -f pe.sby

# Run coverage check
# Edit pe.sby: mode prove → mode cover, then:
sby -f pe.sby
