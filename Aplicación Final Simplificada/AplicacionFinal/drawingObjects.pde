void drawElements() {
  int iV;
  int iRep;
  int[] vFreq;
  int[] vSensor;
  float temp1, temp2, temp3, temp4;
  float progress;
  
  File f = dataFile("..\\Measurements\\RF1\\CALIBRATION_TEST.txt");
  boolean bCalibrationFileExists = f.isFile();
  
  
  String filename = "Measurements\\RF1\\CALIBRATION_TEST.txt";

  background(255);  
  
  b_StartStopMeasure.display();
  b_ConnectDisconnect.display();

  //checkboxes
  textFont(fArialBold, 12); //specify font to be used
  textAlign(LEFT, BASELINE);
  strokeWeight(1);
  fill(0);
  text("Check to calibrate:", 40, 20);
  text("Messages:", 40, 130);
  CB_forCalibration.display();
  fill(255);
  rect(40,80,290,30);
  rect(40,135,290,90);
  textFont(fArial, 12); //specify font to be used
  textAlign(LEFT, BASELINE);
  strokeWeight(1);

  //Checking connection status
  if(bConnected && !b_StartStopMeasure.getState())
  {
    fill(255);
    rect(40,135,290,90);
    fill(0);
    text("Connection Established.", 45, 150);
  }
  else if(bDisconnected && !b_StartStopMeasure.getState())
  {
    fill(255);
    rect(40,135,290,90);
    fill(0);
    text("Disconnected.", 45, 150);
  }
  
  if(bConnecting)
  { //<>//
    return;
  }
  //Check if we need a calibration and show message
  if(bCalibrationRequired)
  {
    fill(255);
    rect(40,135,290,90);
    textFont(fArial, 12); //specify font to be used
    textAlign(LEFT, BASELINE);
    strokeWeight(1);
    fill(0);
    text("Calibration Required...", 45, 150);
    fill(255,0,0);
    rect(230, 25, 40, 40);
    fill(155,155,155);
    rect(290, 25, 40, 40);
   }
  //Check resonance and show message
  else if((bResonates == true || area > 1000) && !b_StartStopMeasure.getState())
  {
    fill(255);
    rect(40,135,290,90);
    fill(155,155,155);
    rect(230, 25, 40, 40);
    fill(0,255,0);
    rect(290, 25, 40, 40);
    textFont(fArial, 12); //specify font to be used
    textAlign(LEFT, BASELINE);
    strokeWeight(1);
    fill(0);
    text("Resonance Found at Specified Frequency!", 45, 150);
  }
  else
  {
    fill(255,0,0);
    rect(230, 25, 40, 40);
    fill(155,155,155);
    rect(290, 25, 40, 40);
    if(!b_StartStopMeasure.getState() && !bCalibrating && bSweepCompleted)
    {
      fill(255);
      rect(40,135,290,90);
      textFont(fArial, 12); //specify font to be used //<>//
      textAlign(LEFT, BASELINE);
      strokeWeight(1);
      fill(0);
      text("No Resonance Found!", 45, 150);
    }
    else if(!b_StartStopMeasure.getState() && bCalibrating)
    {
      fill(255);
      rect(40,135,290,90);
      textFont(fArial, 12); //specify font to be used
      textAlign(LEFT, BASELINE);
      strokeWeight(1);
      fill(0);
      text("Calibration Complete!", 45, 150);
    }
  }


  if (b_StartStopMeasure.getState() && !CB_forCalibration.getCheckedState()) { 
    //Reset values
    bCalibrating = false;
    bResonates = false;
    mindB = 0;
    area = 0;
    res_freq = 0;
    //Check if there exists a file with calibration data
    if (bCalibrationFileExists)
    {    
      bCalibrationRequired = false;
      String[] lines = loadStrings(filename);
      iRep=measurementThread.getiRep();//get at which repetition we are.
      if (iRep>0) {
        fill(255);
        rect(40,135,290,90);
        textFont(fArial, 12); //specify font to be used
        textAlign(LEFT, BASELINE);
        strokeWeight(1);
        fill(0);
        text("Sweeping...", 45, 150);
        iV=ArrayMeasurements[iRep-1].getIv(); //get at which positon of the vFreq and vSensor vector we are, of that repetition
        if (iV>1) { //we have more than 2 points: [0],[1]
          vFreq=ArrayMeasurements[iRep-1].getFreqData();
          vSensor=ArrayMeasurements[iRep-1].getSensorData();
          fill(255);
          rect(40,80,290,30);
          progress = (float)iV/vFreq.length;
          fill(0, 255, 0);
          rect(40,80,progress*290,30);
          for (int i=0; i<iV; i++) {         
            temp1 = vSensor[i];
            temp2 = getdB(lines[i]);
            temp3 = temp1/temp2;
            temp4 = 20*log(temp3);
            // Check if the value is below a threashold, and consecuently we draw it in a different color
            if(temp4 < -3.5)
            {
              bResonates = true;
            }
            if(temp4 < mindB)
            {
              mindB = temp4;
              res_freq = vFreq[i];
            }
            //Calculate area of function
            area = area + DEFstepFreq/10000 * abs(temp4);
          }
        }//end if(iv>1)
        bSweepCompleted = true;
      }
    }
    else
    {
      bCalibrationRequired = true;
      b_StartStopMeasure.setState(false);
      return;
    }
  }//end if (b_StartStopMeasure.getState())
  else if(b_StartStopMeasure.getState() && CB_forCalibration.getCheckedState())
  {
    bCalibrating = true;
    bCalibrationRequired = false;
    bResonates = false;
    textFont(fArial, 12); //specify font to be used
    textAlign(LEFT, BASELINE);
    strokeWeight(1);
    fill(0);
    text("Calibrating...", 45, 150);
  }
}

float getFreq(String dataLine)
{
  float freq;
  String aux;
  int pos = dataLine.indexOf(",");
  aux = dataLine.substring(0,pos);
  freq = Integer.valueOf(aux);
  return freq;
} 

float getdB(String dataLine)
{
  float dB;
  String aux;
  int pos = dataLine.indexOf(",");
  int len = dataLine.length();
  aux = dataLine.substring(pos+1, len);
  dB = Integer.valueOf(aux);
  return dB;
} 
