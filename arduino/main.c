const int row0 = 4;
const int row1 = 5;
const int row2 = 6;
const int row3 = 7;
const int col0 = 8;
const int col1 = 9;
const int col2 = 10;
const int col3 = 11;

int temp0[4][4] = {{1, 1, 1, 1}, //array to store temporary values
                   {1, 1, 1, 1},
                   {1, 1, 1, 1},
                   {1, 1, 1, 1}};

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

  // Sets all pins in PORTD to GND
  PORTD = B00000000;

  // initialize serial communications at 9600 bps:
  Serial.begin(9600);
}

void loop()
{
  pollInputs(temp0);

  for (int i = 0; i < 4; i++)
  {

    for (int j = 0; j < 4; j++)
    {

      Serial.write(temp0[i][j]);
    }
  }

  for (int i = 0; i < 4; i++)
  {

    for (int j = 0; j < 4; j++)
    {
      temp0[i][j] = 1;
    }
  }
}

void pollInputs(int (*tempArray0)[4])
{

  char Row[4] = {0xE0, 0xD0, 0xB0, 0x70};    //preset Row outputs to cyle wich one to ground
  char RowDIR[4] = {0x10, 0x20, 0x40, 0x80}; // Array used to set only one Row as output at a time
                                             // 1 = output, 0 = input
  for (int i = 0; i < 4; i++)
  {

    //Bit-wise or, to prevent overwriting to the serial communication pins
    DDRD = DDRD | RowDIR[i];
    PORTD = Row[i];

    for (int j = 0; j < 4; j++)
    {
      // The Columns are connected to pins 8-13 so an offset of 8 is added
      tempArray0[i][j] = digitalRead(j + 8);
    }
  }
}