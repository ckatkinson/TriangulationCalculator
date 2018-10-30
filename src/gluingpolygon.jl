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
#"add" triangle Δ onto P along boundary edge
function addalongedge!( P::Gluingpolygon, Δ::Triangles, edge::uniqEdge )
    #these "in"'s probably don't work as is.
    if anonymize(edge) in anonymize.(boundary(P)) ∩ anonymize.(edgesof(Δ))
        #do the gluing: First add new vertex to boundary:
        triverts = anonymize.(verticesof(Δ))
        edgeverts = anonymize.(verticesof(edge))
        for vert in setdiff(triverts,edgeverts)
            P.K₀int = setdiff(P.K₀int, [anonymize(vert)])
            push!(P.K₀bdy, makeunique(vert))         
        end
        #Then add two new uniqEdges to boundary:
        triedges = anonymize.(edgesof(Δ))
        for e in setdiff(triedges, [anonymize(edge)])
            push!(P.K₁bdy, makeunique(e))
        end
        #and add the gluing edge to the interior edges
        push!(P.K₁int, anonymize(edge))
        #remove edge form boundary edges
        P.K₁bdy = setdiff(P.K₁bdy, [edge])
        #and finally add the triangle:
        push!(P.K₂, Δ)
    else
        #gluing is not possible
        println("The edge is not both a boundary edge of polygon and an edge of
                the triangle") 
        return -1#probably want to figure out how to have an exception/error here
    end
#export addalongedge

end
