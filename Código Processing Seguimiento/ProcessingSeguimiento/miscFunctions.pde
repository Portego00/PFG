void serialEvent (Serial myPort) {
  //To read the messages from the Lantier Board.

  boolean messOK=false;   //Flag to indicate that the received message is correct.
  int lenData;            //length of the received message
  int pSymbA;              //position of the # symbol.
  int pSymbB;              //position of the : symbol.
  int RFout=0;                //The RF output received in the message
  int receivedFreq=0;        // frequency (in Hz) received in the message
  int receivedSensorValue=0; //value of the sensor received in the message
  //int nCharSensorValue=0;
  int nErrors=0;      //to count the number of errors within the message

  // get the ASCII string:
  String inString = myPort.readStringUntil('\n');

  if (inString != null) { 
    inString = trim(inString);// trim off any whitespace:
    //println(inString);
    lenData=inString.length();

    //Evaluate the message contained in "inString"
    if (inString.substring(0, 3).equals("Bad Format")) { //The comand that we have sent to the Lantier board is incorrect
      print("Incorrect command: ");
      println(inString);
    } else if (inString.equals("Starting Lantier Board")) { //The Lantier board is starting
      println(inString);
      println("Connection established with Lantier Board");
    } else { //it is another message
      //Check if we are performing a measure, if yes then check that the message is correct and process it.
      if (b_StartStopMeasure.getState()) {//If we are performing a measurement,
        //Check if the message is correct
        //check the format of the message.
        //It has to be: <··#·····:·····> , where the number of · is variable.
        // the number of charaters between < and  # is between 1 and 2. 
        // the number of characters between # and : is between 1 and 5.
        // the number of characters between : and > is between 1 and 4.
        pSymbA=inString.indexOf("#");
        pSymbB=inString.indexOf(":");
        if (lenData>=7 && lenData<=15 && inString.charAt(0)=='<' && inString.charAt(lenData-1)=='>' && pSymbA>-1 && pSymbB>-1 ) {
          //Check that the characters corresponding to the RFout are valid numbers and obtain it.
          if (checkOnlyNumbers(inString.substring(1, pSymbA))) {
            RFout = returnTheInteger(inString.substring(1, pSymbA));
          } else {
            nErrors++;
          }

          //Check that the characters corresponding to the frequency are valid numbers and obtain the frequency.
          if (checkOnlyNumbers(inString.substring(pSymbA+1, pSymbB))) {
            receivedFreq = returnTheInteger(inString.substring(pSymbA+1, pSymbB));
            receivedFreq = receivedFreq*1000; //put in Hz.
          } else {
            nErrors++;
          }

          //Check that the characters corresponding to the sensor value are valid numbers and obtain it.
          if (checkOnlyNumbers(inString.substring(pSymbB+1, lenData-1))) {
            receivedSensorValue = returnTheInteger(inString.substring(pSymbB+1, lenData-1));
          } else {
            nErrors++;
          }

          //Check that:
          //1) ALL the characters of the frequency word and sensorvalue word were correct
          //2) The received RFout is in the range [1,...,18]
          //3) The received frequency is in the range [1 ... 99,999,999] Hz
          //4) The received sensorvalue is in the range 0...1023
          if (nErrors==0 && RFout>0 && RFout <19 && receivedFreq>=1 && receivedFreq<=199999999 && receivedSensorValue>=0 && receivedSensorValue<=1023) {
            messOK=true;
          }
        }//end if(lenData>=7 && lenData<=17 && inString.charAt(0)=='<' && inString.charAt(lenData-3)=='#' && inString.charAt(lenData-1)=='>')

        if (messOK) {
          //Store the data
          ArrayMeasurements[measurementThread.getiRep()-1].setData(receivedFreq, receivedSensorValue); //The repetition nº1 is stored in ArrayMeasurements[0]
        } else {
          println(inString);
          println("The received message is erroneous");
        }
      }//end if(b_StartStopMeasure.getState())
    }//end it is another message
  }// end if(inString !=null)
}//end serialEvent



