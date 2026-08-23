# Chapter 5: Heap Sort

*Study time: ~4-5 hours | Prerequisite: Heaps (Data Structures guide, Ch. 5) | Difficulty: Intermediate*

---

## 1. Introduction

**Definition:** Heap Sort sorts an array by first rearranging it into a **Max-Heap** (in-place, using the array itself as the heap's backing storage — see the Data Structures guide's Heap chapter for the underlying structure), then repeatedly extracting the maximum (always at the root) and placing it at the end of the unsorted region, shrinking the heap by one each time.

**Purpose:** To combine Quick Sort's in-place, O(1)-extra-space property with Merge Sort's guaranteed-worst-case O(n log n) — Heap Sort is the algorithm that achieves *both* simultaneously, at the cost of losing stability and having noticeably worse real-world constant factors (cache locality) than either.

**Problem solved:** Sorting when you need a **guaranteed** O(n log n) bound *and* O(1) extra space — exactly the gap between Merge Sort (guaranteed time, but O(n) space) and Quick Sort (O(log n) space, but no time guarantee).

---

## 2. Intuition

If you have a Max-Heap (Data Structures guide, Chapter 5), you already know its root is always the maximum element, retrievable in O(1), with removal costing O(log n) (sift-down). If you repeatedly remove the max and place it at the end of a shrinking "unsorted" region, you naturally build up a sorted array from the back to the front — this is Heap Sort's entire idea, and it reuses 100% of the Heap chapter's machinery, just applied for a new purpose (sorting, rather than priority-queue access).

The clever part is doing this **in-place**: rather than using a separate heap data structure, treat the array itself as the heap's backing array (exactly the array-representation trick from the Heap chapter), and use the "shrinking unsorted region / growing sorted region at the end" idea to avoid needing any extra memory at all.

---

## 3. Step-by-Step Working

**Sorting `[4, 10, 3, 5, 1]`:**

```
STEP 1 — Build a Max-Heap in-place from the unsorted array (this is exactly the O(n)
"build-heap via bottom-up sift-down" technique from the Data Structures guide, Ch.5):

[4, 10, 3, 5, 1]  →  after build-heap  →  [10, 5, 3, 4, 1]

(Verify: parent(10) has children 5,3 — 10≥5,10≥3 ✓. parent(5,index1) has child 4(index3) — 5≥4 ✓.)

STEP 2 — Repeatedly extract max (swap root with last element of the CURRENT heap region,
shrink the heap, sift-down the new root):

Heap region size 5: [10,5,3,4,1] → swap root(10) with last(1) → [1,5,3,4,10]
  Sorted region (end): [10]. Sift-down 1 within [1,5,3,4] (size 4) → [5,4,3,1]... let's re-derive:
  [1,5,3,4] sift down: compare 1 vs children 5,3 → swap with 5 (larger child) → [5,1,3,4]
  continue: 1 at index1, children index3=4 → 1<4 swap → [5,4,3,1]
  Heap region now: [5,4,3,1], Sorted region: [10]

Heap region size 4: [5,4,3,1] → swap root(5) with last(1) → [1,4,3,5]
  Sorted region: [5,10]. Sift-down 1 within [1,4,3] (size 3):
  compare 1 vs children 4,3 → swap with 4 → [4,1,3]
  Heap region: [4,1,3], Sorted region: [5,10]

Heap region size 3: [4,1,3] → swap root(4) with last(3) → [3,1,4]
  Sorted region: [4,5,10]. Sift-down 3 within [3,1] (size 2):
  compare 3 vs child 1 → 3>1, no swap needed
  Heap region: [3,1], Sorted region: [4,5,10]

Heap region size 2: [3,1] → swap root(3) with last(1) → [1,3]
  Sorted region: [3,4,5,10]. Sift-down 1 within [1] (size 1) → nothing to do.
  Heap region: [1], Sorted region: [3,4,5,10]

Heap region size 1: trivially sorted, done.

FINAL: [1,3,4,5,10]  ✓
```

---

## 4. Complexity Analysis

