class topButton {
  //Class for the buttons of the different areas of the program: calibration, measurement...
  float xA; //Position of the button. x-axis
  float yA; //Position of the button. y-axis. Top-left(xA,yA)
  float xB;
  float yB; //Position of the butto. Bottom-right(xB,yB)
  String txt; //Name of the option that the button is responsible: calibration, measurement...
  boolean ButtonSelected; //true if the mouse has been clicked
  //Constructor
  topButton(float tempx, float tempy, String temptxt) {
    xA=tempx;
    yA=tempy;
    xB=xA+0.25*width;
    yB=yA+0.03*height;
    txt=temptxt;
    ButtonSelected=false;
  }

  void display() {
    stroke(0);
    line(xA, yA, xB, yA);
    line(xA, yA, xA, yB);
    //Depending on the state, display different color
    if (ButtonSelected) {
      fill(100);
    } else if (isMouseOver()) {
      fill(153);
    } else {
      fill(255);
    }
    noStroke();
    rect(xA+5, yA+5, xB-xA-5, yB-yA-5);
    textFont(fArialBold, 16); //specify font to be used
    textAlign(LEFT, BASELINE);
    fill(0); //font color
    text(txt, xA+10, yA+20);
  }


  boolean isMouseOver() {
    //Chek if the coordinates of the mouse are over the area of the button
    if (mouseX>=xA && mouseX<=xB &&
      mouseY>=yA && mouseY<=yB) {
      return true;
    } else {
      return false;
    }
  }

  void selectButton(boolean todo) {
    ButtonSelected=todo;
  }

  boolean getButtonSelected() {
    return ButtonSelected;
  }

  float[] getCoordinates() {
    //Return the coordinates of the button and its width and height
    float[] coordinates= {
      xA, yA, xB, yB, xB-xA, yB-yA
    };
    return coordinates;
  }
} //end of class topButton


class refreshButton {
  float xA; //Position of the button. x-axis
  float yA; //Position of the button. y-axis. top-left(xA,yA)
  float xB;
  float yB; //Position of the butto. Bottom-right(xB,yB)
  PImage img; //picture of the button
  //contructor
  refreshButton(float tempx, float tempy) {
    xA=tempx;
    yA=tempy;
    img = loadImage("refresh02_24px.png");
    xB=xA+24;
    yB=yA+24;
  }

  void display() { 
    image(img, xA, yA, xB-xA, yB-yA);
    if (connection.getButtonSelected() && isMouseOver()) {
      noFill();
      stroke(0);
      rect(xA, yA, xB-xA, yB-yA);
    }
  }

  boolean isMouseOver() {
    //Chek if the coordinates of the mouse are over the area of the button
    if (mouseX>=xA && mouseX<=xB &&
      mouseY>=yA && mouseY<=yB) {
      return true;
    } else {
      return false;
    }
  }
  float[] getCoordinates() {
    //Return the coordinates of the button
    float[] coordinates= {
      xA, yA, xB, yB
    };
    return coordinates;
  }
}//end of class refreshButton


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


class textBox {
  boolean selected; //true if the box is selected
  topButton motherOption; //The textbox is inside one of the OPTIONS. 
  String txt; //text contained in the textbox
  float xA; //Position of the button. x-axis
  float yA; //Position of the button. y-axis. top-left(xA,yA)
  float xB;
  float yB; //Position of the butto. Bottom-right(xB,yB)
  float w; //width of the button
  float h; //height of the button

  // Constructor
  textBox(float tempx, float tempy, float tempw, float temph, String temptxt, topButton tempmotherOption) {
    xA=tempx;
    yA=tempy;
    xB=xA+tempw;
    yB=yA+temph;
    w=tempw;
    h=temph;
    txt=temptxt;
    selected=false;
    motherOption=tempmotherOption;
  }

  void display() {
    textFont(fArial, 12); //specify font to be used
    textAlign(LEFT, CENTER);

    if (motherOption.getButtonSelected()) {
      //draw with a rectangle
      stroke(0);
      if (selected) { //If this textBox is selected for eding, gray background
        fill(100);
      } else {
        fill(255);
      }
    } else { // the mother option is not selected, just white background
      fill(255);
      noStroke();
      //draw without rectangle
    }
    rect(xA, yA, w, h);
    fill(0);
    text(txt, xA+5, yA+h/2);
  }//end display()

  boolean isMouseOver() {
    //Chek if the coordinates of the mouse are over the area of the text box
    if (mouseX>=xA && mouseX<=xB &&
      mouseY>=yA && mouseY<=yB) {
      return true;
    } else {
      return false;
    }
  }

  void setSelected(boolean tmpselected) {
    selected=tmpselected;
  }

  boolean getSelected() {
    return selected;
  }

  String getTxt() {
    return txt;
  }

  void setTxt(String tmptxt) {
    txt=tmptxt;
  }

  float[] getCoordinates() {
    //Return the coordinates of the textbox and its width and height
    float[] coordinates= {
      xA, yA, xB, yB, w, h
    };
    return coordinates;
  }
}//end class textBox


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
