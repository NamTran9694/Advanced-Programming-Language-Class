import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DataProcessingSystem {

    // Simple task type
    static class Task {
        private final int id;
        private final String payload;

        Task(int id, String payload) {
            this.id = id;
            this.payload = payload;
        }

        public int getId() {
            return id;
        }

        public String getPayload() {
            return payload;
        }
    }

    // Shared queue wrapper
    static class TaskQueue {
        private final BlockingQueue<Task> queue;

        TaskQueue() {
            this.queue = new LinkedBlockingQueue<>();
        }

        public void addTask(Task task) {
            try {
                queue.put(task);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }

        public Task getTask() throws InterruptedException {
            return queue.take();
        }
    }

    // Worker implementation
    static class Worker implements Runnable {
        private final int workerId;
        private final TaskQueue taskQueue;
        private final List<String> results;
        private final Task poisonPill;
        private final Logger logger;

        Worker(int workerId,
               TaskQueue taskQueue,
               List<String> results,
               Task poisonPill,
               Logger logger) {
            this.workerId = workerId;
            this.taskQueue = taskQueue;
            this.results = results;
            this.poisonPill = poisonPill;
            this.logger = logger;
        }

        @Override
        public void run() {
            logger.info("Worker " + workerId + " started.");
            try {
                while (true) {
                    Task task = taskQueue.getTask();

                    if (task.getId() == poisonPill.getId()) {
                        logger.info("Worker " + workerId + " received shutdown signal.");
                        break;
                    }

                    logger.info("Worker " + workerId + " picked task " + task.getId());
                    try {
                        String result = processTask(task);
                        results.add(result);
                        logger.info("Worker " + workerId + " finished task " + task.getId());
                    } catch (RuntimeException ex) {
                        logger.log(Level.SEVERE,
                                "Worker " + workerId + " error processing task " + task.getId(),
                                ex);
                    }
                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                logger.log(Level.SEVERE, "Worker " + workerId + " interrupted.", e);
            }
            logger.info("Worker " + workerId + " exiting.");
        }

        private String processTask(Task task) {
            try {
                Thread.sleep(500);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                throw new RuntimeException("Task interrupted", e);
            }

            // Simulate occasional error
            if (task.getId() % 7 == 0) {
                throw new RuntimeException("Simulated processing error for task " + task.getId());
            }

            return "Task " + task.getId() +
                   " processed by worker " + workerId +
                   " => " + task.getPayload().toUpperCase();
        }
    }

    public static void main(String[] args) {
        Logger logger = Logger.getLogger(DataProcessingSystem.class.getName());

        final int NUM_WORKERS = 4;
        final int NUM_TASKS = 20;

        TaskQueue taskQueue = new TaskQueue();
        List<String> results = Collections.synchronizedList(new ArrayList<>());
        Task poisonPill = new Task(-1, "POISON");

        ExecutorService executorService = Executors.newFixedThreadPool(NUM_WORKERS);

        // Start workers
        for (int i = 0; i < NUM_WORKERS; i++) {
            executorService.submit(
                    new Worker(i + 1, taskQueue, results, poisonPill, logger));
        }

        // Add tasks
        logger.info("Main thread: adding tasks.");
        for (int i = 1; i <= NUM_TASKS; i++) {
            String payload = "payload-" + i;
            taskQueue.addTask(new Task(i, payload));
        }

        // Send shutdown signals
        logger.info("Main thread: adding poison pills.");
        for (int i = 0; i < NUM_WORKERS; i++) {
            taskQueue.addTask(poisonPill);
        }

        executorService.shutdown();

        try {
            if (!executorService.awaitTermination(60, TimeUnit.SECONDS)) {
                logger.warning("Forcing shutdown - workers did not terminate in time.");
                executorService.shutdownNow();
            }
        } catch (InterruptedException e) {
            logger.log(Level.SEVERE, "Main thread interrupted while waiting for termination.", e);
            executorService.shutdownNow();
            Thread.currentThread().interrupt();
        }

        // Write results to file
        String outputFile = "java_results.txt";
        logger.info("Main thread: writing results to " + outputFile);
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(outputFile))) {
            for (String line : results) {
                writer.write(line);
                writer.newLine();
            }
        } catch (IOException e) {
            logger.log(Level.SEVERE, "Error writing results file", e);
        }

        logger.info("Main thread: processing complete. Results written to " + outputFile);
    }
}
