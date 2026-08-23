# Chapter 1: Binary Search

*Study time: ~4-6 hours | Prerequisite: Big-O primer (see roadmap file) | Difficulty: Beginner (basics) to Intermediate (search-on-answer variant)*

---

## 1. Introduction

**Definition:** Binary Search finds a target value (or a boundary) within a **sorted** (or otherwise monotonic) search space by repeatedly halving the space — comparing the target against the middle element and discarding the half that can't contain it.

**Purpose:** To reduce search time from O(n) (checking every element) to O(log n) — an exponential improvement that becomes dramatic at scale (searching a billion-element sorted array takes ~30 comparisons, not a billion).

**Problem solved:** "Find whether/where a target exists in a sorted collection," and more generally, "find the boundary point where a monotonic condition flips from false to true (or vice versa)."

---

## 2. Intuition

Imagine guessing a number between 1 and 100 that someone is thinking of, where after each guess they tell you "higher" or "lower." The optimal strategy is never to guess sequentially (1, 2, 3, ...) — it's to always guess the **middle** of the remaining range. Guess 50: if "higher," you've just eliminated 50 numbers in one move. Guess 75 next: eliminate 25 more. This halving is *exactly* binary search — and it's the natural strategy any reasonable person derives on their own once they realize the "higher/lower" feedback is available for every guess, not just the first one.

The key insight that makes this valid: **the search space must be monotonic** — once you know the target is "higher" than 50, you can trust that it's *also* higher than every number below 50, without re-checking them. This trust is exactly what "sorted" (or "monotonic predicate") guarantees, and it's the one precondition binary search can never work without.

---

## 3. Step-by-Step Working

**Example: find 23 in `[2, 5, 8, 12, 16, 23, 38, 45, 56, 72]` (indices 0-9).**

```
low=0, high=9
Step 1: mid = (0+9)/2 = 4 → arr[4]=16. 23 > 16 → search RIGHT half → low = 5
Step 2: low=5, high=9, mid=(5+9)/2=7 → arr[7]=45. 23 < 45 → search LEFT half → high = 6
Step 3: low=5, high=6, mid=(5+6)/2=5 → arr[5]=23. MATCH! Return index 5.
```

Visually, the search space shrinks: `[10 elements]` → `[5 elements]` → `[2 elements]` → found. Each step **at least halves** the remaining space — this is the entire source of the O(log n) bound.

**Boundary variants (Lower Bound / Upper Bound):**
- **Lower Bound:** the first index where `arr[i] >= target` (first position you *could* insert target and keep the array sorted, if there are ties, inserting before them).
- **Upper Bound:** the first index where `arr[i] > target` (insertion point *after* any existing duplicates of target).

```
arr = [2, 5, 5, 5, 8, 12], target = 5:
Lower Bound → index 1 (first 5)
Upper Bound → index 4 (first element greater than 5, i.e., where 8 sits)
```

**Binary Search on the Answer:** the same halving logic applied to a *value*, not an array index, when a yes/no predicate about that value is monotonic. Example: "what's the minimum boat capacity to ferry all people across within D trips?" — as capacity increases, "can we do it in ≤ D trips?" flips from false to true exactly once, and never flips back — so you binary search over *capacity values*, not array positions.

---

## 4. Complexity Analysis

**Time: O(log n).** Each comparison discards **at least half** the remaining search space. Starting from n elements, after k halvings you have n/2^k elements left; the search ends when this reaches 1, i.e., `n/2^k = 1` → `k = log₂(n)`. This is why the complexity is logarithmic — it's the direct mathematical consequence of "always eliminate half," not an empirical observation.

**Space: O(1) iterative, O(log n) recursive** (the recursion depth equals the number of halvings, i.e., O(log n) stack frames if implemented recursively).

**Why it can't be faster than O(log n) for comparison-based search:** each comparison yields at most 1 bit of information ("higher" or "lower"), and you need enough bits to distinguish among n possibilities — information-theoretically, that requires at least log₂(n) comparisons in the worst case. Binary search achieves this lower bound exactly, making it asymptotically optimal for comparison-based search on sorted data.

---

## 5. Advantages

- O(log n) — extraordinarily fast, scales gracefully even to enormous datasets.
- O(1) extra space (iterative version) — no auxiliary memory needed.
- Generalizes far beyond "find X in an array" — any monotonic yes/no predicate over a range can be searched this way (binary search on the answer).

## 6. Limitations

- Requires sorted (or monotonic) data — if the data isn't sorted and can't be cheaply sorted/verified monotonic, binary search simply doesn't apply.
- Requires random access (O(1) indexing) to be efficient — doesn't work well on a plain linked list (no O(1) jump to the middle).
- Off-by-one bugs in boundary conditions (`<=` vs `<`, `mid` rounding) are notoriously easy to introduce — binary search has a well-earned reputation as "simple in concept, easy to get subtly wrong in code."

---

## 7. Real-World Applications

