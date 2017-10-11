import processing.serial.*;
import controlP5.*;
import java.util.*;


ControlP5 cp5;

int knobValue = 100;

Knob potKnob;
Serial myPort;        // The serial port
int xPos = 1;         // horizontal position of the graph
int xWidth = 1280/5;
int xHeight = 720/5;
float inByte = 0;
boolean settingPotKnob = false;
int POT_KNOB_MIN = 0;
int POT_KNOB_MAX = 100;
int buttonColor;

// Polar Plot Variables
float stepperTheta;
float theta_vel;
float theta_acc;
long lastTime;
float stepperX;
float stepperY;
int pointSize = 4;
float polarPlotInnerRadius;
long interval = 10000L;
LinkedList<PVector> list;
PVector textBoxSize= new PVector(200, 40); 

// Names of the UI elements
String stepperInStr  = "Stepper Position";
String potNameStr    = "Potentiometer"; // Warning you must change the potentiometer() method if you change this.
String motorSpeedStr = "DC Motor Speed";
String slotSensorStr = "Slot Sensor";
String buttonStr     = "Push Button";

// Positions of each of the UI elements
PVector potPos     = new PVector(100,  50);
PVector slotPos    = new PVector( 50, 250);
PVector buttonPos  = new PVector( 50, 350);
PVector dcMotorPos = new PVector( 50,  50);
PVector dcInPos    = new PVector( 50, 650);
PVector bendyPos   = new PVector(300,  50);
PVector stepperPos = new PVector(640, 360);
PVector stepperIn  = new PVector(543, 180);
PVector distPos    = new PVector(600,  50);
PVector servoPos   = new PVector(600,  640);
PVector servoIn    = new PVector(600,  640);


void setup () {
  POT_KNOB_MAX *= 0.6666666f;
  size(1280,720);
  smooth();
  noStroke();
  
  cp5 = new ControlP5(this);
  
  potKnob = cp5.addKnob(potNameStr)
               .setRange(POT_KNOB_MIN,POT_KNOB_MAX)
               .setValue(50)
               .setPosition(potPos.x,potPos.y)
               .setRadius(50)
               .setDragDirection(Knob.VERTICAL)
               .setConstrained(false)
               ;
  PFont font = createFont("arial",20);
  cp5.addTextfield(stepperInStr)
     .setPosition(stepperIn.x,stepperIn.y)
     .setSize(int(textBoxSize.x),int(textBoxSize.y))
     .setFont(font)
     .setColor(color(255,0,0))
     ;
   cp5.addTextfield(motorSpeedStr)
     .setPosition(dcInPos.x,dcInPos.y)
     .setSize(int(textBoxSize.x),int(textBoxSize.y))
     .setFont(font)
     .setColor(color(255,0,0))
     ;
   cp5.addButton(slotSensorStr)
     .setPosition(slotPos.x,slotPos.y)
     .setSize(int(textBoxSize.x),int(textBoxSize.y))
     .updateSize();
  buttonColor = cp5.getController(slotSensorStr).getColor().getBackground();
  cp5.addButton(buttonStr)
     .setPosition(buttonPos.x,buttonPos.y)
     .setSize(int(textBoxSize.x),int(textBoxSize.y))
     .updateSize();
   // Initialize Polar Plot Variables
  list = new LinkedList<PVector>();
  stepperTheta = 0;
  theta_vel = 0.1;
  lastTime = System.nanoTime();
    // Uncomment to enable serial to Arduino 
    /*myPort = new Serial(this, Serial.list()[0], 9600);

    // don't generate a serialEvent() unless you get a newline character:
    myPort.bufferUntil('\n');
*/
    // set initial background:
    background(0);
  }

void draw () {
  
    //text(cp5.get(Textfield.class,slotSensorStr).getText(), 360,130);
    //text(cp5.get(Textfield.class,motorSpeedStr).getText(), 360,130);
    
    // draw the line:
    stroke(127, 34, 255);
    line(xPos, height, xPos, height - inByte/2);
    drawPolarPlot(stepperPos.x, stepperPos.y, height/4.0, height/4.0);  
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
  
// Draw the polar plot for the stepper motor
void drawPolarPlot(float x, float y, float plotWidth, float plotHeight) {
  // Translate the origin point to the center of the screen
  polarPlotInnerRadius = plotHeight * 0.1;
  translate(x, y);
  fill(0);
  ellipse(0.0, 0.0, plotWidth, plotHeight);
  ellipse(0.0, 0.0, 2.0*polarPlotInnerRadius, 2.0*polarPlotInnerRadius);
  if (System.nanoTime() - lastTime > interval) {
      list.addFirst(new PVector(stepperTheta,polarPlotInnerRadius));
      for (int j = 1; j < list.size(); j++) {
        list.get(j).y += pointSize/4;
        
        if (abs(list.get(j).y - (plotHeight * 0.5)) < 3.0) {
          list.remove(j);
        }
      }
    lastTime = System.nanoTime();
  }
  if (!list.isEmpty()) {
    // Draw the ellipse at the cartesian coordinate
    ellipseMode(CENTER);
    noStroke();
    fill(200);
    
    for (int i = 0; i < list.size(); i++) {
      
      stepperX = list.get(i).y * cos(list.get(i).x);
      stepperY = list.get(i).y * sin(list.get(i).x);
      ellipse(stepperX, stepperY, pointSize, pointSize);
      if (list.get(i).y >= (plotHeight * 0.5)) {
        list.remove(i);
      }
    }
  }
  stroke(255);
  line(-plotHeight*0.5, 0.0, plotHeight*0.5, 0.0);
  line(0.0, -plotHeight*0.5, 0.0, plotHeight*0.5);
  // Apply acceleration and velocity to angle (r remains static in this example)
  stepperTheta += theta_vel;
  if (abs(stepperTheta) > 10.0) {
    theta_vel = -theta_vel;
  }
  translate(-x,-y);
}
// Get string from text box
void controlEvent(ControlEvent theEvent) {
  
  if(theEvent.isAssignableFrom(Textfield.class)) {
    println("controlEvent: accessing a string from controller '"
            +theEvent.getName()+"': "
            +theEvent.getStringValue()
            );
    if (theEvent.getName().equals(stepperInStr)) {
      String str = theEvent.getStringValue();
      str = str.replaceAll("[^\\d]", "");
      if (!str.equals("")) {
        println(Integer.parseInt(str));
      }
    }
  }
}
void Potentiometer(int theValue) {
  int knobRealMax = int(1.3333f*float(POT_KNOB_MAX));
  int knobRange = abs(knobRealMax - POT_KNOB_MIN);
  if (knobRealMax < theValue) {
    potKnob.setValue(theValue - knobRange);
  }
  else if (theValue < POT_KNOB_MIN) {
    potKnob.setValue(theValue + knobRange);
  }
    settingPotKnob = true;
  //println("a knob event. setting background to "+theValue);
}
void Stepper_Position() {
  println("Clicked");
}
void mouseClicked() {
  
}
void mouseReleased() {
  if(settingPotKnob) {
    println("Knob Release Value is " + potKnob.getValue());
    settingPotKnob = false;
  }
}

void keyPressed() {
  //switch(key) {
  //  case('1'):potKnob.setValue(180);break;
  //}
  
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