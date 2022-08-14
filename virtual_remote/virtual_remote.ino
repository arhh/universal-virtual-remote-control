// Length of command code (in bits) to transmit
#define COMMAND_LENGTH 32

// Cool-off period (in milliseconds) after transmission
#define DELAY_AFTER_SEND 1000

// Number of times a command should be transmitted
#define PULSE_COUNT 1

// Arduino IO pin to which IR LED is connected
#define IR_SEND_PIN 3

#define REPEAT_TRANSMISSIONS 1

#include <IRremote.hpp>

// Declare variable for IR transmitter
//IRsend irsend;/

/**
 * Disable built-in LED and prepare serial port.
 */
void setup() {
    pinMode(LED_BUILTIN, OUTPUT);
    digitalWrite(LED_BUILTIN, 0);
    Serial.begin(9600);
    IrSender.begin(IR_SEND_PIN, ENABLE_LED_FEEDBACK);
}

/**
 * Wait for command code from serial port and transmit using IR transmitter.
 */
void loop() {
    // Get user's response
    int commandToTransmit = getCommandToTransmit();

    // Transmit the IR code
    Serial.print(F("Transmitting: "));
    Serial.println(commandToTransmit, HEX);
    sendCommand(commandToTransmit);
}

/**
 * Transmit an integer using the IR transmitter.
 *
 * Arguments:
 *     hexCode: An integer representing the command code to transmit.
 */
void sendCommand(int hexCode) {
    for (int i = 0; i < PULSE_COUNT; i++) {
        // sendNEC should be replaced by the appropriate command depending on
        // what the receiving device understands. See README for more info.
        IrSender.sendLG(hexCode, COMMAND_LENGTH, REPEAT_TRANSMISSIONS);
        delay(DELAY_AFTER_SEND);
    }
}

/**
 * Wait for a command code to arrive at the serial port and read it.
 *
 * Returns:
 *     An integer representing the command code received at the serial port.
 */
int getCommandToTransmit() {
    int commandToTransmit;
    while (! Serial.available());
    commandToTransmit = Serial.read();
    Serial.print(F("Received: "));
    Serial.println(commandToTransmit, HEX);
    return commandToTransmit;
}
