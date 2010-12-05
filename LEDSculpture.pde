/* Properties
_________________________________________________________________ */

int NUM_BOXES = 64;
char identifier = '*';

int colors[64] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

boolean state[64] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

/* Shiftbrite Properties
_________________________________________________________________ */

int datapin  = 3; // DI
int latchpin = 4; // LI
int enablepin = 5; // EI
int clockpin = 6; // CI
unsigned long SB_CommandPacket;

int SB_CommandMode;
int SB_BlueCommand;
int SB_RedCommand;
int SB_GreenCommand;

/* Setup
 _________________________________________________________________ */

void setup() 
{
  Serial.begin(9600);

  setupPins();
}

/* Loop
 _________________________________________________________________ */

void loop() 
{
  if(checkSerial())
  {
    for(int i = 0; i < NUM_BOXES; i++)
    {
      SB_CommandMode = B01; // Write to current control registers
      SB_RedCommand = 127; // Full current
      SB_GreenCommand = 127; // Full current
      SB_BlueCommand = 127; // Full current
      SB_SendPacket();
    }

    delayMicroseconds(15);
    digitalWrite(latchpin, HIGH);
    delayMicroseconds(15);
    digitalWrite(latchpin, LOW);

    for(int i = 0; i < NUM_BOXES; i++)
    {
      SB_CommandMode = B00; // Write to PWM control registers
      SB_RedCommand = getRedFromInt(colors[i]); // red
      SB_GreenCommand = getGreenFromInt(colors[i]); // green
      SB_BlueCommand = getBlueFromInt(colors[i]); // blue
      SB_SendPacket();
    }

    delayMicroseconds(15);
    digitalWrite(latchpin,HIGH);
    delayMicroseconds(15);
    digitalWrite(latchpin,LOW);

    delay(100);
  }
}

/* Get colors
 ______________________________________________________________________*/
 
int getRedFromInt(int c)
{
    switch(c)
    {
      case 0:
        return 255;
        break;
      case 1:
        return 0;
        break; 
      case 2:
        return 46;
        break;
      case 3:
        return 252;
        break;
      case 4:
        return 102;
        break;
      case 5:
        return 41;
        break;
      case 6:
        return 255;
        break;
      case 7:
        return 251;
        break;
      default:
        return 255;      
    }
}

int getGreenFromInt(int c)
{
    switch(c)
    {
      case 0:
        return 0;
        break;
      case 1:
        return 104;
        break; 
      case 2:
        return 49;
        break;
      case 3:
        return 238;
        break;
      case 4:
        return 45;
        break;
      case 5:
        return 171;
        break;
      case 6:
        return 0;
        break;
      case 7:
        return 176;
        break;
      default:
        return 255;      
    }
}

int getBlueFromInt(int c)
{
    switch(c)
    {
      case 0:
        return 0;
        break;
      case 1:
        return 55;
        break; 
      case 2:
        return 146;
        break;
      case 3:
        return 33;
        break;
      case 4:
        return 145;
        break;
      case 5:
        return 226;
        break;
      case 6:
        return 255;
        break;
      case 7:
        return 59;
        break;
      default:
        return 255;      
    }
}

/* Check message
 ______________________________________________________________________*/

boolean checkSerial()
{ 
  if(Serial.available() >= 193) 
  {
    int firstByte = Serial.read();

    if(firstByte == identifier) 
    {
      // read all the serial: Serial.read();

      return true;
    }
  }

  return false;
}

/* ShiftBrite setup
 _________________________________________________________________ */

void setupPins()
{
  pinMode(datapin, OUTPUT);
  pinMode(latchpin, OUTPUT);
  pinMode(enablepin, OUTPUT);
  pinMode(clockpin, OUTPUT);

  digitalWrite(latchpin, LOW);
  digitalWrite(enablepin, LOW);
}

/* Send packet
 _________________________________________________________________ */

void SB_SendPacket() 
{
  SB_CommandPacket = SB_CommandMode & B11;
  SB_CommandPacket = (SB_CommandPacket << 10)  | (SB_BlueCommand & 1023);
  SB_CommandPacket = (SB_CommandPacket << 10)  | (SB_RedCommand & 1023);
  SB_CommandPacket = (SB_CommandPacket << 10)  | (SB_GreenCommand & 1023);

  shiftOut(datapin, clockpin, MSBFIRST, SB_CommandPacket >> 24);
  shiftOut(datapin, clockpin, MSBFIRST, SB_CommandPacket >> 16);
  shiftOut(datapin, clockpin, MSBFIRST, SB_CommandPacket >> 8);
  shiftOut(datapin, clockpin, MSBFIRST, SB_CommandPacket);

  //delay(1); // adjustment may be necessary depending on chain length
  //digitalWrite(latchpin,HIGH); // latch data into registers
  //delay(1); // adjustment may be necessary depending on chain length
  //digitalWrite(latchpin,LOW);
}

