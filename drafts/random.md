
# Generating Pseudo-Random Numbers

Although we endeavor to build systems which behave predictably,
we often find systems that introduce a level of randomness into
their behavior: as we'll see in the "power of two in load balancing"
problem that load balancing can benefit from randomness, and it's far
from the other example.

This brings us to a quandry: how do we verify the solution to problems
when solving them depends on randomness? In this case, we've chosen to
specify a not-at-all random sequence to be used in problem sets that
require randomness.

This library must implement three methods:


1. `seed(n)` which determines the starting point for the sequence of numbers.
1. `pick(low, high)` typically used for selecting an element from an array,
    for example `pick(0, 5)` for an element in an array of length five,
    where `low` is inclusive and `high` is exclusive.
2. `next` should generate the next number in the sequence

The 



Randomness is a matter of life

- use this thing: http://eprint.iacr.org/2011/007.pdf the KISS pseudo-random number genreator


https://github.com/cmcqueen/simplerandom/tree/master/python

https://www.eecs.harvard.edu/~michaelm/postscripts/mythesis.pdf
raft or swim - one uses randomness, I forget