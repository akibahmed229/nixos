# Chapter 4: Quick Sort

*Study time: ~5-6 hours | Prerequisite: Recursion, Merge Sort (Ch. 3) | Difficulty: Intermediate*

---

## 1. Introduction

**Definition:** Quick Sort is a divide-and-conquer sorting algorithm that picks a **pivot** element, **partitions** the array so everything smaller than the pivot ends up to its left and everything larger ends up to its right (with the pivot now in its final sorted position), then recursively sorts the two partitions.

**Purpose:** To sort in-place with excellent average-case performance and the best practical constant factors of any general-purpose comparison sort — it's the algorithm most standard libraries' `sort()` functions are built around (often as part of a hybrid like introsort).

**Problem solved:** Fast, memory-efficient (in-place) general-purpose sorting, when average-case O(n log n) is acceptable and worst-case O(n²) can be avoided or mitigated through good pivot selection.

---

## 2. Intuition

Imagine sorting a shelf of books by picking one book at random (the pivot), then physically moving every book that belongs *before* it to the left of it, and every book that belongs *after* it to the right — after this single pass, that pivot book is **guaranteed to be in its final correct position**, even though nothing else is fully sorted yet. Now you have two smaller, independent shelves to sort the same way — recursively. This is the core insight: unlike Merge Sort (which does its "hard work" *after* recursing, during merge), Quick Sort does its hard work *before* recursing (during partition), and the recursion itself requires no combining step at all — once both halves are individually sorted, the whole array is automatically sorted, because the partition step already guaranteed the correct relative ordering between the two halves.

---

## 3. Step-by-Step Working

**Sorting `[10, 80, 30, 90, 40, 50, 70]` using the last element as pivot (Lomuto partition scheme):**

```
Initial: [10, 80, 30, 90, 40, 50, 70]   pivot = 70 (last element)

Partition pass: maintain a boundary `i` for "everything ≤ pivot goes here or before."
  j=0: arr[0]=10 ≤ 70 → i=0, swap arr[0] with arr[0] (no-op) → [10,80,30,90,40,50,70]
  j=1: arr[1]=80 > 70 → skip
  j=2: arr[2]=30 ≤ 70 → i=1, swap arr[1] with arr[2] → [10,30,80,90,40,50,70]
  j=3: arr[3]=90 > 70 → skip
  j=4: arr[4]=40 ≤ 70 → i=2, swap arr[2] with arr[4] → [10,30,40,90,80,50,70]
  j=5: arr[5]=50 ≤ 70 → i=3, swap arr[3] with arr[5] → [10,30,40,50,80,90,70]
  (j=6 is the pivot itself, stop)
  Finally, swap pivot (index 6) with i+1=4 → [10,30,40,50,70,90,80]

Pivot (70) is now at index 4 — its FINAL correct position, guaranteed.
Left partition:  [10,30,40,50]  (all ≤ 70)
Right partition: [90,80]         (all > 70)

Recursively quick-sort each partition the same way:
  [10,30,40,50] → already sorted after its own partitioning steps
  [90,80] → pivot 80, partition → [80,90]

Final merged-by-position result: [10,30,40,50,70,80,90]
```

**The critical insight:** unlike Merge Sort, there's no separate "combine" step at the end — once both partitions are individually sorted in-place, the whole array is automatically sorted, because the partition step already guaranteed every element in the left partition is ≤ the pivot and every element in the right partition is > the pivot.

---

## 4. Complexity Analysis

**Time: O(n log n) average, O(n²) worst case.**

**Average case reasoning:** if the pivot reasonably splits the array (even a consistently 25%/75% split, not just perfect 50/50), the recursion depth is O(log n), and each level does O(n) total partitioning work — giving O(n log n), the same fundamental reasoning as Merge Sort's complexity derivation.

