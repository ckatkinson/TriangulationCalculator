
function repeatedchar(string::String)
    for i = 1:length(string)-1
        for j = i+1:length(string)
            if string[i] == string[j]
                return true
            end
        end
    end
    return false
end

"""
    isorientable( cpx::SimplicialComplex )

Returns boolean indicating whether `cpx` represents an orientable surface.
"""
function isorientable( cpx::SimplicialComplex )
    p = makepolygonsurface(cpx)
    word = surfacerelation(p)
    return !(repeatedchar(word))
end

"""
    surfaceid( cpx::SimplicialComplex )

Prints the topological type of the surface underlying the complex `cpx`.
"""
function surfaceid( cpx::SimplicialComplex )
    if !issurface(cpx)
        println("This is not a surface")
        return -1
    else
        orientable = isorientable(cpx)
        χ = eulercharacteristic(cpx)
        if orientable
            genus = Int((2-χ)/2)
            println("This surface is orientable of genus $genus")
        else
            genus = 2-χ
            println("This surface is nonorientable with nonorientable genus $genus")
        end
    end
end




