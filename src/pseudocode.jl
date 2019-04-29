#This file provides a pseudocode for algorithm one that provides the architecture for the complete algorithm. Some of these objects can change.


function coursematch(M,
    k,
    βmax,
    besterror,
    t,
    Np, #to be removed from function's arguments, and replaced in the code by neighb_fun
    s::Student)

# Arguments
# s::Student : the student's problem from student.jl
#
#
#
#

    ### Initialization
    # New search price
    ptild = Array{Int, M}
    # Initial guess for p
    p = Array{Int, M}
    # Price that gives the best error
    pstar = Array[]
    # Best error in a searchstart
    searcherror = Array[]
    # Neighbors of the search
    DoubleN = Array[]
    # boolean. true if a new search price has been found (one that does not generate the same demand as one that is in the tabu list)
    foundnextstep = Array{Bool, 1}
    # the demand for courses at search price
    dem = zeros(M)
    # Error in the current search.
    currenterror = Array[]
    # τ vector of Tabu list
    τ = Array[]


    starttime = Dates.Time(now())
    while (Dates.Time(now()) - starttime).value < t * 1000000000
        # Time in nanoseconds
        #repeat from l.25 to 52. This is a do until runtime > t.
        p = zeros(M)#Initial guess for p. Will be replaced also

        # demand function: see demand.jl finished
        # α : make sure that returns root of the sum of squares (so far: combination of clearing.jl & PseudoClearingError (modified))
        searcherror =  α.(demand!(p, s))


        c = 0
        # while loop from l.7 to 34
        while c < 5

            ### Initialize the values for the findnextprices function
            #
            # DoubleN = copy(neighb_fun(ARG))
            DoubleN = copy(Np)  # going to be neighb_fun
            #DoubleN = N(p) #Don't forget this needs to be sorted by clearing error (Issue #6)

            foundnextstep[1] = false

            # repeat from l. 10 to 16

            # What function is this?
            # Takes all possible neighbouring vectors from DoubleN, and find the "best" one (based on clearing error etc)
            # excluding the vectors in the Tabu list
            findnextprices!(ptild,  DoubleN, dem, foundnextstep, τ)
            # if from line 17 to 18
            if isempty(DoubleN) == true
                c = 5
            end
            #l. 19 to 33
            # should be similar to isempty(DoubleN) == false
            # is it also returned by the function
            if foundnextstep[1] == true
                # Push the chosen allocation vector to the Tabu list (so that it is not considered again in the future)
                # Push the discarded neighbouring (allocation) vectors to the Tabu list
                push!(τ,copy(dem))
                # Replace the search price (current optimal price vector) by ptild
                p = copy(ptild)
                # Compute search error with new allocation vector
                currenterror =  α(dem)
                # If searcherror > currenterror :
                # - set c to 0 if improve error, otherwise c to c+1
                # - replace error if improve solution
                # - replace pstar by current p if improve solution
                # - replace error by currenterror if improve solution
                c = resetcounter(currenterror, searcherror, c)
                searcherror = replacesearcherror(currenterror, searcherror)
                pstar = replacepstar(currenterror, besterror, p, pstar)
                besterror = replacebesterror(currenterror, besterror)
            end
            println("we are at step $c")
        end
    end
    # return the optimal vector
    return pstar
end

M = 5 #Number of courses offered
k = 3 #Number of courses students take
βmax = 20 #Maximum budget
t = 1 #time in seconds
besterror = 100 #for now
Np = Array[[0,0,0,0,0],[9,40,5,2,0], [1,1,1,1,1], [1,2,3,0,0], [9,40,5,2,0], [32,40,100,1,2], [10,20,30,3,0]]
pstar = coursematch(M, k, βmax, besterror, t, Np)
