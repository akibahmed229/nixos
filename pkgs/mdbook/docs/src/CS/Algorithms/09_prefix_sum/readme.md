# Chapter 9: Prefix Sum

*Study time: ~3-4 hours | Prerequisite: Arrays | Difficulty: Beginner*

---

## 1. Introduction

**Definition:** A Prefix Sum array precomputes, for each index i, the sum of all elements from the start of the array up to and including i. Once built, the sum of *any* range `[L, R]` can be answered in O(1) via a single subtraction, instead of re-summing the range each time.

**Purpose:** To answer **repeated range-sum queries** in O(1) each, after a one-time O(n) preprocessing pass — trading a small amount of upfront work and O(n) extra space for dramatically faster queries.

**Problem solved:** "Given an array, answer many queries of the form 'what's the sum of elements from index L to R?'" — naively O(n) per query (O(n·q) for q queries), reduced to O(n) total preprocessing + O(1) per query (O(n+q) total).

---

## 2. Intuition

If you know the running total of your bank account balance after every single transaction (a "prefix sum" of all deposits/withdrawals), you can answer "how much did I spend between transaction 5 and transaction 20?" instantly — just subtract balance-after-5 from balance-after-20 — without re-adding every individual transaction in that range. This is the entire idea: **precompute cumulative totals once, then any range's total is just a difference of two cumulative totals.**

```
prefixSum[i] = arr[0] + arr[1] + ... + arr[i]

sum(L, R) = prefixSum[R] - prefixSum[L-1]   (or prefixSum[R] if L==0)

Why this works: prefixSum[R] includes everything from 0 to R.
prefixSum[L-1] includes everything from 0 to L-1.
Subtracting removes exactly the "0 to L-1" portion, leaving exactly "L to R."
```

---

## 3. Step-by-Step Working

**Array `[2, 4, 5, 7, 8, 9]`. Build prefix sum:**

```
arr:        [2, 4, 5, 7, 8, 9]
prefixSum:  [2, 6, 11, 18, 26, 35]
             ↑   ↑    ↑   ↑   ↑   ↑
          arr[0] arr[0..1] arr[0..2] ... arr[0..5]

(prefixSum[i] = prefixSum[i-1] + arr[i], with prefixSum[0] = arr[0])
```

**Query sum(1, 4)** (elements at indices 1 through 4 → 4+5+7+8 = 24):
```
sum(1,4) = prefixSum[4] - prefixSum[0] = 26 - 2 = 24  ✓
```

**Query sum(0, 5)** (the whole array → 2+4+5+7+8+9 = 35):
```
sum(0,5) = prefixSum[5] = 35   (no subtraction needed when L=0)
```

**2D Prefix Sum** — the same idea extended to a matrix, for range-sum queries over rectangular submatrices:

```
matrix:            2D prefix sum (each cell = sum of the rectangle from (0,0) to (i,j)):
1  2  3             1   3   6
4  5  6             5  12  21
7  8  9            12  27  45

To query the sum of the rectangle from (r1,c1) to (r2,c2), use inclusion-exclusion:
sum = P[r2][c2] - P[r1-1][c2] - P[r2][c1-1] + P[r1-1][c1-1]
      (whole rect)  (remove top)  (remove left)  (add back double-removed corner)
```

The `+P[r1-1][c1-1]` term is necessary because subtracting both the "top" and "left" strips double-subtracts their overlapping corner region — adding it back once corrects for this, the same inclusion-exclusion principle used throughout combinatorics.

---

## 4. Complexity Analysis

**Build: O(n)** for 1D (a single pass, each `prefixSum[i]` computed from `prefixSum[i-1]` in O(1)); **O(n·m)** for a 2D array of size n×m (each cell computed in O(1) from three previously-computed neighbors).

**Query: O(1)** for 1D (one subtraction); **O(1)** for 2D (four array lookups + inclusion-exclusion arithmetic) — regardless of how large the queried range/rectangle is.

**Why O(1) query is possible:** all the "hard work" of summing is done exactly once, upfront, during the build phase — every query afterward is just reading two (or four, for 2D) precomputed values and combining them arithmetically, never re-traversing the actual range being queried.

**Total for q queries: O(n + q)** — compare this to the naive O(n·q) of re-summing each range from scratch every time. For a million queries on a million-element array, this is the difference between ~10^12 operations (infeasible) and ~2×10^6 operations (instant).

