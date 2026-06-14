// mmu_pkg.sv

package mmu_pkg;

    parameter int VA_WIDTH         = 32;
    parameter int PA_WIDTH         = 32;

    parameter int PAGE_OFFSET_BITS = 12;

    parameter int VPN_WIDTH        = VA_WIDTH - PAGE_OFFSET_BITS;
    parameter int PPN_WIDTH        = PA_WIDTH - PAGE_OFFSET_BITS;

    parameter int TLB_ENTRIES      = 16;
    parameter int TLB_INDEX_WIDTH  = $clog2(TLB_ENTRIES);

    typedef struct packed {
        logic valid;
        logic [VPN_WIDTH-1:0] vpn;
        logic [PPN_WIDTH-1:0] ppn;
    } tlb_entry_t;

    typedef enum logic [1:0] {
        IDLE,
        READ_PTE,
        WAIT_RESPONSE,
        DONE
    } walker_state_t;

endpackage