#this should be like a SimplicalComplex but with "interior" edges and vertices
#nonunique and boundary edges and vertices uniqCells. I think it should be
#mutable so that I an slowly build it up, one triangle at a time. Or not. We'll
#see. Also, it should be simplicial. May have to implement barycentric subdiv
#elsewhere...
mutable struct Gluingpolygon
    K₀int::Array{Vertex}
    K₀bdy::Array{uniqVertex}
    K₁int::Array{Edge}
    K₁bdy::Array{uniqEdge}
    K₂::Array{Triangle}
end

function Gluingpolygon( tri::Triangles )
    K₀bdy = makeunique.(verticesof(tri))
    K₁bdy = makeunique.(edgesof(tri))
    return Gluingpolygon( [], K₀bdy, [], K₁bdy, [tri])
end

function boundary( P::Gluingpolygon )
    K₀ = P.K₀bdy
    K₁ = P.K₁bdy
    cpx = OneComplex(K₀, K₁)
    return cpx
end



#function boundary( P::Gluingpolygon )
#    K₀ = P.K₀int ∪ P.K₀bdy
#    K₁ = P.K₁int ∪ P.K₁bdy
#    K₂ = P.K₂
#    cpx = SimplicialComplex(K₀, K₁, K₂)
#    return boundary(cpx)
#end


"""
    addalongedge( P::Gluingpolygon, Δ::Triangle, edge::Edges )

Returns the Gluingpolygon resulting from gluing `Δ` to `P` along `edge`.
"""
function addalongedge( P::Gluingpolygon, Δ::Triangle, edge::Edges )
    anonedge = anonymize(edge)
    if anonedge in anonymize.(boundary(P).K₁) ∩ anonymize.(edgesof(Δ))
        #do the gluing: First add new vertex to boundary:
        triverts = verticesof(Δ)
        edgeverts = anonymize.(verticesof(edge))
        newvertex = setdiff(triverts, edgeverts)[1] #newvertex is already anonymous

        #Construct new skeleta:
        newK₀int = P.K₀int #Didn't occur to me before: this procedure never makes an interior vertex!!
        newK₀bdy = push!(copy(P.K₀bdy), makeunique(newvertex)) #newvertex is in the boundary, so needs to be unique

        #Then add two new uniqEdges to boundary:
        triedges = edgesof(Δ)
        newedges = setdiff(anonymize.(triedges), [anonedge])
        newK₁int = push!(copy(P.K₁int), anonedge)

        #anonymize boundary to allow us to remove edge (easily) from old K₁bdy
        anonboundary = anonymize.(boundary(P).K₁)
        anonnewK₁bdy = setdiff(append!(copy(anonboundary), newedges), [anonedge])
        newK₁bdy = makeunique.(anonnewK₁bdy)
        println("\nboundary edges being added in are $newK₁bdy\n")

        newK₂ = push!(copy(P.K₂), Δ)

        newP = Gluingpolygon(newK₀int, newK₀bdy, newK₁int, newK₁bdy, newK₂)
        return newP
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
        for edge in anonymize.(boundary(polygon).K₁)
            new = edgefan(edge, cpx) ∩ triangles
            if length(new) ≠ 0
                newtriangle = new[1]
                polygon = addalongedge(polygon, newtriangle, edge)
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
    print(io, "Interior vertices: ", p.K₀int,"\n")
    print(io, "Boundary vertices: ", p.K₀bdy,"\n")
    print(io, "Interior edges: ", p.K₁int,"\n")
    print(io, "Boundary edges: ", p.K₁bdy,"\n")
    print(io, "Triangles: ", p.K₂,"\n")
end











