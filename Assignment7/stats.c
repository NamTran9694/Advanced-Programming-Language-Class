#include <stdio.h>
#include <stdlib.h>

/* --------- Helper: compare function for qsort ---------- */
int compare_ints(const void *a, const void *b) {
    int ia = *(const int *)a;
    int ib = *(const int *)b;
    if (ia < ib) return -1;
    if (ia > ib) return 1;
    return 0;
}

/* --------- Mean (procedural style) ---------- */
double mean(int *arr, int n) {
    long long sum = 0; // use long long in case of large numbers
    for (int i = 0; i < n; i++) {
        sum += arr[i];
    }
    return (double)sum / (double)n;
}

/* --------- Median (sorts array in-place) ---------- */
double median(int *arr, int n) {
    qsort(arr, n, sizeof(int), compare_ints);

    if (n % 2 == 1) {
        // odd length -> middle element
        return (double)arr[n / 2];
    } else {
        // even length -> average of two middle elements
        int mid1 = arr[(n / 2) - 1];
        int mid2 = arr[n / 2];
        return (mid1 + mid2) / 2.0;
    }
}

/* --------- Mode(s) ----------*/
void modes(int *arr, int n) {
    // First pass: find max frequency
    int current_val = arr[0];
    int current_count = 1;
    int max_count = 1;

    for (int i = 1; i < n; i++) {
        if (arr[i] == current_val) {
            current_count++;
        } else {
            if (current_count > max_count) {
                max_count = current_count;
            }
            current_val = arr[i];
            current_count = 1;
        }
    }
    if (current_count > max_count) {
        max_count = current_count;
    }

    // Second pass: print all values with frequency == max_count
    printf("Mode(s): ");
    current_val = arr[0];
    current_count = 1;
    int first_printed = 0;

    for (int i = 1; i < n; i++) {
        if (arr[i] == current_val) {
            current_count++;
        } else {
            if (current_count == max_count) {
                if (first_printed) {
                    printf(", ");
                }
                printf("%d", current_val);
                first_printed = 1;
            }
            current_val = arr[i];
            current_count = 1;
        }
    }
    // check last run
    if (current_count == max_count) {
        if (first_printed) {
            printf(", ");
        }
        printf("%d", current_val);
    }
    printf(" (frequency: %d)\n", max_count);
}

/* --------- main: procedural orchestration ---------- */
int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s num1 num2 ...\n", argv[0]);
        return 1;
    }

    int n = argc - 1;
    int *data = malloc(n * sizeof(int));
    if (!data) {
        fprintf(stderr, "Memory allocation failed.\n");
        return 1;
    }

    // Parse integers from command line
    for (int i = 0; i < n; i++) {
        data[i] = atoi(argv[i + 1]);
    }

    // We sort a copy for median and mode so original order isn’t required.
    int *sorted = malloc(n * sizeof(int));
    if (!sorted) {
        fprintf(stderr, "Memory allocation failed.\n");
        free(data);
        return 1;
    }
    for (int i = 0; i < n; i++) {
        sorted[i] = data[i];
    }

    double m_mean = mean(data, n);
    double m_median = median(sorted, n); // this sorts 'sorted' in-place

    printf("Number of elements: %d\n", n);
    printf("Mean:   %.2f\n", m_mean);
    printf("Median: %.2f\n", m_median);
    modes(sorted, n);

    free(data);
    free(sorted);
    return 0;
}