**Space: O(n)** extra for 1D, O(n·m) for 2D — the precomputed prefix array itself.

---

## 5. Advantages

- O(1) range-sum queries after O(n) preprocessing — a dramatic speedup for any workload with many repeated range queries on **static** (unchanging) data.
- Simple to implement and reason about — a single pass to build, simple arithmetic to query.
- Generalizes cleanly to 2D (and higher dimensions) via inclusion-exclusion.
- The same underlying idea generalizes beyond sums — prefix XOR, prefix min/max (with caveats — see limitations), prefix product, and other associative operations can use analogous precomputation.

## 6. Limitations

- **Only efficient for static data** — if the underlying array changes frequently (point updates), the prefix sum array would need to be rebuilt (or partially updated) on every change, losing the O(1) query advantage unless paired with a more sophisticated structure (a Fenwick Tree or Segment Tree — see the Data Structures guide, Chapters 15-16 — for O(log n) updates alongside O(log n) or O(1) queries).
- **Doesn't generalize to non-invertible operations** — prefix *min* or *max* cannot be "subtracted" the way sum can (there's no way to recover `min(L,R)` from `min(0,R)` and `min(0,L-1)` in general), so the simple prefix-sum-style range query trick doesn't extend to min/max queries; those need a different structure (Sparse Table for static data, or Segment Tree for dynamic).
- 2D prefix sums require careful inclusion-exclusion arithmetic — an easy source of off-by-one bugs, especially around the boundary rows/columns.

---

## 7. Real-World Applications

- **Databases:** materialized aggregate/rollup tables for fast range-based analytical queries (e.g., "total sales between date X and Y") are conceptually prefix-sum-based.
- **Image Processing:** "integral images" (2D prefix sums of pixel intensities) enable O(1) computation of the sum of any rectangular region — used heavily in real-time computer vision algorithms (e.g., the Viola-Jones face detection algorithm relies on integral images for fast feature computation).
- **Finance:** cumulative return/balance calculations, computing sum/average over arbitrary date ranges from a precomputed running total.
- **Analytics Dashboards:** any "sum/count over a custom date range" feature backed by precomputed cumulative aggregates.
- **Game Development:** precomputed cumulative probability distributions for weighted random selection (build a prefix sum of weights, then binary search — directly combining Chapter 1 and this chapter).
- **Competitive Programming:** an extremely common building-block technique, often combined with binary search, two pointers, or hashing to solve more complex range-based problems.

---

## 8. C++ Implementation

```cpp
#include <iostream>
#include <vector>

// 1D Prefix Sum. O(n) build, O(1) per query.
class PrefixSum1D {
private:
    std::vector<long long> prefix;

public:
    explicit PrefixSum1D(const std::vector<int>& arr) {
        prefix.resize(arr.size());
        prefix[0] = arr[0];
        for (size_t i = 1; i < arr.size(); ++i) {
            prefix[i] = prefix[i - 1] + arr[i];   // each cell built from the previous in O(1)
        }
    }

    // Sum of arr[L..R] inclusive. O(1).
    long long rangeSum(int L, int R) const {
        if (L == 0) return prefix[R];
        return prefix[R] - prefix[L - 1];
    }
};

// 2D Prefix Sum. O(n*m) build, O(1) per query.
class PrefixSum2D {
private:
    std::vector<std::vector<long long>> prefix;

public:
    explicit PrefixSum2D(const std::vector<std::vector<int>>& matrix) {
        int rows = static_cast<int>(matrix.size());
        int cols = static_cast<int>(matrix[0].size());
        prefix.assign(rows, std::vector<long long>(cols, 0));

        for (int i = 0; i < rows; ++i) {
            for (int j = 0; j < cols; ++j) {
                long long top = (i > 0) ? prefix[i - 1][j] : 0;
                long long left = (j > 0) ? prefix[i][j - 1] : 0;
                long long topLeft = (i > 0 && j > 0) ? prefix[i - 1][j - 1] : 0;
                // inclusion-exclusion: add top strip + left strip, subtract double-counted corner
                prefix[i][j] = matrix[i][j] + top + left - topLeft;
            }
        }
    }

    // Sum of the rectangle from (r1,c1) to (r2,c2) inclusive. O(1).
    long long rangeSum(int r1, int c1, int r2, int c2) const {
        long long total = prefix[r2][c2];
        long long top = (r1 > 0) ? prefix[r1 - 1][c2] : 0;
        long long left = (c1 > 0) ? prefix[r2][c1 - 1] : 0;
        long long topLeft = (r1 > 0 && c1 > 0) ? prefix[r1 - 1][c1 - 1] : 0;
        return total - top - left + topLeft;   // inclusion-exclusion again, in reverse
    }
};

// Example usage
int main() {
    std::vector<int> arr = {2, 4, 5, 7, 8, 9};
    PrefixSum1D ps(arr);
    std::cout << "sum(1,4): " << ps.rangeSum(1, 4) << "\n";   // 24
    std::cout << "sum(0,5): " << ps.rangeSum(0, 5) << "\n";   // 35

    std::vector<std::vector<int>> matrix = {
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9}
    };
    PrefixSum2D ps2d(matrix);
    std::cout << "rectSum(0,0,1,1): " << ps2d.rangeSum(0, 0, 1, 1) << "\n";   // 1+2+4+5=12
    std::cout << "rectSum(1,1,2,2): " << ps2d.rangeSum(1, 1, 2, 2) << "\n";   // 5+6+8+9=28

    return 0;
}
```

