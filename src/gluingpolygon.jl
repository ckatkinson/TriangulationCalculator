mutable struct Gluingpolygon
    K₁::Array{uniqEdge}
end

function Gluingpolygon( triangle::Triangles )
    verts = verticesof(triangle)
    uv = makeunique.(verts)
    e1, e2, e3 = uniqEdge(uv[1],uv[2]), uniqEdge(uv[1],uv[3]), uniqEdge(uv[2],uv[3])
    return Gluingpolygon([e1,e2,e3])
end

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
        for edge in polygon.K₁
            new = edgefan(anonymize(edge), cpx) ∩ triangles
            if length(new) ≠ 0
                newtriangle = new[1]
                addalongedge!(polygon, newtriangle, edge)
                triangles = filter(x->x≠newtriangle, triangles)
            end
        end
    end
    return polygon
end

function labelededge( edge::Edges, label::Char )
    h = anonymize(edge.head).index
    t = anonymize(edge.tail).index
    return string(h, "-",label,"-", t)
end


function Base.show(io::IO, p::Gluingpolygon)  
    label = 97 #Char(97) is 'a'
    labeldict = Dict()
    for edge in p.K₁
        if !(edge.head.id in keys(labeldict))
            labeldict[edge.head.id] = Char(label)
            label += 1
        elseif !(edge.tail.id in keys(labeldict))
            labeldict[edge.tail.id] = Char(label)
            label += 1
        end
    end

    output = ""
    for edge in p.K₁
        h = string(edge.head.index)
        t = string(edge.tail.index)
        output *= labeldict[edge.head.id] * "-"* h * t * "-" * labeldict[edge.tail.id] * ", "
    end

    print(io,"Boundary of gluing polygon has labeled edges:\n", output,"\n")
end












