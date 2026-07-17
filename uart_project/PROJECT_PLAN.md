# UART Weekly Series Plan

## Architecture

1. `uart_tx` accepts one byte when `tx_start` is asserted.
2. The transmitter builds the frame: start bit, eight data bits, optional parity, and stop bit(s).
3. `uart_rx` synchronizes the asynchronous input and samples it at 16 times the baud rate.
4. The receiver reconstructs the byte and reports parity or stop-bit errors.
5. `uart_top` connects TX to RX internally for loopback verification.

## Recommended LinkedIn evidence

- Block diagram showing TX, serial line, and RX
- RTL schematic from Vivado or Quartus
- GTKWave/Vivado waveform with `tx_start`, `tx_line`, `rx_data`, and `rx_valid`
- Console showing all five tests passed
- GitHub repository link

## Next verification cases

- Inject an incorrect parity bit and confirm `parity_error`
- Force the stop bit low and confirm `framing_error`
- Test back-to-back bytes
- Sweep supported baud-rate parameter values
- Synthesize and report LUT/flip-flop utilization and maximum clock frequency
