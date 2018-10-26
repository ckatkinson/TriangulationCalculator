module TriangulationTopology

using UUIDs
using Random
rng = MersenneTwister(8675309);


#This module contains basic simplicial complex constructors and operations to
#access basic combinatorial info about them.
#
#Also, functions to test various topological properties are included

#### Basic cells:
#
struct Vertex
    index::Int
    id::UUID
end
export Vertex

function Vertex(a::Int)
    iden = uuid1(rng)
    return Vertex(a, iden)
end

struct Edge
    head::Vertex
    tail::Vertex
    id::UUID
end
export Edge

function Edge(v::Vertex, w::Vertex)
    iden = uuid1(rng)
    return Edge(v, w, iden)
end

#construct edge directly from vertex indices
function Edge(a::Int, b::Int)
    u = Vertex(a)
    v = Vertex(b)
    iden = uuid1(rng)
    return Edge(u,v,iden)
end

struct Triangle
    vertex1::Vertex
    vertex2::Vertex
    vertex3::Vertex
    id::UUID
end
export Triangle


#Constructor for triangle directly from  vertex indices.
function Triangle( a::Int, b::Int, c::Int )
    u = Vertex(a)
    v = Vertex(b)
    w = Vertex(c)
    iden = uuid1(rng)
    return Triangle(u, v, w, iden)
end

#another to construct from Array{Int64}
function Triangle( verts::Array{Int,1} )
    iden = uuid1(rng)
    if length(verts) == 3
        return Triangle(verts...,iden)
    else
        println("input must be an array of length 3")
    end
end

#Hmmm. How to return with no ids? As stated, this only will return with ids (but
#it makes SimplicialComplex work like this!
function edgesof( Δ::Triangle, no_ids=true::Bool )
    if !no_ids
        edges = [Edge(Δ.vertex1, Δ.vertex2), Edge(Δ.vertex1, Δ.vertex3), Edge(Δ.vertex2, Δ.vertex3)]
        return edges
    end
end

##no_ids = true leaves off uuids (by default). If you want uuids, include false
#as second argument
function verticesof( Δ::Triangle, no_ids=true::Bool)
    if no_ids
        return [Δ.vertex1.index, Δ.vertex2.index, Δ.vertex3.index]
    else
        return [Δ.vertex1, Δ.vertex2, Δ.vertex3]
    end
end

function verticesof( e::Edge, no_ids=true::Bool )
    if no_ids
        return [e.head.index, e.tail.index]
    else
        return [e.head, e.tail]
    end
end

###equiv ignores uuids when checking for equivalence. 

function equiv(v::Vertex, u::Vertex)
    return v.index == u.index
end

function equiv(e::Edge, f::Edge)
    return Set(verticesof(e)) == Set(verticesof(f))
end

function equiv(t::Triangle, u::Triangle)
    return Set(verticesof(t)) == Set(verticesof(u))
end

export equiv

####One-complexes:

struct OneComplex
    K₀::Array{Vertex,1}
    K₁::Array{Edge,1}
end
export OneComplex

#Construtor to infer vertices directly from array of edges
function OneComplex( K₁::Array{Edge} )
    K₀ = Vertex[]
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
    K₀::Array{Vertex,1}
    K₁::Array{Edge,1}
    K₂::Array{Triangle,1}
end
export SimplicialComplex


#Constructor to infer edges and vertices directly from array of triangles.
function SimplicialComplex( K₂::Array{Triangle} )
    K₀ = Vertex[]
    K₁ = Edge[]
    for Δ ∈ K₂
        for vertex in verticesof(Δ, false)
            if !(vertex in K₀)
                push!(K₀, vertex)
            end
        end
        for edge in edgesof(Δ, false)
            if !(edge in K₁)
                push!(K₁, edge)
            end
        end
    end
    return SimplicialComplex(K₀, K₁, K₂)
end


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

#returns array of edges containing v in cpx (Works for Simplicial or One)
function edgesfromvertex( v::Vertex, cpx )
    oneskel = cpx.K₁
    edges = Edge[]
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
function adjacenttriangle(Δ::Triangle, e::Edge, cpx::SimplicialComplex)
    twoskel = copy(cpx.K₂)
    filter!(tri -> (e.head in verticesof(tri) && e.tail in verticesof(tri) && tri != Δ), twoskel)
    return twoskel[1]
end
export adjacenttriangle

#returns edge adjacent to e across vertex v in cpx::OneComplex
function adjacentedge(e::Edge, v::Vertex, cpx::OneComplex)
    otheredge = filter!( edge -> edge!=e, edgesfromvertex(v, cpx))
    return otheredge[1]
end
export adjacentedge

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

function boundary( cpx::OneComplex )
    bdy = Vertex[]
    for v in cpx.K₀
        if length(edgesfromvertex(v, cpx)) == 1
            push!(bdy,v)
        end
    end
    return bdy
end
export boundary

#returns set of triangles in cps containing edge e
function edgefan( e::Edge, cpx::SimplicialComplex )
    output = Triangle[]
    twoskel = cpx.K₂
    for tri in twoskel
        if e in edgesof(tri, false)
            push!(output, tri)
        end
    end
    return output
end
export edgefan

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
        componentoneskel = Edge[initedge]
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
function isdisklike( v::Vertex, cpx::SimplicialComplex )
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
