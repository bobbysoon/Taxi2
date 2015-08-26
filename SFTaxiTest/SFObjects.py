from sfml import sf

from TaxiVoronoi import mDist

from SFPoly import *
from SFCircle import *

def pointInPoly(p,poly):
	x,y=p

	n = len(poly)
	inside = False

	p1x,p1y = poly[0]
	for i in range(n+1):
		p2x,p2y = poly[i % n]
		if y > min(p1y,p2y):
			if y <= max(p1y,p2y):
				if x <= max(p1x,p2x):
					if p1y != p2y:
						xints = (y-p1y)*(p2x-p1x)/(p2y-p1y)+p1x
					if p1x == p2x or x <= xints:
						inside = not inside
		p1x,p1y = p2x,p2y
	return inside


class Text(sf.Text):
	def __init__(self):
		sf.Text.__init__(self,font=sf.Font.from_file("/usr/share/fonts/truetype/freefont/FreeMono.ttf"))

class SFObjects(sf.Drawable):
	def __init__(self, polies,isClosed):
		sf.Drawable.__init__(self)
		self.isClosed= isClosed
		self.sfPolies= [ SFPoly(polies[i],G.P[i],isClosed[i]) for i in range(len(polies)) ]
		self.clickedAt= self.selectPoly
		self.selectedPoly=None
		self.pc=0
		self.text=Text()

	def setScale(self,scale): pass
	def updateRays(self, corners): pass

	def draw(self, target,states):
		for sfPoly in self.sfPolies:
			if sfPoly!=self.selectedPoly:
				sfPoly.draw(target, states)
		if self.selectedPoly:
			self.selectedPoly.draw(target, states, True)

	def selectPoly(self, p):
		dists = {mDist(p,G.P[i]):i for i in range(len(G.P))}
		i= dists[min(dists.keys())]
		self.selectedPoly = self.sfPolies[ i ]


