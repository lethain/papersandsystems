# Set the working application directory
# working_directory "/path/to/your/app"
working_directory "/home/papers/papersandsystems"

# Unicorn PID file location
# pid "/path/to/pids/unicorn.pid"
pid "/home/papers/unicorn.pid"

# Path to logs
# stderr_path "/path/to/logs/papers_unicorn.log"
# stdout_path "/path/to/logs/papers_unicorn.log"
stderr_path "/var/log/papers_unicorn.out"
stdout_path "/var/log/papers_unicorn.err"

# Unicorn socket
# listen "/tmp/unicorn.[app name].sock"
listen "/tmp/unicorn.papers.sock"

# Number of processes
worker_processes 4

# Time-out
timeout 30
