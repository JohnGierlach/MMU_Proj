import mmu_pkg::*;
module page_table_mem(
    input logic iclk,
    input logic irst_n,

    input logic rd_en,
    input logic [VPN_WIDTH-1:0] rd_vpn,

    output logic pte_valid,
    output logic [PPN_WIDTH-1:0] pte_ppn
);

endmodule