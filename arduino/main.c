
//////////////////////////////////////////////////////////////////
//// Set up pins used for rows and columns     |  |  |  |
 int row0 = 4;   //PORTD                      --------------- R0
 int row1 = 5;                             //  |  |  |  | 
 int row2 = 6;                             // --------------- R1
 int row3 = 7;                             //  |  |  |  |
 int col0 = 8;   //PORTB                      --------------- R2
 int col1 = 9;                            //   |  |  |  |
 int col2 = 10;                           //  _______________ R3
 int col3 = 11;                           //  C0 C1 C2 C3

////////////////////////////////////////////////////////////////



void setup() {

  pinMode(row0, OUTPUT);
  pinMode(row1, OUTPUT);
  pinMode(row2, OUTPUT);
  pinMode(row3, OUTPUT);

  pinMode(col0, INPUT);
  pinMode(col1, INPUT);
  pinMode(col2, INPUT);
  pinMode(col3, INPUT);

  PORTD = B00000000; // Sets all pins in PORTD to GND
  // initialize serial communications at 9600 bps:
  Serial.begin(9600);
  
}

void loop() {
  
  

  keypadScan();

  
}

void keypadScan(){

  //Serial.println("1");
  char Row[4] = {0x70, 0xB0, 0xD0, 0xE0}; //preset Row outputs to cyle wich one to ground
  char RowDIR[4] = {0x80, 0x40, 0x20, 0x10}; // Array used to set only one Row as output at a time
                                             // 1 = output, 0 = input
  
  int tempArray[4][4] = { {0,0,0,0},//array to store temporary values 
                          {0,0,0,0},
                          {0,0,0,0},
                          {0,0,0,0}
                        }; 


  for(int i = 0; i < 4; i++){

    DDRD = DDRD | RowDIR[i]; //Bit-wise or, to prevent overwriting to the serial communication pins 
    PORTD = Row[i];
    //Serial.println("2");
    //delay(200);
    for(int j = 0; j < 4; j++){
       
      tempArray[i][j] = digitalRead(j+8);  // The Columns are connected to pins 8-13 so an offset of 8 is added
      //Serial.println("3");
    }
  }

  for(int i = 0; i < 4; i++){
    Serial.println(" ");
    for(int j = 0; j < 4; j++){
  
      Serial.print(tempArray[i][j]);
      Serial.print(" ");
    }
  }
  Serial.println(" ");
   delay(1000);
  

}