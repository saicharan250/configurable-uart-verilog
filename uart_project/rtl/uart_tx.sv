module uart_tx #(
    parameter int CLK_FREQ  = 50_000_000,
    parameter int BAUD_RATE = 115_200
) (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       tx_start,
    input  logic [7:0] tx_data,
    input  logic [1:0] parity_mode, // 00:none, 01:even, 10:odd
    input  logic       two_stop_bits,
    output logic       tx,
    output logic       tx_busy,
    output logic       tx_done
);
    localparam int CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam int CW = $clog2(CLKS_PER_BIT);

    typedef enum logic [2:0] {IDLE, START, DATA, PARITY, STOP1, STOP2} state_t;
    state_t state;
    logic [CW-1:0] clk_count;
    logic [2:0] bit_index;
    logic [7:0] data_reg;
    logic parity_bit;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE; tx <= 1'b1; tx_busy <= 1'b0; tx_done <= 1'b0;
            clk_count <= '0; bit_index <= '0; data_reg <= '0; parity_bit <= 1'b0;
        end else begin
            tx_done <= 1'b0;
            case (state)
                IDLE: begin
                    tx <= 1'b1; tx_busy <= 1'b0; clk_count <= '0;
                    if (tx_start) begin
                        data_reg <= tx_data;
                        parity_bit <= (parity_mode == 2'b10) ? ~^tx_data : ^tx_data;
                        tx_busy <= 1'b1; state <= START;
                    end
                end
                START: begin
                    tx <= 1'b0;
                    if (clk_count == CLKS_PER_BIT-1) begin clk_count <= '0; bit_index <= '0; state <= DATA; end
                    else clk_count <= clk_count + 1'b1;
                end
                DATA: begin
                    tx <= data_reg[bit_index];
                    if (clk_count == CLKS_PER_BIT-1) begin
                        clk_count <= '0;
                        if (bit_index == 7) state <= (parity_mode == 0) ? STOP1 : PARITY;
                        else bit_index <= bit_index + 1'b1;
                    end else clk_count <= clk_count + 1'b1;
                end
                PARITY: begin
                    tx <= parity_bit;
                    if (clk_count == CLKS_PER_BIT-1) begin clk_count <= '0; state <= STOP1; end
                    else clk_count <= clk_count + 1'b1;
                end
                STOP1: begin
                    tx <= 1'b1;
                    if (clk_count == CLKS_PER_BIT-1) begin
                        clk_count <= '0;
                        if (two_stop_bits) state <= STOP2;
                        else begin state <= IDLE; tx_done <= 1'b1; end
                    end else clk_count <= clk_count + 1'b1;
                end
                STOP2: begin
                    tx <= 1'b1;
                    if (clk_count == CLKS_PER_BIT-1) begin clk_count <= '0; state <= IDLE; tx_done <= 1'b1; end
                    else clk_count <= clk_count + 1'b1;
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
