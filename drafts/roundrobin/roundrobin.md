
# Round Robin Load Balancing

As a stateless service takes more load, it is common to run multiple copies of that
service behind a load balancer and use the load balancer to distribute load across those
processes somewhat evenly. One of the simplest and most frequently seem algorithms is
the round-robin approach.

Let's take a look at how well that works, designing a program which implements this functionality:

1. Simulate receiving incoming requests via `route(duration)`,
    which represents a new incoming request which will take `duration` units of time to process.
2. Cause time to `advance(duration)` forward by `duration` units of time.
3. Check depth of work queues via `depth(queue)`, where `queue` is the zero-indexed
    position of a simulated worker with traffic being routed to it.

*Please note that validation will assume you always start in position zero.*

Input for the program will be sent over stdin, starting with a single
line indicating the number of workers to include behind the load balancer:

    3

Subsequent lines will submit a new request to route, advance time forward
to allow workers to process tasks, or check the depth of a queue. For example,
submitting three requests of 10, 5 and 1 units of time respectively:

    r 10
    r 5
    r 1

Then we could check the depths of the first and last queue,
both of which would return 1:

    d 0
    d 2

Then we could advance time forward by 4 units, which would allow the
third request (scheduled to the third worker at position 2) to complete:

    a 4
    d 0
    d 1
    d 2

In which case we'd expect this output:

    1
    0
    0

Building on that, a complete example of input is:

    r 1
    r 1
    r 1
    d 0
    a 1
    d 0
    r 5
    r 4
    r 3
    r 2
    r 1
    r 1
    r 2
    r 3
    r 4
    d 2
    t 1
    d 2
    d 1
    t 1
    d 2

Then the output will be:

    <insert here>


Once you're ready, you can download the data set:

    <curl instructions>

And submit your output for review:

    <curl instructions>

As you likely noticed, this example shows a bit of why
round robin load balancing performs somewhat poorly with
non-uniformed workloads, causing short requests to get blocked
behind long requests, and even for some workers to remain idle
while others have large backlogs.

In future problems we'll be looking at some more promising load
balancing strategies for varied workloads, but it's worth mentioning
that one of the critical strengths of round robinning is that it does
not require the ability to inspect the queue depth of the working processes,
which can be complex to implement or expensive to check
if you're balancing over a large number of processes.


# Readings

