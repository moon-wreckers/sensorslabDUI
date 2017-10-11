/*import processing.serial.*;
import cc.arduino.*;

Arduino arduino;
int ledPin = 13;

void setup()
{
  //println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[0], 9600);
  arduino.pinMode(ledPin, Arduino.OUTPUT);
  // change the number below to match your port:
  String portName = Serial.list()[12];
  Serial myPort;
  myPort = new Serial(this, portName, 9600);
}

void draw()
{
  arduino.digitalWrite(ledPin, Arduino.HIGH);
  delay(1000);
  arduino.digitalWrite(ledPin, Arduino.LOW);
  delay(1000);
}
*/
// Graphing sketch

  // This program takes ASCII-encoded strings from the serial port at 9600 baud
  // and graphs them. It expects values in the range 0 to 1023, followed by a
  // newline, or newline and carriage return

  // created 20 Apr 2005
  // updated 24 Nov 2015
  // by Tom Igoe
  // This example code is in the public domain.

import processing.serial.*;
import controlP5.*;


ControlP5 cp5;

int knobValue = 100;

Knob myKnobA;
Serial myPort;        // The serial port
int xPos = 1;         // horizontal position of the graph
int xWidth = 1280/5;
int xHeight = 720/5;
float inByte = 0;
boolean settingKnobAValue = false;
int KNOB_MIN = 0;
int KNOB_MAX = 100;
void setup () {
  KNOB_MAX *= 0.6666666f;
  size(1280,720);
  smooth();
  noStroke();
  
  cp5 = new ControlP5(this);
  
  myKnobA = cp5.addKnob("knob")
               .setRange(KNOB_MIN,KNOB_MAX)
               .setValue(50)
               .setPosition(100,70)
               .setRadius(50)
               .setDragDirection(Knob.VERTICAL)
               .setConstrained(false)
               ;
  PFont font = createFont("arial",20);
  cp5.addTextfield("input")
     .setPosition(300,100)
     .setSize(200,40)
     .setFont(font)
     .setFocus(true)
     .setColor(color(255,0,0))
     ;
     
    // Uncomment to enable serial to Arduino 
    /*myPort = new Serial(this, Serial.list()[0], 9600);

    // don't generate a serialEvent() unless you get a newline character:
    myPort.bufferUntil('\n');
*/
    // set initial background:
    background(0);
  }

void draw () {
  
    //text(cp5.get(Textfield.class,"input").getText(), 360,130);
    // draw the line:
    stroke(127, 34, 255);
    line(xPos, height, xPos, height - inByte/2);

    // at the edge of the screen, go back to the beginning:
    if (xPos >= xWidth) {
      xPos = 0;
      background(0);
    } else {
      // increment the horizontal position:
      xPos++;
    }
  //fill(knobValue);
  //rect(0,height/2,width,height/2);
  //fill(0,100);
  //rect(80,40,140,320);
  }
  
// Get string from text box
void controlEvent(ControlEvent theEvent) {
  if(theEvent.isAssignableFrom(Textfield.class)) {
    println("controlEvent: accessing a string from controller '"
            +theEvent.getName()+"': "
            +theEvent.getStringValue()
            );
    print("Printing int from string: "); 
    String str = theEvent.getStringValue();
    str = str.replaceAll("[^\\d]", "");
    print(Integer.parseInt(str));
  }
}
void knob(int theValue) {
  int knobRealMax = int(1.3333f*float(KNOB_MAX));
  int knobRange = abs(knobRealMax - KNOB_MIN);
  if (knobRealMax < theValue) {
    myKnobA.setValue(theValue - knobRange);
  }
  else if (theValue < KNOB_MIN) {
    myKnobA.setValue(theValue + knobRange);
  }
    settingKnobAValue = true;
  //println("a knob event. setting background to "+theValue);
}
void mouseClicked() {
  
}
void mouseReleased() {
  if(settingKnobAValue) {
    println("Knob Release Value is " + myKnobA.getValue());
    settingKnobAValue = false;
  }
}

void keyPressed() {
  switch(key) {
    case('1'):myKnobA.setValue(180);break;
  }
  
}
void serialEvent (Serial myPort) {
    // get the ASCII string:
    String inString = myPort.readStringUntil('\n');

    if (inString != null) {
      // trim off any whitespace:
      inString = trim(inString);
      // convert to an int and map to the screen height:
      inByte = float(inString);
      //println(inByte);
      if (!Float.isNaN(inByte)) {
        inByte = map(inByte, 0, 1023, 0, height);
      }
    }
  }