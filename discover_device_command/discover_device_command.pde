import java.util.ArrayList;
import processing.serial.*;

// Arduino serial baud rate
final int baudRate = 9600;

// Maximum command code
final int maximumCode = 255;

// Index of Arduino in list of serial ports connected to computer
// This will more than likely be different for each machine, so pay close
// attention to the output of Serial.list() in setup() to find which index is
// associated with your Arduino.
final int arduinoPortIndex = 1;

// List of codes which will never appear for transmit.
// This list should be empty at first, but should be filled with
// populateForbiddenCodes() as you discover more codes for your device, this
// will prevent this program from prompting you to transmit them again.
ArrayList<Integer> forbiddenCodes = new ArrayList<Integer>();

// Serial port for interacting with Arduino
Serial arduinoPort;

// Displays what code will be transmitted once the transmit button is pressed
CommandDisplay commandDisplay;

// Increment the code to transmitted
IncrementCommandButton upArrow;

// Decrement the code to be transmitted
DecrementCommandButton downArrow;

// Send the displayed command code to the Arduino for transmission
TransmitButton transmit;

// Fill colours for text/shapes
final int[] colourWhite = {255, 255, 255};
final int[] colourBlack = {0, 0, 0};

/**
 * Set up the application.
 *
 * This function is run once. It sets the window size, connects to Arduino
 * serial, instaniates the widgets, and stores the forbidden codes, if any.
 */
void setup() {
    size(500, 300);
    printArray(Serial.list());
    String portName = Serial.list()[arduinoPortIndex];
    arduinoPort = new Serial(this, portName, baudRate);
    arduinoPort.bufferUntil('\n');
    initialiseWidgets();
    populateForbiddenCodes();
}

/**
 * Draw the window widgets repeatedly.
 *
 * This function is run repeatedly.
 */
void draw() {
    drawWidgets();
}

/**
 * Event handler for mouseClicked event.
 *
 * Calls appropriate function depending on what widget is clicked.
 */
void mouseClicked() {
    if (upArrow.coOrdinateInTriangle(mouseX, mouseY)) {
        incrementCode();

    }
    else if (downArrow.coOrdinateInTriangle(mouseX, mouseY)) {
        decrementCode();
    }
    else if (transmit.coOrdinateInButton(mouseX, mouseY)) {
        transmit();
    }
}

/**
 * Event handler for keyPressed event.
 *
 * Calls appropriate function depending on what key is pressed.
 */
void keyPressed() {
    if (key == CODED) {
         if (keyCode == UP) {
             incrementCode();
         }
         else if (keyCode == DOWN) {
             decrementCode();
         }
         else if (keyCode == SHIFT) {
             transmit();
         }
    }
}

/**
 * Increment the code to transmit to Arduino.
 */
void incrementCode() {
    Integer commandCode = 0;

    // Convert the string being displayed to user into hex for incrementing
    commandCode = unhex(commandDisplay.getCommandText());

    boolean isForbidden;
    do {
        commandCode++;
        if (commandCode.equals(maximumCode)) { commandCode = 0; }
        isForbidden = false;
        for (Integer code : forbiddenCodes) {
            if (code.equals(commandCode)) {
                isForbidden = true;
            }
        }
    } while (isForbidden);

    commandDisplay.setCommandText(commandCode);
    println(hex(commandCode, 2)); // DEBUG
}

/**
 * Decrement the code to transmit to Arduino.
 */
void decrementCode() {
    Integer commandCode = 0;

    // Convert the string being displayed to user into hex for decrementing
    commandCode = unhex(commandDisplay.getCommandText());

    boolean isForbidden;
    do {
        commandCode--;
        if (commandCode.equals(0)) { commandCode = maximumCode; }
        isForbidden = false;
        for (Integer code : forbiddenCodes) {
            if (code.equals(commandCode)) {
                isForbidden = true;
            }
        }
    } while (isForbidden);

    commandDisplay.setCommandText(commandCode);
    println(hex(commandCode, 2)); // DEBUG
}

/**
 * Transmit the code being displayed to the Arduino.
 */
void transmit() {
    Integer commandCode = 0;
    commandCode = unhex(commandDisplay.getCommandText());
    println(commandCode); // DEBUG
    arduinoPort.write(commandCode);
}

/**
 * Event handler for serialEvent event.
 *
 * Called when Arduino sends data to computer
 */
void serialEvent(Serial arduinoPort) {
    String received = arduinoPort.readStringUntil('\n');
    println(received); // DEBUG
}

/**
 * Draw all widgets on screen.
 */
void drawWidgets() {
    commandDisplay.drawSelf();
    upArrow.drawSelf();
    downArrow.drawSelf();
    transmit.drawSelf();
}

/**
 * Instaniate widgets for drawing later.
 */
void initialiseWidgets() {
    // Create display object
    commandDisplay = new CommandDisplay();
    // Draw up/down triangles
    upArrow = new IncrementCommandButton();
    downArrow = new DecrementCommandButton();
    // Draw transmit button
    transmit = new TransmitButton();
}

/**
 * Add a list of codes that will never be offered for transmit by the program.
 *
 * Useful when narrowing the search for a particular command and not having to
 * skip over all discovered commands.
 */
