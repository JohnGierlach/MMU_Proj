import mmu_pkg::*;

module tlb_unit(
    input  logic iclk,
    input  logic irst_n,

    // lookup path
    input  logic lookup_valid,
    input  logic [VPN_WIDTH-1:0] lookup_vpn,

    output logic hit,
    output logic miss,
    output logic [PPN_WIDTH-1:0] return_ppn,

    // refill path (from page walker)
    input  logic refill_valid,
    input  logic [VPN_WIDTH-1:0] refill_vpn,
    input  logic [PPN_WIDTH-1:0] refill_ppn
);

    tlb_entry_t tlb_entries[TLB_ENTRIES];

    logic [PPN_WIDTH-1:0] tmp_ppn;
    logic [TLB_ENTRIES-1:0] match; 
    logic [TLB_INDEX_WIDTH-1:0] repl_ptr;
    logic [TLB_INDEX_WIDTH-1:0] hit_idx;

    // Refill logic
    always@(posedge iclk)begin
        if(!irst_n)begin
            for(int i = 0; i < TLB_ENTRIES; i++)
                tlb_entries[i].valid <= 0;
                match[i] <= 0;
            repl_ptr <= 0;
            hit_idx <= 0;
            tmp_ppn <= 0;
        end

        else if (refill_valid)begin
            
        end
    end

    always@(*)begin
        
    end

    assign hit  =
    assign miss = 
    assign return_ppn = tmp_ppn;

endmodule