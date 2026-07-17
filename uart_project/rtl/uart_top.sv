module uart_top #(
    parameter int CLK_FREQ  = 50_000_000,
    parameter int BAUD_RATE = 115_200
) (
    input logic clk, rst_n, tx_start,
    input logic [7:0] tx_data,
    input logic [1:0] parity_mode,
    input logic two_stop_bits,
    output logic uart_tx_line, tx_busy, tx_done,
    output logic [7:0] rx_data,
    output logic rx_valid, parity_error, framing_error
);
    uart_tx #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) u_tx (
        .clk, .rst_n, .tx_start, .tx_data, .parity_mode, .two_stop_bits,
        .tx(uart_tx_line), .tx_busy, .tx_done
    );
    uart_rx #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) u_rx (
        .clk, .rst_n, .rx(uart_tx_line), .parity_mode, .two_stop_bits,
        .rx_data, .rx_valid, .parity_error, .framing_error
    );
endmodule