void mousePressed() {
  //Set all the textboxes to selected=false
  for (int i=0; i<5; i++) {
    TXTmeasurement[i].setSelected(false);
  }
  typing = ""; //Empty the typing buffer

  //Check if we have pressed any of the mother OPTIONs
  if (connection.isMouseOver()) {
    connection.selectButton(true);
    outputs.selectButton(false);
    measurement.selectButton(false);
  } else if (outputs.isMouseOver()) {
    connection.selectButton(false);
    outputs.selectButton(true);
    measurement.selectButton(false);
  } else if (measurement.isMouseOver()) {
    connection.selectButton(false);
    outputs.selectButton(false);
    measurement.selectButton(true);
  } else { //We have NOT pressed any of the mother OPTIONs
    //Check if we have pressed another button
    //Each button is inside one of the 4 mother OPTIONS (connection, calibration...)
    //Check first if the OPTION is selected.
    //OPTION: Connection
    if (connection.getButtonSelected()) { //The Connection OPTION is selected
      if (refreshPorts.isMouseOver()) {
        listOfPorts = Serial.list(); //Store the available ports.
      } else if (b_ConnectDisconnect.isMouseOver()) {
        boolean narf = ConnectionProcedure(); //toogle the state of the connection
      }
    }//end CONNECTION option
    //OPTION: RF Outputs
    else if (outputs.getButtonSelected()) { //The RF outputs OPTION is selected
      for (int i=1; i<19; i++) {
        if (rfs[i].isMouseOver()) {
          rfs[i].setCheckedState(!rfs[i].getCheckedState()); //toogle the state
        }
      }
    }
    //OPTION: Measurement
    else if (measurement.getButtonSelected()) {//The Measurement OPTION is selected
      if (b_StartStopMeasure.isMouseOver()) { //The b_StartStopMeasure button is clicked
        MeasurementProcedure();
      } else { 
        //Check the textboxes
        for (int i=0; i<5; i++) {
          if (TXTmeasurement[i].isMouseOver()) { //this textbox has been clicked for edition
            b_StartStopMeasure.setState(false); //we force to stop the measurement (in case it was running) 
            TXTmeasurement[i].setSelected(true);
            TXTmeasurement[i].setTxt("");
          }
        }
        //Check the checkboxes
        if (CB_forCalibration.isMouseOver()) {
          b_StartStopMeasure.setState(false); //we force to stop the measurement (in case it was running) 
          CB_forCalibration.setCheckedState(!CB_forCalibration.getCheckedState()); //toogle the state
          if(CB_plotRT.getCheckedState() && CB_forCalibration.getCheckedState())
          {
            CB_plotRT.setCheckedState(!CB_plotRT.getCheckedState());
          }
          if(!CB_saveResults.getCheckedState() && CB_forCalibration.getCheckedState())
          {
            CB_saveResults.setCheckedState(!CB_plotRT.getCheckedState());
          }
        } else if (CB_plotRT.isMouseOver()) {
          b_StartStopMeasure.setState(false); //we force to stop the measurement (in case it was running) 
          CB_plotRT.setCheckedState(!CB_plotRT.getCheckedState()); //toogle the state
          if(CB_plotRT.getCheckedState() && CB_forCalibration.getCheckedState())
          {
            CB_forCalibration.setCheckedState(!CB_forCalibration.getCheckedState());
          }
        } else if (CB_saveResults.isMouseOver()) {
          b_StartStopMeasure.setState(false); //we force to stop the measurement (in case it was running) 
          CB_saveResults.setCheckedState(!CB_saveResults.getCheckedState()); //toogle the state
          if(CB_forCalibration.getCheckedState()) 
          {
            CB_saveResults.setCheckedState(!CB_saveResults.getCheckedState());
          }
        }
      }
    }// end MEASUREMENT option
  } //end check other buttons
}//end mousePressed()


boolean ConnectionProcedure() {
  //To start or stop the serial connection
  //This is called after the b_ConnectDisconnect button has been clicked or when we want to try to toogle the state
  //It tries to change the state of the connection state. If connected, then disconnect. And viceversa.
  //If we achieve to connect, it returns true. If not, it returns false.
  if (b_ConnectDisconnect.getState()) { //if true we are connected and we want to disconnect
    myPort.clear(); // Clear the buffer, or available() will still be > 0
    myPort.stop();
    b_ConnectDisconnect.setState(false); //We are disconnected.
    println("Disconnected");
    return false;
  } else { //if false we are disconnected and we want to connect
    try {
      //myPort = new Serial(this, Serial.list()[puertoSeleccionado], portSpeed);
      myPort = new Serial(this, puertoSeleccionado, portSpeed);
      myPort.bufferUntil('\n'); // don't generate a serialEvent() unless you get a newline character:
      b_ConnectDisconnect.setState(true); //We are connected
      println("Connected");
      return true;
    } 
    catch (RuntimeException e) {
      System.out.println("Port "+puertoSeleccionado+" not available");
      b_ConnectDisconnect.setState(false); //We stay the same, disconnected.
      return false;
    }
  }
}

