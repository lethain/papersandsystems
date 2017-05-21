# Set the working application directory
working_directory '/var/papers'

# Unicorn PID file location
pid '/home/papers/unicorn.pid'

# Path to logs
#stderr_path '/var/papers/papers_unicorn.out'
#stdout_path '/var/papers/papers_unicorn.err'

# Unicorn socket
listen '0.0.0.0:9292'

# Number of processes
worker_processes 4

# Time-out
timeout 30
