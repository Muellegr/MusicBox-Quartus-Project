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

volumeAdjustment = 0.7 #0 to 1 for amplitude multiplier

#Gets the sampling rate and a array containing all points of the song.  44100Hz sampling rate = 44100 amplitudes per second
songName = 'SuperMario.wav'
fs_rate, signal = wavfile.read(songName)
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
songSectionSize = 0.05 #length of each section in seconds
songSectionSamples = int(fs_rate * songSectionSize) #How many sample points exist per section
#freqStepSize =1 / freqs_side[1] #Multiply with index to get appropriate frequency.

# input("test1")

#Break 

#How many frequencies and amplitudes we pull from the song per songSectionSize
mainFrequenciesToGrabCount = 3
mainFrequenciesArray = [[] for y in range(mainFrequenciesToGrabCount)]
mainRawAmplitudesArray = [[] for y in range(mainFrequenciesToGrabCount)]
mainFixedAmplitudesArray = [[] for y in range(mainFrequenciesToGrabCount)]
maxAmplitude = 0

# mainFrequenciesArray = np.array(0)
# for i in range(0, mainFrequenciesToGrabCount):
#     mainFrequenciesArray.ammend(np.array(0))
#     print("array length: %i" % (mainFrequenciesArray.size))
indexCount = int( int(float(secs) / float(songSectionSize)) - 2 )

#print("index count : %s " % indexCount)


for i in range(5, indexCount - 5):
    #print("Section %s  from [%s : %s]"%(i, (i * songSectionSamples), ((i + 1) * songSectionSamples)))
    #emptyZeroList = [0]*1000
    #songSection.append('0')
    #print("size1 : %s" % (len(emptyZeroList)))
    #input("before..")
    #for r in range(0, 10) :
        #songSection.append(0)
        #print("test")
    songSection = ( signal[ (i-5) * int(songSectionSamples) : (i+7) * int(songSectionSamples) ])
  #  songSection = songSection + songSection
    print("songSection1 : %s" %len(songSection))
    songSection = songSection + songSection
    print("songSection1 : %s" %len(songSection))

    #input("SUCCESS")
    #songSection = emptyZeroList + songSectiont
   # input ("SUCCESS2")
    N = songSection.shape[0]
    FFT = abs(scipy.fft(songSection))

    FFT_side = FFT[range(int(N/2))] #/2 one side FFT range

    freqs = scipy.fftpack.fftfreq(songSection.size, Ts)#t[1]-t[0])
    #print("0 : %s " % t[0])
    #print("1 : %s " % t[1])
    fft_freqs = np.array(freqs)
    freqs_side = freqs[range(int(N/2))]

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
       # print("freq :%s " %(indexMax / freqStepSize) )
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
        FFT_side[indexMax] = 0
        # print(" 1 / stepSize %s" % (1 / freqStepSize))
        # print("    Selected freq : %s" % ( indexMax / freqStepSize))
        # for k in range(indexMax - 5, indexMax + 5 ): #int(1 /freqStepSize)
        #     FFT_side[k] = 0
        #     print("   removing freq at %s " % (k / freqStepSize))
        #     #print("Freq val %s" %(k /freqStepSize ) )
        #     #print(k)

        #print("  val at index after : %s " % FFT_side[indexMax])

    #print("     Avg value : %s " % (  (float(abs(FFT_side[indexMax])) / (songMaxAmplitude )) * 255    ))
    #songSection = signal[0 : 50]
    #print("hi")


for i in range(0, len(mainFrequenciesArray[0])):
    #print("index %i" % i)
    for j in range(0, len(mainFrequenciesArray)):
        #* 0.7  as rough reducer.  Technically multiple of these can add up past 255.  This is a sort of weak normalize rfor it.
        mainFixedAmplitudesArray[j].append( int (   (float (mainRawAmplitudesArray[j][i])  / float(maxAmplitude ) * 0.7 )  * 255 * volumeAdjustment) )
        # print("     [%i] freq :%i " %(j, mainFrequenciesArray[j][i]))
        # print("     [%i] raw :%i " %(j, mainRawAmplitudesArray[j][i]))
        # print("     [%i] fix :%i " %(j, mainFixedAmplitudesArray[j][i]))
        # print("  ---")

#NEXT STEP : Create module that will handle this
#input("COMPLETE")


f = open("songFormattedOutput.txt", "w")
#f.write('assign %s[%i] = 8\'b%s;\n'%(varName, i, b) )

f.write('//COPY PASTE FROM FILE STARTING ON THIS LINE DOWNWARD. INCLUDE ENDMODULE\n')
f.write('bit [%i:0][%i:0][13:0] songFrequencies;\n' %(int(mainFrequenciesToGrabCount) - 1, (len(mainFrequenciesArray[0])-1 )      ))
f.write('bit [%i:0][%i:0][7:0] songFrequencyAmplitudes;\n\n' %(int(mainFrequenciesToGrabCount) - 1 , (len(mainFixedAmplitudesArray[0])-1 )      ))

f.write('//-=-=-=-=-SONG DATA-=-=-=-=- \n')

for i in range(0, len(mainFrequenciesArray[0])):
    #print("index %i" % i)
    for j in range(0, len(mainFrequenciesArray)):
        #Frequency
        #assign songFrequencies[0][0] = dah
        f.write('   assign songFrequencies        [%i][%i] = 14\'d%i;\n' %( j , i , int(mainFrequenciesArray[j][i]) ))
        #Amplitude
        f.write('   assign songFrequencyAmplitudes[%i][%i] =  8\'d%i;\n' %( j , i , int(mainFixedAmplitudesArray[j][i]) ))
    #---Break data with small seperation
    f.write('   //--\n')

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