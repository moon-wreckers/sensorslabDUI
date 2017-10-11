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

int myColorBackground = color(0,0,0);
int knobValue = 100;

Knob myKnobA;
Knob myKnobB;
Serial myPort;        // The serial port
int xPos = 1;         // horizontal position of the graph
float inByte = 0;

void setup () {
  size(700,400);
  smooth();
  noStroke();
  
  cp5 = new ControlP5(this);
  
  myKnobA = cp5.addKnob("knob")
               .setRange(0,255)
               .setValue(50)
               .setPosition(100,70)
               .setRadius(50)
               .setDragDirection(Knob.VERTICAL)
               ;
                     
  myKnobB = cp5.addKnob("knobValue")
               .setRange(0,255)
               .setValue(220)
               .setPosition(100,210)
               .setRadius(50)
               .setNumberOfTickMarks(10)
               .setTickMarkLength(4)
               .snapToTickMarks(true)
               .setColorForeground(color(255))
               .setColorBackground(color(0, 160, 100))
               .setColorActive(color(255,255,0))
               .setDragDirection(Knob.HORIZONTAL)
               ;
    // List all the available serial ports
    // if using Processing 2.1 or later, use Serial.printArray()
    //println(Serial.list());

    // I know that the first port in the serial list on my Mac is always my
    // Arduino, so I open Serial.list()[0].
    // Open whatever port is the one you're using.
    myPort = new Serial(this, Serial.list()[0], 9600);

    // don't generate a serialEvent() unless you get a newline character:
    myPort.bufferUntil('\n');

    // set initial background:
    background(0);
  }

void draw () {
    // draw the line:
    stroke(127, 34, 255);
    line(xPos, height, xPos, height - inByte);

    // at the edge of the screen, go back to the beginning:
    if (xPos >= width) {
      xPos = 0;
      background(0);
    } else {
      // increment the horizontal position:
      xPos++;
    }
  background(myColorBackground);
  fill(knobValue);
  rect(0,height/2,width,height/2);
  fill(0,100);
  rect(80,40,140,320);
  }
void knob(int theValue) {
  myColorBackground = color(theValue);
  println("a knob event. setting background to "+theValue);
}


void keyPressed() {
  switch(key) {
    case('1'):myKnobA.setValue(180);break;
    case('2'):myKnobB.setConstrained(false).hideTickMarks().snapToTickMarks(false);break;
    case('3'):myKnobA.shuffle();myKnobB.shuffle();break;
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
      println(inByte);
      inByte = map(inByte, 0, 1023, 0, height);
    }
  }