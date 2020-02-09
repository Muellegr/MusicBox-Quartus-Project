import math  

f = open("SineCalculations.txt", "w")
f.write('{\n')
subDivisions = 128 #Number of subdivisions
bitSize = 8 #number of bits used for values
a = 0 #Stores the float value of the sine value
b = 0 #Converts it into a nice integer
for i in range(1, subDivisions+1):
    a = (i/subDivisions)*2*math.pi
    
    b = int(round(math.sin(a)*pow(2,bitSize)/2) + pow(2,bitSize)/2)
    #Prevent b from landing at 2^bitSize, which would need an extra bit. 
    b = max(min(b, pow(2,bitSize) - 1), 0)
   # b = bin(b)
    b = format(b, '08b')
    #Handle end comma
    if (i == subDivisions):
        f.write('7\'b%s ' % str(b).zfill(8) )
    else:
        f.write('7\'b%s, ' % str(b).zfill(3))
    #Break up line with occasional new line
    if (i%8 == 0 and i!=0):
        f.write('\n')

#Finish with bracket
f.write('}\n')

f.close()