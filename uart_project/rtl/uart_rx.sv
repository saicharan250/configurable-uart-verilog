module uart_rx #(
    parameter int CLK_FREQ  = 50_000_000,
    parameter int BAUD_RATE = 115_200
) (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       rx,
    input  logic [1:0] parity_mode, // 00:none, 01:even, 10:odd
    input  logic       two_stop_bits,
    output logic [7:0] rx_data,
    output logic       rx_valid,
    output logic       parity_error,
    output logic       framing_error
);
    localparam int OVERSAMPLE = 16;
    localparam int TICKS_PER_SAMPLE = CLK_FREQ / (BAUD_RATE * OVERSAMPLE);
    localparam int TW = (TICKS_PER_SAMPLE <= 1) ? 1 : $clog2(TICKS_PER_SAMPLE);

    typedef enum logic [2:0] {IDLE, START, DATA, PARITY, STOP1, STOP2} state_t;
    state_t state;
    logic rx_meta, rx_sync;
    logic [TW-1:0] tick_count;
    logic [3:0] sample_count;
    logic [2:0] bit_index;
    logic [7:0] data_reg;
    logic sample_tick;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin rx_meta <= 1'b1; rx_sync <= 1'b1; end
        else begin rx_meta <= rx; rx_sync <= rx_meta; end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin tick_count <= '0; sample_tick <= 1'b0; end
        else begin
            sample_tick <= 1'b0;
            if (tick_count == TICKS_PER_SAMPLE-1) begin tick_count <= '0; sample_tick <= 1'b1; end
            else tick_count <= tick_count + 1'b1;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE; sample_count <= '0; bit_index <= '0; data_reg <= '0;
            rx_data <= '0; rx_valid <= 1'b0; parity_error <= 1'b0; framing_error <= 1'b0;
        end else begin
            rx_valid <= 1'b0;
            if (sample_tick) begin
                case (state)
                    IDLE: if (!rx_sync) begin
                        sample_count <= '0; parity_error <= 1'b0; framing_error <= 1'b0; state <= START;
                    end
                    START: begin
                        if (sample_count == 7) begin
                            if (!rx_sync) begin sample_count <= '0; bit_index <= '0; state <= DATA; end
                            else state <= IDLE;
                        end else sample_count <= sample_count + 1'b1;
                    end
                    DATA: begin
                        if (sample_count == 15) begin
                            sample_count <= '0; data_reg[bit_index] <= rx_sync;
                            if (bit_index == 7) state <= (parity_mode == 0) ? STOP1 : PARITY;
                            else bit_index <= bit_index + 1'b1;
                        end else sample_count <= sample_count + 1'b1;
                    end
                    PARITY: begin
                        if (sample_count == 15) begin
                            sample_count <= '0;
                            if (parity_mode == 2'b01) parity_error <= (rx_sync != ^data_reg);
                            else parity_error <= (rx_sync != ~^data_reg);
                            state <= STOP1;
                        end else sample_count <= sample_count + 1'b1;
                    end
                    STOP1: begin
                        if (sample_count == 15) begin
                            sample_count <= '0; framing_error <= !rx_sync;
                            if (two_stop_bits) state <= STOP2;
                            else begin rx_data <= data_reg; rx_valid <= 1'b1; state <= IDLE; end
                        end else sample_count <= sample_count + 1'b1;
                    end
                    STOP2: begin
                        if (sample_count == 15) begin
                            framing_error <= framing_error | !rx_sync;
                            rx_data <= data_reg; rx_valid <= 1'b1; sample_count <= '0; state <= IDLE;
                        end else sample_count <= sample_count + 1'b1;
                    end
                    default: state <= IDLE;
                endcase
            end
        end
    end
endmodule
