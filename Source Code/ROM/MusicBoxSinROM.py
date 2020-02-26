#! /usr/bin/python

"""
main.py - Generate a ROM file for DE10-Lite
Matthew Shuman - shumanm@oregonstate.edu
"""

import numpy as np
import math

#Parameters
address_bits = 11
output_filename = 'Sin_ROM.mif'

lines = 2 ** address_bits
max_sin_amplitude = 100 
data_width = 8   

f = open(output_filename, 'w')

f.write('DEPTH = ' + str(2**address_bits) + ';\n')
f.write('WIDTH = ' + str(2**data_width) + ';\n')
f.write('ADDRESS_RADIX = ' + 'HEX;\n')
f.write('CONTENT\n')
f.write('BEGIN\n')
f.write('--memory address : data\n')

for memory_row in xrange(lines):
    f.write(hex(memory_row)[2:] + ' : ' + np.binary_repr(int(max_sin_amplitude*math.sin(memory_row*2*3.1415/2**address_bits)) , width=data_width)  + ';\n')
f.write('END\n')
f.close()   

print str(lines) + ' rows of memory were written to ' + output_filename    
