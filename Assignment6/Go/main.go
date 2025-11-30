package main

import (
	"fmt"
	"log"
	"os"
	"strings"
	"sync"
	"time"
)

// Task represents a unit of work
type Task struct {
	ID      int
	Payload string
}

// processTask simulates computational work and may return an error.
func processTask(task Task) (string, error) {
	// Simulate CPU work
	time.Sleep(500 * time.Millisecond)

	// Simulate an occasional processing error
	if task.ID%7 == 0 {
		return "", fmt.Errorf("simulated processing error for task %d", task.ID)
	}

	result := fmt.Sprintf(
		"Task %d processed => %s",
		task.ID,
		strings.ToUpper(task.Payload),
	)
	return result, nil
}

// worker reads from tasks channel, processes tasks, and sends results on results channel.
func worker(id int, tasks <-chan Task, results chan<- string, wg *sync.WaitGroup) {
	defer wg.Done()
	log.Printf("Worker %d started.", id)

	for task := range tasks {
		log.Printf("Worker %d picked task %d", id, task.ID)
		result, err := processTask(task)
		if err != nil {
			log.Printf("Worker %d error on task %d: %v", id, task.ID, err)
			continue // skip writing bad result
		}
		results <- fmt.Sprintf("Worker %d: %s", id, result)
		log.Printf("Worker %d finished task %d", id, task.ID)
	}

	log.Printf("Worker %d exiting.", id)
}

func main() {
	log.Println("Main: starting Go data processing system.")

	const numWorkers = 4
	const numTasks = 20

	// Channel as a concurrency-safe queue
	tasks := make(chan Task)
	results := make(chan string)

	var wg sync.WaitGroup

	// Start workers
	for i := 1; i <= numWorkers; i++ {
		wg.Add(1)
		go worker(i, tasks, results, &wg)
	}

	// File for results
	outputFile := "go_results.txt"
	file, err := os.Create(outputFile)
	if err != nil {
		log.Fatalf("Main: could not create results file: %v", err)
	}
	// Ensure we close the file even if there’s a panic or return
	defer func() {
		if cerr := file.Close(); cerr != nil {
			log.Printf("Main: error closing file: %v", cerr)
		}
	}()

	// Collector goroutine: reads from results channel and writes to file
	var collectorWG sync.WaitGroup
	collectorWG.Add(1)
	go func() {
		defer collectorWG.Done()
		for line := range results {
			_, err := fmt.Fprintln(file, line)
			if err != nil {
				log.Printf("Main: error writing to results file: %v", err)
				// We continue so other results can still be written
			}
		}
	}()

	// Send tasks
	log.Println("Main: sending tasks.")
	go func() {
		for i := 1; i <= numTasks; i++ {
			payload := fmt.Sprintf("payload-%d", i)
			tasks <- Task{ID: i, Payload: payload}
		}
		log.Println("Main: all tasks sent, closing tasks channel.")
		close(tasks)
	}()

	// Wait for all workers to finish, then close results
	wg.Wait()
	log.Println("Main: all workers finished, closing results channel.")
	close(results)

	// Wait for collector to finish writing
	collectorWG.Wait()

	log.Printf("Main: processing complete. Results written to %s\n", outputFile)
}
