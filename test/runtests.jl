using TriangulationCalculator
#triangles = [Triangle(1,2,3), Triangle(1,2,4), Triangle(1,3,4), Triangle(5,2,3), Triangle(5,2,4), Triangle(5,3,4)]
#cpx = SimplicialComplex(triangles)

dtris = Triangle.([(1,2,4),
	(2,4,5),
	(1,3,4),
	(3,4,6),
	(2,3,6),
	(2,5,6),
	(1,2,7),
	(2,7,8),
	(3,8,9),
	(1,3,9),
	(2,3,8),
	(1,7,9),
	(5,7,8),
	(5,6,8),
	(6,8,9),
	(4,6,9),
	(4,7,9),
	(4,5,7)])

dcpx = SimplicialComplex(dtris)



dp = TriangulationCalculator.makepolygonsurface( dcpx )
word = TriangulationCalculator.surfacerelation(dp)
println(dp)
println(word)

b = isorientable(dcpx)
println("dcpx is orientable: $b")
surfaceid(dcpx)

