//////////////////////////////////////////////////////////////////
////       Set up pins used for rows and columns     |  |  |  |
const int row0 = 4;  //PORTD                      --------------- R0
const int row1 = 5;  //  |  |  |  |
const int row2 = 6;  // --------------- R1
const int row3 = 7;  //  |  |  |  |
const int col0 = 8;  //PORTB                      --------------- R2
const int col1 = 9;  //   |  |  |  |
const int col2 = 10; //  _____ R3
const int col3 = 11; //  C0 C1 C2 C3

////////////////////////////////////////////////////////////////

void printArray(int (*array)[4]);
bool compare(int (*A0)[4], int (*A1)[4]);
void keypadScan(int (*CC)[4]);              // This function will scan the keypad until a key is pressed and store it in the array passed into it
void copyArray(int (*A0)[4], int (*A1)[4]); // Copy the array elemnts so that A0 = A1
void coordinates(int (*array)[4], int select);
bool gestureTime_done = false;

int temp0[4][4] = {{1, 1, 1, 1}, //array to store temporary values
                   {1, 1, 1, 1},
                   {1, 1, 1, 1},
                   {1, 1, 1, 1}};
int temp1[4][4];
int temp2[4][4];
int temp3[4][4];

int tempCheck[4][4];

int megaArray[4][4][4];

unsigned long time0 = 0;
unsigned long time1 = 0;

int x0, x1, y0, y1 = 0;

void setup()
{

  pinMode(row0, OUTPUT);
  pinMode(row1, OUTPUT);
  pinMode(row2, OUTPUT);
  pinMode(row3, OUTPUT);

  pinMode(col0, INPUT_PULLUP);
  pinMode(col1, INPUT_PULLUP);
  pinMode(col2, INPUT_PULLUP);
  pinMode(col3, INPUT_PULLUP);

  PORTD = B00000000; // Sets all pins in PORTD to GND

  // initialize serial communications at 9600 bps:

  Serial.begin(9600);
}

void loop()
{
 // keypadScan(temp0);

 

  bool change = false;
  gestureTime_done = false;

  while (1)
  {
    copyArray(tempCheck, temp0);
    keypadScan(temp0);
    if (gestureTime_done)
    {

      change = compare(tempCheck, temp0); //If theres a change this returns true
      if (change)
      {
        Serial.println("Array 0 ");
        printArray(temp0);
        break;
      }
      else
      {
        break;
      }
    }

    else
    {
      Serial.println("Array 0 ");
      printArray(temp0);
      delay(5);
      keypadScan(temp1);
      delay(5);
      if (gestureTime_done)
      {

        break;
      }

      else
      {
        Serial.println("Array 1 ");
        printArray(temp1);

        coordinates(temp0, 0);
        Serial.print("A0 = (");
        Serial.print(x0);
        Serial.print(", ");
        Serial.print(y0);
        Serial.println(") ");
        coordinates(temp1, 1);
        Serial.print("A1 = (");
        Serial.print(x1);
        Serial.print(", ");
        Serial.print(y1);
        Serial.println(") ");

        if (y1 > y0)
        {
          Serial.println(" ");
          Serial.println("You swiped right!");
        }

        else if (y1 < y0)
        {
          Serial.println(" ");
          Serial.println("You swiped left!");
        }

        if (x1 > x0)
        {
          Serial.println(" ");
          Serial.println("You swiped up!"); //Janette Added this for swipping up or down
        }

        else if (y1 < x0)
        {
          Serial.println(" ");
          Serial.println("You swiped down!"); //Janette Added this for swipping up or down
        }
         if (x1 > x0)
        {
          Serial.println(" ");
          Serial.println("You swiped up!"); //Janette Added this for swipping up or down
        }

        else if (y1 < x0)
        {
          Serial.println(" ");
          Serial.println("You swiped down!"); //Janette Added this for swipping up or down
        }
      }
    }
  }
}

