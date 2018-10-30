module TriangulationCalculator

using UUIDs
using Random
rng = MersenneTwister(8675309);

include("cellcomplexes.jl")
export Cells, Vertices, Edges, Triangles #abstract types
export Vertex, Edge, Triangle, uniqVertex, uniqEdge, uniqTriangle
export edgesof, verticesof
export equiv
export SimplicialComplex, OneComplex

include("complexinfo.jl")
export star, edgesfromvertex, edgefan
export adjacenttriangle, adjacentedge
export boundary

include("randomtriangulation.jl")
export randomtriangulation

include("basictopology.jl")
export eulercharacteristic, issurface, isconnected



end