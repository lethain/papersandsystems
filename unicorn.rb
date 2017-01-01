# Set the working application directory
working_directory "/home/papers/papersandsystems"

# Unicorn PID file location
pid "/home/papers/unicorn.pid"

# Path to logs
stderr_path "/home/papers/papers_unicorn.out"
stdout_path "/home/papers/papers_unicorn.err"

# Unicorn socket
listen "127.0.0.1:9292"

# Number of processes
worker_processes 4

# Time-out
timeout 30
