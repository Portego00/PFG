import processing.serial.*;
import java.util.Date;

Serial myPort;        // The serial port
String[] listOfPorts;   //To store the names of the available ports
int portSpeed; //the speed of the serial port. In bauds
String puertoSeleccionado; 

//Threads
cMeasuringThread measurementThread; //Thread of the measurement OPTION


//Variables
float[] JD_tNow; //To store the current time in Julian Date format
float[] JD_tLastMeasurement; //To store the time at which the last measurement loop was performed
int tWait; //How much time do we have to wait between measurement cycles [in hours]

PFont fArial; 
PFont fArialBold;
float maximumVoltage; //in volts. Maximum voltage of the y-axis of the plot window
float minimumVoltage; //in volts. Minimum voltage of the y-axis of the plot window
float maximumFrequency; //in MHz. Maximum frequency of the x-axis of the plot window
float minimumFrequency; //in MHz. Minimum frequency of the x-axis of the plot window
float minimumdB;
float maximumdB;

//default values for the textboxes
int DEFstartFreq;
int DEFstepFreq;
int DEFstopFreq;
int DEFdelayBf; //Wait for delayBf ms before commanding a new frequency
int DEFnumRepMeasure; //Number of times that the measurement will be performed

//Booleans for messages
boolean bResonates = false;
boolean bFinish = false;
boolean bCalibrationRequired = false;
boolean bCalibrating = false, bCalibrated = false;

//Data for resonance
float res_freq = 0;
float mindB = 0;
float area = 0;
float progressBar = 0;

measurementData[] ArrayMeasurements; // array of MeasurementData objects to store each measure. One object per repetition.


//GUI
float plotXA, plotYA;      // Position of the plot area. XA,YA:top-left.
float plotXB, plotYB;      // XB, YB: bottom-right.
float messageAreaYA;           // Starting position (Y) of the line that marks the message area

//Buttons
topButton connection;
topButton outputs;
topButton measurement;
refreshButton refreshPorts;
twoStateButton b_ConnectDisconnect;
twoStateButton b_StartStopMeasure;


//textboxes
textBox[] TXTmeasurement; //array of textboxes for the measurement OPTION;
String typing; // Variable to store text currently being typed

//checkboxes
checkBox CB_forCalibration; //To indicate if the measurement is going to be used for calibration
checkBox CB_plotRT; //To indicate if we want to plot the measurements in real time in the graph
checkBox CB_saveResults; //To indicate that we want to save the income data
checkBox[] rfs; //List of checkboxes to select the RF outputs that we want to use.

//Various
String topText; //Text that we will display on top of the graph

