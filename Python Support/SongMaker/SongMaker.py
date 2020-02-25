#!/usr/bin/env python
# -*- coding: utf-8 -*-
#LEFT OFF : Do FFT on whole song, find highest amplitude and save.  This will be used for getting ideal amplitude. 
#At point I can collect multiple frequencies and amplitudes.   Close to needing to write the infractructure for it.
#Replace values near frequency with 0 so we ignore it for subsequent values.   FREQSTOIGNORE * freqStepSize + / -
#Maybe add ovelrap between samples 


#Have several arrays of frequencies and amplitudes set up, go through and create third with average value converted to binary

#Write to files in easy format


from __future__ import print_function
import scipy.io.wavfile as wavfile
import scipy
import scipy.fftpack
import numpy as np
from matplotlib import pyplot as plt

volumeAdjustment = 1.0 #0 to 1 for amplitude multiplier

#Gets the sampling rate and a array containing all points of the song.  44100Hz sampling rate = 44100 amplitudes per second
fs_rate, signal = wavfile.read('test.wav')
print ("Frequency sampling", fs_rate)

#Handles channels.  We only want 1 channel.
l_audio = len(signal.shape)
print ("Channels", l_audio)
if l_audio == 2:
    signal = signal.sum(axis=1) / 2

#N is left(??) channel count of samples.
N = signal.shape[0]
print ("Complete Samplings N", N)

#How long the track is
secs = N / float(fs_rate)
print ("secs", secs)

#Time between each sample
Ts = 1.0/fs_rate # sampling interval in time
print ("Timestep between samples Ts", Ts)

#Array containing all time points
t = scipy.arange(0, secs, Ts) # time vector as scipy arange field / numpy.ndarray

# FFT = abs(scipy.fft(signal))

# FFT_side = FFT[range(N/2)] # one side FFT range
# print("  T1 - t0 : %s "%( t[1]-t[0]))
# freqs = scipy.fftpack.fftfreq(signal.size, t[1]-t[0])

# fft_freqs = np.array(freqs)

# freqs_side = freqs[range(N/2)] # one side frequency range

# indexMax = np.argmax(abs(FFT_side[50: (len(FFT_side)-50 )]))
# songMaxAmplitude =FFT_side[indexMax]
# print("indexMax : %s " %indexMax)
# print("Max value of whole FFT : %s "% songMaxAmplitude);


#At 5*FREQ   so highest value in FFT_side / 5



# print("freqs_side : %s"%freqs_side[0:100])

# print("FFT_side : %s"%abs(FFT_side)[3000])

#How much each song is broken down by
songSectionSize = 0.1 #length of each section in seconds
songSectionSamples = int(fs_rate * songSectionSize) #How many sample points exist per section
#freqStepSize =1 / freqs_side[1] #Multiply with index to get appropriate frequency.

# input("test1")

#Break 

#How many frequencies and amplitudes we pull from the song per songSectionSize
mainFrequenciesToGrabCount = 5 
mainFrequenciesArray = [[] for y in range(mainFrequenciesToGrabCount)]
mainRawAmplitudesArray = [[] for y in range(mainFrequenciesToGrabCount)]
mainFixedAmplitudesArray = [[] for y in range(mainFrequenciesToGrabCount)]
maxAmplitude = 0

# mainFrequenciesArray = np.array(0)
# for i in range(0, mainFrequenciesToGrabCount):
#     mainFrequenciesArray.ammend(np.array(0))
#     print("array length: %i" % (mainFrequenciesArray.size))

