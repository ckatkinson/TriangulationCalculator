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
#export Gluingpolygon

function boundary( P::Gluingpolygon )
    K₀ = P.K₀int ∪ P.K₀bdy
    K₁ = P.K₁int ∪ P.K₁bdy
    K₂ = P.K₂
    cpx = SimplicialComplex(K₀, K₁, K₂)
    return boundary(cpx)
end
#export boundary


#TODO: straighten this out. It has some non-unique madness going on.
#"add" triangle Δ onto P along boundary edge. Returns new polygon
function addalongedge( P::Gluingpolygon, Δ::Triangle, edge::Edges )
    anonedge = anonymize(edge)
    if anonedge in anonymize.(boundary(P)) ∩ anonymize.(edgesof(Δ))
        #do the gluing: First add new vertex to boundary:
        triverts = verticesof(Δ)
        edgeverts = anonymize.(verticesof(edge))
        newvertex = setdiff(triverts, edgeverts)[1] #newvertex is already anonymous

        #Construct new skeleta:
        newK₀int = P.K₀int #Didn't occur to me before: this procedure never makes an interior vertex!!
        newK₀bdy = push!(copy(P.K₀bdy), makeunique(newvertex)) #newvertex is in the boundary, so needs to be unique

        #Then add two new uniqEdges to boundary:
        triedges = edgesof(Δ)
        println("\n triedges = $triedges \n")
        newedges = setdiff(anonymize.(triedges), [anonedge])
        println("\n newedges = $newedges \n")
        newK₁int = push!(copy(P.K₁int), anonedge)
        println("\n newK₁int = $newK₁int \n")


        #anonymize boundary to allow us to remove edge (easily) from old K₁bdy
        anonboundary = anonymize.(boundary(P))
        println("\n boundary of p is $anonboundary\n")
        anonnewK₁bdy = setdiff(append!(copy(anonboundary), newedges), [anonedge])
        println("\n anonnewK₁bdy of p is $anonnewK₁bdy\n")
        newK₁bdy = makeunique.(anonnewK₁bdy)

        newK₂ = push!(copy(P.K₂), Δ)

        newP = Gluingpolygon(newK₀int, newK₀bdy, newK₁int, newK₁bdy, newK₂)
        return newP
    else
        #gluing is not possible
        println("The edge is not both a boundary edge of polygon and an edge of
                the triangle") 
        return -1#probably want to figure out how to have an exception/error here
    end
#export addalongedge

end
