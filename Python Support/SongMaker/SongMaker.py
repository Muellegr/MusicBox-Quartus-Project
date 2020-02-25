#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import print_function
import scipy.io.wavfile as wavfile
import scipy
import scipy.fftpack
import numpy as np
from matplotlib import pyplot as plt

fs_rate, signal = wavfile.read('test.wav')
print ("Frequency sampling", fs_rate)
l_audio = len(signal.shape)
print ("Channels", l_audio)
if l_audio == 2:
    signal = signal.sum(axis=1) / 2
N = signal.shape[0]
print ("Complete Samplings N", N)
secs = N / float(fs_rate)
print ("secs", secs)
Ts = 1.0/fs_rate # sampling interval in time
print ("Timestep between samples Ts", Ts)


t = scipy.arange(0, secs, Ts) # time vector as scipy arange field / numpy.ndarray

FFT = abs(scipy.fft(signal))

FFT_side = FFT[range(N/2)] # one side FFT range
print("  T1 - t0 : %s "%( t[1]-t[0]))
freqs = scipy.fftpack.fftfreq(signal.size, t[1]-t[0])

fft_freqs = np.array(freqs)

freqs_side = freqs[range(N/2)] # one side frequency range
#This displas f

#At 5*FREQ   so highest value in FFT_side / 5



# print("freqs_side : %s"%freqs_side[0:100])

# print("FFT_side : %s"%abs(FFT_side)[3000])


songSectionSize = 0.1 #length of each section in seconds
songSectionSamples = int(fs_rate * songSectionSize) #How many sample points exist per section
#freqStepSize =1 / freqs_side[1] #Multiply with index to get appropriate frequency.

# input("test1")
for i in range(0,int( int(float(secs) / float(songSectionSize)) - 1 )):
    print("Section %s  from [%s : %s]"%(i, (i * songSectionSamples), ((i + 1) * songSectionSamples)))
    songSection = signal[ i * int(songSectionSamples) : (i+1) * int(songSectionSamples) ]

    N = songSection.shape[0]
    FFT = abs(scipy.fft(songSection))

    FFT_side = FFT[range(N/2)] # one side FFT range

    freqs = scipy.fftpack.fftfreq(songSection.size, t[1]-t[0])
    fft_freqs = np.array(freqs)
    freqs_side = freqs[range(N/2)]

    fft_freqs_side = np.array(freqs_side)
    freqStepSize =1 / freqs_side[1] #Multiply with index to get appropriate frequency.
    indexMax = np.argmax(abs(FFT_side))
    print("     Max frequency : %s " % (indexMax / freqStepSize))
    print("     Max value : %s " % abs(FFT_side[indexMax]))
    #songSection = signal[0 : 50]
    #print("hi")


input("COMPLETE")

fft_freqs_side = np.array(freqs_side)
 

print("stepSize : %s" %freqStepSize ) 
indexMax = np.argmax(abs(FFT_side))
print("Max frequency : %s " % (indexMax / freqStepSize))
print("Max value : %s " % abs(FFT_side[indexMax]))

FFT_side[indexMax-50:indexMax+50] = 0
indexMax = np.argmax(abs(FFT_side))
print("2nd frequency : %s " % (indexMax / freqStepSize))
print("2nd value : %s " % abs(FFT_side[indexMax]))

FFT_side[indexMax-50:indexMax+50] = 0
indexMax = np.argmax(abs(FFT_side))
print("3rd frequency : %s " % (indexMax / freqStepSize))
print("3rd value : %s " % abs(FFT_side[indexMax]))


#(max(abs(FFT_side))))

plt.subplot(311)
p1 = plt.plot(t, signal, "g") # plotting the signal
plt.xlabel('Time')
plt.ylabel('Amplitude')
plt.subplot(312)
p2 = plt.plot(freqs, FFT, "r") # plotting the complete fft spectrum
plt.xlabel('Frequency (Hz)')
plt.ylabel('Count dbl-sided')
plt.subplot(313)
p3 = plt.plot(freqs_side, abs(FFT_side), "b") # plotting the positive fft spectrum
plt.xlabel('Frequency (Hz)')
plt.ylabel('Count single-sided')
plt.show()

input("Press any key to exit")
# def minmaxloc(num_list):
#     return np.argmin(num_list), np.argmax(num_list)
# A= [1,1,8,7,5,9,6,9]
# print(minmaxloc(A))