for i in range(1,int( int(float(secs) / float(songSectionSize)) - 2 )):
    #print("Section %s  from [%s : %s]"%(i, (i * songSectionSamples), ((i + 1) * songSectionSamples)))
    songSection = signal[ i * int(songSectionSamples) : (i+1) * int(songSectionSamples) ]

    N = songSection.shape[0]
    FFT = abs(scipy.fft(songSection))

    FFT_side = FFT[range(N/2)] # one side FFT range

    freqs = scipy.fftpack.fftfreq(songSection.size, t[1]-t[0])
    fft_freqs = np.array(freqs)
    freqs_side = freqs[range(N/2)]

    fft_freqs_side = np.array(freqs_side)
    freqStepSize =1 / freqs_side[1] #Multiply with index to get appropriate frequency.


    #indexMax = np.argmax(abs(FFT_side))
    #print("     Max frequency : %s " % (indexMax / freqStepSize))
    #print("     Max value : %s " % (  (float(abs(FFT_side[indexMax]))   )))
     
    #Keep track of major frequencies and amplitudes
    for j in range(0, mainFrequenciesToGrabCount):

        abs_FFT_side = abs(FFT_side)
        indexMax = np.argmax(abs_FFT_side)
       # print("     index max : %s" %indexMax)
        mainFrequenciesArray[j].append( (indexMax / freqStepSize))
        mainRawAmplitudesArray[j].append((float(abs_FFT_side[indexMax])   ))
        if (float(abs(FFT_side[indexMax])) > maxAmplitude) : 
            maxAmplitude = float(abs_FFT_side[indexMax])

        #print("  val at index before : %s " % FFT_side[indexMax])
        #FFT_side[indexMax-int(5*freqStepSize) : indexMax+int(5*freqStepSize)] = 0
        #FFT_side[indexMax] = 0
        #
       # print(int(5 /freqStepSize))
       # print(freqStepSize)
        for k in range(indexMax - int(5 / freqStepSize), indexMax + int(5 /freqStepSize) ):
            FFT_side[k] = 0
            #print("Freq val %s" %(k /freqStepSize ) )
            #print(k)

        #print("  val at index after : %s " % FFT_side[indexMax])

    #print("     Avg value : %s " % (  (float(abs(FFT_side[indexMax])) / (songMaxAmplitude )) * 255    ))
    #songSection = signal[0 : 50]
    #print("hi")


for i in range(0, len(mainFrequenciesArray[0])):
    print("index %i" % i)
    for j in range(0, len(mainFrequenciesArray)):
        mainFixedAmplitudesArray[j].append( int (   (float (mainRawAmplitudesArray[j][i])  / float(maxAmplitude))  * 255 * volumeAdjustment) )
        print("     [%i] freq :%i " %(j, mainFrequenciesArray[j][i]))
        print("     [%i] raw :%i " %(j, mainRawAmplitudesArray[j][i]))
        print("     [%i] fix :%i " %(j, mainFixedAmplitudesArray[j][i]))
        print("  ---")

#NEXT STEP : Create module that will handle this
input("COMPLETE")

# fft_freqs_side = np.array(freqs_side)
 

# print("stepSize : %s" %freqStepSize ) 
# indexMax = np.argmax(abs(FFT_side))
# print("Max frequency : %s " % (indexMax / freqStepSize))
# print("Max value : %s " % abs(FFT_side[indexMax]))

# FFT_side[indexMax-50:indexMax+50] = 0
# indexMax = np.argmax(abs(FFT_side))
# print("2nd frequency : %s " % (indexMax / freqStepSize))
# print("2nd value : %s " % abs(FFT_side[indexMax]))

# FFT_side[indexMax-50:indexMax+50] = 0
# indexMax = np.argmax(abs(FFT_side))
# print("3rd frequency : %s " % (indexMax / freqStepSize))
# print("3rd value : %s " % abs(FFT_side[indexMax]))


# #(max(abs(FFT_side))))

# plt.subplot(311)
# p1 = plt.plot(t, signal, "g") # plotting the signal
# plt.xlabel('Time')
# plt.ylabel('Amplitude')
# plt.subplot(312)
# p2 = plt.plot(freqs, FFT, "r") # plotting the complete fft spectrum
# plt.xlabel('Frequency (Hz)')
# plt.ylabel('Count dbl-sided')
# plt.subplot(313)
# p3 = plt.plot(freqs_side, abs(FFT_side), "b") # plotting the positive fft spectrum
# plt.xlabel('Frequency (Hz)')
# plt.ylabel('Count single-sided')
# plt.show()

#input("Press any key to exit")
# def minmaxloc(num_list):
#     return np.argmin(num_list), np.argmax(num_list)
# A= [1,1,8,7,5,9,6,9]
# print(minmaxloc(A))