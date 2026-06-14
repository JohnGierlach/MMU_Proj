`timescale 1ns/1ps
import mmu_pkg::*;

module tlb_tb;

    logic iclk = 0;
    logic irst_n = 0;

    logic lookup_valid;
    logic [VPN_WIDTH-1:0] lookup_vpn;

    logic hit;
    logic miss;
    logic [PPN_WIDTH-1:0] return_ppn;
    logic [TLB_INDEX_WIDTH-1:0] hit_idx;

    logic refill_valid;
    logic [VPN_WIDTH-1:0] refill_vpn;
    logic [PPN_WIDTH-1:0] refill_ppn;

    tlb_unit uut (
        .iclk(iclk),
        .irst_n(irst_n),
        .lookup_valid(lookup_valid),
        .lookup_vpn(lookup_vpn),
        .hit(hit),
        .miss(miss),
        .return_ppn(return_ppn),
        .hit_idx(hit_idx),
        .refill_valid(refill_valid),
        .refill_vpn(refill_vpn),
        .refill_ppn(refill_ppn)
    );

    always #5 iclk = ~iclk;

    initial begin
        $dumpfile("tb/waveforms/tlb_tb.vcd");
        $dumpvars(0, tlb_tb);

        // Reset
        irst_n = 0;
        lookup_valid = 0;
        refill_valid = 0;
        refill_vpn = '0;
        refill_ppn = '0;
        lookup_vpn = '0;
        #20;
        irst_n = 1;
        #10;

        // Refill a single entry
        refill_valid = 1;
        refill_vpn = 32'h0000_000A >> PAGE_OFFSET_BITS; // low VPN
        refill_ppn = 32'h0000_00AA >> PAGE_OFFSET_BITS;
        #10;
        refill_valid = 0;
        refill_vpn = '0;
        refill_ppn = '0;
        #10;

        // Lookup the same VPN: should hit
        lookup_valid = 1;
        lookup_vpn = 32'h0000_000A >> PAGE_OFFSET_BITS;
        #10;
        lookup_valid = 0;
        #10;

        // Lookup a different VPN: should miss
        lookup_valid = 1;
        lookup_vpn = 32'h0000_000B >> PAGE_OFFSET_BITS;
        #10;
        lookup_valid = 0;
        #10;

        // Refill a second entry and then lookup both
        refill_valid = 1;
        refill_vpn = 32'h0000_000C >> PAGE_OFFSET_BITS;
        refill_ppn = 32'h0000_00BB >> PAGE_OFFSET_BITS;
        #10;
        refill_valid = 0;
        #10;

        lookup_valid = 1;
        lookup_vpn = 32'h0000_000C >> PAGE_OFFSET_BITS;
        #10;
        lookup_valid = 0;
        #10;

        $display("TLB test complete: hit=%0b miss=%0b hit_idx=%0d return_ppn=%h", hit, miss, hit_idx, return_ppn);
        #20;
        $finish;
    end

endmodule
