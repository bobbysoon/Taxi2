from sfml import sf
from SFCircle import *

from TaxiVoronoi.Intersect import *

def ScreenEdgeIntersect(corners,rayOrigin,rayDirection):
	edges= [ Seg(corners[i-1],corners[i]) for i in [0,1,2,3] ]
	rayIntersects = [RaySegIntersect( Ray(rayOrigin,rayOrigin+rayDirection), edge) for edge in edges]
	rayIntersects = [p for p in rayIntersects if p]
	if len(rayIntersects)==1:
		return rayIntersects[0] if rayIntersects else None
	elif rayIntersects:
		dists= {dist(p,rayOrigin):p for p in rayIntersects}
		return dists[max(dists.keys())]


class SFBorder_debug_line(sf.VertexArray):
	def __init__(self, border):
		self.selected=None
		self.border= border
		sf.VertexArray.__init__(self, sf.PrimitiveType.LINES_STRIP,2 )
	def updateRays(self, corners):
		edges= [ Seg(corners[i-1],corners[i]) for i in [0,1,2,3] ]
		rayIntersects = [LineSegIntersect( self.border.lines[0] , edge ) for edge in edges]
		rayIntersects = [p for p in rayIntersects if p]
		self[0].position= rayIntersects[0]
		self[1].position= rayIntersects[1]
	def draw(self, target,states,selected=False):
		if selected!=self.selected:
			self.selected=selected
			c= sf.Color.WHITE if selected else sf.Color(255,255,0) if self.border.quirky else sf.Color(0,0,0, 16)
			for i in [0,1]: self[i].color= c
		target.draw(self,states)

class SFBorder_debug(sf.VertexArray):
	def __init__(self, border):
		self.selected=None
		self.border= border
		sf.VertexArray.__init__(self, sf.PrimitiveType.LINES_STRIP,4 )
		self[1].position= border.lines[1][0]
		self[2].position= border.lines[1][1]
	def updateRays(self, corners):
		p0= ScreenEdgeIntersect(corners, self[1].position,-self.border.axis)
		p3= ScreenEdgeIntersect(corners, self[2].position, self.border.axis)
		if p0: self[0].position= p0
		if p3: self[3].position= p3
	def draw(self, target,states,selected=False):
		if selected!=self.selected:
			self.selected=selected
			c= sf.Color.BLACK if selected else sf.Color(255,255,0,32) if self.border.quirky else sf.Color(0,0,0, 16)
			for i in [0,1,2,3]: self[i].color= c
		target.draw(self,states)


class SFBorder(sf.VertexArray):
	def __init__(self, border, verts):
		self.border= border
		sf.VertexArray.__init__(self, sf.PrimitiveType.LINES_STRIP, len(border.verts) )
		c=0.0;cs=255.0/(len(border.verts)-1)
		for i in range(len(border.verts)):
			self[i].position= verts[border.verts[i]]
			self[i].color= sf.Color(c,c,c)
			c+= cs
	def draw(self, target,states):
		target.draw(self,states)
	def updateRays(self, corners): pass

