(still under construction)

TaxiVoronoi generates a polygonal representation of a voronoi diagram in manhattan metric

sfTest.py requires python-sfml.
TaxiVoronoi uses cython, though if you cant or don't want to use cython, strip out the cdefs from Intersect.pyx and it'll probably work.

The bottleneck is in the border intersects, so I took a crack at cythonizing that part.
Run TaxiVoronoi/TaxiVoronoi/Intersect_cython/comp to compile Intersect.so.
This has greatly improved speed, with only a few variable type declarations.

