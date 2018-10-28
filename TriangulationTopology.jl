module TriangulationTopology

using UUIDs
using Random
rng = MersenneTwister(8675309);


#This module contains basic simplicial complex constructors and operations to
#access basic combinatorial info about them.
#
#Also, functions to test various topological properties are included

#Type hierarchy:
abstract type Cells end
abstract type Vertices <: Cells end
abstract type Edges <: Cells end
abstract type Triangles <: Cells end
export Cells, Vertices, Edges, Triangles

#### Basic cells. Each comes with a uuid so that multiple instances don't
#conglomerate:
#
struct uniqVertex <: Vertices
    index::Int
    id::UUID
end
export uniqVertex

function uniqVertex(a::Int)
    iden = uuid1(rng)
    return uniqVertex(a, iden)
end

struct uniqEdge <: Edges
    head::uniqVertex
    tail::uniqVertex
    id::UUID
end
export uniqEdge

function uniqEdge(v::uniqVertex, w::uniqVertex)
    iden = uuid1(rng)
    return uniqEdge(v, w, iden)
end

#construct edge directly from vertex indices
function uniqEdge(a::Int, b::Int)
    u = uniqVertex(a)
    v = uniqVertex(b)
    iden = uuid1(rng)
    return uniqEdge(u,v,iden)
end

struct uniqTriangle <: Triangles
    vertex1::uniqVertex
    vertex2::uniqVertex
    vertex3::uniqVertex
    id::UUID
end
export uniqTriangle
#Constructor for triangle directly from  vertex indices.
function uniqTriangle( a::Int, b::Int, c::Int )
    u = uniqVertex(a)
    v = uniqVertex(b)
    w = uniqVertex(c)
    iden = uuid1(rng)
    return uniqTriangle(u, v, w, iden)
end

#another to construct from Array{Int64}
function uniqTriangle( verts::Array{Int,1} )
    iden = uuid1(rng)
    if length(verts) == 3
        return uniqTriangle(verts...,iden)
    else
        println("input must be an array of length 3")
    end
end

#####non-unique cells. No uuids. I'm using these to simplify some membership
#checking
struct Vertex <: Vertices
    index::Int
end
export Vertex

struct Edge <: Edges
    head::Vertex
    tail::Vertex
end
export Edge

function Edge(a::Int, b::Int)
    u = Vertex(a)
    v = Vertex(b)
    return Edge(u,v)
end

struct Triangle <: Triangles
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
    return Triangle(u, v, w )
end

#another to construct from Array{Int64}
function Triangle( verts::Array{Int,1} )
    if length(verts) == 3
        return Triangle(verts...)
    else
        println("input must be an array of length 3")
    end
end


#method to anonymize (make non-unique) a cell
function anonymize( cell::Cells )
    if typeof(cell) == uniqVertex
        return Vertex(cell.index)
    end
    if typeof(cell) == uniqEdge
        return Edge(anonymize(cell.head), anonymize(cell.tail))
    end
    if typeof(cell) == uniqTriangle
        return Triangle(anonymize(cell.vertex1), anonymize(cell.vertex2), 
                          anonymize(cell.vertex3))
    end
    if typeof(cell) <: Cells
        return cell
    end
    return -1
end
export anonymize


###Get array of edges or vertice:
function edgesof( Δ::Triangles )
    edges = [uniqEdge(Δ.vertex1, Δ.vertex2), uniqEdge(Δ.vertex1, Δ.vertex3), uniqEdge(Δ.vertex2, Δ.vertex3)]
    return edges
end

function edgesof( Δ::uniqTriangle )
    edges = [uniqEdge(Δ.vertex1, Δ.vertex2), uniqEdge(Δ.vertex1, Δ.vertex3), uniqEdge(Δ.vertex2, Δ.vertex3)]
    return edges
end

function edgesof( Δ::Triangle )
    edges = [Edge(Δ.vertex1, Δ.vertex2), Edge(Δ.vertex1, Δ.vertex3), Edge(Δ.vertex2, Δ.vertex3)]
    return edges
end

function verticesof( v::Vertices)
    return [v]
end

function verticesof( Δ::Triangles)
    return [Δ.vertex1, Δ.vertex2, Δ.vertex3]
end

function verticesof( e::Edges )
    return [e.head, e.tail]
end

export edgesof, verticesof

###equiv ignores uuids when checking for equivalence. 

function equiv( x::Cells, y::Cells)
    if typeof(x) == typeof(y)  
        return Set(verticesof(x)) == Set(verticesof(y))
    else
        return false   
    end
end


#I think what I've learned about abstract types (see prev function def) makes
#the following unnecessary! SMRT!
#function equiv(v::uniqVertex, u::uniqVertex)
#    return v.index == u.index
#end
#
#function equiv(e::uniqEdge, f::uniqEdge)
#    return Set(verticesof(e)) == Set(verticesof(f))
#end
#
#function equiv(t::uniqTriangle, u::uniqTriangle)
#    return Set(verticesof(t)) == Set(verticesof(u))
#end

export equiv

####One-complexes:

struct OneComplex
    K₀::Array{<:Vertices,1}
    K₁::Array{<:Edges,1}
end
export OneComplex

#Construtor to infer vertices directly from array of edges
function OneComplex( K₁::Array{<:Edges} )
    K₀ = Vertices[]
    for edge ∈ K₁
        for vertex ∈ verticesof(edge)
            if !(vertex in K₀)
                push!(K₀, vertex)
            end
        end
    end
    return OneComplex(K₀, K₁)
end


