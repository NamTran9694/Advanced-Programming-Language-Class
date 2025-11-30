JAVA DATA PROCESSING SYSTEM
===========================

This program implements a multi-threaded Data Processing System in Java.
It demonstrates concurrency, shared resource management, synchronization,
exception handling, and logging.

Multiple worker threads retrieve tasks from a shared queue, process them,
and write results to an output file.


-------------------------------------
1. PROJECT FILES
-------------------------------------

DataProcessingSystem.java
(java_results.txt will be generated after running)


-------------------------------------
2. REQUIREMENTS
-------------------------------------

- Java Development Kit (JDK) 8 or later (JDK 17 recommended)
- java and javac must be available in PATH

Check installation:
    java -version
    javac -version


-------------------------------------
3. HOW TO COMPILE AND RUN
-------------------------------------

Step 1. Navigate to the java folder:
    cd java

Step 2. Compile the program:
    javac DataProcessingSystem.java

This creates:
    DataProcessingSystem.class

Step 3. Run the program:
    java DataProcessingSystem


-------------------------------------
4. EXAMPLE CONSOLE OUTPUT
-------------------------------------

INFO: Worker 1 started.
INFO: Worker 2 started.
INFO: Worker 1 picked task 3
INFO: Worker 1 finished task 3
SEVERE: Worker 2 error processing task 7 (simulated error)
INFO: Main: writing results to java_results.txt
INFO: Main: processing complete.


-------------------------------------
5. OUTPUT FILE
-------------------------------------

After running, the program generates:
    java_results.txt

Sample content:
    Task 1 processed by worker 2 => PAYLOAD-1
    Task 2 processed by worker 4 => PAYLOAD-2
    Task 3 processed by worker 1 => PAYLOAD-3

Tasks like 7, 14, etc. will be missing due to simulated errors.


-------------------------------------
6. HOW THE PROGRAM WORKS
-------------------------------------

- Shared queue implemented with LinkedBlockingQueue
- Worker threads managed with ExecutorService (Fixed Thread Pool)
- Workers take tasks, process them, and write results
- Synchronization:
      Collections.synchronizedList for shared results list
- Safe shutdown using a "poison pill" (Task ID = -1)
- Exception handling:
      InterruptedException
      IOException
      RuntimeException
- Logging using java.util.logging.Logger


-------------------------------------
7. SUMMARY
-------------------------------------

The Java version demonstrates:
- Multi-threaded concurrency
- Thread-safe task queue
- Worker lifecycle management
- Graceful shutdown
- Exception handling and logging
- File output

