# Arduino Remote Transmitter
A customisable virtual remote control made with the Arduino prototyping platform and Processing language.

## Contents of README:
* [Features](#features)
* [Motivation for this Project](#motivation-for-this-project)
* [Limitations](#current-limitations)
* [Requirements](#hardware-components-required)
* [Installation](#installation-assuming-processing-ide-and-arduino-ide-are-already-installed)
* [Circuit Diagram](#arduino-circuit-diagram)
* [Usage](#usage)
* [Appendix](#appendix)

## Features:
* Allows a user to control most infrared receiver devices once the command codes are discovered.
* Requires very little circuit wiring for the Arduino board.

## Motivation for this Project:
I got an old set-top box which was missing its remote control. I had a universal remote control lying around but it couldn't properly control the box no matter which device code I tried. Instead of buying an official remote for the box, I just used the Arduino platform and a bit of Processing to make my own remote control.

## Current Limitations:
* Not easy to tweak since I only programmed the software to "work", not "work efficiently". Optimisation is an ongoing task.

## Hardware Components Required:
_Note: "receiving device" below refers to the set-top box, TV, etc. That the virtual remote control will control._
* Arduino, or Arduino-compatible microcontroller board. The code assumes an Uno board is being used but modifying the code to run on other models should be trivial.
* A computer running an operating system capable of 1) uploading Arduino sketches to the board, and 2) capable of running the Processing IDE.
* USB/Serial cable for connecting computer to Arduino.
* Ideally, a universal remote control which can at least _partially_ control the receiving device. (This is used to determine what type of IR signals the receiving device recognises.) If you don't have a universal remote, try using other remotes around you, if any of them triggers some action (e.g. power button on remote causes the volume to change on the receiving device), then it can be used to determine the type of IR signals.
* IR LED for transmitting remote control commands to the receiving device.
* IR Receiver for determining the type of signals that the receiving device recognises. Make sure you know which pin is +, -, and SIGNAL. I learned the importance of this the hard way!
* I used a 2.2k Ohm resistor with the IR LED just to be on the safe side. Note: I have not tested the LED without a resistor, or with other resistor ratings.
* The actual receiving device.

## Software Components Required:
* Arduino IDE (other IDEs/uploaders may work but have not been tested).
* Processing IDE.
* This [IRremote library](https://github.com/z3t0/Arduino-IRremote).

## Installation (assuming Processing IDE and Arduino IDE are already installed):
1. Download a ZIP file of the repository.
2. Extract the contents of the ZIP to some folder on your computer.
3. Place the "discover_device_command.pde" file in a folder named "discover_device_command" so that it can be opened by the Processing IDE (typically you would put it into the "Processing" folder - which is automatically created when Processing is installed).
4. Place the "virtual_remote.pde" file in a folder named "virtual_remote" and place it into the Processing directory also.
5. Place the "virtual_remote.ino" file into a folder named "virtual_remote". This folder can be placed in your "Arduino" folder - which is automatically created when the Arduino IDE is installed.
6. See the following site for instructions on installing/configuring the IRremote library:  [Arduino IRremote](https://z3t0.github.io/Arduino-IRremote/).
8. You should now be able to start up both IDEs and open the downloaded files for this project without problems.

## Arduino Circuit Diagram:
![IR Receiver Diagram](https://github.com/arhh/arduino-remote-transmitter/blob/master/diagrams/circuit_diagram.png)

## Usage:
### Discovering the Type of IR Signals your Receiving Device Recognises:
_Note: The following steps require the IRremote library only._
1. Get a universal remote control and try going through some brands in its code list to see which code causes some action on the receiving device when a button on the remote is pressed. (Some universal remotes have a "scan" function whereby you keep pressing the "power" button until the receiving device turns on/off. It's okay if the receiving device does something other than turn on/off, like change volume when you press the power button on the remote for instance, we only care about the face that the receiving device is reacting to the remote in _some_ way.)
2. Launch the Arduino IDE and open the IRrecvDump sketch (found in: File > Examples > IRremote).
3. Make sure your Arduino is wired up according to the diagram above, especially the IR receiver.
4. Upload the sketch to the Arduino.
5. Press some buttons on the universal remote while facing it towards the IR receiver.
6. Observe the Arduino serial monitor, one line of output should read "Decoded 'x'", where 'x' is some remote signal brand (e.g SONY, NEC, JVC). Make note of this.

#### Troubleshooting:
1. _Serial output when pressing remote buttons shows "Decoded: UNKNOWN"_
    * Try pressing the buttons slower on the remote.
    * Try replacing the batteries in the remote, some produce garbled signals when their batteries are dying.
    * Repeat step 1 above but find another code for the remote that the receiving device reacts to.

### Discovering the Command Codes the Receiving Device Responds to:
1. Launch the Arduino IDE and open the virtual_remote.ino sketch you downloaded by following the [installation](#installation) section above.
3. Using the name you noted from step 6 in [discovering receiving device IR signal type above](#discovering-the-type-of-ir-signals-your-receiving-device-recognises), replace the `sendNEC` in `irsend.sendNEC(hexCode, COMMAND_LENGTH);` with `sendX`, where X is the type you noted (e.g `sendSONY`, `sendJVC`, etc). Of course, if your receiving device recognises NEC IR signals, then you need not modify the code.
2. Make sure your Arduino is wired up according to the diagram above, especially the IR transmitter (LED).
3. Upload the sketch to the Arduino.
4. Launch the Processing IDE and open the discover_device_command.pde you downloaded by following the [installation](#installation) section above.
5. Ensure the Arduino board is connected to the computer and run the Processing sketch.
6. For now, ignore the window that appears. Instead, look at the console in the Processing IDE (the black area at the bottom third of the window) and make note of the index (i.e. the number in square brackets) beside the name of your Arduino board.
7. Terminate the application by pressing the 'X' (stop) button in the Processing IDE.
8. In the code for discover_device_command.pde displayed in the Processing IDE, find the following line: `final int arduinoPortIndex = 1;`. Update the value of this variable (i.e replace the '1') to the number you noted in step 6 above. If '1' is what you noted in step 6, then you need not modify the code here.
9. Repeat step 5.
10. The window that appears is what will be used to discover what command codes your receiving device responds to.
11. Press the "Transmit" button (or "enter" key) to transmit the displayed code to the receiving device via the Arduino.
12. Press the "Up"/"Down" arrow (or up/down keys) to increment/decrement the code to transmit.
13. Go through each code from "0x00" up to the max "0xFF" and take note of which code causes what action on the receiving device. For example, when I transmit "0x10" to my TV, it increases the volume, I would then note this down.
14. If for any reason, you terminate the program, and don't want to start at the beginning code "0x00", you can edit the following line `private String commandText = "0";` and replace "0" with whatever code you want to start from (e.g. 10, FA, etc.).
15. If you are unsure on whether you have all the commands noted for the receiving device, you can check the user manual for the device. Most TV/DVD/set-top-box manufacturers have PDF user manuals for their devices.

### Creating the Virtual Remote Control with the Command Codes:
_Note: It is assumed you have uploaded the virtual_remote.ino sketch to the Arduino board._
1. Launch the Processing IDE and open the virtual_remote.pde you downloaded by following the [installation](#installation) section above.
2. In the function `initialiseCommandCodeMap()` add the name of the command and its corresponding code, which you should have a big list of by now, using the following syntax:
```
    commandCodeMap.put("VOL+", 0x4F);
    commandNameDirectory.add("VOL+");

    commandCodeMap.put("Mute", 0x4F);
    commandNameDirectory.add("Mute");
```
Note how the command name is typed in exactly the same way (capitalisation, etc.) for the put() function and the add() function, this must be the case for **every** command you fill in.
Also note that the actual name of the command doesn't matter as long as it's typed the same way for each pair of statements, as mentioned in the previous note.
3. Ensure the Arduino board is connected to the computer and run the Processing sketch.
4. For now, ignore the window that appears. Instead, look at the console in the Processing IDE (the black area at the bottom third of the window) and make note of the index (i.e. the number in square brackets) beside the name of your Arduino board.
5. Terminate the application by pressing the 'X' (stop) button in the Processing IDE.
6. In the code for virtual_remote.pde displayed in the Processing IDE, find the following line: `final int arduinoPortIndex = 1;`. Update the value of this variable (i.e replace the '1') to the number you noted in step 6 above.
9. Repeat step 3.
10. You should now see the virtual remote on-screen.
11. By pressing the buttons on the virtual remote, you should be able to control the appropriate function on your receiving device.

#### Troubleshooting:
1. _Receiving device has too many commands to fit into the virtual remote window_
    * Increase the window width and height by editing the following lines of code:
```
    size(600, 350);
```
The first value represents the width, the second represents the height, increase either to fit more buttons into the window. If there are more buttons to fit into the new space, then they will be included automatically. If you find that the buttons are being filled with a "-" then there is no need to increase these values anymore.

## Appendix
### Disclaimer
Please note that I take no responsiblity for damage caused due to improper wiring.

### Acknowledgements
Many thanks to the IRremote library code  [contributors](https://github.com/z3t0/Arduino-IRremote/blob/master/Contributors.md). I would not have been able to develop this project if it wasn't for the work these individuals put into the library.