void MeasurementProcedure() {
  //To start or stop a measurement ordered by the Measurement OPTION
  //This is called after the b_StartStopMeasure button has been clicked

  int[] parameters = new int[5]; //To store the 5 parameters of the measurement
  int[] listRF = new int[18]; //To store which RF outputs are going to be used
  int nRFouts=0;              //Number of enabled RFoutputs.
  int nErrors=0;      //to count the number of errors within the message
  //int MeasurementLength=0; //The length of the vFreq and vSensor
  String nameFileMeasurements; //The name of the txt at which we are going to save the measurements.
  //by default
  //parameters[0] = DFstartFreq;
  //parameters[1] = DFstepFreq;
  //parameters[2] = DFstopFreq;
  //parameters[3] = DFdelayBf; //Wait for delayBf ms before commanding a new frequency
  //parameters[4] = DFnumRepMeasure; //Number of times that the measurement will be performed

  if (b_StartStopMeasure.getState()) { //if true the system is started and we want to stop it.
    b_StartStopMeasure.setState(false); //Stop measuring, button in state 0
  } else { //the system is stopped and we want to start it
    //Check: if we are connected to the Lantier board
    if (!b_ConnectDisconnect.getState()) { //if true this means that we are connected to the lantier board
      nErrors++;
      System.out.println("We are not connected to the Lantier Board");
    }

    //Check: at least one RF output selected
    for (int i=1; i<19; i++) {
      if (rfs[i].getCheckedState()) {
        listRF[nRFouts]=i;
        nRFouts++;
      } else {
        listRF[i-1]=0;
      }
    }
    if (nRFouts<1) {
      nErrors++;
      System.out.println("No RF output selected");
    }

    //Read the parameters from the textBoxes
    //Check: that the parameters in the textBoxes are numbers
    for (int i=0; i<5; i++) {
      if (checkOnlyNumbers(TXTmeasurement[i].getTxt())) { //All the characters of the text box are numbers
        //Obtain the number
        parameters[i]=returnTheInteger(TXTmeasurement[i].getTxt());
        if (i==0) {
          minimumFrequency = parameters[i]/1000000;
        } else if (i==2) {
          maximumFrequency = parameters[i]/1000000;
        }
      } else { //In the textbox there are erroneous characters
        nErrors++;
        parameters[i]=0;
        System.out.println("Check the measurement parameters");
      }
    }//End check that the parameters in the textBoxes are numbers

    if (nErrors==0) {
      //Update the thread, create the arrays to store the data, and START MEASURING!!!
      //measurementThread.setParameters(startFreq, stepFreq, stopFreq, delayBf, numRepMeasure);
      measurementThread.setParameters(parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], listRF, nRFouts);  
      //MeasurementLength=(int)(10+(parameters[2]-parameters[0])/parameters[1]); //The +10 is unnecessary, with a +1 or +2 is enought
      //ArrayMeasurements = new measurementData[parameters[4]]; //Array of measurementData objects. One for each repetition of the measurement.
      //for (int i=0; i<parameters[4]; i++) {
      //  ArrayMeasurements[i]=new measurementData(MeasurementLength, 3);
      //}

      //START MEASURING.
      b_StartStopMeasure.setState(true); //START MEASURING!!!, button in state 1
    }//end of if (nErrors==0)
    else { //nErrors>0
      System.out.println("There are " + str(nErrors) + " errors");
    }
  }//end of "the system is stopped and we want to start it"
}//end of "MeasurementProcedure()"


void SendCommand(int freqCm, int rfOut) {
  //put the freqCm in KHz
  freqCm=freqCm/1000;
  String s_freq=str(freqCm);
  String s_Command;
  s_Command="<" + rfOut + "#" + s_freq + ">";
  myPort.write(s_Command);
  myPort.write(10); //New Line
}

void keyPressed() {

  //Check if any textbox is selected
  for (int i=0; i<5; i++) {
    if (TXTmeasurement[i].getSelected()) {
      if (key == '\n' ) { // If the return key is pressed, save the String and clear it
        typing = "";
        TXTmeasurement[i].setSelected(false); //unselect the textbox
      } else { // Otherwise, concatenate the String and show it
        // Otherwise, concatenate the String
        typing = typing + key;
        TXTmeasurement[i].setTxt(typing);
      }
      break; //output the for
    }
  }
}


