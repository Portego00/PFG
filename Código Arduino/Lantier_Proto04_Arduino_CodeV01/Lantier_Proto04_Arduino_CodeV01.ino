//LIBRARIES
#include "SPI.h"      // SPI library. To control the DDS

//PINS
//The pins 13,12,11 are used for the SPI communication with the DDS.
//They are the SCLK, SDO(MISO) and SDIO(MOSI) respectively.
#define IOUP 10      // i/o update pin of the DDS
#define CSB 9        // CSB pin of the DDS
#define RESETDDS 8   // reset pin of the DDS
#define SER 7        // pin to send serial data to the shift registers
#define LATCH 6      // Latch pin of the shift registers
#define CLK 5        // clock pin of the shift registers
#define SENSOR 5     // The analog value of the sensor is read&converted by the sensorPin of the arduino
//GLOBAL VARIABLES
const static float factorWord=10.73741824; //DDS frequency resolution: 2^32/fClock in Hz. e.g: (2^32)/(400*10^6) = 10.737418
const unsigned int MAX_INPUT = 50; // how much serial data we expect before a newline
//Array to select the switch RF that we want to activate
const word RF[19]={
  0xFFFF, //All switches OFF
  0x1FFF, //RF1 ON. The switch A is ON and the others OFF.
  0x3FFF, //RF2 ON. The switch A is ON and the others OFF.
  0X5FFF,
  0X7FFF,
  0X9FFF,
  0XBFFF,
  0XE3FF,  //RF7 ON. The switch B is On and the others OFF.
  0XE7FF,
  0XEBFF,
  0XEFFF,
  0XF3FF,
  0XF7FF,
  0XFC7F,  //RF13 ON. The switch C is ON and the others OFF.
  0XFCFF,
  0XFD7F,
  0XFDFF,
  0XFE7F,  
  0XFEFF}; //RF18 ON. The switch C is ON and the others OFF.


void setup(){
  //PC communication
  Serial.begin(115200);
  delay(600);
  Serial.println("Starting Lantier Board");
  //DDS communication
  SPI.begin();
  SPI.setBitOrder(MSBFIRST); 
  SPI.setDataMode(SPI_MODE0);
  delay(500);
  //Arduino pins
  pinMode(IOUP,OUTPUT);
  pinMode(CSB,OUTPUT);
  pinMode(RESETDDS,OUTPUT);
  pinMode(SER, OUTPUT);
  pinMode(LATCH,OUTPUT);
  pinMode(CLK,OUTPUT);  
  //Default state
  digitalWrite(IOUP,LOW);
  digitalWrite(CSB,HIGH);
  digitalWrite(RESETDDS,LOW);
  digitalWrite(CLK,LOW);
  digitalWrite(LATCH,LOW);
  //Reset DDS and clean the Shift Register
  DDSinitialization(); //Init. the DDS.
  ActivateSwitch(0); //All the switches OFF
  delay(2000);
}

void loop(){
  // if serial data available, process it
  if (Serial.available() > 0){
    processIncomingByte(Serial.read());
  }
}


//We are going to send LSbyte first and LSbit first.
void ActivateSwitch(int ind){
  digitalWrite(CLK,LOW);
  digitalWrite(LATCH,LOW);
  shiftOut(SER,CLK,LSBFIRST,lowByte(RF[ind]));
  shiftOut(SER,CLK,LSBFIRST,highByte(RF[ind]));
  digitalWrite(LATCH,HIGH);
  delayMicroseconds(10); 
  digitalWrite(LATCH,LOW);  
}

void DDSinitialization(){
  //First: hard-reset DDS
  digitalWrite(RESETDDS,HIGH);
  delay(1);
  digitalWrite(RESETDDS,LOW);
  delay(10); 

  //Second: the reset has set everything to the default state, but we will ensure that
  // the control function register No.1 is set to zeros.
  // registerInfo is a 2-element array which contains [register, number of bytes]
  // data is a registerInfo-element array which contains the bytes to be written. 
  // CFR1<1>=1. The SYNC_CLK pin inactive to keep digital noise at minimum.
  // CFR1<9>=1. SDIO pin configured as input-only pin (3-wire serial programming mode).
  byte registerInfo[]={0x00,4};
  byte data[]={0x00,0x00,0x02,0x02}; //We are in MSB mode, hence, the first 0x00 corresponds to bit range  31:24 bits.
  writeRegister(registerInfo,data);
  
  //Third: set a 400Mhz clock with the 25Mhz crystal of the board.
  //Since there is a 25Mhz crystal, it is necessary a 16x multiplier.
  //To do so, it is necessary to write the control function register No.2
  //The third byte is the most important (corresponding to the bit range: 7:0
  //the last 5 bits set the REFCLK multiplier. In our case we have set a 16x, hence: 10000
  //The 3rd bit is used to control the range setting on the VCO. 
  //When it is ==1, the VCO operates in a range of 250 MHz to 400 MHz.
  //The 1st and 2nd bits are useless in this application.
  byte registerInfoR[]={0x01,3};
  byte dataR[]={0x00,0x00,0x84}; 
  writeRegister(registerInfoR,dataR);
}