- **Databases:** Index lookups on sorted B-Tree pages internally use binary-search-like logic to find the right key within a node (see the Data Structures guide, Chapter 10).
- **Search Engines:** Locating a term's postings list within a sorted term dictionary.
- **Operating Systems:** Finding a specific memory page or process ID within sorted kernel structures.
- **Networking:** IP routing table lookups often use binary-search-like structures over sorted prefix ranges.
- **Finance:** Binary search on the answer is common in algorithmic trading systems for finding threshold prices/quantities satisfying a constraint.
- **Game Development:** Collision detection systems sometimes binary-search along a sorted spatial axis.
- **Compilers:** Symbol table lookups in sorted structures, and binary-searching version/compatibility ranges.
- **AI/ML:** Hyperparameter search sometimes uses binary-search-on-the-answer when a metric is known to be monotonic in a parameter.

---

## 8. C++ Implementation

```cpp
#include <iostream>
#include <vector>

// Classic binary search: return the index of target, or -1 if not found. O(log n).
int binarySearch(const std::vector<int>& arr, int target) {
    int low = 0, high = static_cast<int>(arr.size()) - 1;

    while (low <= high) {
        int mid = low + (high - low) / 2;   // avoids overflow vs (low+high)/2 for large indices

        if (arr[mid] == target) {
            return mid;
        } else if (arr[mid] < target) {
            low = mid + 1;    // target must be in the right half
        } else {
            high = mid - 1;   // target must be in the left half
        }
    }
    return -1;   // not found
}

// Lower Bound: first index where arr[i] >= target. O(log n).
int lowerBound(const std::vector<int>& arr, int target) {
    int low = 0, high = static_cast<int>(arr.size());   // note: high starts at size(), not size()-1

    while (low < high) {
        int mid = low + (high - low) / 2;
        if (arr[mid] < target) {
            low = mid + 1;
        } else {
            high = mid;        // arr[mid] >= target — this could be the answer, so keep it in range
        }
    }
    return low;   // low == high, the first index where arr[i] >= target (or arr.size() if none)
}

// Upper Bound: first index where arr[i] > target. O(log n).
int upperBound(const std::vector<int>& arr, int target) {
    int low = 0, high = static_cast<int>(arr.size());

    while (low < high) {
        int mid = low + (high - low) / 2;
        if (arr[mid] <= target) {
            low = mid + 1;
        } else {
            high = mid;
        }
    }
    return low;
}

// Binary Search on the Answer example: minimum "capacity" such that a monotonic
// predicate canAchieve(capacity) becomes true. O(log(range) * cost of predicate check).
// Here illustrated abstractly — canAchieve would be problem-specific.
int binarySearchOnAnswer(int lo, int hi, const std::function<bool(int)>& canAchieve) {
    while (lo < hi) {
        int mid = lo + (hi - lo) / 2;
        if (canAchieve(mid)) {
            hi = mid;         // mid works — try to do even better (smaller), keep mid in range
        } else {
            lo = mid + 1;      // mid doesn't work — need a larger value
        }
    }
    return lo;   // smallest value for which canAchieve(value) is true
}

// Example usage
int main() {
    std::vector<int> arr = {2, 5, 8, 12, 16, 23, 38, 45, 56, 72};

    std::cout << "binarySearch(23): " << binarySearch(arr, 23) << "\n";   // 5

    std::vector<int> withDupes = {2, 5, 5, 5, 8, 12};
    std::cout << "lowerBound(5): " << lowerBound(withDupes, 5) << "\n";   // 1
    std::cout << "upperBound(5): " << upperBound(withDupes, 5) << "\n";   // 4

    return 0;
}
```

---

## 9. Code Walkthrough

- **`mid = low + (high - low) / 2`:** This formula (rather than the seemingly-equivalent `(low + high) / 2`) avoids integer overflow when `low` and `high` are both large — a classic, real-world bug (famously present in early binary search implementations, including in published textbooks) that only manifests for very large arrays.
- **`binarySearch`'s loop condition `low <= high`:** The `<=` (not `<`) is essential — when `low == high`, there's still exactly one element left to check; using `<` would incorrectly skip it.
- **`lowerBound`/`upperBound`'s `high = arr.size()` (not `size()-1`):** These functions must be able to return "one past the end" (meaning "target would belong after every existing element") — starting `high` at `size()` (an otherwise-invalid index) is what allows that result to naturally fall out of the loop.
- **`lowerBound`'s `high = mid` (not `mid - 1`) on a "keep" condition:** Unlike classic binary search, here `mid` itself might be the answer, so we can't exclude it — we narrow `high` down to `mid` rather than `mid - 1`, and the loop continues until `low == high` converges on the exact boundary.
- **`binarySearchOnAnswer`'s abstracted predicate:** This function takes a `canAchieve` predicate as a parameter specifically to demonstrate that the *shape* of binary-search-on-the-answer is identical regardless of the underlying problem — only the predicate changes.

**Common mistakes to watch for here:**
- Using `(low + high) / 2` and hitting overflow on very large arrays.
- Using `<=` vs `<` inconsistently between the loop condition and the boundary-update logic, causing infinite loops or off-by-one skips.
- Forgetting that `lowerBound`/`upperBound` need `high` to start at `size()`, not `size()-1`.

