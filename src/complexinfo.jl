
#Returns the star of vertex v in cpx (all triangles in cpx  that contain v)
function star( v::Vertices, cpx::SimplicialComplex )
    output = Triangles[]
    twoskel = cpx.K₂
    for tri in twoskel
        if anonymize(v) in verticesof(anonymize(tri))
            push!(output, tri)
        end
    end
    return output
end
export star

#returns array of edges containing v in cpx (Works for Simplicial or One)
function edgesfromvertex( v::Vertices, cpx )
    oneskel = cpx.K₁
    edges = Edges[]
    for e in oneskel
        #if e.head == v || e.tail == v
        if equiv(e.head, v) || equiv(e.tail, v)
            push!(edges, e)
        end
    end
    return edges
end
export edgesfromvertex

#returns triangle adjacent to Δ across edge in cpx
function adjacenttriangle(Δ::Triangles, e::Edges, cpx::SimplicialComplex)
    twoskel = copy(cpx.K₂)
    filter!(tri -> (e.head in verticesof(tri) && e.tail in verticesof(tri) && tri != Δ), twoskel)
    return twoskel[1]
end
export adjacenttriangle

#returns edge adjacent to e across vertex v in cpx::OneComplex
function adjacentedge(e::Edges, v::Vertices, cpx::OneComplex)
    otheredge = filter!( edge -> edge!=e, edgesfromvertex(v, cpx))
    return otheredge[1]
end
export adjacentedge

#returns set of triangles in cps containing edge e
function edgefan( e::Edges, cpx::SimplicialComplex )
    output = Triangles[]
    twoskel = cpx.K₂
    for tri in twoskel
        if anonymize(e) in edgesof(anonymize(tri))
            push!(output, tri)
        end
    end
    return output
end
export edgefan

##################^^^^^THat's one file, I think.
#computes the boundary of a complex. Here, we'll usually compute it for a
#subcomplex

function boundary( cpx::SimplicialComplex )
  bdy = Edges[]
  for e in cpx.K₁
	if length(edgefan(e, cpx)) == 1
	  push!(bdy,e)
	end
  end
  return bdy
end

function boundary( cpx::OneComplex )
    bdy = Vertices[]
    for v in cpx.K₀
        if length(edgesfromvertex(v, cpx)) == 1
            push!(bdy,v)
        end
    end
    return bdy
end

function boundary( P::gluingpolygon )
    K₀ = P.K₀int ∪ P.K₀bdy
    K₁ = P.K₁int ∪ P.K₁bdy
    K₂ = P.K₂
    cpx = SimplicialComplex(K₀, K₁, K₂)
    return boundary(cpx)
end
export boundary
