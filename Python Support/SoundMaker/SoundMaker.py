#!/usr/bin/env python
# -*- coding: utf-8 -*-
#LEFT OFF : Do FFT on whole song, find highest amplitude and save.  This will be used for getting ideal amplitude. 
#At point I can collect multiple frequencies and amplitudes.   Close to needing to write the infractructure for it.
#Replace values near frequency with 0 so we ignore it for subsequent values.   FREQSTOIGNORE * freqStepSize + / -
#Maybe add ovelrap between samples 


#Have several arrays of frequencies and amplitudes set up, go through and create third with average value converted to binary

#Write to files in easy format

#TODO : Add normalizer 
    #Adds raw powers per step together, looking for max
    #I think this would just replace 
    #Maybe just a flat 1/3 ?  It will be loud enough as is. 
    #Or 1/n   Worst case they add up to 255, or rough worst case (we aren't feeding it noise to exploit it)
        #may need fine tuning



from __future__ import print_function
import scipy.io.wavfile as wavfile
import scipy
import scipy.fftpack
import numpy as np
from matplotlib import pyplot as plt

volumeAdjustment = 0.5 #0 to 1 for amplitude multiplier

songName = 'Test1.wav'
#Gets the sampling rate and a array containing all points of the song.  44100Hz sampling rate = 44100 amplitudes per second
fs_rate, signal = wavfile.read(songName)
print ("Frequency sampling", fs_rate)

#Handles channels.  We only want 1 channel.
l_audio = len(signal.shape)
print ("Channels", l_audio)
if l_audio == 2:
    signal = signal.sum(axis=1) / 2

print ("song : %s \n" , signal)
#N is left(??) channel count of samples.
N = signal.shape[0]
print ("Complete Samplings N", N)


f = open("soundFormattedOutput.txt", "w")
#f.write('assign %s[%i] = 8\'b%s;\n'%(varName, i, b) )

f.write('//COPY PASTE FROM FILE STARTING ON THIS LINE DOWNWARD. INCLUDE ENDMODULE\n')
f.write('bit [%i:0][7:0] soundFileAmplitudes;\n\n' %(int(N)   )) 

f.write('//-=-=-=-=-SONG DATA-=-=-=-=- \n')

for i in range(0, N):
    #print("index %i" % i)

	#assign songFrequencies[0][0] = dah
	f.write('   assign soundFileAmplitudes [%i] = 8\'d%i;\n' %( i , signal[i] * 128 + 128 ) )


	#* 0.7  as rough reducer.  Technically multiple of these can add up past 255.  This is a sort of weak normalize rfor it.
	#mainFixedAmplitudesArray[j].append( int (   (float (mainRawAmplitudesArray[j][i])  / float(maxAmplitude ) * 0.7 )  * 255 * volumeAdjustment) )
	#print("     [%i] freq :%i " %(j, mainFrequenciesArray[j][i]))
	#print("     [%i] raw :%i " %(j, mainRawAmplitudesArray[j][i]))
	#print("     [%i] fix :%i " %(j, mainFixedAmplitudesArray[j][i]))


f.write('endmodule\n')
f.close()
input("exit..")
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