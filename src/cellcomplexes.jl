

#This file contains basic simplicial complex constructors and operations to
#access basic combinatorial info about them.

#Type hierarchy:
abstract type Cells end
abstract type Vertices <: Cells end
abstract type Edges <: Cells end
abstract type Triangles <: Cells end
export Cells, Vertices, Edges, Triangles




#####Basic cells.
#
"""
    Vertex(a)

Constructs a vertex with index `a`.
"""
struct Vertex <: Vertices
    index::Int
end
export Vertex

"""
    Edge(u, v)

Constructs an edge between vertices `u` and `v`.
"""
struct Edge <: Edges
    head::Vertex
    tail::Vertex
end
export Edge

"""
    Edge(a, b)

Constructs an edge between vertices `Vertex(a)` and `Vertex(b)`.
"""
function Edge(a::Int, b::Int)
    u = Vertex(a)
    v = Vertex(b)
    return Edge(u,v)
end

"""
    Triangle(u, v, w)

Constructs a triangle with vertices `u`, `v`, and `w`.
"""
struct Triangle <: Triangles
    vertex1::Vertex
    vertex2::Vertex
    vertex3::Vertex
end
export Triangle

"""
    Triangle(a, b, c)

Constructs a triangle with vertices `Vertex(a)`, `Vertex(b)`, and `Vertex(c)`.
"""
function Triangle( a::Int, b::Int, c::Int )
    u = Vertex(a)
    v = Vertex(b)
    w = Vertex(c)
    return Triangle(u, v, w )
end

function Triangle(tuple::Tuple{Int, Int, Int})
    return Triangle(tuple...)
end

"""
    Triangle(verts::Array{Int, 1})

Constructs a triangle with vertex indices coming from a 3-long array of Ints.

# Example
```jldoctest
julia> verts = [1, 2, 3];
julia> t = Triangle(verts)
Triangle(Vertex(1), Vertex(2), Vertex(3))
```
"""
function Triangle( verts::Array{Int,1} )
    if length(verts) == 3
        return Triangle(verts...)
    else
        println("input must be an array of length 3")
    end
end

"""
    uniqVertex(a,id)

Constructs a vertex with index `a` and a uuid `id`.
"""
struct uniqVertex <: Vertices
    index::Int
    id::UUID
end
export uniqVertex

"""
    uniqVertex(a)

Constructs a vertex with index `a` and a randomly seeded uuid.
"""
function uniqVertex(a::Int)
    iden = uuid1(rng)
    return uniqVertex(a, iden)
end

"""
    uniqEdge(u,v,id)

Constructs an edge with vertices `u` and `v` with uuid `id`.
"""
struct uniqEdge <: Edges
    head::uniqVertex
    tail::uniqVertex
    id::UUID
end
export uniqEdge

"""
    uniqEdge(u,v)

Constructs an edge with vertices `u` and `v` with randomly seeded uuid.
"""
function uniqEdge(v::uniqVertex, w::uniqVertex)
    iden = uuid1(rng)
    return uniqEdge(v, w, iden)
end

"""
    uniqEdge(a,b)

Constructs an edge with vertices having indices `a` and `b` with randomly seeded uuid.
"""
function uniqEdge(a::Int, b::Int)
    u = uniqVertex(a)
    v = uniqVertex(b)
    iden = uuid1(rng)
    return uniqEdge(u,v,iden)
end

"""
    uniqTriangle(u,v,w,id)

Constructs a triangle with vertices `u`, `v`, and `w` with uuid `id`. Note that
the vertices must be `uniqVertex` This may or may not be what you intend.  
"""
struct uniqTriangle <: Triangles
    vertex1::uniqVertex
    vertex2::uniqVertex
    vertex3::uniqVertex
    id::UUID
end
export uniqTriangle

"""
    uniqTriangle(u,v,w)

Constructs a triangle with vertices with indices `a`, `b`, and `c`. Note that the vertices will be `uniqVertex` This may or may not be what you intend.
"""
function uniqTriangle( a::Int, b::Int, c::Int )
    u = uniqVertex(a)
    v = uniqVertex(b)
    w = uniqVertex(c)
    iden = uuid1(rng)
    return uniqTriangle(u, v, w, iden)
end

"""
    uniqTriangle(verts::Array{Int, 1})

Constructs a triangle with vertex indices coming from a 3-long array of Ints and randomly seeded uuid.
"""
function uniqTriangle( verts::Array{Int,1} )
    iden = uuid1(rng)
    if length(verts) == 3
        return uniqTriangle(verts...,iden)
    else
        println("input must be an array of length 3")
    end
end



"""
    anonymize(cell::Cells)

Converts uniqCell to a Cell, wiping out the uuid info.
"""
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

"""
    makeunique(cell::Cells)

Returns a uniqCell having the same index data as cell. Careful: right now, if you apply this to an edge or triangle, the edges and triangles INSIDE might not be uniq. I'm not sure what I need just yet...
"""
function makeunique(cell::Cells)
    if :id in fieldnames(typeof(cell))
        return cell
    elseif typeof(cell) == Vertex
            return uniqVertex(cell.index)
    elseif typeof(cell) == Edge
            return uniqEdge(cell.head, cell.tail)
    elseif typeof(cell) == Triangle
            return uniqTriangle(cell.vertex1, cell.vertex2, cell.vertex3)
    end
end





"""
    edgesof( Δ )

Returns `array{Edges}` containing edges of Δ
"""
function edgesof( Δ::Triangles )
    edges = [uniqEdge(Δ.vertex1, Δ.vertex2), uniqEdge(Δ.vertex1, Δ.vertex3), uniqEdge(Δ.vertex2, Δ.vertex3)]
    return edges
end

"""
    edgesof( Δ )

Returns `array{Edges}` containing edges of Δ
"""
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

#I need to add a bunch of these to make printing uniq stuff less ugly. This
#might be excessively stripped down...
Base.show(io::IO, Δ::uniqTriangle) = print(io, "uniqTriangle with vertices ", anonymize.(verticesof(Δ)))