####Two-complexes
struct SimplicialComplex
    K₀::Array{<:Vertices,1}
    K₁::Array{<:Edges,1}
    K₂::Array{<:Triangles,1}
end
export SimplicialComplex


#Constructor to infer edges and vertices directly from array of triangles.
function SimplicialComplex( K₂::Array{<:Triangles} )
    K₀ = Vertices[]
    K₁ = Edges[]
    for Δ ∈ K₂
        for vertex in verticesof(Δ)
            if !(vertex in K₀)
                push!(K₀, vertex)
            end
        end
        for edge in edgesof(Δ)
            if !(edge in K₁)
                push!(K₁, edge)
            end
        end
    end
    return SimplicialComplex(K₀, K₁, K₂)
end


#Returns the star of vertex v in cpx (all triangles in cpx  that contain v)
function star( v::Vertices, cpx::SimplicialComplex )
    output = Triangles[]
    twoskel = cpx.K₂
    for tri in twoskel
        if anonymize(v) in verticesof(anonymize(tri))
            push!(output, tri)
        end
    end
    return output
end
export star

#returns array of edges containing v in cpx (Works for Simplicial or One)
function edgesfromvertex( v::Vertices, cpx )
    oneskel = cpx.K₁
    edges = Edges[]
    for e in oneskel
        #if e.head == v || e.tail == v
        if equiv(e.head, v) || equiv(e.tail, v)
            push!(edges, e)
        end
    end
    return edges
end
export edgesfromvertex

#returns triangle adjacent to Δ across edge in cpx
function adjacenttriangle(Δ::Triangles, e::Edges, cpx::SimplicialComplex)
    twoskel = copy(cpx.K₂)
    filter!(tri -> (e.head in verticesof(tri) && e.tail in verticesof(tri) && tri != Δ), twoskel)
    return twoskel[1]
end
export adjacenttriangle

#returns edge adjacent to e across vertex v in cpx::OneComplex
function adjacentedge(e::Edges, v::Vertices, cpx::OneComplex)
    otheredge = filter!( edge -> edge!=e, edgesfromvertex(v, cpx))
    return otheredge[1]
end
export adjacentedge

#computes the boundary of a complex. Here, we'll usually compute it for a
#subcomplex

function boundary( cpx::SimplicialComplex )
  bdy = Edges[]
  for e in cpx.K₁
	if length(edgefan(e, cpx)) == 1
	  push!(bdy,e)
	end
  end
  return bdy
end

function boundary( cpx::OneComplex )
    bdy = Vertices[]
    for v in cpx.K₀
        if length(edgesfromvertex(v, cpx)) == 1
            push!(bdy,v)
        end
    end
    return bdy
end
export boundary

#returns set of triangles in cps containing edge e
function edgefan( e::Edges, cpx::SimplicialComplex )
    output = Triangles[]
    twoskel = cpx.K₂
    for tri in twoskel
        if e in edgesof(tri)
            push!(output, tri)
        end
    end
    return output
end
export edgefan

#random triangulation having numverts vertices and numtris triangles
function randomtriangulation( numverts, numtris )
    tris = Triangles[]
    for k in 1:101
        #TODO: add a conditional that checks that a random triangle has three
        #distinct vertices.
        vs = abs.(rand(Int,3).%numverts)
        t = Triangles(vs)
        push!(tris, t)
    end
    s = SimplicialComplex(tris)
    return s
end
export randomtriangulation


###------------Topology-stuff below------------

#Computes euler characteristic
function eulercharacteristic( simp::SimplicialComplex )
    v = length(simp.K₀)
    e = length(simp.K₁)
    f = length(simp.K₂)
    return v - e + f
end
export eulercharacteristic




#isonemanifold checks if a OneComplex is a closed 1-manifold. Simply need to check that
#each vertex is in exactly two edges.
function isonemanifold( cpx::OneComplex )
    for vertex in cpx.K₀
        if length(edgesfromvertex(vertex, cpx)) != 2
            return false
        end
    end
    return true
end


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

#checks of one-manifold is connected
#
function isconnected( cpx::OneComplex )
    if isonemanifold(cpx)
        initedge = cpx.K₁[1]
        componentoneskel = Edges[initedge]
        component = OneComplex(componentoneskel)
        cptbdy = boundary(component)
        while !(isonemanifold(component))
            for v in cptbdy
                estar = edgesfromvertex(v, cpx)
                for edge in estar
                    if !(edge in componentoneskel)
                        push!(componentoneskel, edge)
                    end
                end
            end
            component = OneComplex(componentoneskel)
            cptbdy = boundary(component)
        end
        if length(component.K₁) == length(cpx.K₁)
            return true
        else return false
        end
    end
println("Sorry! This only checks if closed one-manifolds are connected right now.\n 
		Your complex is not a closed one-manifold")
end

#Checks of vertex v is surrounded by a single disk of 2-cells. Condition 2 in
#Kinsley's triangulated surface definition.
function isdisklike( v::Vertices, cpx::SimplicialComplex )
    starv = SimplicialComplex(star(v, cpx))
    bstarv = OneComplex(boundary(starv))
    return isonemanifold(bstarv) && isconnected(bstarv)
end
export isdisklike


#checks if triangulated surface is connected. Does this need to be
#specialized to just surfaces or will the ideas from the combinatorial
#connectedness theorem work for general triangulations? I have to think about
#that. Right now, it assumes that cpx is a surface

function isconnected( cpx::SimplicialComplex)
  if issurface(cpx)
  inittriangle = cpx.K₂[1]
  componenttwoskel = Triangles[inittriangle]
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
