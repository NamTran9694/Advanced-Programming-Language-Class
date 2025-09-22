public class JavaDemo2 {
    public static void main(String[] args) {
        // Allocate an array of integers on the heap
        int[] numbers = new int[10];

        // The 'numbers' reference points to the array
        for (int i = 0; i < 10; i++) {
            numbers[i] = i;
        }

        // Print the contents of the array to the console
        System.out.print("Array contents: ");
        for (int i = 0; i < 10; i++) {
            System.out.print(numbers[i] + " ");
        }
        System.out.println(); // Print a newline for cleaner output

        // The garbage collector will eventually reclaim this memory
        // when the 'numbers' array is no longer reachable.
        numbers = null;
    }
}