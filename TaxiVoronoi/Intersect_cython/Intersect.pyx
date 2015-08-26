#!/usr/bin/python

class G:
	clockwise=False
	ccw= not clockwise
	WindingOrderUsed = ccw
	epsilon = 1e-04

from math import *

def sgn(n): return 1.0 if n>G.epsilon else -1.0 if n<-G.epsilon else 0.0

def angle(p1,p2):
	cdef float dx,dy
	dx=p2[0]-p1[0]
	dy=p2[1]-p1[1]
	return atan2(dx,dy)

def dist(p1,p2):
	cdef float dx,dy
	dx=p2[0]-p1[0]
	dy=p2[1]-p1[1]
	return sqrt(dx*dx+dy*dy)

def mDist(p1,p2):
	cdef float dx,dy
	dx=p2[0]-p1[0]
	dy=p2[1]-p1[1]
	return abs(dx)+abs(dy)


def Pairs(n):
	cdef int i,j
	return [(i,j) for j in range(1,n) for i in range(j)]
def Combinations(l):
	cdef int i,j
	return [ (l[i],l[j]) for i,j in Pairs(len(l)) ]


def IndexVert(v,verts):
	cdef int l,vi
	cdef ax,ay,d
	l= len(verts)
	for vi in range(l):
		ax = abs(verts[vi][0]-v[0])
		ay = abs(verts[vi][1]-v[1])
		d= ax if ax>ay else ay
		if d<G.epsilon:
			return vi
	verts.append(v)
	return l


def IsClosed(poly):
	cdef float x1,y1,x2,y2
	cdef int i,j
	if poly:
		x1=poly[-1][0]
		y1=poly[-1][1]
		for i in range(len(poly)):
			x2=poly[i][0]
			y2=poly[i][1]
			if not bool(BisectPoint( ((x1+x2)/2.0 , (y1+y2)/2.0)) ):
				for j in range(i): poly.append(poly.pop(0))
				return False
			x1=x2;y1=y2
		return True


cdef float MAX_FLOAT
from sys import float_info
MAX_FLOAT= float_info.max


from sfml.sf import Vector2 as Vec2


def BisectPoint(p):
	cdef float d,d1,d2,dx,dy,x,y,xx,yy
	cdef int i,i1,i2
	d1=MAX_FLOAT;d2=MAX_FLOAT
	i1=-1;i2=-1
	x,y=p
	for i in range(len(G.P)):
		xx,yy=G.P[i]
		dx= x-xx
		dy= y-yy
		d= abs(dx)+abs(dy)
		if d<=d1:
			d2=d1;i2=i1
			d1=d ;i1=i
		elif d<=d2:
			d2=d;i2=i
	if d2-d1<G.epsilon:
		return [i1,i2]

'''
def _BisectPoint(p):
	cdef float d
	cdef int i
	dists= sorted( [ (mDist(p,G.P[i]),i) for i in range(len(G.P)) ] , key=lambda x: x[0] )[:2]
	s= [ d for d,i in dists ]
	if s[1]-s[0]<G.epsilon:
		return [i for d,i in dists]
'''

def TrisectPoint(p):
	cdef float d,d1,d2,d3,dx,dy,x,y,xx,yy
	cdef int i,i1,i2,i3
	d1=MAX_FLOAT;d2=MAX_FLOAT;d3=MAX_FLOAT
	i1=-1;i2=-1;i3=-1
	x,y=p
	for i in range(len(G.P)):
		xx,yy=G.P[i]
		dx= x-xx
		dy= y-yy
		d= abs(dx)+abs(dy)
		if d<=d1:
			d3=d2;i3=i2
			d2=d1;i2=i1
			d1=d ;i1=i
		elif d<=d2:
			d3=d2;i3=i2
			d2=d ;i2=i
		elif d<=d3:
			d3=d ;i3=i
	if d2-d1<G.epsilon and d3-d2<G.epsilon:
		return [i1,i2,i3]


'''
def _TrisectPoint(p):
	cdef float d
	cdef int i
	dists= sorted( [ (mDist(p,G.P[i]),i) for i in range(len(G.P)) ] , key=lambda x: x[0] )[:3]
	s= [ d for d,i in dists ]
	if s[1]-s[0]<G.epsilon and s[2]-s[1]<G.epsilon:
		return [i for d,i in dists]
'''


