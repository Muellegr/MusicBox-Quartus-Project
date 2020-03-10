#!/usr/bin/python

"""
MusicBoxROM.py - Generate a ROM file for DE10-Lite/Pollen Board
Tristan Luther - luthert@oregonstate.edu
"""

import sys
import numpy as np
import math

#Check command line arguments
if len(sys.argv) < 4:
    print("Usage: MusicBoxROM.py song1.hex song2.hex beeNoise.hex")
    sys.exit()

#Parameters
address_bits = 11
output_filename = 'songsROM.mif'
songFileOne = sys.argv[1]
songFileTwo = sys.argv[2]
beeNoise = sys.argv[3]

songOneEnd = 0
songTwoEnd = 0
beeNoiseEnd = 0

count = 0

lines = 2 ** address_bits
max_amplitude = 100 
data_width = 16   

f = open(output_filename, 'w')
fSongOne = open(songFileOne, 'r')
fSongTwo = open(songFileTwo, 'r')
fBee = open(beeNoise, 'r')

f.write('DEPTH = ' + str(2**address_bits) + ';\n')
f.write('WIDTH = ' + str(2**data_width) + ';\n')
f.write('ADDRESS_RADIX = ' + 'HEX;\n')
f.write('CONTENT\n')
f.write('BEGIN\n')
f.write('--memory address : data\n')

#Read the first song into memory, keeping track of the index where it ends
with fSongOne as fp:
    Lines = fp.readlines()
    for line in Lines:
        count += 1
<<<<<<< HEAD
        f.write(hex(count)[2:] + ' : ' + hex(line) + ';\n') # Write the frequency to the file
=======
        f.write(hex(count)[2:] + ' : ' + line.strip() + ';\n') # Write the frequency to the file
>>>>>>> c6cb5de3f752124148adc500f2d4f3cd12c179a1
songOneEnd = count
with fSongTwo as fp:
    Lines = fp.readlines()
    for line in Lines:
        count += 1
        f.write(hex(count)[2:] + ' : ' + line.strip() + ';\n') # Write the frequency to the file
songTwoEnd = count
with fBee as fp:
    Lines = fp.readlines()
    for line in Lines:
        count += 1
        f.write(hex(count)[2:] + ' : ' + line.strip() + ';\n') # Write the frequency to the file
beeNoiseEnd = count
f.write('END\n')

fSongOne.close()
fSongTwo.close()
fBee.close()
f.close()   

<<<<<<< HEAD
#print str(count) + ' rows of memory were written to ' + output_filename + '\nSong One ends at address: ' + str(songOneEnd) + '\nSong Two ends at address: ' + str(songTwoEnd) + '\nBee Noise ends at address: ' + str(beeNoiseEnd)
=======
print str(count) + ' rows of memory were written to ' + output_filename + '\nSong One ends at address: ' + str(songOneEnd) + '\nSong Two ends at address: ' + str(songTwoEnd) + '\nBee Noise ends at address: ' + str(beeNoiseEnd)
>>>>>>> c6cb5de3f752124148adc500f2d4f3cd12c179a1
