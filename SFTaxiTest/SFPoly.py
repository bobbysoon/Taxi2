from sfml import sf

#from SFCircle import *
from SFBorder import *

from SFLineStrip import *
from SFTriFan import *

from time import time

class SFPoly(sf.Drawable):
	def __init__(self, poly,centroid,isClosed):
		self.poly= poly
		sf.Drawable.__init__(self)
		self.blackBorder=	SFLineStrip(poly+[poly[0]],col=sf.Color.BLACK)
		if isClosed:
			self.triFan=	SFTriFan([centroid]+poly+[poly[0]],col=sf.Color(0,0,0,128))
		else:
			self.triFan=	SFTriFan([centroid]+poly,col=sf.Color(0,0,0,32))

	def setScale(self,scale): pass
	def updateRays(self, corners): pass

	def draw(self, target,states,selected=False):
		target.draw( self.triFan , states)
		if selected:
			target.draw( self.blackBorder , states)

