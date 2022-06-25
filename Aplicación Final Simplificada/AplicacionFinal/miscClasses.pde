class twoStateButton {
  //A button that has two possible states(0 and 1), with different colors and texts
  float xA; //Position of the button. x-axis
  float yA; //Position of the button. y-axis. top-left(xA,yA)
  float xB;
  float yB; //Position of the butto. Bottom-right(xB,yB)
  float w; //width of the button
  float h; //height of the button
  String txtS0; //Text of the button when it is in state 0
  String txtS1; //Text of the button when it is in state 1
  color ColorS0; //Color of the button when it is in state 0
  color ColorS1; //Color of the button whe it is in state 1
  boolean ButtonState; //false:state 0 ; true:state 1
  // Constructor
  twoStateButton(float tempx, float tempy, float tempw, float temph, String temptxtS0, String temptxtS1, color tempColorS0, color tempColorS1) {
    xA=tempx;
    yA=tempy;
    xB=xA+tempw;
    yB=yA+temph;
    w=tempw;
    h=temph;
    txtS0=temptxtS0;
    txtS1=temptxtS1;
    ColorS0= tempColorS0;
    ColorS1=tempColorS1;
    ButtonState=false; //state 0
  }

  void display() {

    textFont(fArial, 12); //specify font to be used
    textAlign(CENTER, CENTER);

    if (ButtonState) { //state 1
      fill(ColorS1);
      stroke(0);
      rect(xA, yA, w, h);
      fill(0); //font color 
      text(txtS1, xA+w/2, yA+h/2);
    } else { //state 0
      fill(ColorS0);
      stroke(0);
      rect(xA, yA, w, h);
      fill(0); //font color 
      text(txtS0, xA+w/2, yA+h/2);
    }
  }//end display()

  boolean isMouseOver() {
    //Chek if the coordinates of the mouse are over the area of the button
    if (mouseX>=xA && mouseX<=xB &&
      mouseY>=yA && mouseY<=yB) {
      return true;
    } else {
      return false;
    }
  }

  void setState(boolean tmpState) {
    ButtonState=tmpState;
  }

  boolean getState() {
    return ButtonState;
  }
}// end of Class generalButton


class checkBox {
  boolean checked; //to indicate if the checkbox is checked
  float xA; //Position of the button. x-axis
  float yA; //Position of the button. y-axis. top-left(xA,yA)
  float xB;
  float yB; //Position of the butto. Bottom-right(xB,yB)
  float w; //width of the button
  float h; //height of the button
  String textNext; //The shown text next to it.

  //constructors
  checkBox(){
    xA=0;
    yA=0;
    xB=0;
    yB=0;
    w=0;
    h=0;
    checked=false;
    textNext="";
  }
  checkBox(float tempx, float tempy, float tempw, float temph, boolean tempchecked) {
    xA=tempx;
    yA=tempy;
    xB=xA+tempw;
    yB=yA+temph;
    w=tempw;
    h=temph;
    checked=tempchecked;
    textNext="";
  }
  checkBox(float tempx, float tempy, float tempw, float temph, boolean tempchecked, String temptextNext) {
    xA=tempx;
    yA=tempy;
    xB=xA+tempw;
    yB=yA+temph;
    w=tempw;
    h=temph;
    checked=tempchecked;
    textNext=temptextNext;
  }
  
  //end constructor

  void display() {
    //draw white rectangle
    fill(255);
    stroke(0);
    rect(xA, yA, w, h);
    if (checked) {//if checked draw the "tick" symbol
      line(xA+0.2*w, yA+0.5*h, xA+0.4*w, yA+0.8*h);
      line(xA+0.4*w, yA+0.8*h, xA+0.8*w, yA+0.2*h);
    }
    fill(0);
    textAlign(RIGHT, CENTER);
    text(textNext,xA-3,yA+h*0.5);
  }//end display()

  boolean isMouseOver() {
    //Chek if the coordinates of the mouse are over the area of the check box
    if (mouseX>=xA && mouseX<=xB &&
      mouseY>=yA && mouseY<=yB) {
      return true;
    } else {
      return false;
    }
  }

  boolean getCheckedState() {
    return checked;
  }

  void setCheckedState(boolean tmpchecked) {
    checked=tmpchecked;
  }

  float[] getCoordinates() {
    //Return the coordinates of the textbox and its width and height
    float[] coordinates= {
      xA, yA, xB, yB, w, h
    };
    return coordinates;
  }
}

class measurementData {
  //To store 1 repetition of a measurement
  int[] vFreq;
  int[] vSensor;
  int iv; //To indicate the position of the last data introduced
  int rfOut; //To indicate the rf output of the board

  measurementData(int MeasurementLength, int rfOut_) {
    vFreq=new int[MeasurementLength];
    vSensor=new int[MeasurementLength];
    iv=-1;
    rfOut = rfOut_;
  }

  void setData(int valueFreq, int valueSensor) {
    iv++;
    vFreq[iv]=valueFreq;
    vSensor[iv]=valueSensor;
  }

  int getIv() {
    return iv;
  }

  int[] getFreqData() {
    return vFreq;
  }

  int[] getSensorData() {
    return vSensor;
  }
}
