module Complexes
#This module contains basic simplicial complex constructors and operations to
#access basic combinatorial info about them.

#### Basic cells:
#
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

function edgesof( Δ::Triangle )
    edges = [Edge(Δ.vertex1, Δ.vertex2), Edge(Δ.vertex1, Δ.vertex3), Edge(Δ.vertex2, Δ.vertex3)]
    return edges
end

function verticesof( Δ::Triangle )
    return [Δ.vertex1, Δ.vertex2, Δ.vertex3]
end

function verticesof( e::Edge )
    return [e.head, e.tail]
end


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
        for vertex ∈ verticesof(e)
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


end