void keypadScan(int (*CC)[4])
{

  bool change = false;      // variable that is true when a change in he keypad is detected
  bool change_zero = false; // goes true if the new matrix is a zero state matrix

  //Serial.println("1");
  char Row[4] = {0xE0, 0xD0, 0xB0, 0x70};    //preset Row outputs to cyle wich one to ground
  char RowDIR[4] = {0x10, 0x20, 0x40, 0x80}; // Array used to set only one Row as output at a time
                                             // 1 = output, 0 = input

  int tempArray0[4][4] = {{1, 1, 1, 1}, //array to store temporary values
                          {1, 1, 1, 1},
                          {1, 1, 1, 1},
                          {1, 1, 1, 1}};
  int tempArray1[4][4] = {{1, 1, 1, 1}, //array to store temporary values
                          {1, 1, 1, 1},
                          {1, 1, 1, 1},
                          {1, 1, 1, 1}};
  int tempArray2[4][4] = {{1, 1, 1, 1}, //array to store temporary values
                          {1, 1, 1, 1},
                          {1, 1, 1, 1},
                          {1, 1, 1, 1}};

  unsigned long time_start = millis();

  while (true)
  {

    if ((millis() - time_start > 2000))
    {
      gestureTime_done = true;
      return;
    }
    //-----------------------------------------------------------------------------------------------------------------------
    for (int i = 0; i < 4; i++)
    {

      DDRD = DDRD | RowDIR[i]; //Bit-wise or, to prevent overwriting to the serial communication pins
      PORTD = Row[i];
      //Serial.println("2");
      //delay(200);
      for (int j = 0; j < 4; j++)
      {

        tempArray0[i][j] = digitalRead(j + 8); // The Columns are connected to pins 8-13 so an offset of 8 is added

        //Serial.println("3");
      }
    }
    delay(50);
    //-----------------------------------------------------------------------------------------------------------------------
    for (int i = 0; i < 4; i++)
    {

      DDRD = DDRD | RowDIR[i]; //Bit-wise or, to prevent overwriting to the serial communication pins
      PORTD = Row[i];
      //Serial.println("2");
      //delay(200);
      for (int j = 0; j < 4; j++)
      {

        tempArray1[i][j] = digitalRead(j + 8); // The Columns are connected to pins 8-13 so an offset of 8 is added

        //Serial.println("3");
      }
    }

    //------------------------------------------------------------------------------------------------------------------------

    change = compare(tempArray0, tempArray1); // Compare the last 2 stored temporary arrays

    if (change)
    { // If there is a change then copy the last array into a global array and returns
      change_zero = compare(tempArray1, tempArray2);

      if (change_zero)
      {

        for (int i = 0; i < 4; i++)
        {

          for (int j = 0; j < 4; j++)
          {

            CC[i][j] = tempArray1[i][j];
          }
        }
        //printArray(temp0);
        change = false;
        change_zero = false;

        return;
      }

      else
      {
        change = false;
        change_zero = false;
      }
    }

    else
    {
      change = false;
      change_zero = false;
    }
  }
}

void printArray(int (*array)[4])
{

  for (int i = 0; i < 4; i++)
  {
    Serial.println(" ");
    for (int j = 0; j < 4; j++)
    {
      Serial.print(array[i][j]);
      Serial.print(" ");
    }
  }
  Serial.println("       ");
}

bool compare(int (*A0)[4], int (*A1)[4])
{ //compares arrays and returns true if there is a change
  int count = 0;

  for (int i = 0; i < 4; i++)
  {

    for (int j = 0; j < 4; j++)
    {

      if (A0[i][j] != A1[i][j])
      {
        count++;
      }
    }
  }

  if (count == 1)
  {

    return true;
  }

  else
  {

    return false;
  }
}

void copyArray(int (*A0)[4], int (*A1)[4])
{

  for (int i = 0; i < 4; i++)
  {

    for (int j = 0; j < 4; j++)
    {

      A0[i][j] = A1[i][j];
    }
  }
}

void coordinates(int (*array)[4], int select)
{

  for (int i = 0; i < 4; i++)
  {

    for (int j = 0; j < 4; j++)
    {

      if (array[i][j] == 0)
      {
        if (select == 0)
        {
          x0 = i;
          y0 = j;
        }
        else
        {
          x1 = i;
          y1 = j;
        }
      }
    }
  }
}