---

## 10. Dry Run

**`lowerBound([2,5,5,5,8,12], target=5)`:**

| Step | low | high | mid | arr[mid] | Condition | Action |
|---|---|---|---|---|---|---|
| 1 | 0 | 6 | 3 | 5 | 5 >= 5 → keep | high = 3 |
| 2 | 0 | 3 | 1 | 5 | 5 >= 5 → keep | high = 1 |
| 3 | 0 | 1 | 0 | 2 | 2 < 5 → too small | low = 1 |
| 4 | 1 | 1 | — | — | low == high, loop ends | return 1 |

Result: index 1 — the first occurrence of 5. ✓

---

## 11. Complexity Table

| Case | Time | Space |
|---|---|---|
| Best (target is the middle element) | O(1) | O(1) |
| Average | O(log n) | O(1) |
| Worst (target absent, or at a boundary) | O(log n) | O(1) |

**Every entry explained:** Best case is O(1) purely by luck (the very first `mid` check happens to match). Average and worst case are both O(log n) because binary search's halving behavior doesn't depend on *where* the target is — even in the best-случaй-excluded general case, you're always doing the same halving work until either a match is found or the range is exhausted; there's no scenario (short of the lucky first guess) where fewer than ~log₂(n) comparisons are needed.

---

## 12. Common Mistakes

- **Integer overflow in mid calculation** (`(low+high)/2` on huge arrays/index ranges).
- **Off-by-one errors** in loop conditions and boundary updates — the single most common source of binary search bugs.
- **Applying binary search to unsorted or non-monotonic data** — silently gives wrong answers rather than crashing, which makes this mistake dangerous.
- **Confusing "found" binary search with boundary search** — using the wrong template when the problem actually wants a lower/upper bound, not an exact match.
- **Infinite loops** from inconsistent update rules (e.g., setting `high = mid` when it should be `high = mid - 1`, causing the range to never shrink).

---

## 13. Interview Questions

**Conceptual:**
1. Why does binary search require sorted (or monotonic) data specifically?
2. Prove that binary search is asymptotically optimal for comparison-based search — why can't any comparison-based algorithm beat O(log n) in the worst case?
3. What's "binary search on the answer," and how do you recognize when a problem calls for it?
4. Explain the difference between lower bound and upper bound, with an example involving duplicates.
5. Why is `low + (high-low)/2` preferred over `(low+high)/2`?

**Coding:**
1. Implement binary search (iterative and recursive).
2. Find the first and last occurrence of a target in a sorted array with duplicates.
3. Search in a rotated sorted array.
4. Find the peak element in a mountain array.
5. Median of Two Sorted Arrays (binary search on the partition point — a hard but classic application).
6. Capacity to Ship Packages Within D Days (binary search on the answer).
7. Split Array Largest Sum (binary search on the answer).

**Follow-ups / interviewer traps:**
- "What if the array has duplicates — does plain binary search still find *a* valid index?" (yes, but not necessarily the first/last — that's what lower/upper bound solve)
- "Can you binary search on a rotated sorted array?" (yes, with modified comparison logic — tests deeper understanding beyond the textbook template)
- "Your solution uses recursion — what's the space complexity, and can you make it O(1)?" (tests awareness of the iterative conversion)

---

## 14. Practice Problems

**Easy**
- Binary Search (LeetCode 704)
- Search Insert Position (LeetCode 35)
- Sqrt(x) (LeetCode 69)

**Medium**
- Find First and Last Position of Element in Sorted Array (LeetCode 34)
- Search in Rotated Sorted Array (LeetCode 33)
- Find Peak Element (LeetCode 162)
- Koko Eating Bananas (LeetCode 875) — binary search on the answer
- Capacity To Ship Packages Within D Days (LeetCode 1011)

**Hard**
- Median of Two Sorted Arrays (LeetCode 4)
- Split Array Largest Sum (LeetCode 410)
- Find in Mountain Array (LeetCode 1095)

Also recommended: GeeksforGeeks "Binary Search" practice set, Codeforces problems tagged `binary search` (rating 1200-1700 for a good progression).

---

## 15. Summary

**Key takeaways:**
- Binary search's O(log n) is a direct mathematical consequence of "each comparison eliminates at least half the remaining space" — not an empirical rule to memorize.
- The precondition is monotonicity, not literally "sortedness" — this generalization (binary search on the answer) unlocks a huge additional problem class beyond simple array search.
- Lower bound and upper bound are subtly different templates from exact-match search — know all three, and know which one a given problem actually needs.

**Complexity recap:**

| | Time | Space |
|---|---|---|
| Binary Search (any variant) | O(log n) | O(1) iterative |

**Decision guide:** Reach for binary search whenever data is sorted (or you can define a monotonic yes/no predicate) and you need to find a value, a boundary, or the optimal threshold of some parameter. If the data isn't sorted and can't cheaply be verified monotonic, look elsewhere (hashing for exact lookup, linear scan for one-off unsorted search).

---

*Next chapter: `02_simple_sorts.md`*