void setup () {
  // set the window size:
  size(1000, 750);
  background(255);

  //Serial Port
  portSpeed=115200;
  // Store the available ports.
  listOfPorts = Serial.list(); 
  //puertoSeleccionado="COM10";
  puertoSeleccionado=listOfPorts[0];

  //Fonts
  fArial=createFont("Arial", 32, true); //create font;
  fArialBold=createFont("Arial Bold", 32, true); //create font;

  // Create the buttons of the mother OPTIONs. 
  connection = new topButton(0.03*width, 0.03*height, "Connection");
  outputs = new topButton(0.03*width, 0.2*height, "RF Outputs");
  measurement = new topButton(0.03*width, 0.35*height, "Measurement");

  messageAreaYA=0.76*height;

  // Create the refresh ports button 
  refreshPorts = new refreshButton(connection.getCoordinates()[0], connection.getCoordinates()[3]+10); //its position is relative to the Connection button
  // Create the connect-disconnect button
  b_ConnectDisconnect = new twoStateButton(connection.getCoordinates()[0]+70, connection.getCoordinates()[3]+60, 100, 20, "Connect", "Disconnect", color(255, 255, 255), color(255, 0, 0));
  // Create the start-stop measurement button
  b_StartStopMeasure = new twoStateButton(measurement.getCoordinates()[0]+70, measurement.getCoordinates()[3]+250, 100, 20, "START", "STOP", color(255, 255, 255), color(255, 0, 0));

  //Text boxes
  //default values
  DEFstartFreq= 100000000;
  DEFstepFreq = 50000;
  DEFstopFreq = 190000000;
  DEFdelayBf = 5; //Wait for delayBf ms before commanding a new frequency
  DEFnumRepMeasure = 1; //Number of times that the measurement will be performed

  // Plot area dimensions
  plotXA=0.3*width;
  plotYA=0.03*height;
  plotXB=0.97*width;
  plotYB=0.95*height;
  maximumVoltage=5; //in volts. Maximum voltage of the y-axis of the plot window
  minimumVoltage=0; //in volts. Minimum voltage of the y-axis of the plot window
  maximumFrequency=42; //in MHz. Maximum frequency of the x-axis of the plot window
  minimumFrequency=11; //in MHz. Minimum frequency of the x-axis of the plot window
  maximumdB = 5;
  minimumdB = -20;


  //textBoxes
  TXTmeasurement = new textBox[5];
  TXTmeasurement[0]= new textBox(measurement.getCoordinates()[0]+155, measurement.getCoordinates()[3]+10, 80, 20, str(DEFstartFreq), measurement); //startFreq text box
  TXTmeasurement[1]= new textBox(measurement.getCoordinates()[0]+155, measurement.getCoordinates()[3]+40, 80, 20, str(DEFstepFreq), measurement); //stepFreq text box
  TXTmeasurement[2]= new textBox(measurement.getCoordinates()[0]+155, measurement.getCoordinates()[3]+70, 80, 20, str(DEFstopFreq), measurement); //stopFreq text box
  TXTmeasurement[3]= new textBox(measurement.getCoordinates()[0]+155, measurement.getCoordinates()[3]+100, 80, 20, str(DEFdelayBf), measurement); //delayBf text box
  TXTmeasurement[4]= new textBox(measurement.getCoordinates()[0]+155, measurement.getCoordinates()[3]+130, 80, 20, str(DEFnumRepMeasure), measurement); //numRepMeasure text box
  typing = "";

  //Checkboxes
  CB_forCalibration = new checkBox(measurement.getCoordinates()[0]+155, measurement.getCoordinates()[3]+160, 15, 15, false);
  CB_plotRT = new checkBox(measurement.getCoordinates()[0]+155, measurement.getCoordinates()[3]+190, 15, 15, true);
  CB_saveResults = new checkBox(measurement.getCoordinates()[0]+155, measurement.getCoordinates()[3]+220, 15, 15, false);
  rfs = new checkBox [19]; //the first one will not be used. So the ports are correctlye mapped: 1->RF1 2->RF2...
  for (int i=1; i<7; i++) {
    rfs[i]=new checkBox(outputs.getCoordinates()[0]+(i-1)*42+25, outputs.getCoordinates()[3]+10, 15, 15, false, str(i)+":");
  }
  for (int i=7; i<13; i++) {
    rfs[i]=new checkBox(outputs.getCoordinates()[0]+(i-7)*42+25, outputs.getCoordinates()[3]+35, 15, 15, false, str(i)+":");
  }
  for (int i=13; i<19; i++) {
    rfs[i]=new checkBox(outputs.getCoordinates()[0]+(i-13)*42+25, outputs.getCoordinates()[3]+60, 15, 15, false, str(i)+":");
  }
  
  //Extra
  topText= " ";

  // Draw everything
  drawElements();

  //Create the threads, 
  measurementThread = new cMeasuringThread("Measurement"); //With default values 
  measurementThread.start(); //it starts, but it is not measuring
}

void draw () {
  drawElements(); //Draw everything on the screen
}



///////////////////////////////// THREADS //////////////////////////////////////////////////////////////////////////////////////////////


