import java.util.HashMap;
import java.util.ArrayList;
import processing.serial.*;

// Size of blank space surrounding each button
final int padding = 10;

// Dimensions of a button
final int buttonHeight = 30;
final int buttonWidth = 100;

// Colour of button when clicked
final int[] buttonClickedColour = {255, 80, 80};

// Map command names to infrared command codes
HashMap<String, Integer> commandCodeMap = new HashMap<String, Integer>();

// Array to store all command names, used to index commandCodeMap
ArrayList<String> commandNameDirectory = new ArrayList<String>();

// Array of all buttons currently placed on remote control
ArrayList<Button> buttonStore = new ArrayList<Button>();

// Serial port for interacting with Arduino
Serial arduinoPort;

// Arduino serial baud rate
final int baudRate = 9600;

// Index of Arduino in list of serial ports connected to computer
// This will more than likely be different for each machine, so pay close
// attention to the output of Serial.list() in setup() to find which index is
// associated with your Arduino.
final int arduinoPortIndex = 1;

/**
 * Populate command code map, draw initial (unlabelled) buttons, and connect to
 * Arduino using serial.
 *
 * This function is run once when the program is launched.
 */
void setup() {
    size(600, 350);
    initialiseCommandCodeMap();
    initialiseButtons();
    printArray(Serial.list());
    String portName = Serial.list()[arduinoPortIndex];
    arduinoPort = new Serial(this, portName, baudRate);
    arduinoPort.bufferUntil('\n');
}

/**
 * Re-draw buttons which are mapped to a command.
 *
 * This function is run repeatedly after setup() terminates.
 */
void draw() {
    refreshButtons();
}

/**
 * Event handler for mousePressed event.
 *
 * Change colour of pressed remote button and send the command code to Arduino
 * if the button is mapped to a command.
 */
void mousePressed() {
    int commandCode = 0;
    for (Button buttonToPoll : buttonStore) {
        if (buttonToPoll.coOrdinatesInButton(mouseX, mouseY)) {
            buttonToPoll.setColour(buttonClickedColour[0], buttonClickedColour[1], buttonClickedColour[2]);
            if (commandNameDirectory.contains(buttonToPoll.getButtonText())) {
                commandCode = commandCodeMap.get(buttonToPoll.getButtonText());
            }
            println(commandCode); // DEBUG
            arduinoPort.write(commandCode);
        }
    }
}

/**
 * Event handler for mouseReleased event.
 *
 * Change colour of pressed remote button.
 */
void mouseReleased() {
    for (Button buttonToPoll : buttonStore) { buttonToPoll.setColour(); }
}

/**
 * Event handler for serialEvent event.
 *
 * Read the string received at the serial port from the Arduino.
 */
void serialEvent(Serial arduinoPort) {
    String received = arduinoPort.readStringUntil('\n');
    println(received); // DEBUG
}

/**
 * Draw each button onto the application window.
 */
void refreshButtons() {
    for (Button buttontoRefresh : buttonStore) {
        buttontoRefresh.drawSelf();
    }
}

/**
 * Create initial layout of buttons.
 *
 * Buttons will be created to fill up the application window, even if they are
 * not mapped to a command code.
 */
void initialiseButtons() {
    int buttonsDrawn = 0;
    for ( int y = padding; y < height - (buttonHeight + padding); y += padding + buttonHeight) {
        buttonsDrawn = drawRowOfButtons(y, buttonsDrawn);
    }
}

/**
 * Instantiate a row of buttons across the width of the appliation window.
 *
 * @return An int representing the number total number of buttons drawn so far.
 */
int drawRowOfButtons(int y, int buttonsDrawn) {
    for ( int x = padding; x < width - (buttonWidth + padding); x += padding + buttonWidth) {
        buttonStore.add(new Button(x, y, buttonsDrawn));
        buttonsDrawn++;
    }
    return buttonsDrawn;
}

/**
 * Create a mapping between command names and command codes.
 */
void initialiseCommandCodeMap() {
    /*
      commandCodeMap.put("Mute", 0x67);
      commandNameDirectory.add("Mute");

      commandCodeMap.put("VOL+", 0x4F);
      commandNameDirectory.add("VOL+");
    */

    // Put your command-code here, making sure you follow the same synatax as above
}

/**
 * Class representing a remote control button.
 */
class Button {
    // Offset for text label inside button
    private final int textOffsetX = 3;
    private final int textOffsetY = 20;

    private int x, y, buttonDrawn;
    private int[] colour = {255, 255, 255};
    private String buttonText = "-";

    /**
     * Constructor for button class.
     *
     * @param x An int representing the x co-ordinate of the button.
     * @param y An int representing the y co-ordinate of the button.
     * @param buttonsDrawn An int representing the total number of buttons drawn.
     */
    public Button(int x, int y, int buttonsDrawn) {
        this.x = x;
        this.y = y;
        buttonDrawn = buttonsDrawn;
    }

    /**
     * Draw the button frame onto the application window.
     */
    public void drawSelf() {
        fill(colour[0], colour[1], colour[2]);
        rect(this.x, this.y, buttonWidth, buttonHeight);
        fill(0x000000);
        applyButtonText();
    }

    /**
     * Apply text representing the command name onto the button frame.
     */
    private void applyButtonText() {
        if (buttonDrawn < commandNameDirectory.size() ) {
            buttonText = commandNameDirectory.get(buttonDrawn);
        }
        text(buttonText, x + textOffsetX, y + textOffsetY);
    }

    /**
     * Set the colour of the button.
     *
     * @param red An int representing the colour red in RGB.
     * @param green An int representing the colour green in RGB.
     * @param blue An int representing the colour blue in RGB.
     */
    public void setColour(int red, int green, int blue) {
        colour[0] = red;
        colour[1] = green;
        colour[2] = blue;
    }

    /**
     * Overloaded method to set button colour to white.
     */
    public void setColour() {
        colour[0] = 255;
        colour[1] = 255;
        colour[2] = 255;
    }

    /**
     * Check if co-ordinates are within this button's draw area.
     *
     * @param x An int representing an x co-ordinate.
     * @param y An int representing a y co-ordinate.
     *
     * @return A boolean representing whether the co-ordinates are within this
     * buttons's draw area.
     */
    public boolean coOrdinatesInButton(int x, int y) {
        boolean inButton = false;
        if ((x > this.x && x < this.x + buttonWidth) && (y > this.y && y < this.y + buttonHeight)) {
            inButton = true;
        }
        return inButton;
    }

    /**
     * Getter for this button's command name.
     */
    public String getButtonText() { return buttonText; }
}
