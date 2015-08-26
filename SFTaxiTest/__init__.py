#from G import *
from sfml import sf
from Window import *
from MouseCursor import *
from NavCheck import *
from SFTaxiShader import *
from SFObjects import *
from SFBorder import *


def regionAt(p):
	dists={mDist(c,p):c for c in G.P}
	return dists[min(dists.keys())]

def nearest3(p):
	dists={mDist(c,p):c for c in G.P}
	return [dists[d] for d in sorted(dists.keys())][:3]

def SFTaxiTest(B,polies,isClosed):
	sfBorders= [SFBorder_debug(b) for b in B] if len(B)<100 else []
	verts=[]

	xa,ya= zip(*G.P)
	pMin= Vec2(min(xa),min(ya))
	pMax= Vec2(max(xa),max(ya))

	window= Window()
	sz=((pMax-pMin)*1.125).y
	window.view.size= sz,sz*window.size.y/window.size.x ; HomeView.size= window.view.size
	window.view.center= (pMax+pMin)/2.0 ; HomeView.center= window.view.center
	
	circ= SFCircle(sf.Color.BLACK)

	ca= nearest3(regionAt(window.map_pixel_to_coords(window.size/2.0)))


	sfTaxiShader= SFTaxiShader(G.P)
	mouseCursor= MouseCursor(window)

	sfObjects= SFObjects(polies,isClosed)

	clickPos=None ; clock = sf.Clock()
	while window.is_open:
		tDelta= clock.restart().seconds

		scale= window.view.size.x/window.size.x
		circ.setScale(2.5*scale)

		window.clear()
		window.draw(sfTaxiShader)
		corners= sfTaxiShader.quad.corners()
		for p in verts:
			circ.circle.position=p
			window.draw(circ.circle)
		for b in sfBorders:
			b.updateRays(corners)
			window.draw(b)

		window.draw(sfObjects)
		window.draw(mouseCursor)
		window.display()

		checkNavKeys(window,tDelta,mouseCursor.pos)
		for event in window.events:
			if		type(event) is sf.CloseEvent:			window.close()
			elif	type(event) is sf.MouseButtonEvent and event.pressed:
				if event.button==sf.Mouse.LEFT:			sfObjects.clickedAt(mouseCursor.pos)
				else:	checkForNavEvents(window,event,mouseCursor.pos)
			elif	type(event) is sf.KeyEvent and event.pressed:
				if		event.code == sf.Keyboard.ESCAPE: window.close()
				elif	event.code == sf.Keyboard.G:	drawShader= not drawShader
				elif	event.code == sf.Keyboard.V:	G.drawVerts= not G.drawVerts
				elif	event.code == sf.Keyboard.P:	sfObjects.clickedAt= selectPoly
				elif	event.code == sf.Keyboard.I:	sfObjects.clickedAt= selectIntersect
				else:	checkForNavEvents(window,event,mouseCursor.pos)
			else:	checkForNavEvents(window,event,mouseCursor.pos)


