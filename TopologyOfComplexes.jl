module TopologyOfComplexes

using Complexes
export Vertex, Edge, Triangle, OneComplex, SimplicialComplex, star
export adjacenttriangle, edgefan, randomtriangulation

#Computes euler characteristic
function eulercharacteristic( simp::SimplicialComplex )
    v = length(simp.K₀)
    e = length(simp.K₁)
    f = length(simp.K₂)
    return v - e + f
end
export eulercharacteristic


#Boolean value. Checks if the star of a vertex v in complex cpx is disklike (#2 in Kinsley's
#triangulated surface definition. Assumes that every edge is in exactly two
#triangles. The way it works is to just start at an arbitrary triangle in the
#star, and move to one of the two possible "next" triangles (cyclically around
#v) in the star. Each time we move to another triangle, increment a counter.
#When we return to the starting triangle, if the counter value equals the number
#of triangles in the star, then the star is disklike.
#This also assumes that the complex is ACTUALLY simplicial
#
#TODO: think about whether and how to check that cpx is actually simplicial. I'm
#pretty sure that our struct is cool with non-simplicial triangulations. 
#
#I think I could drastically simplify the code below using boundary. In
#short, if we can show that the boundary of the star of the vertex v is a
#single connected circle, then v is disklike.

function isdisklike( v::Vertex, cpx::SimplicialComplex )
    starv = star(v, cpx)
    edgesv = edgesfromvertex(v, cpx)
    inittriangle = starv[1]
    initedges = edgesof(inittriangle) ∩ edgesv
    currentedge = initedges[1]
    currenttriangle = adjacenttriangle(inittriangle, currentedge, cpx)
    count = 1
    while currenttriangle != inittriangle
        tempedges = edgesof(currenttriangle) ∩ edgesv
        filter!( e -> (e!=currentedge), tempedges )
        currentedge = tempedges[1]
        currenttriangle = adjacenttriangle(currenttriangle, currentedge, cpx)
        count += 1
    end
    if count == length(starv)
        return true
    else return false
    end
end
export isdisklike



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



#checks if triangulated surface is connected. Does this need to be
#specialized to just surfaces or will the ideas from the combinatorial
#connectedness theorem work for general triangulations? I have to think about
#that. Right now, it assumes that cpx is a surface

function isconnected( cpx::SimplicialComplex)
  if issurface(cpx)
  inittriangle = cpx.K₂[1]
  componenttwoskel = Triangle[inittriangle]
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

end
