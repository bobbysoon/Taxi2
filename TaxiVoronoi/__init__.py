from Poly import *
from time import time

def TaxiVoronoi(P):
	G.P= P
	B= [ Border(P[i],P[j]) for i,j in Pairs(len(P)) ]
	borders=B

	print 'Polies_Neighbors'
	t=time()
	polies,neighbors = Polies_Neighbors(B)
	print '%.3f'%(time()-t)

	for i in range(len(polies)):
		polies[i].sort( key=lambda p: angle(p,G.P[i]) )

	for poly in polies:
		i=0
		while i+1<len(poly):
			dx,dy= poly[i][0]-poly[i+1][0] , poly[i][1]-poly[i+1][1]
			if max([abs(dx),abs(dy)])<G.epsilon:	poly[i]=poly.pop(i)
			else: i+=1

	isClosed= [IsClosed(poly) for poly in polies]
	return borders,polies,isClosed
