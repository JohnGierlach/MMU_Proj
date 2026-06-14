import mmu_pkg::*;

module mmu_top(

    input logic iclk,
    input logic irst_n,

    // CPU request
    input logic req_valid,
    input logic [VA_WIDTH-1:0] virt_addr,

    // CPU response
    output logic resp_valid,
    output logic [PA_WIDTH-1:0] phys_addr,
    output logic page_fault

);

logic [VPN_WIDTH-1:0] lookup_vpn;
logic [PAGE_OFFSET_BITS-1:0] page_offset;

logic tlb_hit;
logic tlb_miss;
logic [PPN_WIDTH-1:0] tlb_ppn;

logic walker_done;
logic [VPN_WIDTH-1:0] walker_vpn;
logic [PPN_WIDTH-1:0] walker_ppn;
logic walker_fault;

logic rd_en;
logic [VPN_WIDTH-1:0] rd_vpn;

logic pte_valid;
logic [PPN_WIDTH-1:0] pte_ppn;

tlb u_tlb (
    .iclk(iclk),
    .irst_n(irst_n),
    .lookup_valid(req_valid),
    .lookup_vpn(lookup_vpn),
    .hit(tlb_hit),
    .miss(tlb_miss),
    .return_ppn(tlb_ppn),
    .refill_valid(walker_done & ~walker_fault),
    .refill_vpn(walker_vpn),
    .refill_ppn(walker_ppn)
);

page_walker u_page_walker (
    .iclk(iclk),
    .irst_n(irst_n),
    .miss_valid(tlb_miss),
    .miss_vpn(lookup_vpn),
    .rd_en(rd_en),
    .rd_vpn(rd_vpn),
    .pte_valid(pte_valid),
    .pte_ppn(pte_ppn),
    .done(walker_done),
    .walk_vpn(walker_vpn),
    .walk_ppn(walker_ppn),
    .page_fault(walker_fault)
);

page_table_mem u_page_table (
    .iclk(iclk),
    .irst_n(irst_n),
    .rd_en(rd_en),
    .rd_vpn(rd_vpn),
    .pte_valid(pte_valid),
    .pte_ppn(pte_ppn)
);

assign lookup_vpn =virt_addr[VA_WIDTH-1:PAGE_OFFSET_BITS];
assign page_offset = virt_addr[PAGE_OFFSET_BITS-1:0];
assign phys_addr = {tld_ppn, page_offset};

endmodule