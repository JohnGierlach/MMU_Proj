# TLB Lookup & Refill Flow (ASCII)

This file shows a simple ASCII diagram of the CAM-style TLB lookup and refill paths, and maps the main signals used by `tlb_unit.sv`.

CPU / MMU Client
    |
    | lookup_valid, lookup_vpn
    v
    +----------------------+    compare in parallel (CAM)    +----------------------------+
    | TLB Unit: Lookup     | --------------------------------> | Parallel comparator across |
    |  (inputs: lookup_vpn)|                                    | entries (match vector)    |
    +----------------------+                                    +------------+---------------+
                        |
                 match found? ---+     +--- no match
                        |
                        v
                +----------------+     |     +------------------------+
                | Hit (first)    |     |     | Miss: `miss` asserted  |
                | return_ppn     |     |     | -> page walker triggered |
                | hit_idx, hit   |     |     +------------------------+
                +----------------+     |
                        v
                      +----------------+
                      | Page Walker    |
                      +----------------+
                        |
                  refill_valid, refill_vpn, refill_ppn
                        v
                      +----------------+
                      | Refill logic   |
                      | write at repl_ptr
                      +----------------+
                        |
                        v
            +-----------------+   +-----------------+  +-----------------+
            | valid_array[]   |   | vpn_array[]     |  | ppn_array[]     |
            +-----------------+   +-----------------+  +-----------------+

**Signal mapping**
- `iclk`: clock for sequential logic (refill writes, replacement pointer update).
- `irst_n`: active-low reset to invalidate TLB and reset `repl_ptr`.
- `lookup_valid` / `lookup_vpn`: client request signals to start a translation lookup.
- `hit`: true when at least one valid entry matches `lookup_vpn`.
- `miss`: true when no valid entry matches (used to start a page walk).
- `return_ppn`: the PPN read from the matched entry (valid when `hit`).
- `hit_idx`: index of the first matching entry (useful for diagnostics / indexed ops).
- `refill_valid` / `refill_vpn` / `refill_ppn`: inputs from the page walker to insert a new translation.
- `valid_array`, `vpn_array`, `ppn_array`: internal per-entry storage used by the CAM lookup.
- `match`: combinational one-hot vector indicating which entries matched.
- `tmp_ppn`: temporary combinational register used to latch the chosen PPN before output.
- `repl_ptr`: round-robin pointer selecting the entry to overwrite on refill.
- `found_match` / `i`: internal helpers for scanning and selecting the first match.

If you'd like, I can refactor `rtl/tlb_unit.sv` to use a `typedef struct packed` for entries and update this ASCII diagram to show the packed fields.