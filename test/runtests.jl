using TriangulationCalculator
triangles = [Triangle(1,2,3), Triangle(1,2,4), Triangle(1,3,4), Triangle(5,2,3), Triangle(5,2,4), Triangle(5,3,4)]
cpx = SimplicialComplex(triangles)
p = TriangulationCalculator.makepolygonsurface( cpx )
println(p)