LINE,SEG,RAY,HRAY,VRAY = 1,2,3,4,5
cdef class cLine:
	cdef public float  x, y
	cdef public float dx,dy
	cdef public int type

	def __init__(self, float x1,float y1,float x2,float y2 , int type):
		self.x = x1; self.y = y1; self.dx = x2-x1; self.dy = y2-y1
		if type==RAY:
			if self.dx and abs(self.dy)<G.epsilon:	type=HRAY
			if self.dy and abs(self.dx)<G.epsilon:	type=VRAY
		self.type=type

	cdef int intersect(self,other, float *x, float *y):
		if self.type==HRAY and other.type==VRAY:
			x[0]=self.x
			y[0]=other.y
			return True

		if self.type==VRAY and other.type==HRAY:
			x[0]=other.x
			y[0]=self.y
			return True

		if self.type==HRAY and other.type==HRAY: return False
		if self.type==VRAY and other.type==VRAY: return False

		cdef float m1,m2 , d,ddx,ddy , r,s

		m1= self.dx/self.dy if self.dy else MAX_FLOAT
		m2= other.dx/other.dy if other.dy else MAX_FLOAT
		if m1!=m2:
			d = self.dx*other.dy - self.dy*other.dx
			if d:
				ddx= self.x-other.x
				ddy= self.y-other.y
				r = ( ddy*other.dx - ddx*other.dy) / d
				s = ( ddy* self.dx - ddx* self.dy) / d

				if  self.type!=LINE and r<0.0:	return False
				if  self.type==SEG and r>1.0:	return False
				if other.type!=LINE and s<0.0:	return False
				if other.type==SEG and s>1.0:	return False

				x[0]= self.x + r*self.dx
				y[0]= self.y + r*self.dy
				return True

		return False



def SegSegIntersect(s1,s2):
	cdef cLine l1,l2
	l1= cLine(s1[0][0],s1[0][1],s1[1][0],s1[1][1],SEG)
	l2= cLine(s2[0][0],s2[0][1],s2[1][0],s2[1][1],SEG)
	cdef float x,y
	if l1.intersect(l2,&x,&y): return x,y

def RaySegIntersect(s1,s2):
	cdef cLine l1,l2
	l1= cLine(s1[0][0],s1[0][1],s1[1][0],s1[1][1],RAY)
	l2= cLine(s2[0][0],s2[0][1],s2[1][0],s2[1][1],SEG)
	cdef float x,y
	if l1.intersect(l2,&x,&y): return x,y

def RayRayIntersect(s1,s2):
	cdef cLine l1,l2
	l1= cLine(s1[0][0],s1[0][1],s1[1][0],s1[1][1],RAY)
	l2= cLine(s2[0][0],s2[0][1],s2[1][0],s2[1][1],RAY)
	cdef float x,y
	if l1.intersect(l2,&x,&y): return x,y


def LineLineIntersect(s1,s2):
	cdef cLine l1,l2
	l1= cLine(s1[0][0],s1[0][1],s1[1][0],s1[1][1],LINE)
	l2= cLine(s2[0][0],s2[0][1],s2[1][0],s2[1][1],LINE)
	cdef float x,y
	if l1.intersect(l2,&x,&y): return x,y

def SegLineIntersect(s1,s2):
	cdef cLine l1,l2
	l1= cLine(s1[0][0],s1[0][1],s1[1][0],s1[1][1],SEG)
	l2= cLine(s2[0][0],s2[0][1],s2[1][0],s2[1][1],LINE)
	cdef float x,y
	if l1.intersect(l2,&x,&y): return x,y

def RayLineIntersect(s1,s2):
	cdef cLine l1,l2
	l1= cLine(s1[0][0],s1[0][1],s1[1][0],s1[1][1],RAY)
	l2= cLine(s2[0][0],s2[0][1],s2[1][0],s2[1][1],LINE)
	cdef float x,y
	if l1.intersect(l2,&x,&y): return x,y


