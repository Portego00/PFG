void drawElements() {
  int iV;
  int iRep;
  int[] vFreq;
  int[] vSensor;
  float temp1, temp2, temp3, temp4;
  
  File f = dataFile("..\\Measurements\\RF1\\CALIBRATION_TEST.txt");
  boolean bCalibrationFileExists = f.isFile();
  
  
  String filename = "Measurements\\RF1\\CALIBRATION_TEST.txt";

  background(255);  
  //debug
  //text(millis(),10,10);
  
  //Draw the plot area  
  printAxes(maximumVoltage, minimumVoltage, maximumFrequency, minimumFrequency);
  deleteAxesLabel(maximumVoltage, minimumVoltage, maximumFrequency, minimumFrequency);
  plotAxesLabel(maximumdB, minimumdB, maximumFrequency, minimumFrequency);
  // Display the buttons of the options
  connection.display();
  outputs.display();
  measurement.display();
  // Display the other buttons
  b_ConnectDisconnect.display();
  refreshPorts.display();
  b_StartStopMeasure.display();

  //textboxes
  for (int i=0; i<5; i++) { //plot the 5 text boxes of the measurement OPTION
    TXTmeasurement[i].display();
  }

  //checkboxes
  CB_forCalibration.display();
  CB_plotRT.display();
  CB_saveResults.display();
  
  for(int i=1;i<19;i++){
    rfs[i].display();
  }
  //Draw the Message section
  stroke(0);
  line(connection.getCoordinates()[0], messageAreaYA, connection.getCoordinates()[2], messageAreaYA);
  line(connection.getCoordinates()[0], messageAreaYA, connection.getCoordinates()[0], messageAreaYA+connection.getCoordinates()[5]);
  textFont(fArialBold, 16); //specify font to be used
  textAlign(LEFT, BASELINE);
  fill(0); //font color
  text("Resonance Info", connection.getCoordinates()[0]+10, messageAreaYA+20);

  //Write Static text
  textbackground();
  
  //Checking resonance and showing messages
  if(bResonates == true || area > 1000)
  {
    textFont(fArial, 12); //specify font to be used
    textAlign(LEFT, BASELINE);
    strokeWeight(1);
    fill(0);
    text("RFID tag resonance:", connection.getCoordinates()[0]+10, messageAreaYA+50);
    if(res_freq > 175000000 && res_freq < 190000000)
    {
      fill(155,155,155);
      rect(connection.getCoordinates()[0]+150, 606, 20, 20);
      fill(0,255,0);
      rect(connection.getCoordinates()[0]+180, 606, 20, 20);
    }
    else
    {
      fill(255,0,0);
      rect(connection.getCoordinates()[0]+150, 606, 20, 20);
      fill(155,155,155);
      rect(connection.getCoordinates()[0]+180, 606, 20, 20);
    }
    fill(0);
    text("Resonance frequency: ", connection.getCoordinates()[0]+10, messageAreaYA+80);
    text("Resonance S21: ", connection.getCoordinates()[0]+10, messageAreaYA+110);
    text("Area: ", connection.getCoordinates()[0]+10, messageAreaYA+140);
    textFont(fArialBold, 12);

    text(res_freq/1E6 + " MHz", connection.getCoordinates()[0]+150, messageAreaYA+80);
    text(nf(mindB, 0, 2) + " dB", connection.getCoordinates()[0]+150, messageAreaYA+110);
    text(area , connection.getCoordinates()[0]+150, messageAreaYA+140);

  } 
  else //if there is no resonance
  {
    textFont(fArial, 12); //specify font to be used
    textAlign(LEFT, BASELINE);
    strokeWeight(1);
    fill(0);
    text("RFID tag resonance:", connection.getCoordinates()[0]+10, messageAreaYA+50);
    fill(255,0,0);
    rect(connection.getCoordinates()[0]+150, 606, 20, 20);
    fill(155,155,155);
    rect(connection.getCoordinates()[0]+180, 606, 20, 20);
    fill(0);
    text("Resonance frequency: ", connection.getCoordinates()[0]+10, messageAreaYA+80);
    text("Resonance S21: ", connection.getCoordinates()[0]+10, messageAreaYA+110);
    text("Area: ", connection.getCoordinates()[0]+10, messageAreaYA+140);
    textFont(fArialBold, 12);
    text("None", connection.getCoordinates()[0]+150, messageAreaYA+80);
    text("None", connection.getCoordinates()[0]+150, messageAreaYA+110);
    text(area , connection.getCoordinates()[0]+150, messageAreaYA+140);
  }
  //Showing a message if there is no calibration file
  if(bCalibrationRequired)
  {
      fill(255);
      rect(510,340,280,60);
      textFont(fArialBold, 25); //specify font to be used
      textAlign(CENTER, BASELINE);
      strokeWeight(1);
      fill(0);
      text("Calibration required...", 650, 380);
   }

  //GRAPH
  //draw
  if (b_StartStopMeasure.getState() && CB_plotRT.getCheckedState()) { //if we are performing a measurement and we have selected to show it in real time
    //plot the last measurement
    
    //Reset all the values and booleans
    bCalibrating = false;
    bResonates = false;
    bFinish = false;
    area = 0;
    mindB = 0;
    res_freq = 0;
    //Check if there is a file with the calibration data
    if (bCalibrationFileExists)
    {    
      bCalibrationRequired = false;
      String[] lines = loadStrings(filename);
      iRep=measurementThread.getiRep();//get at which repetition we are.
      deleteAxesLabel(maximumVoltage, minimumVoltage, maximumFrequency, minimumFrequency);
      plotAxesLabel(maximumdB, minimumdB, maximumFrequency, minimumFrequency);
      if (iRep>0) {
        iV=ArrayMeasurements[iRep-1].getIv(); //get at which positon of the vFreq and vSensor vector we are, of that repetition
        if (iV>1) { //we have more than 2 points: [0],[1]
          vFreq=ArrayMeasurements[iRep-1].getFreqData();
          vSensor=ArrayMeasurements[iRep-1].getSensorData();
          for (int i=1; i<iV; i++) {
            //Calculate the S21 parameter and map it for plot
            float x1=mapFreq(vFreq[i-1], maximumFrequency, minimumFrequency);
            temp1 = vSensor[i-1];
            temp2 = getdB(lines[i-1]);
            temp3 = temp1/temp2;
            temp4 = 20*log(temp3);
            float y1=mapdB(temp4, maximumdB, minimumdB);
            float x2=mapFreq(vFreq[i], maximumFrequency, minimumFrequency);
            temp1 = vSensor[i];
            temp2 = getdB(lines[i]);
            temp3 = temp1/temp2;
            temp4 = 20*log(temp3);
            float y2=mapdB(temp4, maximumdB, minimumdB);
            // Check if the value is below a threashold, and consecuently we draw it in a different color
            if(temp4 < -3.5)
            {
              bResonates = true;
              stroke(0, 255, 0);
            }
            else
            {
              stroke(0);
            }
            //Save minimum value of S21 and its frequency
            if(temp4 < mindB)
            {
              mindB = temp4;
              res_freq = vFreq[i];
            }
            strokeWeight(2);
            line(x1, y1, x2, y2);
            //Calculate the area in the range of frequency of the tag
            if(vFreq[i] > 170000000 && vFreq[i] < 190000000)
            {
              area = area + DEFstepFreq/10000 * abs(temp4);
            }
          }
        }//end if(iv>1)
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
    fill(255);
    rect(520,340,260,60);
    textFont(fArialBold, 30); //specify font to be used
    textAlign(CENTER, BASELINE);
    strokeWeight(1);
    fill(0);
    text("CALIBRATING...", 650, 380);
  }
}

void textbackground() {
  //To print all the static text of the application

  //Connection
  textFont(fArial, 12); //specify font to be used
  textAlign(LEFT, CENTER);
  fill(0); //font color
  //The next text is aligned relative to the refreshPorts button
  text("Ports :", refreshPorts.getCoordinates()[2]+5, -2+refreshPorts.getCoordinates()[1]+(refreshPorts.getCoordinates()[3]-refreshPorts.getCoordinates()[1])/2);
  for (int i=0; i<listOfPorts.length; i++) {
    text(listOfPorts[i], refreshPorts.getCoordinates()[2]+42+40*i, -2+refreshPorts.getCoordinates()[1]+(refreshPorts.getCoordinates()[3]-refreshPorts.getCoordinates()[1])/2);
  }
  textAlign(LEFT, BASELINE);

  //OPTION: Measurement
  textFont(fArial, 12); //specify font to be used
  textAlign(LEFT, CENTER);
  fill(0); //font color
  //The text is aligned relative to the text boxes of the Measurement button
  text("Start Freq. (Hz) :", measurement.getCoordinates()[0]+10, TXTmeasurement[0].getCoordinates()[3]-TXTmeasurement[0].getCoordinates()[5]/2);
  text("Step Freq. (Hz) :", measurement.getCoordinates()[0]+10, TXTmeasurement[1].getCoordinates()[3]-TXTmeasurement[1].getCoordinates()[5]/2);
  text("Stop Freq. (Hz) :", measurement.getCoordinates()[0]+10, TXTmeasurement[2].getCoordinates()[3]-TXTmeasurement[2].getCoordinates()[5]/2);
  text("Wait Between Steps (ms) :", measurement.getCoordinates()[0]+10, TXTmeasurement[3].getCoordinates()[3]-TXTmeasurement[3].getCoordinates()[5]/2);
  text("# of Repetitions :", measurement.getCoordinates()[0]+10, TXTmeasurement[4].getCoordinates()[3]-TXTmeasurement[4].getCoordinates()[5]/2);
  //The text is aligned relative to the checkboxes
  text("Use for Calibration :", measurement.getCoordinates()[0]+10, CB_forCalibration.getCoordinates()[3]-CB_forCalibration.getCoordinates()[5]/2);
  text("Plot in Real Time :", measurement.getCoordinates()[0]+10, CB_plotRT.getCoordinates()[3]-CB_plotRT.getCoordinates()[5]/2);
  text("Save the Measurements :", measurement.getCoordinates()[0]+10, CB_saveResults.getCoordinates()[3]-CB_saveResults.getCoordinates()[5]/2);

  
  //Top text
  textFont(fArialBold, 16); //specify font to be used
  textAlign(CENTER, BASELINE);
  fill(0); //font color
  text(topText,plotXA+(plotXB-plotXA)/2, plotYA-5);
}

void printAxes(float maxVol, float minVol, float maxFreq, float minFreq) {
  textFont(fArial, 16); //specify font to be used
  fill(0); //font color
  textAlign(LEFT, BASELINE);
  strokeWeight(2);
  float x1=mapFreq(minFreq*1000000, maxFreq, minFreq);
  float y1=mapVol(minVol, maxVol, minVol);
  float x2=x1;
  float y2=mapVol(maxVol, maxVol, minVol);
  stroke(0);
  line(x1, y1, x2, y2); //y-axis
  x1=mapFreq(minFreq*1000000, maxFreq, minFreq);
  y1=mapVol(minVol, maxVol, minVol);
  x2=mapFreq(maxFreq*1000000, maxFreq, minFreq);
  y2=y1;
  stroke(0);
  line(x1, y1, x2, y2); //x-axis
  int nPasosVol=5;
  int nPasosFreq=10;
  float pasoV=(maxVol-minVol)/nPasosVol;
  float pasoF=(maxFreq-minFreq)/nPasosFreq;

  //Marks y-axis
  for (int i=1; i<=nPasosVol; i=i+1) {
    x1=mapFreq(minFreq*1000000, maxFreq, minFreq);
    y1=mapVol(minVol+i*pasoV, maxVol, minVol);
    x2=mapFreq(maxFreq*1000000, maxFreq, minFreq);
    y2=y1;
    stroke(105);
    strokeWeight(1);
    line(x1, y1, x2, y2);
    text(minVol+i*pasoV, x1, y1-5); //the -5 is for better looking.
    fill(255);
    rect(x1+1,y1-30,60,30);
    fill(0);
    text(minVol+i*pasoV, x1, y1-5); //the -5 is for better looking.
  }

  //Marks x-axis
  for (int i=1; i<=nPasosFreq; i=i+1) {
    x1=mapFreq((minFreq+i*pasoF)*1000000, maxFreq, minFreq);
    y1=mapVol(minVol, maxVol, minVol);
    x2=x1;
    y2=mapVol(maxVol, maxVol, minVol);
    stroke(105);
    strokeWeight(1);
    line(x1, y1, x2, y2);
    String sf=nf(minFreq+i*pasoF, 2, 2);
    text(sf, x1-0.02*width, y1+0.03*height);
  }
}//end printAxes

void deleteAxesLabel(float maxVol, float minVol, float maxFreq, float minFreq)
{
  float x1, y1;
  int nPasosVol=5;
  float pasoV=(maxVol-minVol)/nPasosVol;
  for(int i=1; i<=5; i++)
  {
    x1=mapFreq(minFreq*1000000, maxFreq, minFreq);
    y1=mapVol(minVol+i*pasoV, maxVol, minVol);
    fill(255);
    rect(x1+1,y1-30,60,30);
  }
}

void plotAxesLabel(float maxVol, float minVol, float maxFreq, float minFreq)
{
  textFont(fArial, 16); //specify font to be used
  textAlign(LEFT, BASELINE);
  fill(0);
  float x1, y1, x2, y2;
  int nPasosVol=5;
  float pasoV=(maxVol-minVol)/nPasosVol;
  for(int i=1; i<=5; i++)
  {
    x1=mapFreq(minFreq*1000000, maxFreq, minFreq);
    y1=mapVol(minVol+i*pasoV, maxVol, minVol);
    x2=mapFreq(maxFreq*1000000, maxFreq, minFreq);
    y2=y1;
    stroke(105);
    strokeWeight(1);
    line(x1, y1, x2, y2);
    text(minVol+i*pasoV, x1+3, y1-5); //the -5 is for better looking.
  }
}

float mapFreq(float freq, float maxFreq, float minFreq) {
  //To map the frequency into the plot area
  //freq: frequency in Hz
  //maxFreq: maximum frequency that will be mapped
  //minFreq: minimum frequency that will be mapped
  float m=(plotXB-plotXA)/(maxFreq-minFreq);
  float freqMapped=m*(freq/1000000 -maxFreq)+plotXB;
  return freqMapped;
}

float mapVol(float vol, float maxVol, float minVol) {
  //To map the voltage into the plot area
  //vol: voltage in volts
  //maxVol: maximum voltage that will be mapped
  //minVol: minimum voltage that will be mapped
  float m=(plotYA - plotYB)/(maxVol-minVol); 
  float volMapped=m*(vol-minVol)+plotYB;
  return volMapped;
}

float mapdB(float dB, float maxdB, float mindB)
{
  //To map the S21 parameter into the plot area
  float m=(plotYA - plotYB)/(maxdB-mindB); 
  float dBMapped = m*(dB-mindB)+plotYB;
  return dBMapped;
}

float getFreq(String dataLine)
{
  //Get the frequency from the calibration file
  float freq;
  String aux;
  int pos = dataLine.indexOf(",");
  aux = dataLine.substring(0,pos);
  freq = Integer.valueOf(aux);
  return freq;
} 

float getdB(String dataLine)
{
  //Get the S21 from the calibration file
  float dB;
  String aux;
  int pos = dataLine.indexOf(",");
  int len = dataLine.length();
  aux = dataLine.substring(pos+1, len);
  dB = Integer.valueOf(aux);
  return dB;
} 
