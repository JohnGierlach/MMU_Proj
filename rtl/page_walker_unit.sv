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

    walker_state_t state, next_state;
    logic [VPN_WIDTH-1:0] vpn_reg;
    logic [PPN_WIDTH-1:0] ppn_reg;

    // State machine for page walking
    always @(posedge iclk or negedge irst_n) begin
        if (!irst_n) begin
            state <= IDLE;
            vpn_reg <= '0;
            ppn_reg <= '0;
        end else begin
            state <= next_state;
            if (next_state == READ_PTE) begin
                vpn_reg <= miss_vpn;
            end
            if (pte_valid && state == WAIT_RESPONSE) begin
                ppn_reg <= pte_ppn;
            end
        end
    end

    // State machine combinational logic
    always @* begin
        next_state = state;
        rd_en = 1'b0;
        rd_vpn = vpn_reg;
        done = 1'b0;
        walk_vpn = vpn_reg;
        walk_ppn = ppn_reg;
        page_fault = 1'b0;

        case (state)
            IDLE: begin
                if (miss_valid) begin
                    next_state = READ_PTE;
                end
            end

            READ_PTE: begin
                rd_en = 1'b1;
                rd_vpn = miss_vpn;
                next_state = WAIT_RESPONSE;
            end

            WAIT_RESPONSE: begin
                if (pte_valid) begin
                    next_state = DONE;
                end
            end

            DONE: begin
                done = 1'b1;
                next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule