`timescale 1ns/1ps
module uart_loopback_tb;
    localparam int CLK_FREQ = 16_000_000;
    localparam int BAUD_RATE = 1_000_000;
    logic clk = 0, rst_n = 0, tx_start = 0, two_stop_bits = 0;
    logic [7:0] tx_data;
    logic [1:0] parity_mode = 0;
    logic tx_line, tx_busy, tx_done, rx_valid, parity_error, framing_error;
    logic [7:0] rx_data;
    int passed = 0;

    always #31.25 clk = ~clk;
    uart_top #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) dut (.*,
        .uart_tx_line(tx_line));

    task automatic send_and_check(input logic [7:0] value, input logic [1:0] parity, input logic stops);
        begin
            parity_mode = parity; two_stop_bits = stops; tx_data = value;
            @(posedge clk); tx_start = 1; @(posedge clk); tx_start = 0;
            wait(rx_valid); #1;
            if (rx_data !== value || parity_error || framing_error)
                $fatal(1, "FAIL sent=%02h received=%02h parity_err=%b frame_err=%b", value, rx_data, parity_error, framing_error);
            passed++;
            wait(!tx_busy); repeat(3) @(posedge clk);
        end
    endtask

    initial begin
        $dumpfile("uart_waveform.vcd"); $dumpvars(0, uart_loopback_tb);
        repeat(5) @(posedge clk); rst_n = 1;
        send_and_check(8'h55, 2'b00, 0); // 8N1
        send_and_check(8'hA3, 2'b01, 0); // even parity
        send_and_check(8'hC7, 2'b10, 1); // odd parity, 2 stop bits
        send_and_check(8'h00, 2'b00, 0);
        send_and_check(8'hFF, 2'b00, 0);
        $display("PASS: %0d UART loopback tests completed", passed);
        $finish;
    end
endmodule
