
#Computes euler characteristic
function eulercharacteristic( simp::SimplicialComplex )
    v = length(simp.K₀)
    e = length(simp.K₁)
    f = length(simp.K₂)
    return v - e + f
end
export eulercharacteristic


#isonemanifold checks if a OneComplex is a closed 1-manifold. Simply need to check that
#each vertex is in exactly two edges.
function isonemanifold( cpx::OneComplex )
    for vertex in cpx.K₀
        if length(edgesfromvertex(vertex, cpx)) != 2
            return false
        end
    end
    return true
end


#issurface function implements the algorithm suggested by the definition of a
#triangulated surface in Kinsley. The definition says that a triangluation has
#underlying space a surface if 
#1) Each edges is contained in exactly two triangles.
#2) For each vertex v, the set of triangles containing v can be cyclically
#ordered so that two triangles in the set share an edge iff their indices differ
#by 1 (mod numtris at v) This is implemented above as the isdisklike function.

function issurface( cpx::SimplicialComplex)
    oneskel = cpx.K₁
    #Check condition 1)
    for e in oneskel
        if length(edgefan(e, cpx))!=2
            return false
        end
    end
    #check condition 2)
    for v in cpx.K₀
        if !isdisklike(v, cpx)
            return false
        end
    end
    return true
end
export issurface
##################^^^^^THat's one file, I think.

#checks of one-manifold is connected
#
function isconnected( cpx::OneComplex )
    if isonemanifold(cpx)
        initedge = cpx.K₁[1]
        componentoneskel = Edges[initedge]
        component = OneComplex(componentoneskel)
        cptbdy = boundary(component)
        while !(isonemanifold(component))
            for v in cptbdy
                estar = edgesfromvertex(v, cpx)
                for edge in estar
                    if !(edge in componentoneskel)
                        push!(componentoneskel, edge)
                    end
                end
            end
            component = OneComplex(componentoneskel)
            cptbdy = boundary(component)
        end
        if length(component.K₁) == length(cpx.K₁)
            return true
        else return false
        end
    end
println("Sorry! This only checks if closed one-manifolds are connected right now.\n 
		Your complex is not a closed one-manifold")
end
##################^^^^^THat's one file, I think.

#Checks of vertex v is surrounded by a single disk of 2-cells. Condition 2 in
#Kinsley's triangulated surface definition.
function isdisklike( v::Vertices, cpx::SimplicialComplex )
    starv = SimplicialComplex(star(v, cpx))
    bstarv = OneComplex(boundary(starv))
    return isonemanifold(bstarv) && isconnected(bstarv)
end
export isdisklike


#checks if triangulated surface is connected. Does this need to be
#specialized to just surfaces or will the ideas from the combinatorial
#connectedness theorem work for general triangulations? I have to think about
#that. Right now, it assumes that cpx is a surface

function isconnected( cpx::SimplicialComplex)
  if issurface(cpx)
  inittriangle = cpx.K₂[1]
  componenttwoskel = Triangles[inittriangle]
  component = SimplicialComplex(componenttwoskel)
  cptbdy = boundary(component)
    while !(issurface(component)) #If I can figure out how to check if we've enumerated a whole 
      						    #component, things will work for general complexes...
        for e in cptbdy
      	efan = edgefan(e, cpx)
      	for tri in efan
      	  if !(tri in componenttwoskel)
      		push!(componenttwoskel, tri)
      	  end
      	end
        end
        component = SimplicialComplex(componenttwoskel)
        cptbdy = boundary(component)
    end
      if length(component.K₂) == length(cpx.K₂)
        return true
      else return false
    end
  end
println("Sorry! This only checks if closed surfaces are connected right now.\n 
		Your complex is not a closed surface")
end
export isconnected
