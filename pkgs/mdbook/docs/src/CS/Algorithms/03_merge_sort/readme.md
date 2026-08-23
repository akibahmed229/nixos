# Chapter 3: Merge Sort

*Study time: ~5-6 hours | Prerequisite: Recursion, Simple Sorts (Ch. 2) | Difficulty: Intermediate*

---

## 1. Introduction

**Definition:** Merge Sort is a **divide-and-conquer** sorting algorithm: recursively split the array in half until each piece has one element (trivially sorted), then repeatedly **merge** sorted pieces back together into larger sorted pieces until the whole array is sorted.

**Purpose:** To guarantee O(n log n) sorting performance — no worst-case degradation, unlike Quick Sort — at the cost of extra memory.

**Problem solved:** Sorting with a *guaranteed* time bound, and with **stability** (equal elements retain their relative order) — both properties matter in real systems (e.g., sorting by one field after already having sorted by another, or real-time systems that can't tolerate Quick Sort's rare O(n²) worst case).

---

## 2. Intuition

If you have two *already-sorted* piles of cards, merging them into one sorted pile is easy and fast: repeatedly compare the top cards of each pile, take the smaller, and repeat — this is O(n) for two piles totaling n cards, since each comparison "consumes" exactly one card. Merge Sort's insight is to **manufacture** those two sorted piles by recursively applying the same idea: a pile of 1 card is trivially "sorted," so you can always get down to piles small enough to be sorted for free, then merge your way back up.

This is the classic **divide-and-conquer** pattern: divide the problem into smaller subproblems of the same type, solve them (recursively, down to a trivial base case), then combine the subproblem solutions into a solution for the original problem.

---

## 3. Step-by-Step Working

**Sorting `[38, 27, 43, 3, 9, 82, 10]`:**

```
DIVIDE (recursively split in half until single elements):

[38,27,43,3,9,82,10]
       /          \
[38,27,43,3]      [9,82,10]
   /      \          /    \
[38,27]  [43,3]   [9,82]  [10]
  /  \     /  \      /  \
[38][27] [43][3]  [9][82]

CONQUER/COMBINE (merge sorted pairs back up):

[38]+[27] → merge → [27,38]
[43]+[3]  → merge → [3,43]
[9]+[82]  → merge → [9,82]
[10] stays as-is (odd one out at this level)

[27,38]+[3,43] → merge → [3,27,38,43]
[9,82]+[10]    → merge → [9,10,82]

[3,27,38,43]+[9,10,82] → merge → [3,9,10,27,38,43,82]  ← FINAL SORTED ARRAY
```

**The merge step itself**, merging `[3,27,38,43]` and `[9,10,82]`:
```
Pointers: i=0 (left), j=0 (right). Compare left[0]=3 vs right[0]=9 → 3 smaller → take 3, i=1
Compare left[1]=27 vs right[0]=9 → 9 smaller → take 9, j=1
Compare left[1]=27 vs right[1]=10 → 10 smaller → take 10, j=2
Compare left[1]=27 vs right[2]=82 → 27 smaller → take 27, i=2
Compare left[2]=38 vs right[2]=82 → 38 smaller → take 38, i=3
Compare left[3]=43 vs right[2]=82 → 43 smaller → take 43, i=4 (left exhausted)
Left exhausted — copy remaining right elements directly: 82

Result: [3,9,10,27,38,43,82]
```

---

## 4. Complexity Analysis

**Time: O(n log n), guaranteed in ALL cases (best, average, worst).**

