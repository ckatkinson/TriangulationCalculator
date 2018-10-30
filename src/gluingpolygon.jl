#this should be like a SimplicalComplex but with "interior" edges and vertices
#nonunique and boundary edges and vertices uniqCells. I think it should be
#mutable so that I an slowly build it up, one triangle at a time. Or not. We'll
#see. Also, it should be simplicial. May have to implement barycentric subdiv
#elsewhere...
mutable struct gluingpolygon
    K₀int::array{Vertex}
    K₀bdy::array{uniqVertex}
    K₁int::array{Edge}
    K₁bdy::array{uniqEdge}
    K₂::array{Triangle}
end

#"add" triangle Δ onto P along boundary edge
function addalongedge( P::gluingpolygon, Δ::Triangles, edge::uniqEdge )
    if edge in anonymize.(boundary(P)) ∩ anonymize.(edgesof(Δ))
        #do the gluing
        
    else
        #gluing is not possible
        println("The edge is not both a boundary edge of polygon and an edge of
                the triangle") 
        return -1#probably want to figure out how to have an exception/error here
    end

end
