#this should be like a SimplicalComplex but with "interior" edges and vertices
#nonunique and boundary edges and vertices uniqCells. I think it should be
#mutable so that I an slowly build it up, one triangle at a time. Or not. We'll
#see. Also, it should be simplicial. May have to implement barycentric subdiv
#elsewhere...
#
mutable struct Gluingpolygon
    K₁::Array{uniqEdge}
end

function Gluingpolygon( triangle::Triangles )
    verts = verticesof(triangle)
    uv = makeunique.(verts)
    e1, e2, e3 = uniqEdge(uv[1],uv[2]), uniqEdge(uv[1],uv[3]), uniqEdge(uv[2],uv[3])
    return Gluingpolygon([e1,e2,e3])
end

#OK! I've got the right idea. I don't need to worry about the vertices in the
#gluing polygon. I don't even need to keep track of the triangles. I think just
#keeping track of boundary edges is enough to make makepolygonsurface work
#
#Everything needs to be changed (via simplifying...)


#Also, when I actually use this in the makegluingpolygon function, I want to be
#sure that the vertices have the same ids when two edges are meant to be glued

#function boundary( P::Gluingpolygon )
    #K₁ = P.K₁bdy
    #cpx = OneComplex(K₁)
    #return cpx
#end
#Don't need that anymore!


#function boundary( P::Gluingpolygon )
#    K₀ = P.K₀int ∪ P.K₀bdy
#    K₁ = P.K₁int ∪ P.K₁bdy
#    K₂ = P.K₂
#    cpx = SimplicialComplex(K₀, K₁, K₂)
#    return boundary(cpx)
#end


"""
    addalongedge( P::Gluingpolygon, Δ::Triangle, edge::Edges )

Returns the Gluingpolygon resulting from gluing `Δ` to `P` along `edge`. `edge` is meant to be thought of as an edge of `P`.
"""
function addalongedge!( P::Gluingpolygon, Δ::Triangle, edge::Edges )
    anonedge = anonymize(edge)
    if anonedge in anonymize.(P.K₁) ∩ anonymize.(edgesof(Δ))
        #do the gluing: First add new vertex to boundary:
        triverts = verticesof(Δ)
        edgeverts = anonymize.(verticesof(edge))
        newvertex = makeunique(setdiff(triverts, edgeverts)[1])

        #make two new edges for P with the correct vertices:
        newedge1 = uniqEdge( edge.head, newvertex )
        newedge2 = uniqEdge( newvertex, edge.tail )

        #remove edge from P:
        P.K₁ = filter(x->x≠edge, P.K₁)

        #add two new edges to P:
        push!(P.K₁, newedge1, newedge2) 
    else
        #gluing is not possible
        println("The edge is not both a boundary edge of polygon and an edge of
                the triangle") 
        return -1#probably want to figure out how to have an exception/error here
    end
end


"""
    makepolygonsurface( cpx::SimplicialComplex )

Returns Gluingpolygon representing the surface underlying `cpx`.
"""
function makepolygonsurface( cpx::SimplicialComplex )
    triangles = copy(cpx.K₂)
    inittriangle = triangles[1]
    triangles = filter(x->x≠inittriangle, triangles)
    polygon = Gluingpolygon( inittriangle )
    while length(triangles)≠0
        for edge in anonymize.(polygon.K₁)
            new = edgefan(edge, cpx) ∩ triangles
            if length(new) ≠ 0
                newtriangle = new[1]
                addalongedge!(polygon, newtriangle, edge)
                triangles = filter(x->x≠newtriangle, triangles)
            end
        end
    end
    return polygon
end
#IT WORKS!!!! (almost... The remaining issue is that the boundary edges are each
#only added in once. Also, the more daunting task of figuring out how to
#determine orientation around the boundary is still there)

function Base.show(io::IO, p::Gluingpolygon)  
    print(io, "Boundary edges: ", p.K₁,"\n")
end











