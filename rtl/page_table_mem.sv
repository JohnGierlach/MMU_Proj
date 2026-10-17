import mmu_pkg::*;

module page_table_mem(
    input logic iclk,
    input logic irst_n,

    input logic rd_en,
    input logic [VPN_WIDTH-1:0] rd_vpn,

    output logic pte_valid,
    output logic [PPN_WIDTH-1:0] pte_ppn
);

    // Page table memory storage
    // In a real system, this would be a larger memory structure
    // For this design, we use a simple associative memory with 256 entries
    localparam int PT_ENTRIES = 256;
    
    logic valid_array[PT_ENTRIES];
    logic [PPN_WIDTH-1:0] ppn_array[PT_ENTRIES];
    logic pte_valid_r;
    logic [PPN_WIDTH-1:0] pte_ppn_r;
    integer i;

    // Initialize page table with some default mappings
    initial begin
        for (i = 0; i < PT_ENTRIES; i = i + 1) begin
            valid_array[i] = 1'b0;
            ppn_array[i] = {PPN_WIDTH{1'b0}};
        end
        
        // Add some test mappings for verification
        // VPN 0x0A -> PPN 0x0AA
        if (20'h0000_A < PT_ENTRIES) begin
            valid_array[20'h0000_A] = 1'b1;
            ppn_array[20'h0000_A] = 20'h0000_AA;
        end
        
        // VPN 0x0B -> PPN 0x0BB  
        if (20'h0000_B < PT_ENTRIES) begin
            valid_array[20'h0000_B] = 1'b1;
            ppn_array[20'h0000_B] = 20'h0000_BB;
        end
        
        // VPN 0x0C -> PPN 0x0CC
        if (20'h0000_C < PT_ENTRIES) begin
            valid_array[20'h0000_C] = 1'b1;
            ppn_array[20'h0000_C] = 20'h0000_CC;
        end
    end

    // Sequential logic for pipelined read response (1-cycle latency)
    always @(posedge iclk or negedge irst_n) begin
        if (!irst_n) begin
            pte_valid_r <= 1'b0;
            pte_ppn_r <= {PPN_WIDTH{1'b0}};
        end else if (rd_en) begin
            // Check if VPN is within valid range
            if (rd_vpn < PT_ENTRIES) begin
                pte_valid_r <= valid_array[rd_vpn];
                pte_ppn_r <= ppn_array[rd_vpn];
            end else begin
                pte_valid_r <= 1'b0;
                pte_ppn_r <= {PPN_WIDTH{1'b0}};
            end
        end else begin
            pte_valid_r <= 1'b0;
        end
    end

    assign pte_valid = pte_valid_r;
    assign pte_ppn = pte_ppn_r;

endmodule