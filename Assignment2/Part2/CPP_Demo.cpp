#include <iostream>

int main() {
    // Allocate an array of integers on the heap
    int* numbers = new int[10];

    // Populate the array
    for (int i = 0; i < 10; ++i) {
        numbers[i] = i;
    }

    // Print the contents of the array
    std::cout << "Array contents: ";
    for (int i = 0; i < 10; ++i) {
        std::cout << numbers[i] << " ";
    }
    std::cout << std::endl;

    // Deallocate the memory when we are done
    delete[] numbers;

    return 0;
}