The recursion splits the array in half at each level, producing **log₂(n) levels** of recursion (this is identical reasoning to Binary Search's O(log n): repeatedly halving n until you reach 1 takes log₂(n) steps). At **each level**, the total work across all the merges at that level is O(n) — every element gets touched exactly once per level during merging, regardless of how many pieces that level has been split into. Total work = (number of levels) × (work per level) = O(log n) × O(n) = **O(n log n)**.

**Why it's guaranteed, unlike Quick Sort:** Merge Sort's split is *always* exactly even (or as even as integer division allows) — it never depends on the data's actual values, unlike Quick Sort's pivot-dependent partitioning. This is precisely why Merge Sort has no bad-input vulnerability.

**Space: O(n) extra** — the merge step needs a temporary array to hold merged results (you can't merge two adjacent sorted subarrays purely in-place without either extra space or a much more complex, slower algorithm) — this is Merge Sort's main practical drawback versus Quick Sort's O(log n).

---

## 5. Advantages

- **Guaranteed O(n log n)** in every case — no adversarial input can degrade it, unlike Quick Sort.
- **Stable** — equal elements retain their original relative order, which matters for multi-key sorting and certain application-level correctness requirements.
- Naturally parallelizable — independent subarrays can be sorted concurrently on separate threads/cores before merging.
- Works well for **external sorting** (data too large to fit in memory) — merging sorted runs from disk is exactly what Merge Sort's core operation does, and it doesn't require random access to the whole dataset the way Quick Sort's partitioning does.

## 6. Limitations

- O(n) extra space — a real cost for very large datasets, and a genuine disadvantage versus in-place alternatives.
- Slightly slower in practice than a well-implemented Quick Sort on typical (non-adversarial) data, due to the overhead of allocating/copying the temporary merge array.
- Not in-place (standard implementation) — some specialized in-place merge sort variants exist, but they're significantly more complex and usually slower in practice than the extra-space version.

---

## 7. Real-World Applications

- **External Sorting:** Sorting datasets too large for RAM (database sort operations, large file sorting) — Merge Sort's sequential-access merge pattern is ideal for disk I/O, unlike Quick Sort's random-access partitioning.
- **Standard Library Sorts:** Java's `Arrays.sort()` for objects (not primitives) uses a variant of merge sort (Timsort, which is fundamentally merge-sort-based) specifically because stability matters for sorting objects by a field.
- **Databases:** Merge joins and external sort-merge operations in query execution engines.
- **Linked Lists:** Merge Sort is the preferred sort for linked lists specifically, since it doesn't need random access (unlike Quick Sort, which relies on it for efficient partitioning) — merging two sorted linked lists is a natural O(n) pointer-relinking operation.
- **Version Control / Diff Tools:** Merging sorted change sets uses the same underlying merge logic.
- **Distributed Systems:** MapReduce-style sorting of massive distributed datasets fundamentally relies on the same divide-conquer-merge structure.

---

## 8. C++ Implementation

```cpp
#include <iostream>
#include <vector>

// Merge two sorted subarrays arr[left..mid] and arr[mid+1..right] into one sorted range.
void merge(std::vector<int>& arr, int left, int mid, int right) {
    std::vector<int> leftPart(arr.begin() + left, arr.begin() + mid + 1);
    std::vector<int> rightPart(arr.begin() + mid + 1, arr.begin() + right + 1);

    int i = 0, j = 0, k = left;

    // Merge while both subarrays still have elements — always take the smaller front element.
    while (i < static_cast<int>(leftPart.size()) && j < static_cast<int>(rightPart.size())) {
        if (leftPart[i] <= rightPart[j]) {   // <= (not <) preserves stability for equal elements
            arr[k++] = leftPart[i++];
        } else {
            arr[k++] = rightPart[j++];
        }
    }

    // Copy any remaining elements — at most one of these loops does any work.
    while (i < static_cast<int>(leftPart.size())) arr[k++] = leftPart[i++];
    while (j < static_cast<int>(rightPart.size())) arr[k++] = rightPart[j++];
}

// Recursively divide, then merge on the way back up. O(n log n).
void mergeSort(std::vector<int>& arr, int left, int right) {
    if (left >= right) return;   // base case: 0 or 1 element is trivially sorted

    int mid = left + (right - left) / 2;
    mergeSort(arr, left, mid);         // sort left half
    mergeSort(arr, mid + 1, right);    // sort right half
    merge(arr, left, mid, right);      // combine the two sorted halves
}

// Example usage
int main() {
    std::vector<int> arr = {38, 27, 43, 3, 9, 82, 10};
    mergeSort(arr, 0, static_cast<int>(arr.size()) - 1);

    for (int x : arr) std::cout << x << " ";
    std::cout << "\n";   // 3 9 10 27 38 43 82
    return 0;
}
```

---

## 9. Code Walkthrough

- **`merge`'s temporary vectors `leftPart`/`rightPart`:** Copying both halves out first is what makes the merge itself simple and correct — trying to merge two adjacent ranges of the *same* array in-place without a copy is surprisingly tricky (you risk overwriting values you still need to read), which is exactly why Merge Sort's standard form isn't in-place.
- **`leftPart[i] <= rightPart[j]` (using `<=`, not `<`):** This is the specific detail that makes Merge Sort **stable** — when elements are equal, always preferring the left subarray's element (which, due to the recursive structure, always originated from an earlier position in the original array) preserves their original relative order.
- **The two trailing `while` loops:** Only one of them ever actually executes any iterations (whichever subarray still has leftover elements after the main merge loop exits) — but writing both is necessary since you don't know in advance which one will have leftovers.
- **`mergeSort`'s base case `left >= right`:** Handles both the 0-element case (`left > right`, shouldn't normally occur but is a safe guard) and the 1-element case (`left == right`) — both are trivially "already sorted," requiring no work.
- **Recursing on both halves BEFORE merging:** This ordering (divide fully, then combine on the way back up) is the defining structure of divide-and-conquer — contrast this with Quick Sort (next chapter), which does its "combine-equivalent" work (partitioning) *before* recursing, not after.

**Common mistakes to watch for here:**
- Using `<` instead of `<=` in the merge comparison, silently breaking stability.
- Off-by-one errors in the `mid` calculation or the subarray boundary indices passed to recursive calls.
- Forgetting either of the two trailing copy loops, losing leftover elements from whichever subarray wasn't fully consumed by the main merge loop.

---

## 10. Dry Run

Already traced in full in section 3 — the recursive split down to `[38]`, `[27]`, `[43]`, `[3]`, `[9]`, `[82]`, `[10]`, then merged back up level by level to `[3,9,10,27,38,43,82]`. The key detail worth re-emphasizing: **the merge step at the top level** (merging `[3,27,38,43]` with `[9,10,82]`) does exactly 6 comparisons to interleave 7 elements — each comparison "consumes" one element into the output, so the merge cost is linear in the combined size of the two halves being merged, consistent with the O(n) per-level claim from section 4.

---

## 11. Complexity Table

| Case | Time | Space |
|---|---|---|
| Best | O(n log n) | O(n) |
| Average | O(n log n) | O(n) |
| Worst | O(n log n) | O(n) |

**Every entry explained:** All three cases are identical because Merge Sort's split is always balanced (roughly n/2 and n/2) **regardless of the input data's actual values** — unlike Quick Sort, where an adversarial input can force wildly unbalanced splits. There is no "lucky" or "unlucky" input for Merge Sort's *time* complexity; the O(n) extra space is likewise constant across all cases, since the temporary merge buffer's size only depends on the subarray length being merged, never on data values.

---

## 12. Common Mistakes

- **Breaking stability** by using `<` instead of `<=` in the merge comparison.
- **Off-by-one errors** in computing `mid` or in the subarray ranges passed to recursive calls — extremely common, and worth carefully tracing through a small example (as in section 10) whenever debugging.
- **Forgetting to copy leftover elements** from whichever subarray wasn't fully drained during the main merge loop.
- **Assuming Merge Sort is in-place** — it fundamentally requires O(n) extra space in its standard form; don't claim O(1) space in an interview without discussing the significantly more complex in-place variants.
- **Unnecessary re-allocation** of temporary vectors on every single merge call in performance-sensitive code — a well-optimized implementation allocates one reusable buffer once, rather than a fresh vector on every recursive merge call.

---

## 13. Interview Questions

**Conceptual:**
1. Why is Merge Sort's time complexity guaranteed O(n log n) in all cases, unlike Quick Sort?
2. Explain why Merge Sort is stable and Quick Sort (standard implementation) is not.
3. Why does Merge Sort require O(n) extra space — can you avoid it?
4. Why is Merge Sort preferred for sorting linked lists specifically?
5. How would you parallelize Merge Sort across multiple threads/cores?

**Coding:**
1. Implement Merge Sort (array and linked list versions).
2. Count Inversions in an array using a modified merge step (an inversion is counted every time a right-subarray element is taken before a left-subarray element during merge).
3. Merge k Sorted Lists (generalizes the two-way merge to k-way — connects back to the Heap chapter in the Data Structures guide).
4. Sort a linked list in O(n log n) using merge sort.
5. External sort simulation: sort a dataset too large for memory using disk-based merge passes.

**Follow-ups / interviewer traps:**
- "Can you reduce the space complexity to O(1)?" (possible but significantly more complex and generally slower in practice — expects awareness that this is a real but rarely-used technique, not a simple tweak)
- "How does counting inversions relate to merge sort?" (tests recognizing that the merge step's "take from right before left is exhausted" moments are exactly the inversions — a beautiful, non-obvious connection worth knowing cold)
- "Merge k sorted lists — how does your approach's complexity compare to repeatedly merging two at a time?" (tests understanding that a heap-based k-way merge, O(N log k), beats naive repeated pairwise merging, O(N·k))

---

## 14. Practice Problems

**Easy**
- Merge Sorted Array (LeetCode 88) — related merge logic, different setup

**Medium**
- Sort an Array (LeetCode 912) — implement and benchmark against Chapter 2's sorts
- Sort List (LeetCode 148) — linked list merge sort
- Count of Smaller Numbers After Self (LeetCode 315) — solvable via modified merge sort

**Hard**
- Reverse Pairs (LeetCode 493) — modified merge sort counting a different condition
- Merge k Sorted Lists (LeetCode 23)
- Count of Range Sum (LeetCode 327)

Also recommended: implement Count Inversions and verify your count against a brute-force O(n²) double-loop on small test cases — an excellent correctness-check exercise.

---

## 15. Summary

**Key takeaways:**
- Merge Sort is the textbook example of divide-and-conquer: divide until trivial, conquer (merge) on the way back up.
- Its O(n log n) is *guaranteed*, not average-case, because the split is always balanced regardless of input values — the opposite of Quick Sort's data-dependent partitioning.
- Stability and guaranteed worst-case performance are Merge Sort's headline advantages; O(n) extra space is its main cost.

**Complexity recap:**

| | Time (all cases) | Space | Stable |
|---|---|---|---|
| Merge Sort | O(n log n) | O(n) | Yes |

**Decision guide:** Choose Merge Sort when you need guaranteed worst-case performance (real-time systems, adversarial-input contexts), stability (multi-key sorting), or you're sorting a linked list (no random access needed) or external/disk-resident data. If memory is tight and average-case performance is acceptable, Quick Sort (next chapter) is usually the faster practical choice.

---

*Next chapter: `04_quick_sort.md`*
