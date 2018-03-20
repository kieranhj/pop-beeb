#!/usr/bin/env python


import sys
import math


volume_table = [ 32767, 26028, 20675, 16422, 13045, 10362, 8231, 6568, 5193, 4125, 3277, 2603, 2067, 1642, 1304, 0 ]

# level 0 is silence
# level 8 is half volume
# level 15 is full volume
level_scale = 16.0 / 16.0

output_table = [ 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 ]

print "Calculating volume table"
print ".volume_lookup_table"
for level in range(0,16):
    #print "Calculating table for volume level " + str(level)
    s = level_scale * float(level)

    for v in range(0,16):
        n = volume_table[v]
        p = float(n) / 32767.0
        p *= s
        output_table[v] = 15 - int(p)#*15.0)

        #print n, v, int(p*100.0)
    o = " EQUB "
    for i in range(0,16):
        if output_table[i]<10:
            o += "0"
        o += str(output_table[i])
        if i !=15:
            o += ", "
    o += " ; volume level " + str(level)
    #print output_table
    print o

print "done"

# print volume_table
