import mmu_pkg::*;

module page_walker_unit(
    input logic iclk,
    input logic irst_n,

    // Miss request from TLB/MMU
    input logic miss_valid,
    input logic [VPN_WIDTH-1:0] miss_vpn,

    // Page table memory interface
    output logic rd_en,
    output logic [VPN_WIDTH-1:0] rd_vpn,

    input logic pte_valid,
    input logic [PPN_WIDTH-1:0] pte_ppn,

    // Result
    output logic done,
    output logic [VPN_WIDTH-1:0] walk_vpn,
    output logic [PPN_WIDTH-1:0] walk_ppn,
    output logic page_fault
);



endmodule