class cMeasuringThread extends Thread {
  boolean running;           // Is the thread running?  Yes or no?
  int startFreq;
  int stepFreq;
  int stopFreq;
  int delayBf; //Wait for delayBf ms before commanding a new frequency
  int numRepMeasure; //Number of times that the measurement will be performed
  String id;                 // Thread name
  int iRep;                 // counter of the number of repetitons performed
  int freqCm;      //The frequency that the DDS has to output.
  int[] vFreq;     //We will store the freq contained in this vector
  int[] vSensor;   //We will store the sensor data contained in this vector.
  int lenVector;   //The length of the vFreq and vSensor data
  int[] listRF;    //To store which RF outputs are going to be used
  int nRFouts;     //Number of enabled RFoutputs.
  int iRFout;
  String nameFileMeasurements; //The name of the txt at which we are going to save the measurements.
  PrintWriter fileMeasurements; //Text file for saving the measurements

    cMeasuringThread (String s) {  
    startFreq=DEFstartFreq; //default values
    stepFreq=DEFstepFreq;
    stopFreq=DEFstopFreq;
    delayBf = DEFdelayBf;
    numRepMeasure=DEFdelayBf;
    id = s;
    freqCm=startFreq; 
    iRep = 0;
    running = false;
    listRF = new int[18]; //To store which RF outputs are going to be used
    nRFouts=0;              //Number of enabled RFoutputs.
    iRFout=0;
  }

  void setParameters(int startFreq_, int stepFreq_, int stopFreq_, int delayBf_, int numRepMeasure_, int[] listRF_, int nRFouts_) {
    startFreq = startFreq_;
    stepFreq = stepFreq_;
    stopFreq = stopFreq_;
    delayBf = delayBf_;
    numRepMeasure = numRepMeasure_; 
    listRF = listRF_;
    nRFouts = nRFouts_;
    freqCm=startFreq;
    iRep = 0;
    iRFout=0;
    //System.out.println(str(listRF[0]) + "_" + str(listRF[1]) +  "_" + str(listRF[2]));
  }

  // Overriding "start()"
  void start () {
    running=true;
    //println("Thread started");    
    super.start();
  }

