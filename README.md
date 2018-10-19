# TriangulationCalculator
Implements some of the concepts from my topology course related to triangulations of surfaces.

This is a work-in-progress and will likely change drastically.

I'm teaching an introductory topology course (Math 4221) at UMN Morris. We're following L. Christine Kinsley's 
book "Topology of Surfaces". Just to see if I could, I decided to learn a bit more about Julia by attempting to implement some of the triangulation stuff.

To use this, first be sure to have a working Julia installation.

Start the Julia REPL from the directory in which you have the file Triangulation.jl and import the module by typing:

`using Triangulation`

You can then build up a simplicial complex. There are various ways of constructing a complex (see the code for the various constructors). The most straightforward ways is via specifying the list of triangles. Vertices are named by integers. Here's an example complex:

    triangles = [Triangle(1,2,3), Triangle(1,2,4), Triangle(1,3,4), Triangle(5,2,3), Triangle(5,2,4), Triangle(5,3,4)]  
    cpx = SimplicialComplex(triangles)
    
This is a simplicial complex on the 2-sphere. We can check that it is a surface by running

    issurface(cpx)
    
It should return true for this example.
 
 

