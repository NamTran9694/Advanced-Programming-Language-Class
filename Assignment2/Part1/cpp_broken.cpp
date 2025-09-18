// C++: Calculate the sum of an array (BROKEN ON PURPOSE)
#include <iostream>
using namespace std;

int calculateSum(int arr[], int size) {
    int total = 0  // missing semi colon
    for (int i = 0; i < size; i++) {
        total += arr[i];
    } 
    return total  // missing semi colon
}

int main() {
    int numbers[] = {1, 2, 3, 4, 5};
    int size = sizeof(numbers) / sizeof(numbers[0]);
    int result = calculateSum(numbers, size);
    cout << "Sum in C++" " << result << endl; // extra quote breaks operator chain
    return 0  // missing semi colon
}
