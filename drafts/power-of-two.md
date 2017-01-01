
# Load Balancing and the Power of Two

In problem <number two?> we took a look round robin load balancing,
which is excellent in cases you can't inspect the queue depth of workers,
but can also end up with unpredictably latency for tasks if they happen
to get stuck behind a long running task.

If you are able to inspect the queue depth of workers
(or if you can track incoming and outgoing requests to
always know the queue depth), then
a significant improvement to this approach would be to check
the depth of every worker and assign the task to the worker with
the smallest depth. (A further improvement would be to estimate the
expected time tasks will take, perhaps using historical latencies,
and then assign to the worker that is expected to clear its existing
workload the earliest.)

However, if you imagine a large, distributed system, then maintaining
that kind of global awareness tends to become expensive (distributed coordination)
or risky (introducing single points of failure), especially in the context
of load information which changes from millisecond to millisecond as requests
are completed.

Fortunately, there is a very clever strategy somewhere inbetween stateless
round-robinning and routing based on omnipotence: randomly checking two of
the possible processes and routing to one of them.


Let's run a similar experiment, using an improved approach to load balancing:




https://www.eecs.harvard.edu/~michaelm/postscripts/mythesis.pdf