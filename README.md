# Configurable UART Transmitter and Receiver

This project implements a configurable **8-bit UART Transmitter and Receiver** using SystemVerilog. I developed it as part of my weekly RTL design series to understand asynchronous serial communication, FSM-based design, oversampling, and RTL verification.

## Features

- 8-bit serial data transmission
- Configurable baud rate
- Standard 8N1 communication
- No parity, even parity, and odd parity modes
- One or two stop bits
- 16× oversampling at the receiver
- Two-flip-flop synchronizer for the RX input
- Parity-error detection
- Framing-error detection
- Transmitter busy and done signals
- Receiver data-valid signal
- Self-checking loopback testbench

## UART Frame Format

UART remains HIGH while idle. Each transmission begins with a LOW start bit, followed by eight data bits transmitted LSB first.

```text
Idle | Start | D0 | D1 | D2 | D3 | D4 | D5 | D6 | D7 | Parity | Stop
  1  |   0   |              Data Bits              | Optional |  1
```

The main demonstration uses:

```text
Data bits : 8
Baud rate : 115200
Parity    : None
Stop bits : 1
Format    : 8N1
```

## Project Structure

```text
configurable-uart-verilog/
├── rtl/
│   ├── uart_tx.sv
│   ├── uart_rx.sv
│   └── uart_top.sv
├── tb/
│   └── uart_loopback_tb.sv
├── docs/
│   └── simulation_waveform.png
├── .gitignore
├── PROJECT_PLAN.md
├── LICENSE
└── README.md
```

## Module Description

### UART Transmitter

The transmitter accepts an 8-bit parallel input and converts it into a serial UART frame.

Its finite-state machine performs the following operations:

1. Waits in the idle state
2. Sends the start bit
3. Sends eight data bits, LSB first
4. Sends the optional parity bit
5. Sends one or two stop bits
6. Generates the `tx_done` signal

### UART Receiver

The receiver detects the incoming start bit and reconstructs the transmitted byte.

It uses 16× oversampling to sample every bit near its centre. It also checks the parity and stop bits to identify communication errors.

### UART Top Module

The top module connects the transmitter output to the receiver input in loopback mode. This allows the complete transmission and reception process to be verified in simulation.

## Important Signals

| Signal | Description |
|---|---|
| `tx_start` | Starts transmission |
| `tx_data` | 8-bit data given to the transmitter |
| `uart_tx_line` | Serial UART output |
| `tx_busy` | Indicates that transmission is active |
| `tx_done` | Pulses when transmission is completed |
| `rx_data` | 8-bit received data |
| `rx_valid` | Pulses when received data is available |
| `parity_error` | Indicates incorrect parity |
| `framing_error` | Indicates an invalid stop bit |

## Verification

A self-checking SystemVerilog testbench connects the transmitter and receiver in loopback mode and verifies multiple UART configurations.

The following test values are used:

```text
0x55 — 8N1
0xA3 — Even parity
0xC7 — Odd parity with two stop bits
0x00 — All bits LOW
0xFF — All bits HIGH
```

For every test, the testbench checks:

- Received data against transmitted data
- Parity-error status
- Framing-error status
- Transmitter and receiver handshake signals

Expected simulation output:

```text
PASS: 5 UART loopback tests completed
```

## Simulation Waveform

![UART simulation waveform](docs/simulation_waveform.png)

The waveform demonstrates:

- Transmission-start pulse
- Start bit
- Eight data bits transmitted LSB first
- Optional parity bit
- Stop bit
- Receiver data output
- Receiver-valid pulse
- Error-status signals

## Tools Used

- SystemVerilog
- Xilinx Vivado 2025.2
- Vivado XSIM
- Git and GitHub

## Running the Simulation in Vivado

1. Create a new RTL project.
2. Add the files inside `rtl/` as design sources.
3. Add `tb/uart_loopback_tb.sv` as a simulation source.
4. Set `uart_top` as the design top.
5. Set `uart_loopback_tb` as the simulation top.
6. Select **Run Behavioral Simulation**.
7. Select **Run All** to complete every test.
8. Check the Tcl Console for the final test result.

## What I Learned

Through this project, I learned about:

- UART frame structure
- Asynchronous serial communication
- FSM-based transmitter and receiver design
- Baud-rate and sampling-clock generation
- 16× receiver oversampling
- Asynchronous input synchronization
- Parity generation and checking
- Framing-error detection
- Self-checking testbench development
- Waveform analysis using Vivado

## Future Improvements

- Configurable data length
- Runtime baud-rate selection
- Separate transmitter and receiver FIFOs
- Back-to-back data verification
- Noise and false-start-bit testing
- FPGA hardware implementation
- Communication with a computer using a USB-to-UART converter

## Author

**Sai Charan**  
B.Tech Electronics and Communication Engineering  
Interested in RTL Design, VLSI and Digital Hardware Design
