GO DATA PROCESSING SYSTEM
=========================

This program implements a concurrent Data Processing System in Go.
It uses goroutines, channels, WaitGroups, and explicit error handling.

Workers receive tasks from a shared channel, process them, and send results
to another channel for writing to a file.


-------------------------------------
1. PROJECT FILES
-------------------------------------

main.go
(go_results.txt will be generated after running)


-------------------------------------
2. REQUIREMENTS
-------------------------------------

- Go version 1.20 or newer
Check installation:
    go version


-------------------------------------
3. HOW TO RUN THE PROGRAM
-------------------------------------

Step 1. Navigate to the go folder:
    cd go

Step 2. (Optional) Initialize a Go module:
    go mod init data-processing-system

Step 3. Run the program:
    go run .
or:
    go run main.go


-------------------------------------
4. EXAMPLE CONSOLE OUTPUT
-------------------------------------

2025/11/30 15:22:00 Worker 1 started.
2025/11/30 15:22:00 Worker 2 started.
2025/11/30 15:22:01 Worker 1 finished task 2
2025/11/30 15:22:01 Worker 3 error on task 7: simulated processing error
2025/11/30 15:22:03 Main: processing complete. Results written to go_results.txt


-------------------------------------
5. OUTPUT FILE
-------------------------------------

After running, the program creates:
    go_results.txt

Sample content:
    Worker 1: Task 1 processed => PAYLOAD-1
    Worker 3: Task 2 processed => PAYLOAD-2
    Worker 2: Task 3 processed => PAYLOAD-3

Tasks divisible by 7 fail intentionally and appear only in logs.


-------------------------------------
6. HOW THE PROGRAM WORKS
-------------------------------------

- Shared task queue implemented using a Go channel:
      tasks := make(chan Task)
- Workers are launched as goroutines.
- Workers read from the tasks channel, process tasks, and send results.
- A separate collector goroutine writes all results to go_results.txt.
- Synchronization:
      sync.WaitGroup ensures workers finish before closing results channel.
- Error handling:
      Functions return error values (no exceptions).
- File resources closed safely using:
      defer file.Close()


-------------------------------------
7. SUMMARY
-------------------------------------

The Go version demonstrates:
- Goroutine-based concurrency
- Task distribution through channels
- Worker lifecycle and synchronization with WaitGroup
- Explicit error handling
- Safe file writing in a concurrent system

