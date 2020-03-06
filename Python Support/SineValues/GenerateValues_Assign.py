import math  

f = open("SineCalculations_Assign.txt", "w")
#f.write('{\n')
subDivisions = 128 #Number of subdivisions
bitSize = 8 #number of bits used for values
a = 0 #Stores the float value of the sine value
b = 0 #Converts it into a nice integer
varName = "preCalcSine"

#assign dataFile[i] = val;


for i in range(0, subDivisions):
    a = float(i/subDivisions) #*2*math.pi - 0.5*math.pi
    
    b = int(round(math.sin(a)*pow(2,bitSize)/2) + pow(2,bitSize)/2)
    #Prevent b from landing at 2^bitSize, which would need an extra bit. 
    b = max(min(b, pow(2,bitSize) - 1), 0)
   # b = bin(b)
    b = format(b, '08b')

    f.write('assign %s[%i] = 8\'b%s;\n'%(varName, i, a) )

#Finish with bracket
f.write('}\n')

f.close()

##-- TRIANGLE

f = open("TriangleCalculations_Assign.txt", "w")
#f.write('{\n')
subDivisions = 128 #Number of subdivisions
bitSize = 8 #number of bits used for values
a = 0 #Stores the float value of the sine value
b = 0 #Converts it into a nice integer
varName = "preCalcTriangle"

#assign dataFile[i] = val;


for i in range(0, subDivisions):
    a = i
    
    if (a > ((subDivisions)* 0.5 )) :
        a =subDivisions - a
    
   # b = bin(b)
    b = a*4
    b = max(min(b, pow(2,bitSize) - 1), 0)
    b = format(b, '08b')

    f.write('assign %s[%i] = 8\'b%s;\n'%(varName, i, b) )

#Finish with bracket
f.write('}\n')

f.close()


f = open("SquareWave_Assign.txt", "w")
#f.write('{\n')
subDivisions = 128 #Number of subdivisions
bitSize = 8 #number of bits used for values
a = 0 #Stores the float value of the sine value
b = 0 #Converts it into a nice integer
varName = "squareWave"

#assign dataFile[i] = val;


for i in range(0, subDivisions):
    a = 255 if (i >= subDivisions * 0.5) else 0
    
  #  if (a > ((subDivisions)* 0.5 )) :
    #    a =subDivisions - a;
    
   # b = bin(b)
   # b = a*4
    b = max(min(a, pow(2,bitSize) - 1), 0)
    b = format(b, '08b')

    f.write('   assign %s[%i] = 8\'b%s;\n'%(varName, i, b) )

#Finish with bracket
f.write('\n')

f.close()