boolean checkOnlyNumbers(String sTocheck) {
  //Checks if the string sTocheck is composed only by numbers.
  //Returns true if it is so.
  int cErrorsString=0;
  for (int i=0; i<sTocheck.length (); i++) {
    switch(sTocheck.charAt(i))
    {
    case '0':  
    case '1': 
    case '2': 
    case '3': 
    case '4':
    case '5': 
    case '6': 
    case '7': 
    case '8': 
    case '9': 
      break;
    default:
      cErrorsString++;
      break;
    }
  }//end for
  if (cErrorsString==0) {
    return true;
  } else {
    return false;
  }
}//end checkOnlyNumbers

int returnTheInteger(String stInt) {
  //the string stInt is an integer with String format. Return the real integer
  //NOTE: we are not checking that all the characters are numbers
  int realInt=0; //the returned integer
  for (int i=0; i<stInt.length (); i++) {
    switch(stInt.charAt(i))
    {
    case '0':  
    case '1': 
    case '2': 
    case '3': 
    case '4':
    case '5': 
    case '6': 
    case '7': 
    case '8': 
    case '9': 
      realInt *= 10;
      realInt += stInt.charAt(i) - '0';
      break;
    default:
      break;
    }
  }//end for
  return realInt;
}

String returnDate() {
  //Return the date and time in format: yyyymmdd_hhmmss
  String strDate;
  strDate=year()+nf(month(), 2)+nf(day(), 2)+"_"+nf(hour(), 2)+nf(minute(), 2)+nf(second(), 2);
  return strDate;
}

float[] obtainJD(float cYear, float cMonth, float cDay, float cHour, float cMinute, float cSecond) {
  //Return the Julian Date.
  //Since we have to work with floats the JD will be returned as an array
  //JD[0]: the integer part of the JD. Also known as Julain day number, JDN
  //JD[1]: the decimal part of the JD
  int a;
  int y;
  int m;
  float[] JD = new float[2];

  a=floor((14-cMonth)/12);
  y=(int)cYear+4800-a;
  m=(int)cMonth+12*a-3;
  JD[0]=(float)(cDay + floor((153*m+2)/5) + 365*y + floor(y/4) - floor(y/100) + floor(y/400) -32045); //The integer part, JDN
  JD[1]=(float)((cHour-12)/24) + (float)(cMinute/1440) + (float)(cSecond/86400);
  if (JD[1]<0) {
    JD[0]=JD[0]-1;
    JD[1]=1+JD[1];
  }
  return JD;
}

boolean checkJDnow(float[] JDnow, float[] JDlastMes, int waitTime) {
  //Check if JDnow >= JDlastMe + waitTime
  //where JDnow and JDlastMe have Julian Date format in a 2-element array form 
  //waitTime is the amount of hours that we have to wait before performing another cycle of measurements
  int days_add;
  int hours_add;
  float[] JDcomb = new float[2];

  //Obtain JDcomb = JDlastMes + waitTime
  days_add=floor(waitTime/24); //how many days
  hours_add=waitTime-days_add*24; //how many hours
  JDcomb[0]=(float)JDlastMes[0]+days_add;
  JDcomb[1]=(float)JDlastMes[1]+(float)((float)hours_add / (float)24);
  if (JDcomb[1]<1.0) {
  } else if (JDcomb[1]==1.0) { //check for rounding errors
    JDcomb[0]=JDlastMes[0]+1;
    JDcomb[1]=0.0;
  } else { //JDcombination[1]>1.0
    JDcomb[0]=JDcomb[0]+1;
    JDcomb[1]=JDcomb[1]-1;
  }

  /* System.out.println(JDnow[0]);
   System.out.println(JDnow[1]);
   System.out.println(JDlastMes[0]);
   System.out.println(JDlastMes[0]); */

  //Check JDnow >= JDcomb
  if (floor(JDnow[0]) < floor(JDcomb[0])) {
    return false;
  } else if (floor(JDnow[0]) == floor(JDcomb[0])) {
    if (JDnow[1]<JDcomb[1]) {
      return false;
    } else {// integer part equal and JDnow[1]>=JDcomb[0]
      return true;
    }
  } else {// (floor(JDnow[0] > floor(JDcomb[0])
    return true;
  }
}