---

## 9. Code Walkthrough

- **`PrefixSum1D`'s build loop:** Each `prefix[i]` is computed as `prefix[i-1] + arr[i]` — O(1) work per index, O(n) total, since each cell only ever looks at its immediate predecessor.
- **`rangeSum`'s `L == 0` special case:** Without this check, `prefix[L-1]` would be `prefix[-1]`, an out-of-bounds access — the special case handles the fact that "everything before index 0" has a sum of 0, which isn't naturally representable as `prefix[-1]`.
- **`PrefixSum2D`'s build formula (`matrix[i][j] + top + left - topLeft`):** This is inclusion-exclusion in action — `top` and `left` each independently include the `topLeft` corner region, so naively adding both would double-count it; subtracting `topLeft` once corrects for exactly that overcounting.
- **`PrefixSum2D::rangeSum`'s four-term formula:** The mirror image of the build formula — start with the full rectangle from the origin to `(r2,c2)`, subtract the excess "top" strip and "left" strip, then add back `topLeft` once since it was subtracted twice (once as part of each strip).
- **Using `long long` instead of `int`:** Prefix sums can grow large even when individual elements are small (a sum of a million elements each up to 1000 could reach a billion, straining `int`'s range) — using a wider type is a defensive habit worth having by default for any accumulating sum.

**Common mistakes to watch for here:**
- Forgetting the `L == 0` (or `r1==0`/`c1==0`) boundary special cases, causing out-of-bounds access.
- Sign errors in the 2D inclusion-exclusion formula (forgetting to subtract `topLeft`, or adding instead of subtracting a term) — always re-derive this formula from first principles rather than memorizing it verbatim if unsure.
- Using `int` instead of a wider type for large arrays/value ranges, risking silent overflow.
- Rebuilding the entire prefix sum array on every single point update instead of recognizing that this workload calls for a Fenwick Tree or Segment Tree instead (Data Structures guide, Chapters 15-16).

---

## 10. Dry Run

**2D query `rangeSum(1,1,2,2)` on the matrix from section 8** (prefix table computed in section 3):

```
prefix table:
 1   3   6
 5  12  21
12  27  45

rangeSum(r1=1,c1=1,r2=2,c2=2):
total = prefix[2][2] = 45
top = prefix[0][2] = 6      (r1-1=0)
left = prefix[2][0] = 12     (c1-1=0)
topLeft = prefix[0][0] = 1    (r1-1=0, c1-1=0)

result = 45 - 6 - 12 + 1 = 28
```

Verify directly: the rectangle from (1,1) to (2,2) covers matrix values 5,6,8,9 → sum = 5+6+8+9 = 28. ✓

---

## 11. Complexity Table

| Operation | Time | Space |
|---|---|---|
| Build (1D) | O(n) | O(n) |
| Build (2D) | O(n·m) | O(n·m) |
| Query (1D or 2D) | O(1) | — |
| Naive re-sum per query (for comparison) | O(range size) | O(1) |

**Every entry explained:** Build cost is linear (or the 2D equivalent) because each cell is computed once from a small, fixed number of already-computed neighbors — no cell is ever revisited. Query cost is O(1) precisely because it never touches the original range at all, only the small, fixed number of precomputed boundary values — this decoupling of "one-time preprocessing cost" from "per-query cost" is the entire value proposition of the technique.

---

## 12. Common Mistakes

- **Off-by-one errors at range boundaries**, especially the `L==0` / `r1==0` / `c1==0` special cases.
- **Sign errors in the 2D inclusion-exclusion formula** — always sanity-check against a small hand-computed example (as in section 10) when in doubt.
- **Applying prefix sum to frequently-updated data** without recognizing that a Fenwick Tree or Segment Tree is the appropriate tool once updates enter the picture.
- **Attempting to extend the technique naively to min/max queries** — subtraction-based range recovery fundamentally doesn't work for non-invertible operations; a different structure (Sparse Table, Segment Tree) is needed instead.
- **Integer overflow** from not using a sufficiently wide type for large cumulative sums.

---

## 13. Interview Questions

**Conceptual:**
1. Why does Prefix Sum achieve O(1) query time, and what's the total cost across n build operations plus q queries compared to naive re-summing?
2. Why doesn't the prefix-sum trick work for range *minimum* or *maximum* queries the way it works for sums?
3. Explain the inclusion-exclusion principle behind the 2D prefix sum query formula.
4. When would you use a Fenwick Tree instead of a plain Prefix Sum array?
5. How does an "integral image" in computer vision relate to 2D prefix sums?

**Coding:**
1. Implement 1D and 2D Prefix Sum from scratch.
2. Range Sum Query - Immutable (LeetCode 303) — the direct 1D application.
3. Range Sum Query 2D - Immutable (LeetCode 304) — the direct 2D application.
4. Subarray Sum Equals K (LeetCode 560) — prefix sum combined with a hash map for O(n) counting.
5. Product of Array Except Self (LeetCode 238) — a prefix/suffix product variant of the same idea.
6. Continuous Subarray Sum (LeetCode 523) — prefix sum + modular arithmetic.

**Follow-ups / interviewer traps:**
- "The array now needs point updates — does your Prefix Sum approach still work efficiently?" (no — expects recognizing that a Fenwick Tree or Segment Tree is now the right tool, since naive prefix sum rebuild is O(n) per update)
- "Can you count subarrays summing to exactly K in O(n)?" (expects combining prefix sums with a hash map tracking "how many times has this prefix sum value been seen before" — a very common and elegant technique)
- "Why doesn't this technique work for range GCD or range XOR the same way it works for sum?" (XOR is actually invertible — same trick works via `prefixXor[R] ^ prefixXor[L-1]` — but GCD is not; tests whether the candidate understands *which* operations are invertible, not just memorizing "sum works")

---

## 14. Practice Problems

**Easy**
- Range Sum Query - Immutable (LeetCode 303)
- Running Sum of 1d Array (LeetCode 1480)
- Find Pivot Index (LeetCode 724)

**Medium**
- Range Sum Query 2D - Immutable (LeetCode 304)
- Subarray Sum Equals K (LeetCode 560)
- Product of Array Except Self (LeetCode 238)
- Continuous Subarray Sum (LeetCode 523)

**Hard**
- Maximum Size Subarray Sum Equals K (related prefix-sum + hash map problem)
- Count of Range Sum (LeetCode 327) — combines prefix sum with merge sort or a BIT/Segment Tree

Also recommended: GeeksforGeeks "Prefix Sum Array" practice set; implement the "count subarrays summing to K" pattern from scratch, as it's one of the most widely reused prefix-sum + hash map combinations in interview problem sets.

---

## 15. Summary

**Key takeaways:**
- Prefix Sum trades O(n) one-time preprocessing for O(1) range-sum queries — ideal for static data with many repeated range queries.
- The technique fundamentally relies on sum being *invertible* (subtraction recovers a sub-range) — it does not generalize to non-invertible operations like min/max without a different underlying structure.
- 2D prefix sums use inclusion-exclusion, a pattern worth internalizing since it recurs throughout combinatorics and range-query problems generally.

**Complexity recap:**

| | Time | Space |
|---|---|---|
| Build | O(n) [1D] / O(n·m) [2D] | O(n) / O(n·m) |
| Query | O(1) | — |

**Decision guide:** Reach for Prefix Sum whenever you have static data and need to answer many range-sum (or other invertible-operation) queries efficiently. If the data needs frequent updates, move to a Fenwick Tree or Segment Tree (Data Structures guide, Chapters 15-16) instead — same query-speed philosophy, but supporting O(log n) updates that plain Prefix Sum cannot handle efficiently.

---

*Next chapter: `10_greedy_algorithms.md`*
