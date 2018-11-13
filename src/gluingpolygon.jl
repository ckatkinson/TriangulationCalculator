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
function addalongedge!( P::Gluingpolygon, Δ::Triangle, edge::uniqEdge )
    anonedge = anonymize(edge)
    #if anonedge in anonymize.(P.K₁) ∩ anonymize.(edgesof(Δ))
    if (anonedge in anonymize.(P.K₁)) && (anonedge in Δ)        
        #do the gluing: First add new vertex to boundary:
        triverts = verticesof(Δ)
        edgeverts = anonymize.(verticesof(edge))
        newvertex = makeunique(setdiff(triverts, edgeverts)[1])

        #make two new edges for P with the correct vertices:
        newedge1 = uniqEdge( makeunique(edge.head), newvertex )
        newedge2 = uniqEdge( newvertex, makeunique(edge.tail) )

        #remove edge from P:
        P.K₁ = filter(x->x≠edge, P.K₁)

        #add two new edges to P:
        push!(P.K₁, newedge1, newedge2) 
    else
        #gluing is not possible
        println("The edge edge is not both a boundary edge of polygon and an edge of
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
        edges = copy(polygon.K₁)
        for edge in polygon.K₁
            new = edgefan(anonymize(edge), cpx) ∩ triangles
            if length(new) ≠ 0
                newtriangle = new[1]
                if edge in newtriangle
                    addalongedge!(polygon, newtriangle, edge)
                #else
                    #addalongedge!(polygon, newtriangle, reverseedge(anonymize(edge)))
                end
                triangles = filter(x->x≠newtriangle, triangles)
            end
        end
    end
    return polygon
end
export makepolygonalsurface

function labelededge( edge::Edges, label::Char )
    h = anonymize(edge.head).index
    t = anonymize(edge.tail).index
    return string(h, "-",label,"-", t)
end


function edgesinorder( p::Gluingpolygon )
    numedges = length(p.K₁)
    edges = copy(p.K₁)
    edge = edges[1]
    output = [edge]
    edges = filter(x->x≠edge, edges)
    while length(output)< numedges
        tailvertex = edge.tail
        for nextedge in edges 
            if nextedge.head.id == tailvertex.id
                edge = nextedge
                push!(output, edge)
                edges = filter(x->x≠edge, edges)
            elseif nextedge.tail.id == tailvertex.id
                edges = filter(x->x≠nextedge, edges)
                edge = reverseedge( nextedge )
                push!(output, edge)
            end
        end
    end
    return output
end

#THERE's a bug in this: If there are two many vertices, then we run out of
#characters...
function surfacerelation( p::Gluingpolygon )
    eop = edgesinorder(p)
    label = 97 #Char(97) is 'a'
    labeldict = Dict()
    for edge in eop
        if !([edge.head.index, edge.tail.index] in keys(labeldict))
            labeldict[[edge.head.index, edge.tail.index]] = Char(label)
            labeldict[[edge.tail.index, edge.head.index]] = uppercase(Char(label))
            label += 1
        end
    end
    word = ""
    for edge in eop
        word *= labeldict[[edge.head.index, edge.tail.index]]
    end
    return word
end


function Base.show(io::IO, p::Gluingpolygon)  
    label = 97 #Char(97) is 'a'
    labeldict = Dict()
    #for edge in p.K₁
    edgesordered = edgesinorder(p)
    for edge in edgesordered
        if !(edge.head.id in keys(labeldict))
            #labeldict[edge.head.id] = Char(label)
            labeldict[edge.head.id] = label
            label += 1
        elseif !(edge.tail.id in keys(labeldict))
            #labeldict[edge.tail.id] = Char(label)
            labeldict[edge.tail.id] = label
            label += 1
        end
    end

    output = "-"
    #for edge in p.K₁
    for edge in edgesordered
        h = string(edge.head.index)
        t = string(edge.tail.index)
        #output *= "("*labeldict[edge.head.id]*")" * "-"* h * "," * t * "-" 
        output *= "("*string(labeldict[edge.head.id])*")" * "-"* h * "," * t * "-" 
    end
    #output *= "(" * labeldict[edgesordered[end].tail.id] *")-"
    output *= "(" * string(labeldict[edgesordered[end].tail.id]) *")-"

    print(io,"Boundary of gluing polygon has labeled edges:\n", output,"\n\n")
end













