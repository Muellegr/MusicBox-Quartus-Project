/*
 * Filename: pianoTone.ino
 * Author: Tristan Luther
 * Date: 3/3/2020
 * Purpose: Sends frequency and amplitude of chosen piano note
 * to be sent to a DE10 Lite for subsitution of the Max10 
 * Pollen Board
 */
 
/********************** Includes/Macros **********************/
#include <SPI.h>

/********************** Globals ***********************/
//Piano notes for notes in our exepected frequency range (100Hz - 5000Hz)
#define A2 110
#define A#2 117
#define B2 123
#define C3 131
#define C#3 139
#define D3 147
#define D#3 156
#define E3 165
#define F3 175
#define F#3 185
#define G3 196
#define G#3 208
#define A3 220
#define A#3 233
#define B3 247
#define C4 262
#define C#4 277
#define D4 294
#define D#4 311
#define E4 330
#define F4 350
#define F#4 370
#define G4 392
#define G#4 415
#define A4 440
#define A#4 466
#define B4 493
#define C5 523
#define C#5 554
#define D5 587
#define D#5 622
#define E5 659
#define F5 698
#define F#5 740
#define G5 784
#define G#5 831
#define A5 880
#define A#5 932
#define B5 988
#define C6 1047
#define C#6 1108
#define D6 1175
#define D#6 1245
#define E6 1319
#define F6 1397
#define F#6 1480
#define G6 1568
#define G#6 1661
#define A6 1760
#define A#6 1865
#define B6 1975
#define C7 2093
#define C#7 2217
#define D7 2349
#define D#7 2489
#define E7 2637
#define F7 2794
#define F#7 2960
#define G7 3136
#define G#7 3322
#define A7 3520
#define A#7 3729
#define B7 3951
#define C8 4186
#define C#8 4435
#define D8 4699
#define D#8 4978

/***************** Functions *************************/
void writeFreq(uint16_t frequency) {
  //Shift the first bit into the amplitude and frequency so it can be read
  frequency |= (0 << 13);
  //This sets the 
  // take the SS pin low to select the chip:
  digitalWrite(SS, LOW);
  //Send the value via SPI:
  SPI.transfer16(frequency);
  // take the SS pin high to de-select the chip:
  digitalWrite(SS, HIGH);
}

void writeAmp(uint16_t amplitude) {
  //Shift the first bit into the amplitude and frequency so it can be read
  amplitude |= (1 << 13);
  //This sets the 
  // take the SS pin low to select the chip:
  digitalWrite(SS, LOW);
  //Send the value via SPI:
  SPI.transfer16(amplitude);
  // take the SS pin high to de-select the chip:
  digitalWrite(SS, HIGH);
}

/***************** Setup **************************/
void setup() {
   //Initalize the I/O & Begin Serial
  Serial.begin(9600);
  //Initialize SPI
  SPI.begin();
  SPI.setClockDivider(SPI_CLOCK_DIV128);    //Sets clock for SPI communication at 8 (16/8=2Mhz)
  digitalWrite(SS,HIGH);                  // Setting SlaveSelect as HIGH (So master doesnt connnect with slave)
}

/****************** Loop ************************/
void loop() {
  //Assign frequency and amplitude of waveform
  uint16_t frequency = G7;
  uint16_t amplitude = 100;
  writeFreq(frequency); //Send that out over SPI 
  writeAmp(amplitude); //Send that out over SPI 
}