class pyLine:
	def __init__(self, r1,r2,type):
		cdef x1,y1,x2,y2
		x1,y1=r1;x2,y2=r2
		self.line= cLine(x1,y1,x2,y2,type)
	def intersect(self,other):
		cdef float x,y
		cdef cLine l1,l2
		l1= self.line
		l2= other.line
		if l1.intersect(l2,&x,&y):
			return x,y
	def __getitem__(self, int key):
		cdef cLine l
		l= self.line
		if key==0:	return l.x,l.y
		if key==1:	return l.x+l.dx,l.y+l.dy

class Ray(pyLine):
	def __init__(self, r1,r2):
		pyLine.__init__(self, r1,r2,RAY)

class Seg(pyLine):
	def __init__(self, r1,r2):
		pyLine.__init__(self, r1,r2,SEG)

class Line(pyLine):
	def __init__(self, r1,r2):
		pyLine.__init__(self, r1,r2,LINE)




def Polies_Neighbors(B):
	cdef int bi1,bi2 , pi , ri,rj,r,r2

	cdef cLine b1r1,b1r2,b1s,b1l,b2r1,b2r2,b2s,b2l
	cdef float x,y

	cdef float d,d1,d2,d3,dx,dy,xx,yy
	cdef int i,i1,i2,i3
	cdef intersected

	polies= [ [] for i in range(len(G.P))]
	neighbors= [ [] for i in range(len(G.P))]

	print 'intersects'
	for b1,b2 in Combinations(B):
		if b1.isLine:
			b1l= b1.lines[0].line
		else:
			b1r1= b1.lines[0].line
			b1r2= b1.lines[2].line
			b1s= b1.lines[1].line

		if b2.isLine:
			b2l= b2.lines[0].line
		else:
			b2r1= b2.lines[0].line
			b2r2= b2.lines[2].line
			b2s= b2.lines[1].line

		intersected= False
		if not (b1.isLine or b2.isLine):
			if not intersected: intersected=b1r1.intersect(b2r1, &x, &y)
			if not intersected: intersected=b1r1.intersect(b2r2, &x, &y)
			if not intersected: intersected=b1r2.intersect(b2r1, &x, &y)
			if not intersected: intersected=b1r2.intersect(b2r2, &x, &y)
			if not intersected: intersected=b1r1.intersect(b2s, &x, &y)
			if not intersected: intersected=b1r2.intersect(b2s, &x, &y)
			if not intersected: intersected=b1s.intersect(b2r1, &x, &y)
			if not intersected: intersected=b1s.intersect(b2r2, &x, &y)
			if not intersected: intersected=b1s.intersect(b2s, &x, &y)
		elif b1.isLine:
			if not intersected: intersected=b1l.intersect(b2r1, &x, &y)
			if not intersected: intersected=b1l.intersect(b2r2, &x, &y)
			if not intersected: intersected=b1l.intersect(b2s, &x, &y)
		else:
			if not intersected: intersected=b1r1.intersect(b2l, &x, &y)
			if not intersected: intersected=b1r2.intersect(b2l, &x, &y)
			if not intersected: intersected=b1s.intersect(b2l, &x, &y)

		if intersected:
			d1=MAX_FLOAT;d2=MAX_FLOAT;d3=MAX_FLOAT
			i1=-1;i2=-1;i3=-1
			for i in range(len(G.P)):
				xx,yy=G.P[i]
				dx= x-xx
				dy= y-yy
				d= abs(dx)+abs(dy)
				if d<=d1:
					d3=d2;i3=i2
					d2=d1;i2=i1
					d1=d ;i1=i
				elif d<=d2:
					d3=d2;i3=i2
					d2=d ;i2=i
				elif d<=d3:
					d3=d ;i3=i

			if d2-d1<G.epsilon and d3-d2<G.epsilon:
				regions= [i1,i2,i3]
				p= (x,y)
				for ri in range(len(regions)):
					r=regions[ri]
					polies[r].append( p )
					for rj in range(len(regions)):
						r2=regions[rj]
						if r!=r2 and not r2 in neighbors[r]:
							neighbors[r].append(r2)


	print 'bisects'
	for b in B:
		if not b.isLine:
			for p in b.seg:
				regions= BisectPoint(p)
				if regions:
					for r in regions:
						polies[r].append(p)
						for r2 in regions:
							if r!=r2 and not r2 in neighbors[r]:
								neighbors[r].append(r2)

	return polies,neighbors