  void run () {
    while (running) {
      while (b_StartStopMeasure.getState ()) {
        while (b_StartStopMeasure.getState () && iRFout<nRFouts) {
          //We are going to start a new set of measurements for a new RFoutput
          //We initialize again the variables.
          iRep = 0;
          topText = "RF " + str(listRF[iRFout]);
          System.out.println(topText);
          int MeasurementLength=(int)(10+(stopFreq-startFreq)/stepFreq); //The +10 is unnecessary, with a +1 or +2 is enought
          ArrayMeasurements = new measurementData[numRepMeasure]; //Array of measurementData objects. One for each repetition of the measurement.
          for (int i=0; i<numRepMeasure; i++) {
            ArrayMeasurements[i]=new measurementData(MeasurementLength, 3);
          }
          //We RESET the Arduino to force the reset of the DDS
          //Reason: Sometimes the DDS is working incorrectly due to external interferences. 
          //How: we are going to disconnect and connect to the Lantier board.
          boolean conState = ConnectionProcedure(); //We try to disconnect (because now we are connected)
          // Wait for 1000 ms
          try { 
            sleep((long)(1000));
          }
          catch (Exception e) {
          }
          conState = ConnectionProcedure(); //We try to connect again
          try { 
            sleep((long)(5000));
          }
          catch (Exception e) {
          }
          if (!conState) {
            b_StartStopMeasure.setState(false); //we force to stop the measurement because we are not connected.
          }

          //Create the text files for saving the measurements if the checkbox is checked
          if (b_StartStopMeasure.getState () && CB_saveResults.getCheckedState()) {
            try {
              //Create the name of the file
              nameFileMeasurements="Measurements\\"; //Folder
              nameFileMeasurements = nameFileMeasurements + "RF" + str(listRF[iRFout]) + "\\";
              if (CB_forCalibration.getCheckedState()) {//if it is going to be used for calibration, append the name CALIBRATION_
                nameFileMeasurements=nameFileMeasurements+"CALIBRATION_";
              }
              //nameFileMeasurements=nameFileMeasurements+returnDate();
              nameFileMeasurements=nameFileMeasurements + "TEST.txt";
              fileMeasurements = createWriter(nameFileMeasurements);
            } 
            catch (Exception e) {
              b_StartStopMeasure.setState(false); //we force to stop the measurement
              System.out.println("Error while creating the txt file");
            }
          }// END if (CB_saveResults.getCheckedState())
          
          //Now we measure numRepMeasure repetitions
          while (b_StartStopMeasure.getState () && iRep < numRepMeasure) {
            iRep++;
            freqCm=startFreq;
            while (b_StartStopMeasure.getState () && freqCm<=stopFreq) {
              SendCommand(freqCm, listRF[iRFout]);
              // Wait for delayBf ms
              try {
                sleep((long)(delayBf));
              }
              catch (Exception e) {
              }
              freqCm+=stepFreq;
            }//END while (b_StartStopMeasure.getState () && freqCm<=stopFreq); Measurement completed or stopped

            //We have finished the measurement because:
            //1)We have stopped the measurements OR
            //2)The measurement of one repetition is complete
            //If we are in the second case, store the data in the txt file if the saveRT checkbox is checked
            if (b_StartStopMeasure.getState() && CB_saveResults.getCheckedState() ) {//if true, we are in state 2, still measuring
              vFreq=ArrayMeasurements[iRep-1].getFreqData();
              vSensor=ArrayMeasurements[iRep-1].getSensorData();
              lenVector=vFreq.length;
              for (int i=0; i<lenVector; i++) {
                if (vFreq[i]==0 && vSensor[i]==0) {
                  //In this case we are discarting these values because are part of over-protection while creating the array ArrayMeasurement[iRep-1]
                } else {
                  //fileMeasurements.print(listRF[iRFout]);
                  //fileMeasurements.print(",");
                  fileMeasurements.print(vFreq[i]);
                  fileMeasurements.print(",");
                  fileMeasurements.println(vSensor[i]);
                }
              }
            }//end if
          }//END while (b_StartStopMeasure.getState () && iRep < numRepMeasure)

          //We are not measuring because:
          //1)The system is stopped (during a measurement or because it was already stopped)
          //2)OR we have finished the measurements for this RF output

          //If we were saving the data, we have to close the txt file.
          if (iRep>0 && CB_saveResults.getCheckedState()) {
            fileMeasurements.flush();
            fileMeasurements.close();
          }
         
          //If the system is stopped (state0), it is possible that we have been measuring (if iRep>0). 
          //In that case we have to remove the substract iRep because the last measurement is not complete.
          //the iRep variable is read by other functions to evaluate how many correct measurements we have performed.
          if(!b_StartStopMeasure.getState() && iRep>0){
           iRep--;
          }
          
          iRFout++; //next RF output
        }//END while (b_StartStopMeasure.getState() && iRFout<nRFouts)
        
        //If we are here we have finished all the RFoutsputs or because b_StartStopMeasure.getState is false
        //in any of these cases we have to exit.
        b_StartStopMeasure.setState(false); //we put the button in state 0, (system stopped)
        bFinish = true;
      }//END while (b_StartStopMeasure.getState())
      

      //We are not measuring
      //sleep the thread for 50ms
      try {
        sleep((long)(50));
      } 
      catch (Exception e) {
      }
    } //END while(running)
    //System.out.println(id + " thread is done!");  // The thread is done when we get to the end of run()
  }//END run

  int getiRep() {
    //Returns at which repetion of measurement we are.
    return iRep;
  }

  // Our method that quits the thread
  void quit() {
    System.out.print("Quitting..."); 
    running = false;  // Setting running to false ends the loop in run()    
    interrupt();// IUn case the thread is waiting. . .
    System.out.println("OK.");
  }
}// end of Class SimpleThread
