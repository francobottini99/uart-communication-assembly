# UART Communication Between PIC16F887 Microcontrollers

This project, written in assembly language, involves the implementation of a UART communication system between two PIC16F887 microcontrollers. One microcontroller acts as the transmitter, while the other functions as the receiver. The communication is established through serial data transmissions and receptions, allowing interaction between both devices. The project is developed in the **MPLAB X IDE** environment.

## Authors
- **Franco Nicolas Bottini**
- **Valentin Robledo**
- **Aquiles Benjamin Lencina**
- **Santiago Quinteros del Castillo**

## Components Used
### Microcontrollers
- **Transmitter:** PIC16F887
- **Receiver:** PIC16F887

### Other Components
- **Matrix Keypad:** Used on the transmitter for data input.
- **7-Segment Display:** Implemented on the receiver for displaying received data.

## Simulation in Proteus
The project includes a simulation of the system in the Proteus electronic design environment. This allows for verifying the system's functionality before physical implementation, ensuring greater efficiency in development and early identification of potential issues.

## Main Features
1. **Transmitter:**
   - Scans a matrix keypad for data input.
   - Stores the data in a buffer for later transmission via UART.

2. **Receiver:**
   - Receives data through UART communication.
   - Displays the received data on a 7-segment display.

## Project Development

### Microcontroller Configuration
- The PIC16F887 microcontroller is selected for both the transmitter and receiver.
- The configuration includes oscillator frequency, pin setup, and other microcontroller-specific parameters.

### UART Communication
- UART communication is established between the microcontrollers using the TX and RX pins.
- The transmission speed (baud rate) is configured to ensure efficient and reliable communication.

### Matrix Keypad (Transmitter)
- A matrix keypad scan is implemented for data input on the transmitter.
- Accurate keypress detection is ensured to prevent erroneous readings.

### 7-Segment Display (Receiver)
- The receiver includes a 7-segment display for visualizing the received data.
- A decoding table is defined to convert data into appropriate formats for display.

### Specific Subroutines
1. **PutBuffer (Transmitter):**
   - Stores data from the matrix keypad in a buffer for later transmission.

2. **PollBuffer (Receiver):**
   - Checks and extracts data from the reception buffer for processing.

3. **SendRegister (Transmitter):**
   - Sends the data stored in the buffer via UART communication.

4. **Keypad (Transmitter):**
   - Handles keypad scanning and keypress management, ensuring correct data input.

5. **DisplayData (Receiver):**
   - Processes received data and displays it on the 7-segment display.

6. **Multiplex (Receiver):**
   - Performs multiplexing to update the display visualization.