void populateForbiddenCodes() {
    // forbiddenCodes.add(0x65);

    // Add your forbidden codes here following the same style as the example
    // above
}

/**
 * Class representing the command code display in the program window.
 */
class CommandDisplay {
    private final int fieldHeight = 50;
    private final int fieldWidth = 90;
    private final int x = 10;
    private final float y = (height / 2) - (fieldHeight / 2);
    private final int textOffsetX = 30;
    private final int textOffsetY = 30;

    // The code that is displayed to the user
    private String commandText = "0";

    /**
     * Draw the display frame onto the window.
     */
    public void drawSelf() {
        rect(this.x, this.y, fieldWidth, fieldHeight);
        applyCommandText();
    }

    /**
     * Apply text representing the command onto the display frame.
     */
    private void applyCommandText() {
        fill(0, 0, 0);
        text(commandText, x + textOffsetX, y + textOffsetY);
        fill(255, 255, 255);
    }

    /**
     * Getter for commandText.
     *
     * @return A string representing the command code displayed to the user.
     */
    public String getCommandText() { return commandText; }

    /**
     * Setter for commandText.
     */
    public void setCommandText(int commandText) {
        this.commandText = hex(commandText, 2);
    }
}

/**
 * Class representing a button to transmit displayed code to Arduino
 */
class TransmitButton {
    private final int fieldHeight = 50;
    private final int fieldWidth = 90;
    private final int x = 400;
    private final float y = (height / 2) - (fieldHeight / 2);
    private final int textOffsetX = 30;
    private final int textOffsetY = 30;
    private final String buttonText = "Transmit";

    /**
     * Draw the button frame onto the window.
     */
    public void drawSelf() {
        rect(this.x, this.y, fieldWidth, fieldHeight);
        applyButtonText();
    }

    /**
     * Apply the text of the button onto the button frame.
     */
    private void applyButtonText() {
        fill(colourBlack[0], colourBlack[1], colourBlack[2]);
        text(buttonText, x + textOffsetX, y + textOffsetY);
        fill(colourWhite[0], colourWhite[1], colourWhite[2]);
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
    public boolean coOrdinateInButton(int x, int y) {
        boolean inButton = false;
        if ((x > this.x && x < this.x + fieldWidth) && (y > this.y && y < this.y + fieldHeight)) {
            inButton = true;
        }
        return inButton;
    }
}

/**
 * Abstract class representing a triangle widget shape
 */
abstract class Triangle {
    private float x1;
    private float y1;
    private float x2;
    private float y2;
    private float x3;
    private float y3;

    /**
     * Constructor for Triangle object.
     *
     * @param x1 A float representing the x co-ordinate of the first point.
     * @param y1 A float representing the y co-ordinate of the first point.
     * @param x2 A float representing the x co-ordinate of the second point.
     * @param y2 A float representing the y co-ordinate of the second point.
     * @param x3 A float representing the x co-ordinate of the third point.
     * @param y3 A float representing the y co-ordinate of the third point.
     */
    public Triangle(float x1, float y1, float x2, float y2, float x3, float y3) {
        this.x1 = x1;
        this.y1 = y1;
        this.x2 = x2;
        this.y2 = y2;
        this.x3 = x3;
        this.y3 = y3;
    }

    /**
     * Draw the triangle onto the window.
     */
    public void drawSelf() {
        triangle(x1, y1, x2, y2, x3, y3);
    }

    /**
     * Check if co-ordinates are within this triangle's draw area.
     *
     * @param x An int representing an x co-ordinate.
     * @param y An int representing a y co-ordinate.
     *
     * @return A boolean representing whether the co-ordinates are within this
     * triangle's draw area.
     */
    public abstract boolean coOrdinateInTriangle(int x, int y);
}

/**
 * Abstract class representing an up arrow.
 */
class IncrementCommandButton extends Triangle {
    private static final float x1 = 300;
    private static final float y1 = 30;
    private static final float x2 = x1 - 30;
    private static final float y2 = y1 + 30;
    private static final float x3 = x1 + 30;
    private static final float y3 = y1 + 30;

    /**
     * Constructor for IncrementCommandButton object.
     */
    public IncrementCommandButton() {
        super(x1, y1, x2, y2, x3, y3);
    }

    public boolean coOrdinateInTriangle(int x, int y) {
        boolean result = false;
        if ((x > x2 && x < x3) && (y < y2 && y > y1)) { result = true; }
        return result;
    }
}

/**
 * Abstract class representing a down arrow.
 */
class DecrementCommandButton extends Triangle {
    private static final float x1 = 300;
    private static final float y1 = 200;
    private static final float x2 = x1 - 30;
    private static final float y2 = y1 - 30;
    private static final float x3 = x1 + 30;
    private static final float y3 = y1 - 30;

    /**
     * Constructor for DecrementCommandButton object.
     */
    public DecrementCommandButton() {
        super(x1, y1, x2, y2, x3, y3);
    }

    public boolean coOrdinateInTriangle(int x, int y) {
        boolean result = false;
        if ((x > x2 && x < x3) && (y > y2 && y < y1)) { result = true; }
        return result;
    }
}
