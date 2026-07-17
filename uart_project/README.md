# Configurable UART Transmitter and Receiver

A synthesizable SystemVerilog UART developed as part of my weekly RTL design series. The project demonstrates full-duplex building blocks, configurable framing, receiver synchronization, 16x oversampling, and self-checking verification.

## Features

- 8-bit data transmission, LSB first
- Configurable baud rate through parameters
- No, even, or odd parity
- One or two stop bits
- 16x oversampling receiver
- Two-flop RX synchronizer
- `busy`, `done`, and `data_valid` status signals
- Parity-error and framing-error detection
- Self-checking loopback testbench

## Default demonstration

The intended hardware demo is **115200 baud, 8N1** with a 50 MHz FPGA clock. The testbench uses a faster simulation configuration while exercising 8N1, even parity, odd parity, and two-stop-bit modes.

## Structure

```text
uart_project/
├── rtl/
│   ├── uart_tx.sv
│   ├── uart_rx.sv
│   └── uart_top.sv
└── tb/
    └── uart_loopback_tb.sv
```

## UART frame

```text
Idle(1) | Start(0) | D0 D1 D2 D3 D4 D5 D6 D7 | Optional parity | Stop(1)
```

## Run with Icarus Verilog

```bash
iverilog -g2012 -o uart_sim rtl/uart_tx.sv rtl/uart_rx.sv rtl/uart_top.sv tb/uart_loopback_tb.sv
vvp uart_sim
gtkwave uart_waveform.vcd
```

Expected result:

```text
PASS: 5 UART loopback tests completed
```

## What I learned

This design helped me understand asynchronous serial framing, finite-state-machine based control, clock-domain input synchronization, oversampling, parity generation/checking, and automated RTL verification.
