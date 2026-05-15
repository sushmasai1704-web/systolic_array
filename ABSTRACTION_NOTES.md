# Abstraction Techniques Used in PE Formal Verification

## 1. Symbolic Input Abstraction
The upstream data sources (north_in, west_in) are treated as fully
unconstrained symbolic inputs. No SRAM or upstream PE model is needed —
the solver explores all possible input sequences, including corner cases
no simulation would hit (max positive, max negative, alternating signs).

## 2. Protocol Assumption Constraints
Rather than modeling a real AXI-style handshake upstream, we use `assume`
to encode only the rules the environment must obey:
- valid must stay high until ready is asserted (no spurious drops)
- valid/ready are deasserted during reset

This is abstraction by assumption: we ignore *how* the upstream works
and only constrain *what* it guarantees, reducing state space dramatically.

## 3. Reset Abstraction
`initial assume(!rst_n)` forces the solver to start from a known reset
state rather than an arbitrary state, bounding the reachability problem
and preventing vacuous proofs from unreachable initial states.

## 4. Shadow Register Technique
Instead of using $past(north_lat, 2) — which breaks when north_lat is
overwritten by a new input in the same cycle — we introduce f_north_shadow
and f_west_shadow registers that capture the value only when pipe_v1 is
active. This is an abstraction of the pipeline's internal timing into a
simpler "value at this stage" model that the solver can reason about cleanly.