**Worst case reasoning:** if the pivot is *always* the smallest or largest remaining element (e.g., naively picking the first or last element as pivot on an already-sorted or reverse-sorted array), each partition step only removes **one** element from consideration, requiring n, then n-1, then n-2, ... levels of recursion — O(n) levels instead of O(log n), each still doing O(n) partitioning work, giving O(n²) total. This is exactly analogous to a plain BST degenerating into a linked list when built from sorted input (Data Structures guide, Chapter 7) — an unlucky/adversarial choice removes the "balanced halving" that the algorithm's good performance depends on.

**Mitigating the worst case:** randomized pivot selection (pick a uniformly random element as pivot before partitioning) makes the worst case *astronomically unlikely* for any fixed input, since an adversary can't predict which element will be chosen — this single change is what makes Quick Sort practically reliable despite its theoretical O(n²) worst case. The **median-of-three** heuristic (use the median of the first, middle, and last elements as the pivot) is another common, cheap mitigation.

**Space: O(log n) average (recursion stack for a balanced split), O(n) worst case (recursion stack for a maximally unbalanced split)** — this is genuinely in-place in the sense of not needing an auxiliary array like Merge Sort, but the recursion stack itself is real (if usually small) extra space.

---

## 5. Advantages

- Excellent average-case performance, and the best practical constant factors of any general-purpose comparison sort — usually faster in wall-clock time than Merge Sort on typical data, due to better cache locality (in-place partitioning touches memory more predictably) and no allocation overhead.
- In-place (O(log n) auxiliary space for the recursion stack, versus Merge Sort's O(n)).
- Easily randomized to make worst-case behavior practically negligible.

## 6. Limitations

- O(n²) worst case is real — without randomization or a good pivot heuristic, adversarial or already-sorted/reverse-sorted input can trigger it.
- Not stable (standard implementation) — partitioning can reorder equal elements relative to each other.
- More implementation care needed than Merge Sort to get right (partition scheme edge cases — duplicate-heavy arrays, in particular, can degrade a naive implementation's performance without special handling like a three-way partition).

---

## 7. Real-World Applications

- **Standard Library Sorts:** C++'s `std::sort` is typically implemented as **introsort** — Quick Sort with a fallback to Heap Sort if recursion depth gets suspiciously large (signaling a potential worst-case scenario), combined with Insertion Sort for small subarrays. This hybrid is specifically designed to capture Quick Sort's excellent average performance while eliminating its worst-case risk.
- **Databases:** In-memory sort operations (when data fits in RAM, unlike Merge Sort's external-sort use case) commonly use quicksort-family algorithms.
- **Operating Systems:** Various kernel-level sorting tasks where memory efficiency (in-place) matters.
- **Competitive Programming:** The default general-purpose sort choice whenever stability isn't required and data fits in memory.
- **Graphics/Game Development:** Sorting objects by depth/z-order for rendering, where speed matters more than stability.

---

## 8. C++ Implementation

```cpp
#include <iostream>
#include <vector>
#include <cstdlib>
#include <ctime>

// Lomuto partition scheme: places pivot (last element) in its final position,
// returns that final index. Everything ≤ pivot ends up to its left.
int partition(std::vector<int>& arr, int low, int high) {
    int pivot = arr[high];
    int i = low - 1;   // boundary: everything at index <= i is confirmed <= pivot

    for (int j = low; j < high; ++j) {
        if (arr[j] <= pivot) {
            i++;
            std::swap(arr[i], arr[j]);
        }
    }
    std::swap(arr[i + 1], arr[high]);   // place the pivot in its final position
    return i + 1;
}

// Randomized pivot selection: swap a random element into the pivot position BEFORE
// partitioning — this is what makes worst-case O(n²) practically negligible.
int randomizedPartition(std::vector<int>& arr, int low, int high) {
    int randomIndex = low + rand() % (high - low + 1);
    std::swap(arr[randomIndex], arr[high]);   // move random element to the pivot slot
    return partition(arr, low, high);
}

void quickSort(std::vector<int>& arr, int low, int high) {
    if (low >= high) return;   // base case: 0 or 1 element is trivially sorted

    int pivotIndex = randomizedPartition(arr, low, high);
    quickSort(arr, low, pivotIndex - 1);    // recursively sort left partition
    quickSort(arr, pivotIndex + 1, high);   // recursively sort right partition
}

// Example usage
int main() {
    std::srand(static_cast<unsigned>(std::time(nullptr)));

    std::vector<int> arr = {10, 80, 30, 90, 40, 50, 70};
    quickSort(arr, 0, static_cast<int>(arr.size()) - 1);

    for (int x : arr) std::cout << x << " ";
    std::cout << "\n";   // 10 30 40 50 70 80 90
    return 0;
}
```

---

## 9. Code Walkthrough

- **`partition`'s boundary variable `i`:** Everything at index `<= i` is *confirmed* to be `<= pivot` — the loop invariant this algorithm maintains throughout. Each time `arr[j] <= pivot` is found, `i` advances by one and the two elements swap, extending the "confirmed small" region by exactly one.
- **The final swap `arr[i+1]` with `arr[high]`:** This places the pivot (which sat at `arr[high]` throughout the scan) into its correct final position — right after the last confirmed-small element, which is exactly where it belongs.
- **`randomizedPartition`'s pre-swap:** By swapping a uniformly random element into the pivot slot *before* calling the ordinary `partition`, we ensure the pivot used is effectively random — without changing `partition`'s logic at all. This is a clean, minimal way to add randomization to any existing Lomuto-style partition implementation.
- **`quickSort`'s recursive structure:** Unlike Merge Sort, there's no work done *after* the two recursive calls — partitioning (the "hard work") happens *before* recursing, and once both partitions are individually sorted, the array is automatically fully sorted with no combine step needed.

**Common mistakes to watch for here:**
- Forgetting randomization (or another pivot-selection safeguard) entirely, leaving the implementation vulnerable to O(n²) on sorted/reverse-sorted or adversarially-crafted input.
- Off-by-one errors in the partition boundary logic — a very common source of subtle bugs, especially around the final pivot-placing swap.
- Not handling duplicate-heavy arrays well — the standard two-way partition shown here can still degrade toward O(n²)-like behavior on arrays with many equal elements; a three-way partition (Dutch National Flag style) fixes this specific case.

---

## 10. Dry Run

Traced in full in section 3: pivot 70 correctly lands at index 4 after one partition pass, splitting into `[10,30,40,50]` and `[90,80]`, each recursively sorted the same way, converging on `[10,30,40,50,70,80,90]`.

**Partition pass trace, condensed:**

| j | arr[j] | ≤ pivot(70)? | i after | Array state |
|---|---|---|---|---|
| 0 | 10 | yes | 0 | [10,80,30,90,40,50,70] |
| 1 | 80 | no | 0 | unchanged |
| 2 | 30 | yes | 1 | [10,30,80,90,40,50,70] |
| 3 | 90 | no | 1 | unchanged |
| 4 | 40 | yes | 2 | [10,30,40,90,80,50,70] |
| 5 | 50 | yes | 3 | [10,30,40,50,80,90,70] |
| final swap | — | — | — | swap i+1=4 with high=6 → [10,30,40,50,70,90,80] |

Pivot 70 lands at index 4 — correctly separating everything ≤70 (left) from everything >70 (right). ✓

---

## 11. Complexity Table

| Case | Time | Space | Cause |
|---|---|---|---|
| Best | O(n log n) | O(log n) | Pivot always splits roughly evenly |
| Average | O(n log n) | O(log n) | Random/typical data gives reasonably balanced splits on average |
| Worst | O(n²) | O(n) | Pivot always the min/max of the remaining range (e.g., naive pivot on sorted input) |

**Every entry explained:** The best and average cases coincide at O(n log n) because "reasonably balanced" splits (even far from perfectly 50/50) are enough to keep recursion depth at O(log n) — the argument doesn't require *exact* halving, just splits that shrink geometrically. The worst case arises specifically when the pivot choice is maximally unlucky at every single level, turning geometric shrinkage into linear shrinkage (n, n-1, n-2, ...) — randomization makes this scenario's probability vanishingly small for any fixed adversarial input, though it remains theoretically possible.

---

## 12. Common Mistakes

- **Not randomizing (or otherwise safeguarding) pivot selection** — leaves the implementation vulnerable to real, exploitable O(n²) worst-case behavior on common inputs like sorted or reverse-sorted arrays.
- **Off-by-one errors in partition boundaries** — extremely common; always trace through a small example by hand when debugging.
- **Assuming Quick Sort is stable** — it is not, in its standard form; don't claim this in an interview without qualification.
- **Poor performance on duplicate-heavy arrays** without a three-way partition — a common interview follow-up probes exactly this weakness.
- **Confusing average-case and worst-case complexity** when discussing Quick Sort's guarantees — always be explicit about which case you're describing.

---

## 13. Interview Questions

**Conceptual:**
1. Why is Quick Sort's worst case O(n²), and what specific inputs trigger it for a naive (unrandomized) implementation?
2. Why does randomizing pivot selection make the worst case practically negligible without changing its theoretical existence?
3. Compare Quick Sort and Merge Sort — when would you choose each?
4. Why isn't standard Quick Sort stable, and does that ever matter in practice?
5. What is introsort, and why do many standard libraries use it instead of pure Quick Sort?

**Coding:**
1. Implement Quick Sort with randomized pivot selection.
2. Implement a three-way partition (Dutch National Flag) to handle duplicate-heavy arrays efficiently.
3. Find the Kth largest/smallest element using Quickselect (a Quick-Sort-partition-based selection algorithm, average O(n)).
4. Sort an array of 0s, 1s, and 2s in one pass (Dutch National Flag problem directly).
5. Implement Quick Sort iteratively (using an explicit stack instead of recursion).

**Follow-ups / interviewer traps:**
- "Can you find the Kth largest element without fully sorting the array?" (expects Quickselect, average O(n), a direct and very common application of Quick Sort's partition step alone)
- "Your Quick Sort is slow on an array of all identical elements — why, and how do you fix it?" (tests awareness of the duplicate-heavy degradation and the three-way-partition fix)
- "What's the actual worst-case space complexity, and how does tail-call/smaller-first recursion help?" (tests knowledge that recursing into the smaller partition first, and looping for the larger one, bounds stack depth to O(log n) even in cases that would otherwise risk O(n))

---

## 14. Practice Problems

**Easy**
- Sort Colors (LeetCode 75) — Dutch National Flag / 3-way partition

**Medium**
- Sort an Array (LeetCode 912) — benchmark against Merge Sort
- Kth Largest Element in an Array (LeetCode 215) — Quickselect application
- Sort List (compare Quick Sort's poor fit for linked lists against Merge Sort's natural fit)

**Hard**
- Median of Two Sorted Arrays (LeetCode 4) — partition-based thinking, related in spirit
- Wiggle Sort II (LeetCode 324) — uses a Quickselect-based median-finding step

Also recommended: benchmark your Quick Sort against Merge Sort on random, sorted, reverse-sorted, and duplicate-heavy inputs — directly observe the worst-case behavior and how randomization/three-way partitioning fixes it.

---

## 15. Summary

**Key takeaways:**
- Quick Sort does its "hard work" (partitioning) before recursing, unlike Merge Sort's "hard work after recursing" (merging) — this is the fundamental structural difference between the two.
- O(n log n) average case comes from geometrically-shrinking partition sizes; O(n²) worst case comes from a maximally unlucky pivot at every level, mitigated almost entirely in practice by randomization.
- In-place with excellent real-world constant factors makes it the default choice for general in-memory sorting when stability isn't required.

**Complexity recap:**

| | Best | Average | Worst | Space | Stable |
|---|---|---|---|---|---|
| Quick Sort | O(n log n) | O(n log n) | O(n²) | O(log n) avg | No |

**Decision guide:** Choose Quick Sort (or trust your language's built-in sort, which is often introsort/Quick-Sort-based) for general-purpose in-memory sorting when average-case performance and memory efficiency matter more than worst-case guarantees or stability. Choose Merge Sort instead when you need guaranteed worst-case performance, stability, or you're sorting a linked list or external/disk-resident data.

---

*Next chapter: `05_heap_sort.md`*