//Writes SPI to particular register.
// registerInfo is a 2-element array which contains [register, number of bytes]
// data is a registerInfo[1]-element array which contains the bytes to be written in the register.
void writeRegister(byte registerInfo[], byte data[]){
  digitalWrite(CSB,LOW);
  //Writes the register value
  SPI.transfer(registerInfo[0]);
  //Writes the data
  for(int i = 0; i < registerInfo[1]; i++){
    SPI.transfer(data[i]);
  }
  digitalWrite(CSB,HIGH);
  //update
  digitalWrite(IOUP,HIGH);
  delayMicroseconds(5); 
  digitalWrite(IOUP,LOW);
}


//Sends the command to the DDS to output the frequency "freq" (in Hz)
//The command is the Frequency tunning word that has to be written in the 0x04 register.
void setFreq(unsigned long freq){
  unsigned long _ftw=freq*factorWord;
  byte ftw[]={
    lowByte(_ftw>>24),lowByte(_ftw>>16),lowByte(_ftw>>8),lowByte(_ftw) };
  //write four bytes to register 0x04
  byte registerInfo[]={0x04,4};
  writeRegister(registerInfo,ftw);
}



void processIncomingByte(const byte inByte){
  // Variables declared as static will only be created and initialized the first time a function is called
  static char input_line [MAX_INPUT]; 
  static unsigned int input_pos = 0;

  switch (inByte)
  {
  case '\n':   // end of text
    input_line[input_pos] = 0;  // terminating null byte
    process_data(input_line);
    input_pos = 0;  // reset buffer for next time
    break;

  case '\r':   // discard carriage return
    break;

  default:
    // keep adding if not full ... allow for terminating null byte
    if (input_pos < (MAX_INPUT - 1))
      input_line [input_pos++] = inByte;
    break;
  }  // end of switch
} // end of processIncomingByte  


// To process incoming serial data after a terminator received
void process_data (const char * data){
  String mensaje = String(data);
  int lenData=mensaje.length();        //length of the received message.
  boolean messOK=false;          //Flag to indicate that the received message is correct.
  unsigned long receivedFreq=0;    // the frequency that the DDS has to output.
  int RFout = 0;              //The signal will be emitted from RF output RFout
  int sensorValue=0;             //value obtained from the sensorPin
  
  
  
  //Check the format of the message.
  //It has to be: <··#·····> , where the number of charaters between < and # is between 1 and 2, and after is between 1 and 5
  int sep = mensaje.indexOf('#'); // Find the separator. If not found sep=-1. 
  if(lenData>4 && lenData<11 && sep>-1 && mensaje.charAt(0)=='<' && mensaje.charAt(lenData-1)=='>'){
    //Check that the characters corresponding to the frequency are valid numbers and obtain the frequency.
    for (int i=sep+1;i<lenData-1;i++){
      switch(mensaje.charAt(i))
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
        receivedFreq *= 10;
        receivedFreq += mensaje.charAt(i) - '0';
        break;
      }
    }
    //Check that the characters corresponding to the RFout are valid numbers and obtain the number.
    for (int i=1;i<sep;i++){
      switch(mensaje.charAt(i))
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
        RFout *= 10;
        RFout += mensaje.charAt(i) - '0';
        break;
      }
    }
   
    //Check that:
    //1) The received frequency is in the range [1 ... 199,999] KHz 
    //2) The received RF output is in the range [0 ... 18]
    if(receivedFreq>0 && receivedFreq<=199999 && RFout>=0 && RFout<19){
      messOK=true;
    }
    
  } //end of If: check format

  if(messOK){
  
    //The format of the message is correct, the RFout is correct, and the frequency is valid.
    //Set the RF output. if RFout=0 then there is no output.
    ActivateSwitch(RFout);
    //Set the frequency, read the sensor value and send the response
    receivedFreq = receivedFreq*1000;
    setFreq(receivedFreq);
    delay(2);
    sensorValue = analogRead(SENSOR);

    Serial.print("<");
    Serial.print(RFout);
    Serial.print("#");
    Serial.print(receivedFreq/1000);
    Serial.print(":");
    Serial.print(sensorValue);
    Serial.println(">");
  }
  else{
    Serial.print("Bad ");
    Serial.println(mensaje);
  }
}  // end of process_data
