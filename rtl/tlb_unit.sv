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
    output logic [TLB_INDEX_WIDTH-1:0] hit_idx,

    // refill path (from page walker)
    input  logic refill_valid,
    input  logic [VPN_WIDTH-1:0] refill_vpn,
    input  logic [PPN_WIDTH-1:0] refill_ppn
);

    logic valid_array[TLB_ENTRIES];
    logic [VPN_WIDTH-1:0] vpn_array[TLB_ENTRIES];
    logic [PPN_WIDTH-1:0] ppn_array[TLB_ENTRIES];
    integer i;

    logic [TLB_ENTRIES-1:0] match;
    logic [PPN_WIDTH-1:0] tmp_ppn;
    logic [TLB_INDEX_WIDTH-1:0] repl_ptr;
    logic found_match;

    // Refill logic
    always @(posedge iclk or negedge irst_n) begin
        if (!irst_n) begin
            for (i = 0; i < TLB_ENTRIES; i = i + 1) begin
                valid_array[i] <= 1'b0;
                vpn_array[i]   <= {VPN_WIDTH{1'b0}};
                ppn_array[i]   <= {PPN_WIDTH{1'b0}};
            end
            repl_ptr <= {TLB_INDEX_WIDTH{1'b0}};
        end else if (refill_valid) begin
            valid_array[repl_ptr] <= 1'b1;
            vpn_array[repl_ptr]   <= refill_vpn;
            ppn_array[repl_ptr]   <= refill_ppn;
            repl_ptr <= repl_ptr + 1;
        end
    end

    // CAM-style lookup: compare all TLB entries in parallel
    always @* begin
        hit_idx = {TLB_INDEX_WIDTH{1'b0}};
        tmp_ppn = {PPN_WIDTH{1'b0}};
        found_match = 1'b0;

        for (i = 0; i < TLB_ENTRIES; i = i + 1) begin
            match[i] = lookup_valid && valid_array[i] && (vpn_array[i] == lookup_vpn);
        end

        if (lookup_valid) begin
            for (i = 0; i < TLB_ENTRIES; i = i + 1) begin
                if (match[i] && !found_match) begin
                    hit_idx = i;
                    tmp_ppn = ppn_array[i];
                    found_match = 1'b1;
                end
            end
        end
    end

    assign hit  = lookup_valid && |match;
    assign miss = lookup_valid && ~|match;
    assign return_ppn = tmp_ppn;

endmodule