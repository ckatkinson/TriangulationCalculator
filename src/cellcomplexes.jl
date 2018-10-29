

#This file contains basic simplicial complex constructors and operations to
#access basic combinatorial info about them.
#
#Also, functions to test various topological properties are included
#
#
########IDK where this goes. Need research.

#Type hierarchy:
abstract type Cells end
abstract type Vertices <: Cells end
abstract type Edges <: Cells end
abstract type Triangles <: Cells end
export Cells, Vertices, Edges, Triangles



#### Basic cells. Each uniqCell comes with a uuid so that multiple instances don't
#conglomerate. :
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