**Time: O(n log n), guaranteed in all cases.**

Building the initial heap is O(n) (the same surprising-but-proven bound from the Data Structures guide's Heap chapter — bottom-up sift-down, not naive one-by-one insertion). Then there are **n extraction steps**, each costing O(log n) (one sift-down per extraction, and the heap shrinks by one each time, but sift-down's cost is still bounded by O(log(current heap size)) = O(log n)). Total: O(n) [build] + O(n log n) [n extractions × O(log n) each] = **O(n log n)**.

**Why it's guaranteed, unlike Quick Sort:** Heap Sort's structure — a complete binary tree stored as an array — has height *exactly* ⌊log₂ n⌋ by definition, completely independent of the data's actual values (unlike Quick Sort's pivot-dependent, data-dependent partition balance, or even Merge Sort's need to re-derive the balanced-split argument). Every single sift-down, in every case, costs at most O(log n) — there's no "unlucky data" scenario that can degrade this.

**Space: O(1) extra** — genuinely in-place; unlike Quick Sort's O(log n) recursion stack, Heap Sort's extraction loop is naturally iterative, needing no recursion at all (sift-down itself is typically implemented iteratively too).

---

## 5. Advantages

- **Guaranteed O(n log n)** in every case, like Merge Sort — no adversarial input can degrade it, unlike Quick Sort.
- **O(1) extra space**, genuinely in-place — better than both Merge Sort (O(n)) and even Quick Sort (O(log n) stack).
- Combines the best guarantees of both prior algorithms into one — theoretically the "safest" general-purpose comparison sort.

## 6. Limitations

