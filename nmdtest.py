import numpy as np
#import matplotlib.pyplot as plt
import nmdsetup as nmdsetup
import sys
import re

eig=nmdsetup.Eig('eigvec.dat')
vel=nmdsetup.Vel('dump.vel')
pos=nmdsetup.Pos('x0.dat')
kpt=np.loadtxt('kptlist.dat')

testnmd=nmdsetup.Nmd(vel,pos,eig,kpt)

testnmd.genscript(1)

#print testnmd.spctEnrg(1,1)



