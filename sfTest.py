#!/usr/bin/python

from RandomPointGrid import *
from TaxiVoronoi import TaxiVoronoi,G
from SFTaxiTest import SFTaxiTest

from random import seed,randint
from sys import maxint,argv
if argv[1:]: s=int(argv[1])
else:
	s = randint(0, maxint )
	print 'seed:\t%i'%s
seed(s)

G.epsilon=1e-03
centroids= RandomPointGrid( gridSize=5 , noise=2.5 , scale=1024.0 )
borders,polies,isClosed= TaxiVoronoi( centroids )
SFTaxiTest(borders,polies,isClosed)
