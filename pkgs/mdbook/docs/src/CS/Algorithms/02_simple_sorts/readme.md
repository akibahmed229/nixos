# Chapter 2: Simple Sorts (Bubble, Selection, Insertion)

*Study time: ~4-5 hours | Prerequisite: Arrays, Big-O primer | Difficulty: Beginner*

---

## 1. Introduction

**Definition:** Bubble Sort, Selection Sort, and Insertion Sort are the three canonical O(n²) comparison-based sorting algorithms — each repeatedly compares and rearranges elements until the whole array is sorted, differing only in *which* comparisons/swaps they make and in what order.

**Purpose:** Not primarily to sort large real-world datasets (better algorithms exist for that — see Chapters 3-4) but to build the foundational intuition for **loop invariants**, **in-place manipulation**, and **stability** that every later, more sophisticated algorithm builds on.

**Problem solved:** Given an unordered array, produce a sorted array — these three algorithms solve it in the most direct, easy-to-verify-correct ways, at the cost of speed.

---

## 2. Intuition

- **Bubble Sort:** repeatedly scan the array, swapping any adjacent out-of-order pair. Each full pass "bubbles" the largest remaining unsorted element to its correct position at the end — like carbonation bubbles naturally rising to the top of a glass, the largest values naturally rise to the end of the array with each pass.
- **Selection Sort:** repeatedly find the minimum of the *remaining* unsorted portion and swap it into place at the front. It's how a person might sort a hand of playing cards by repeatedly picking out "the smallest card I haven't placed yet."
- **Insertion Sort:** build up a sorted portion one element at a time, inserting each new element into its correct position within the already-sorted portion — exactly how most people sort a hand of cards in real life: pick up a new card, slide it into the correct spot among the cards already in your sorted hand.

---

## 3. Step-by-Step Working

**Bubble Sort on `[5, 2, 8, 1, 9]`:**
```
Pass 1: compare adjacent pairs, swap if out of order.
(5,2)→swap→[2,5,8,1,9]  (5,8)→no swap  (8,1)→swap→[2,5,1,8,9]  (8,9)→no swap
End of pass 1: [2,5,1,8,9] — largest element (9) is now bubbled to the end.

Pass 2: (2,5)→no swap (5,1)→swap→[2,1,5,8,9]  (5,8)→no swap  (8,9 already placed, skip)
End of pass 2: [2,1,5,8,9]

Pass 3: (2,1)→swap→[1,2,5,8,9]  (2,5)→no swap
End of pass 3: [1,2,5,8,9] — sorted! (An optimization: if a pass makes ZERO swaps, the array is already sorted — stop early.)
```

**Selection Sort on `[5, 2, 8, 1, 9]`:**
```
Pass 1: find min of [5,2,8,1,9] → 1 (index 3). Swap with index 0 → [1,2,8,5,9]
Pass 2: find min of [2,8,5,9] (indices 1-4) → 2 (already at index 1, no swap needed) → [1,2,8,5,9]
Pass 3: find min of [8,5,9] (indices 2-4) → 5 (index 3). Swap with index 2 → [1,2,5,8,9]
Pass 4: find min of [8,9] (indices 3-4) → 8 (already in place) → [1,2,5,8,9] — sorted!
```

**Insertion Sort on `[5, 2, 8, 1, 9]`:**
```
Start: [5] is trivially sorted. Consider 2: insert into sorted portion → [2,5]
Consider 8: 8 > 5, stays at end → [2,5,8]
Consider 1: shift 8,5,2 right one each until correct spot found → [1,2,5,8]
Consider 9: 9 > 8, stays at end → [1,2,5,8,9] — sorted!
```

---

## 4. Complexity Analysis

**Bubble Sort:** each of the (n-1) passes does up to (n-1) comparisons → O(n²) comparisons and swaps in the worst/average case. Best case (already sorted, with the early-exit optimization) is O(n) — a single pass detects zero swaps and stops immediately.