- **Not stable** — the heap-extraction process has no mechanism to preserve relative order of equal elements.
- **Worse real-world constant factors** than Quick Sort (and often than Merge Sort) due to poor cache locality — heap operations jump around the array via parent/child index arithmetic (`2i+1`, `2i+2`), which doesn't access memory sequentially the way Merge Sort's linear merge or Quick Sort's linear partition scan does. In practice, Heap Sort is usually the slowest of the three O(n log n) sorts on typical hardware, despite matching or beating them asymptotically.
- Less naturally parallelizable than Merge Sort (the heap operations are inherently sequential in a way merge sort's independent-subarray recursion is not).

---

## 7. Real-World Applications

- **Systems requiring both a strict worst-case time guarantee AND memory efficiency:** embedded/real-time systems where O(n) extra space (Merge Sort) is unacceptable but O(n²) worst-case risk (unmitigated Quick Sort) is also unacceptable.
- **Introsort (hybrid sorts):** as mentioned in the Quick Sort chapter, C++'s `std::sort` typically falls back to Heap Sort specifically when Quick Sort's recursion depth suggests a worst-case scenario is unfolding — Heap Sort's guaranteed bound acts as a safety net without needing Merge Sort's extra memory.
- **Priority-based/selection problems more broadly:** Heap Sort is really "repeated extract-max" applied to sorting — the same underlying mechanism (Data Structures guide, Ch.5) powers task scheduling, top-K queries, and any other priority-queue-driven application, of which sorting is just one specific use.
- **Operating Systems:** Some kernel-level sorting tasks with strict worst-case timing requirements.

---

## 8. C++ Implementation

```cpp
#include <iostream>
#include <vector>

// Sift down the element at index i, within a heap region of the given size.
// Identical in spirit to the Data Structures guide's Heap chapter, adapted for in-place array sorting.
void siftDown(std::vector<int>& arr, int size, int i) {
    while (true) {
        int largest = i;
        int left = 2 * i + 1;
        int right = 2 * i + 2;

        if (left < size && arr[left] > arr[largest]) largest = left;
        if (right < size && arr[right] > arr[largest]) largest = right;

        if (largest == i) break;   // heap property restored, stop

        std::swap(arr[i], arr[largest]);
        i = largest;
    }
}

// Heap Sort. O(n log n) guaranteed, O(1) extra space.
void heapSort(std::vector<int>& arr) {
    int n = static_cast<int>(arr.size());

    // STEP 1: Build a Max-Heap in-place. O(n) — bottom-up from the last non-leaf node.
    for (int i = n / 2 - 1; i >= 0; --i) {
        siftDown(arr, n, i);
    }

    // STEP 2: Repeatedly extract the max (root) to the end of the shrinking heap region.
    for (int end = n - 1; end > 0; --end) {
        std::swap(arr[0], arr[end]);   // move current max to its final sorted position
        siftDown(arr, end, 0);          // restore heap property within the shrunk region [0, end)
    }
}

// Example usage
int main() {
    std::vector<int> arr = {4, 10, 3, 5, 1};
    heapSort(arr);

    for (int x : arr) std::cout << x << " ";
    std::cout << "\n";   // 1 3 4 5 10
    return 0;
}
```

---

## 9. Code Walkthrough

- **`siftDown`'s `size` parameter:** Unlike a standalone heap (Data Structures guide, Ch.5), Heap Sort's heap **shrinks** with every extraction — `size` represents the current boundary of the "still a heap" region, distinct from the array's total length. This is the key adaptation that makes the same sift-down logic serve double duty for both build-heap and the extraction loop.
- **STEP 1's loop (`i = n/2 - 1` down to `0`):** Identical to the Data Structures guide's O(n) build-heap technique — starting from the last non-leaf node and working backward ensures every subtree is a valid heap by the time its parent is sifted down.
- **STEP 2's `swap` then `siftDown`:** Each iteration does exactly two things: (1) move the current maximum (always at `arr[0]`, guaranteed by the heap property) to its final position at `arr[end]`, and (2) restore the heap property for the now-shrunk region `[0, end)` by sifting the newly-placed root value down. This pair of operations, repeated n-1 times, is the entire sorting mechanism.
- **Why `end > 0` (not `end >= 0`)** in the extraction loop: when `end` reaches 0, there's exactly one element left (`arr[0]`), which is trivially already in its correct position — no swap or sift-down is needed.

**Common mistakes to watch for here:**
- Confusing the shrinking heap `size` with the array's total length — using the wrong bound causes sift-down to incorrectly consider already-sorted (and no longer part of the heap) elements as heap children.
- Forgetting that Heap Sort's heap is a **Max**-Heap specifically (to produce ascending sorted output) — a Min-Heap would need extraction into the *front* of a growing sorted region instead, a less natural in-place adaptation.
- Assuming stability — like Quick Sort, Heap Sort's swaps can reorder equal elements relative to each other.

---

## 10. Dry Run

Already fully traced in section 3, extracting 10, then 5, then 4, then 3, then 1 (in that order, each landing at the correct position from the end backward), producing `[1,3,4,5,10]`.

**Complexity bookkeeping across the extraction loop:**

| Extraction | Heap size before | Sift-down cost (max levels) |
|---|---|---|
| 1st (extract 10) | 5 | ≤ ⌊log₂5⌋ = 2 |
| 2nd (extract 5) | 4 | ≤ ⌊log₂4⌋ = 2 |
| 3rd (extract 4) | 3 | ≤ ⌊log₂3⌋ = 1 |
| 4th (extract 3) | 2 | ≤ ⌊log₂2⌋ = 1 |

Total sift-down work across all extractions sums to O(n log n) — this table makes concrete exactly what section 4's complexity argument means in practice.

---

## 11. Complexity Table

| Case | Time | Space |
|---|---|---|
| Best | O(n log n) | O(1) |
| Average | O(n log n) | O(1) |
| Worst | O(n log n) | O(1) |

**Every entry explained:** All three cases coincide because the heap's shape (a complete binary tree with height exactly ⌊log₂ n⌋) is **entirely determined by n**, never by the data's actual values — there is no analogous "bad pivot" or "bad split" scenario that Quick Sort or an unlucky comparison-heavy algorithm could suffer from. Every sift-down, in every case, costs at most O(log(current heap size)).

---

## 12. Common Mistakes

- **Confusing the shrinking heap size with array length** in the extraction loop's `siftDown` calls.
- **Using a Min-Heap instead of a Max-Heap** for ascending-order output (or forgetting to flip comparisons if adapting for descending order).
- **Assuming stability** — Heap Sort, like Quick Sort, does not preserve relative order of equal elements.
- **Underestimating real-world slowness** relative to Quick Sort on typical (non-adversarial) data — Heap Sort's asymptotic guarantees don't translate to it being the *fastest* choice in practice, only the *safest*.
- **Implementing build-heap as repeated single inserts** (O(n log n)) instead of the bottom-up O(n) technique — loses a real, well-known optimization.

---

## 13. Interview Questions

**Conceptual:**
1. Why does Heap Sort guarantee O(n log n) in every case, unlike Quick Sort?
2. Compare Heap Sort, Merge Sort, and Quick Sort across time guarantee, space, stability, and real-world speed — when would you choose each?
3. Why is Heap Sort typically slower in practice than Quick Sort despite matching or beating its asymptotic complexity?
4. How does Heap Sort reuse the build-heap technique from the Heap data structure chapter?
5. Why is Heap Sort not stable, and can it be made stable? (Generally no, not without sacrificing its O(1) space advantage.)

**Coding:**
1. Implement Heap Sort from scratch (build-heap + extraction loop).
2. Sort in descending order using a Min-Heap-based Heap Sort.
3. Find the K largest elements using a partial Heap Sort (extract only K times, not all n).
4. Implement introsort-style hybrid: Quick Sort with a Heap Sort fallback triggered by excessive recursion depth.

**Follow-ups / interviewer traps:**
- "If you only need the top K elements, do you need to fully heap-sort the array?" (no — build the heap once, O(n), then extract only K times, O(K log n) — much better than fully sorting when K << n)
- "Why does introsort fall back to Heap Sort specifically, rather than Merge Sort, when Quick Sort's recursion gets too deep?" (tests understanding that Heap Sort's O(1) space fits naturally into an in-place-oriented hybrid, whereas falling back to Merge Sort would reintroduce the O(n) space Quick Sort was chosen to avoid)

---

## 14. Practice Problems

**Easy**
- Kth Largest Element in a Stream (LeetCode 703) — heap-based, related mechanism

**Medium**
- Sort an Array (LeetCode 912) — implement and benchmark against Merge/Quick Sort
- Kth Largest Element in an Array (LeetCode 215) — compare a partial-heap-sort approach against Quickselect (Chapter 4)
- Top K Frequent Elements (LeetCode 347)

**Hard**
- Find Median from Data Stream (LeetCode 295) — two-heap technique, conceptually related

Also recommended: benchmark Heap Sort against Merge Sort and Quick Sort on the same random, sorted, and reverse-sorted inputs — directly observe that all three achieve similar asymptotic behavior on random data, but with meaningfully different wall-clock times due to cache locality differences.

---

## 15. Summary

**Key takeaways:**
- Heap Sort combines Merge Sort's guaranteed O(n log n) with Quick Sort's in-place (here, even better — O(1) vs O(log n)) space usage, at the cost of stability and real-world speed (poor cache locality).
- It's built entirely from the Heap data structure's existing machinery (build-heap in O(n), sift-down in O(log n)) — nothing new to learn mechanically, just a new *application* of a structure you already know.
- In practice, it's the "safety net" choice — theoretically excellent guarantees, but usually not the fastest option on typical, non-adversarial data.

**Complexity recap:**

| | Time (all cases) | Space | Stable |
|---|---|---|---|
| Heap Sort | O(n log n) | O(1) | No |

**Decision guide:** Choose Heap Sort when you need both a guaranteed worst-case time bound AND strict memory constraints (ruling out Merge Sort's O(n) space) — otherwise, Quick Sort (with randomization) usually wins on real-world speed, and Merge Sort wins when stability is required. Heap Sort's most common real-world role is as the safety-net fallback within hybrid sorts like introsort, rather than as a standalone first choice.

---

*Next chapter: `06_non_comparison_sorts.md` — Counting Sort, Radix Sort, Bucket Sort.*
