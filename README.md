# TriangulationCalculator
Implements some of the concepts from my topology course related to triangulations of surfaces.

This is a work-in-progress and will likely change drastically.

I'm teaching an introductory topology course (Math 4221) at UMN Morris. We're following L. Christine Kinsley's 
book "Topology of Surfaces". Just to see if I could, I decided to learn a bit more about Julia by attempting to implement some of the triangulation stuff.

To use this, first be sure to have a working Julia installation.

Start the Julia REPL from the directory in which you have the file TriangulationCalculator.jl. You'll need to add the path to the LOAD_PATH array:
    
    push!(LOAD_PATH, "./")
    
(You can get around doing this every time you start julia by adding the above command to ~/julia/config/startup.jl) I'm assuming that you're working on Mac or Linux. I don't know about how to specify path on a Windows machine. Sorry!
    
Then import the module by typing:

    using TriangulationCalculator

You can then build up a simplicial complex. There are various ways of constructing a complex (see the code for the various constructors). The most straightforward ways is via specifying the list of triangles. Vertices are named by integers. Here's an example complex:

    triangles = [Triangle(1,2,3), Triangle(1,2,4), Triangle(1,3,4), Triangle(5,2,3), Triangle(5,2,4), Triangle(5,3,4)]  
    cpx = SimplicialComplex(triangles)
    
This is a simplicial complex on the 2-sphere. We can check that it is a surface by running

    issurface(cpx)
    
It should return true for this example.

We can also check that it is connected by running

    isconnected(cpx)
    
It should return true for this example.

Also, we can compute its Euler characteristic

    eulercharacteristic(cpx)
    
and get 2. 

If you're trying to understand the topology of a surface, you can get a planar
polygon with identifications representing the surface via

    makepolygonsurface(cpx)

This will return something of the form
    
    -(a)-14-(b)-45-(c)-52-(d)-25-(e)-53-(f)-35-(g)-54-(h)-41-(a)-

The letters in parenthesis represent the vertices of the polygon. The numerals
between represent edge pairings with gluing represented by the order of the
numerals. The left-most vertices and right-most vertices are the same vertex.

To get a string representing a surface relation (see section on Tietze
transformations in the textbook), call the following:

    p = makepolyonsurface(cpx)
    surfacerelation(p)

To identify a surface, represent it as a SimplicialComplex and then

    surfaceid(cpx)

will print its topological type.