**Selection Sort:** always does exactly (n-1) + (n-2) + ... + 1 = O(n²) **comparisons**, regardless of input order — there's no early-exit optimization possible, because finding the minimum of the remaining portion always requires scanning all of it. However, it does at most O(n) **swaps** (one per pass) — far fewer than Bubble Sort's potentially O(n²) swaps, which matters when swaps are expensive (e.g., large records, not just integers).

**Insertion Sort:** worst case (reverse-sorted input) requires shifting almost every element on almost every insertion — O(n²). Best case (already sorted input) requires zero shifts — O(n), since every new element is immediately found to be in the correct place. This adaptivity (fast on nearly-sorted data) is Insertion Sort's standout practical advantage.

**Why all three are O(n²) in general:** each involves, in the worst case, comparing every pair of elements at least implicitly — with n elements, there are O(n²) pairs, and none of these three algorithms has a mechanism (unlike Merge/Quick Sort's divide-and-conquer) to avoid touching most of them.

---

## 5. Advantages

- Extremely simple to understand, implement, and verify correct — valuable for teaching and for tiny inputs where simplicity beats raw speed.
- All are in-place — O(1) extra space.
- Insertion Sort is genuinely fast (O(n)) on nearly-sorted data, and is used in practice as the base case for hybrid sorts (e.g., Timsort and introsort switch to insertion sort for small subarrays).
- Selection Sort minimizes the number of swaps — useful when writes are expensive (e.g., flash memory with limited write cycles).

## 6. Limitations

- O(n²) makes all three impractical for large datasets (n > ~10,000 becomes noticeably slow; n > millions is essentially unusable).
- Bubble Sort is rarely used in practice even for teaching purposes beyond introducing the concept — it's dominated by Insertion Sort in almost every practical respect (similar complexity, but Insertion Sort does less unnecessary work).
- Selection Sort's O(n²) comparisons happen unconditionally, even on already-sorted input — it has no adaptivity at all.

---

## 7. Real-World Applications

- **Insertion Sort specifically:** used as the base case in hybrid sorting algorithms (Timsort — Python's and Java's default sort — switches to insertion sort for small runs; introsort, used in many C++ standard library implementations, does the same).
- **Embedded/resource-constrained systems:** for genuinely tiny, fixed-size datasets, the simplicity and low constant-factor overhead of these algorithms can beat asymptotically superior but more complex algorithms.
- **Teaching/Education:** foundational for understanding loop invariants, a skill that transfers directly to proving correctness of every later algorithm in this guide.
- **Nearly-sorted data streams:** Insertion Sort's adaptivity makes it a reasonable choice for maintaining a mostly-sorted list that receives occasional new elements near the correct position (e.g., a live leaderboard with infrequent updates).

---

## 8. C++ Implementation

```cpp
#include <iostream>
#include <vector>

// Bubble Sort with early-exit optimization. O(n) best case, O(n²) worst case.
void bubbleSort(std::vector<int>& arr) {
    int n = static_cast<int>(arr.size());
    for (int i = 0; i < n - 1; ++i) {
        bool swapped = false;
        for (int j = 0; j < n - 1 - i; ++j) {   // shrink the range each pass — the last i elements are already placed
            if (arr[j] > arr[j + 1]) {
                std::swap(arr[j], arr[j + 1]);
                swapped = true;
            }
        }
        if (!swapped) break;   // no swaps this pass means the array is already fully sorted
    }
}

// Selection Sort. Always O(n²) comparisons, O(n) swaps.
void selectionSort(std::vector<int>& arr) {
    int n = static_cast<int>(arr.size());
    for (int i = 0; i < n - 1; ++i) {
        int minIndex = i;
        for (int j = i + 1; j < n; ++j) {       // scan the remaining unsorted portion for the minimum
            if (arr[j] < arr[minIndex]) {
                minIndex = j;
            }
        }
        if (minIndex != i) {
            std::swap(arr[i], arr[minIndex]);    // one swap per outer iteration, at most
        }
    }
}

// Insertion Sort. O(n) best case (nearly sorted), O(n²) worst case.
void insertionSort(std::vector<int>& arr) {
    int n = static_cast<int>(arr.size());
    for (int i = 1; i < n; ++i) {
        int key = arr[i];                          // the element being inserted into the sorted portion
        int j = i - 1;
        while (j >= 0 && arr[j] > key) {
            arr[j + 1] = arr[j];                     // shift larger elements one position right
            j--;
        }
        arr[j + 1] = key;                             // place key in its correct position
    }
}

// Example usage
int main() {
    std::vector<int> a = {5, 2, 8, 1, 9};
    std::vector<int> b = a, c = a;

    bubbleSort(a);
    selectionSort(b);
    insertionSort(c);

    auto print = [](const std::vector<int>& v) {
        for (int x : v) std::cout << x << " ";
        std::cout << "\n";
    };
    std::cout << "Bubble: "; print(a);       // 1 2 5 8 9
    std::cout << "Selection: "; print(b);    // 1 2 5 8 9
    std::cout << "Insertion: "; print(c);    // 1 2 5 8 9
    return 0;
}
```

---

## 9. Code Walkthrough

- **Bubble Sort's `n - 1 - i` inner bound:** After `i` passes, the last `i` elements are guaranteed already in their final sorted positions (each pass bubbles one more max element to the end) — so each subsequent pass can safely shrink its range, avoiding redundant comparisons against already-placed elements.
- **Bubble Sort's `swapped` flag:** This is what gives Bubble Sort its O(n) best case — without it, the algorithm would blindly run all (n-1) passes even on already-sorted input.
- **Selection Sort's `minIndex` tracking:** Notice the swap only happens *once* per outer iteration, after the full inner scan completes — this is why Selection Sort does at most n-1 swaps total, dramatically fewer than Bubble Sort's potentially O(n²) swaps, even though both do O(n²) comparisons.
- **Insertion Sort's shift-then-place pattern:** The `while` loop shifts elements right to make room, and `arr[j+1] = key` places the element only *after* the correct position is found — this is structurally identical to how you'd manually insert a card into a sorted hand, sliding existing cards over one at a time.

**Common mistakes to watch for here:**
- Forgetting the early-exit optimization in Bubble Sort, losing its O(n) best case for free.
- In Selection Sort, swapping inside the inner loop instead of after it completes — this would perform far more swaps than necessary and technically changes the algorithm's swap-count guarantee.
- In Insertion Sort, using `>=` instead of `>` in the while condition — this subtle change affects stability (see summary section).

---

## 10. Dry Run

**Insertion Sort on `[5, 2, 8, 1, 9]`, traced index by index:**

| i | key | Array before shifting | Shifts | Array after placing key |
|---|---|---|---|---|
| 1 | 2 | [5,2,8,1,9] | 5>2, shift 5 right | [2,5,8,1,9] |
| 2 | 8 | [2,5,8,1,9] | 8>5? no (5<8) — 0 shifts | [2,5,8,1,9] |
| 3 | 1 | [2,5,8,1,9] | 8>1 shift, 5>1 shift, 2>1 shift | [1,2,5,8,9] |
| 4 | 9 | [1,2,5,8,9] | 8>9? no — 0 shifts | [1,2,5,8,9] |

Final: `[1,2,5,8,9]` — sorted. ✓ Notice how much work step 3 required (three shifts) versus step 2 and 4 (zero shifts) — this variability is exactly Insertion Sort's adaptivity in action.

---

## 11. Complexity Table

| Algorithm | Best | Average | Worst | Space | Stable? | In-place? |
|---|---|---|---|---|---|---|
| Bubble Sort | O(n) | O(n²) | O(n²) | O(1) | Yes | Yes |
| Selection Sort | O(n²) | O(n²) | O(n²) | O(1) | No* | Yes |
| Insertion Sort | O(n) | O(n²) | O(n²) | O(1) | Yes | Yes |

*Selection Sort's standard swap-based implementation is not stable (swapping a minimum element past equal-valued elements can reorder them); a stable variant exists but requires shifting instead of swapping, sacrificing its "at most n swaps" advantage.

**Every entry explained:** Bubble and Insertion Sort both achieve O(n) best case because they can detect "nothing more to do" (zero swaps, or zero shifts needed) and stop early on already-sorted input. Selection Sort cannot — finding the minimum of the remaining portion always requires a full scan, regardless of whether that portion happens to already be in order, so its best case is no better than its worst case.

---

## 12. Common Mistakes

- **Forgetting Bubble Sort's early-exit check**, losing adaptivity for free.
- **Off-by-one in loop bounds** — a very common source of bugs across all three (e.g., iterating one index too far and reading out of bounds).
- **Swapping instead of shifting in Insertion Sort** — technically works but performs three assignments per shift instead of one, a real (if small) performance difference.
- **Assuming Selection Sort is stable** — the standard swap-based version is not; this can matter when sorting records by one field while wanting to preserve relative order of another.
- **Using these algorithms on large datasets** in production code — always reach for Merge/Quick/Heap Sort (or the standard library's sort) beyond small n.

---

## 13. Interview Questions

**Conceptual:**
1. Why is Insertion Sort adaptive (fast on nearly-sorted data) while Selection Sort is not?
2. Why does Selection Sort do fewer swaps than Bubble Sort, and when would that matter?
3. Explain what "stable" means for a sorting algorithm, and why Selection Sort's standard implementation isn't stable.
4. Why are these algorithms still taught/used despite being asymptotically worse than Merge/Quick Sort?
5. How do hybrid sorting algorithms (Timsort, introsort) use Insertion Sort as a component?

**Coding:**
1. Implement all three sorts from scratch.
2. Modify Selection Sort to be stable.
3. Sort a nearly-sorted array (each element at most k positions from its sorted position) optimally — Insertion Sort with a heap can achieve O(n log k).
4. Count the number of swaps Bubble Sort would perform (related to counting inversions).

**Follow-ups / interviewer traps:**
- "Can you sort in O(n log k) if each element is at most k positions from its final sorted spot?" (tests recognizing a heap-based hybrid approach, connecting back to the Data Structures guide's Heap chapter)
- "What's the minimum number of swaps to sort an array?" (a different, cycle-decomposition-based problem — tests whether the candidate conflates "sorting algorithm swap count" with "minimum possible swaps")

---

## 14. Practice Problems

**Easy**
- Sort an Array (LeetCode 912) — use as a testbed to implement and compare all three
- Insertion Sort List (LeetCode 147) — linked list variant

**Medium**
- Minimum Number of Swaps to Sort an Array (related concept, GeeksforGeeks)
- Sort Colors (LeetCode 75) — related partitioning idea, though solved more elegantly with a specialized approach

**Hard**
- Count Inversions in an Array (naturally solved by a modified merge sort — foreshadows Chapter 3)

Also recommended: GeeksforGeeks "Sorting Algorithms" practice set for implementation drills.

---

## 15. Summary

**Key takeaways:**
- All three are O(n²) in general, differing mainly in *adaptivity* (Bubble and Insertion can exploit partial order; Selection cannot) and *swap count* (Selection does the fewest).
- Insertion Sort is the most practically useful of the three — genuinely fast on nearly-sorted data and used as a component in real-world hybrid sorting algorithms.
- These algorithms exist primarily to build intuition (loop invariants, in-place manipulation, stability) that transfers directly to understanding Merge Sort and Quick Sort next.

**Complexity recap:**

| | Best | Worst | Space | Stable |
|---|---|---|---|---|
| Bubble | O(n) | O(n²) | O(1) | Yes |
| Selection | O(n²) | O(n²) | O(1) | No |
| Insertion | O(n) | O(n²) | O(1) | Yes |

**Decision guide:** Use Insertion Sort for small arrays or nearly-sorted data (or as a component within a larger hybrid sort). Use Selection Sort only when minimizing writes specifically matters more than comparison count. Avoid Bubble Sort in production code entirely — Insertion Sort dominates it in essentially every practical respect. For anything beyond small/nearly-sorted inputs, move on to Merge Sort or Quick Sort (next chapters).

---

*Next chapter: `03_merge_sort.md`*
