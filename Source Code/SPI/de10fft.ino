/*
 * Filename: de10fft.ino
 * Author: Tristan Luther
 * Date: 2/26/2020
 * Purpose: Audio processing via a Fast Fourier Transform
 * to be sent to a DE10 Lite for subsitution of the Max10 
 * Pollen Board
 */
 
/********************** Includes/Macros **********************/
#include <arduinoFFT.h>
#include <SPI.h>

/********************** Globals ***********************/
//Specifications & I/O for Hardware
uint8_t inSigPin = A0; //Audio input
uint8_t ssSpi = 10; //Slave select pin

//Sampling Audio
arduinoFFT FFT = arduinoFFT(); /* Create FFT object */
const uint16_t samples = 64;
const double samplingFrequency = 10000; //Hz, must be less than 10000 due to ADC on ATmega328

unsigned int sampling_period_us;
unsigned long microseconds;

double real[samples];
double imag[samples];

double largest = 0; //Holds the largest amplitude for the frequencies in the array
int largestIndex = 0; //The index in the FFT array that holds the most significant value

long timeStart = 0;

/***************** Functions *************************/
void writeFreq(uint16_t frequency) {
  //Shift the first bit into the amplitude and frequency so it can be read
  frequency |= (0 << 13);
  //This sets the 
  // take the SS pin low to select the chip:
  digitalWrite(SS, LOW);
  //Send the value via SPI:
  SPI.transfer16(0b0000000000000010);
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
  sampling_period_us = round(1000000*(1.0/samplingFrequency)); 
  //Initialize SPI
  SPI.begin();
  SPI.setClockDivider(SPI_CLOCK_DIV128);    //Sets clock for SPI communication at 8 (16/8=2Mhz)
  digitalWrite(SS,HIGH);                  // Setting SlaveSelect as HIGH (So master doesnt connnect with slave)
}

/****************** Loop ************************/
void loop() {
  //Sample the audio
  for(uint16_t i = 0; i < samples; i++){
    real[i] = analogRead(inSigPin);
    imag[i] = 0;
  }
  //Reset these values for the next sampling batch
  largest = 0; //Holds the largest amplitude for the frequencies in the array
  largestIndex = 0; //The index in the FFT array that holds the most significant value
  //Compute the Discrete Fouier Transform to get the frequency domain equivalent
  FFT.Windowing(real, samples, FFT_WIN_TYP_HAMMING, FFT_FORWARD);  /* Weigh data */
  FFT.Compute(real, imag, samples, FFT_FORWARD);
  FFT.ComplexToMagnitude(real, imag, samples); /* Compute magnitudes */

  //Find the frequency with the most substantial amplitude (ignore the first few points; too strong)
   for(int i = 2; i < (samples >> 1); i++){
    //If that amplitude is larger than the current largest/replace it
    if(largest < real[i]){
      largest = real[i];
      largestIndex = i;
    }
  }
  uint16_t abscissa = ((largestIndex * 1.0 * samplingFrequency) / samples);
  //Serial.println(abscissa);
  uint16_t amp = real[largestIndex];
  writeFreq(abscissa); //Send that out over SPI 
  //writeAmp(amp); //Send that out over SPI 
}
