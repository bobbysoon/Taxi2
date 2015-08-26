from Intersect import *

class Border:
	def __init__(self, c,oc ):
		self.centroids= [c,oc]

		dx,dy=oc-c
		ax,ay=abs(dx),abs(dy)
		sx,sy=sgn(dx),sgn(dy)

		self.isLine= abs(ax-ay)<G.epsilon or ax<G.epsilon or ay<G.epsilon

		diag = Vec2(-dx/2.0,sy*ax/2.0) if ax<ay else Vec2(sx*ay/2.0,-dy/2.0) if ax>ay else Vec2(-sx,sy)

		cp= (c+oc)/2.0
		if self.isLine:
			self.lines= [Line(cp-diag,cp+diag)]
			self.seg=[]
			print 'line:'
		else:
			p1,p2 = cp+diag,cp-diag
			self.axis= Vec2(sx,0.0) if ax<ay else Vec2(0.0,sy) if ax>ay else None

			self.seg= [p1,p2]
			self.lines= [Ray(p1,p1-self.axis),Seg(p1,p2),Ray(p2,p2+self.axis)]

