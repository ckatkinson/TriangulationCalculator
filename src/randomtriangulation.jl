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
