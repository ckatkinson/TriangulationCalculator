module Triangulation

struct Vertex
    index::Int
end
export Vertex

struct Edge
    head::Vertex
    tail::Vertex
end
export Edge

#construct edge directly from vertex indices
function Edge(a::Int, b::Int)
    u = Vertex(a)
    v = Vertex(b)
    return Edge(u,v)
end

struct Triangle
    vertex1::Vertex
    vertex2::Vertex
    vertex3::Vertex
end
export Triangle


#Constructor for triangle directly from  vertex indices.
function Triangle( a::Int, b::Int, c::Int )
    u = Vertex(a)
    v = Vertex(b)
    w = Vertex(c)
    return Triangle(u, v, w)
end

#another to construct from Array{Int64}
function Triangle( verts::Array{Int,1} )
    if length(verts) == 3
        return Triangle(verts...)
    else
        println("input must be an array of length 3")
    end
end


struct SimplicialComplex
    K₀::Array{Vertex,1}
    K₁::Array{Edge,1}
    K₂::Array{Triangle,1}
end
export SimplicialComplex

function edgesof( Δ::Triangle )
    edges = [Edge(Δ.vertex1, Δ.vertex2), Edge(Δ.vertex1, Δ.vertex3), Edge(Δ.vertex2, Δ.vertex3)]
    return edges
end

function verticesof( Δ::Triangle )
    return [Δ.vertex1, Δ.vertex2, Δ.vertex3]
end

#Constructor to infer edges and vertices directly from array of triangles.
function SimplicialComplex( K₂::Array{Triangle} )
    K₀ = Vertex[]
    K₁ = Edge[]
    for Δ ∈ K₂
        tempverts = verticesof(Δ)
        for vertex in tempverts
            if !(vertex in K₀)
                push!(K₀, vertex)
            end
        end
        tempedges = edgesof(Δ)
        for edge in tempedges
            if !(edge in K₁)
                push!(K₁, edge)
            end
        end
    end
    return SimplicialComplex(K₀, K₁, K₂)
end

#Computes euler characteristic
function eulercharacteristic( simp::SimplicialComplex )
    v = length(simp.K₀)
    e = length(simp.K₁)
    f = length(simp.K₂)
    return v - e + f
end
export eulercharacteristic

#random triangulation having numverts vertices and numtris triangles
function randomtriangulation( numverts, numtris )
    tris = Triangle[]
    for k in 1:101
        #TODO: add a conditional that checks that a random triangle has three
        #distinct vertices.
        vs = abs.(rand(Int,3).%numverts)
        t = Triangle(vs)
        push!(tris, t)
    end
    s = SimplicialComplex(tris)
    return s
end
export randomtriangulation


#Returns the star of vertex v in cpx (all triangles in cpx  that contain v)
function star( v::Vertex, cpx::SimplicialComplex )
    output = Triangle[]
    twoskel = cpx.K₂
    for tri in twoskel
        if v in verticesof(tri)
            push!(output, tri)
        end
    end
    return output
end
export star

#returns array of edges containing v in cpx
function edgesfromvertex( v::Vertex, cpx::SimplicialComplex )
    oneskel = cpx.K₁
    edges = Edge[]
    for e in oneskel
        if e.head == v || e.tail == v
            push!(edges, e)
        end
    end
    return edges
end

#returns triangle adjacent to Δ across edge in cpx
function adjacenttriangle(Δ::Triangle, e::Edge, cpx::SimplicialComplex)
    twoskel = copy(cpx.K₂)
    filter!(tri -> (e.head in verticesof(tri) && e.tail in verticesof(tri) && tri !=    Δ), twoskel)
    return twoskel[1]
end
export adjacenttriangle

#Boolean value. Checks if the star of a vertex v in complex cpx is disklike (#2 in Kinsley's
#triangulated surface definition. Assumes that every edge is in exactly two
#triangles. The way it works is to just start at an arbitrary triangle in the
#star, and move to one of the two possible "next" triangles (cyclically around
#v) in the star. Each time we move to another triangle, increment a counter.
#When we return to the starting triangle, if the counter value equals the number
#of triangles in the star, then the star is disklike.
#This also assumes that the complex is ACTUALLY simplicial
#TODO: think about whether and how to check that cpx is actually simplicial. I'm
#pretty sure that our struct is cool with non-simplicial triangulations. 

function isdisklike( v::Vertex, cpx::SimplicialComplex )
    starv = star(v, cpx)
    edgesv = edgesfromvertex(v, cpx)
    inittriangle = starv[1]
    initedges = edgesof(inittriangle) ∩ edgesv
    currentedge = initedges[1]
    currenttriangle = adjacenttriangle(inittriangle, currentedge, cpx)
    count = 1
    while currenttriangle != inittriangle
        tempedges = edgesof(currenttriangle) ∩ edgesv
        filter!( e -> (e!=currentedge), tempedges )
        currentedge = tempedges[1]
        currenttriangle = adjacenttriangle(currenttriangle, currentedge, cpx)
        count += 1
    end
    if count == length(starv)
        return true
    else return false
    end
end
export isdisklike




#returns set of triangles in cps containing edge e
function edgefan( e::Edge, cpx::SimplicialComplex )
    output = Triangle[]
    twoskel = cpx.K₂
    for tri in twoskel
        if e in edgesof(tri)
            push!(output, tri)
        end
    end
    return output
end
export edgefan

#issurface function implements the algorithm suggested by the definition of a
#triangulated surface in Kinsley. The definition says that a triangluation has
#underlying space a surface if 
#1) Each edges is contained in exactly two triangles.
#2) For each vertex v, the set of triangles containing v can be cyclically
#ordered so that two triangles in the set share an edge iff their indices differ
#by 1 (mod numtris at v) This is implemented above as the isdisklike function.

function issurface( cpx::SimplicialComplex)
    oneskel = cpx.K₁
    #Check condition 1)
    for e in oneskel
        if length(edgefan(e, cpx))!=2
            return false
        end
    end
    #check condition 2)
    for v in cpx.K₀
        if !isdisklike(v, cpx)
            return false
        end
    end
    return true
end
export issurface

#computes the boundary of a complex. Here, we'll usually compute it for a
#subcomplex

function boundary( cpx::SimplicialComplex )
  bdy = Edge[]
  for e in cpx.K₁
	if length(edgefan(e, cpx)) == 1
	  push!(bdy,e)
	end
  end
  return bdy
end


#checks if triangulated surface is connected. Does this need to be
#specialized to just surfaces or will the ideas from the combinatorial
#connectedness theorem work for general triangulations? I have to think about
#that. Right now, it assumes that cpx is a surface

function isconnected( cpx::SimplicialComplex)
  if issurface(cpx)
  inittriangle = cpx.K₂[1]
  componenttwoskel = Triangle[inittriangle]
  component = SimplicialComplex(componenttwoskel)
  cptbdy = boundary(component)
  while !(issurface(component)) #If I can figure out how to check if we've enumerated a whole 
							    #component, things will work for general complexes...
	  for e in cptbdy
		efan = edgefan(e, cpx)
		for tri in efan
		  if !(tri in componenttwoskel)
			push!(componenttwoskel, tri)
		  end
		end
	  end
	  component = SimplicialComplex(componenttwoskel)
	  cptbdy = boundary(component)
  end
  if length(component.K₂) == length(cpx.K₂)
    return true
  else return false
  end
end
println("Sorry! This only checks if closed surfaces are connected right now.\n 
		Your complex is not a closed surface")
end
export isconnected

end
