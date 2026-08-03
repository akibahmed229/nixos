# Chapter 15: Fenwick Tree (Binary Indexed Tree, BIT)

*Study time: ~5-6 hours | Prerequisite: Arrays, Bit Manipulation basics, Segment Tree (helpful for contrast) | Difficulty: Advanced*

---

## 1. Introduction

**Definition:** A Fenwick Tree (also called a Binary Indexed Tree, or BIT) is a compact array-based structure that supports **prefix sum queries** and **point updates**, both in O(log n), using clever bit manipulation instead of an explicit tree of pointers or a 4x-oversized array.

**Purpose:** To solve the exact same core problem as a Segment Tree — efficient range queries with efficient updates — but with a simpler implementation and roughly half the memory, specifically for prefix-sum-style (and other simply invertible) aggregate operations.

**Real-world analogy:** Think of a Fenwick Tree as a very well-organized set of "running subtotal" receipts, where each receipt only needs to be updated in a small, precisely chosen set of places when one purchase changes — rather than re-adding everything from the start, or (like a Segment Tree) walking an explicit tree structure. The "which places" is determined entirely by the binary representation of the index — a clever mathematical shortcut that replaces tree pointers with arithmetic.

**Motivation:** A Segment Tree solves the "range query + update" problem generally and flexibly, but for the common special case of prefix sums, its generality costs extra memory (4n) and more code. A Fenwick Tree achieves the *same asymptotic complexity* (O(log n) query and update) with a single flat array of size n+1 and two simple bit-manipulation formulas — no recursion, no explicit tree structure required (though it can be understood as an implicit tree).

**History:** Introduced by Peter Fenwick in a 1994 paper on "a new data structure for cumulative frequency tables," originally motivated by data compression algorithms needing fast cumulative frequency counts.

---

## 2. Why Do We Need It?

**Problem it solves:** Prefix sum queries and point updates, both in O(log n), with minimal memory and implementation complexity.

**Why previous structures are insufficient:**
- **Prefix sum array:** O(1) query, but O(n) update (must shift every subsequent prefix sum).
- **Plain array:** O(1) update, but O(n) query (must sum a whole prefix each time).
- **Segment Tree:** achieves the same O(log n) for both, but with ~4x the memory and a more involved recursive implementation — overkill when you only need sums (not arbitrary min/max/custom aggregates) and don't need lazy-propagation-style range updates.

**Trade-offs:**
- You gain O(log n) query/update with a tiny memory footprint (a single array of size n+1) and remarkably short, iterative (no recursion needed) code.
- You lose the Segment Tree's flexibility — a plain Fenwick Tree naturally handles only aggregates with an efficient **inverse** operation (sum's inverse is subtraction — this is what makes range-sum-via-two-prefix-sums work). Min/max, notably, do NOT have a usable inverse this way, so a standard Fenwick Tree cannot efficiently support range min/max queries the way a Segment Tree can.

---

## 3. Internal Working

**The key trick: every index's "responsibility range" is determined by its lowest set bit.**

For array size n=8 (1-indexed, which is the standard convention for Fenwick Trees — this avoids awkward edge cases at index 0):

```
Index (binary):  1(0001) 2(0010) 3(0011) 4(0100) 5(0101) 6(0110) 7(0111) 8(1000)
Responsible for:    [1]    [1,2]   [3]   [1,2,3,4] [5]   [5,6]    [7]  [1..8]
```

Each Fenwick array slot `tree[i]` stores the sum of a specific range ending at `i`, whose length is determined by `i`'s lowest set bit (the rightmost 1 in its binary representation). For example, `tree[4]` (binary 100, lowest set bit = 4) covers the sum of elements [1,2,3,4] — a range of length 4. `tree[6]` (binary 110, lowest set bit = 2) covers [5,6] — a range of length 2.

**Update (adding `delta` to position `i`):** move to the *next* index that also needs updating, by repeatedly adding the lowest set bit:
```
i = i + (i & (-i))
```

**Prefix sum query up to index `i`:** move to the *previous* relevant index by repeatedly removing the lowest set bit:
```
i = i - (i & (-i))
```

**Example — update index 3 by +5** (n=8):
```
Start i=3 (binary 011). Update tree[3].
i += (3 & -3) = 3 + 1 = 4 (binary 100). Update tree[4].
i += (4 & -4) = 4 + 4 = 8 (binary 1000). Update tree[8].
i += (8 & -8) = 8 + 8 = 16 > n=8, STOP.

Updated: tree[3], tree[4], tree[8]  — exactly the 3 nodes whose "responsibility range" includes index 3.
```

**Example — prefix sum query up to index 6** (binary 110):
```
Start i=6 (binary 110). Add tree[6] (covers [5,6]).
i -= (6 & -6) = 6 - 2 = 4 (binary 100). Add tree[4] (covers [1,2,3,4]).
i -= (4 & -4) = 4 - 4 = 0. STOP (i=0 means done).

Total = tree[6] + tree[4] = sum([5,6]) + sum([1,2,3,4]) = sum([1..6])  ✓
```

This is the entire mechanism — no explicit tree, no pointers, just two lines of bit arithmetic that implicitly navigate an underlying tree structure encoded in the binary representation of indices.

---

## 4. Operations

**Update(index, delta):**
- Starting at `index` (1-indexed), repeatedly add `delta` to `tree[index]`, then move to `index += index & (-index)`, until `index` exceeds array size n.
- O(log n) — each step strictly increases `index`, and there are at most O(log n) such steps (the number of bits in n).

**Prefix Sum Query(index):**
- Starting at `index`, repeatedly add `tree[index]` to a running total, then move to `index -= index & (-index)`, until `index` reaches 0.
- O(log n) — symmetric reasoning to Update.

**Range Sum Query(L, R):**
- Computed as `prefixSum(R) - prefixSum(L-1)` — this is exactly why sum (which has a clean inverse, subtraction) works so elegantly with a Fenwick Tree, while min/max (no clean inverse) do not.

**Point Update (set, not just add):**
- To *set* index `i` to a new value `v` (rather than adding a delta), first query the current value at `i` (via `prefixSum(i) - prefixSum(i-1)`), compute `delta = v - currentValue`, then call `Update(i, delta)`.

**Build from an initial array:**
- Simplest approach: start with all zeros, then call `Update(i, arr[i])` for each `i` — O(n log n) total. A more advanced O(n) construction exists but is rarely necessary in practice.

---

## 5. Time & Space Complexity

| Operation | Time Complexity | Space Complexity |
|---|---|---|
| Update (point) | O(log n) | O(1) extra |
| Prefix Sum Query | O(log n) | O(1) extra |
| Range Sum Query | O(log n) | O(1) extra |
| Build from array (naive) | O(n log n) | O(n) |
| Overall storage | — | O(n) — just one array, no 4x overhead |

**Why these hold:**
- Both Update and Query are O(log n) because each step of `i += i & (-i)` (or the subtractive equivalent) strictly changes `i`'s binary representation in a way that can happen at most O(log n) times before exceeding n (or reaching 0) — directly tied to n's number of bits.
- Storage is exactly O(n) — a single array of size n+1 — versus the Segment Tree's conventional 4n, a meaningful practical memory saving at scale.

---

## 6. Advantages

- Minimal memory: a single array of size n+1, versus a Segment Tree's ~4n.
- Simple, short, iterative code — no recursion, no explicit tree nodes/pointers.
- O(log n) for both prefix-sum-style queries and point updates.
- Easy to reason about once the bit-manipulation trick clicks (though that initial "click" can take real study time).

## 7. Disadvantages

- Limited to operations with a usable inverse (sum/subtraction is the classic case) — cannot directly support range min/max/GCD the way a Segment Tree can (some advanced variants exist for min/max with extra tricks, but they're considerably more complex and lose some of the simplicity that makes Fenwick Trees appealing in the first place).
- Less intuitive at first glance than a Segment Tree — the bit-manipulation logic, while elegant once understood, isn't as immediately visual as an explicit tree.
- Range updates (updating every element in a range) require an extra trick (a second Fenwick Tree, or a "difference array" technique) to remain O(log n) — not as naturally supported as a Segment Tree with lazy propagation.

---

## 8. Real-World Applications

- **Competitive Programming:** The default go-to structure for "point update, prefix/range sum query" problems — even more common than Segment Trees due to its simplicity, whenever a Segment Tree's extra flexibility isn't needed.
- **Data Compression:** Fenwick's original motivation — maintaining cumulative frequency tables efficiently for algorithms like arithmetic coding.
- **Databases/Analytics:** Efficient running-total/cumulative-statistics computation over frequently-updated data.
- **Inversion Counting:** Counting the number of "inversions" in a sequence (a classic algorithmic subproblem in sorting analysis and computational biology) is efficiently solved using a Fenwick Tree over ranks.
- **Order Statistics:** Answering "how many elements inserted so far are less than X" efficiently, which is foundational to some streaming/online algorithm designs.

---

## 9. Implementation (C++17)

```cpp
#include <iostream>
#include <vector>

// A Fenwick Tree (Binary Indexed Tree) supporting point updates and prefix sum queries.
// Uses 1-INDEXED internally (the standard convention) to avoid the (index & -index)
// trick breaking down at index 0.
class FenwickTree {
private:
    std::vector<long long> tree;
    int n;

public:
    // Construct a Fenwick Tree of size n, all zeros initially.
    FenwickTree(int size) : n(size), tree(size + 1, 0) {}

    // Add `delta` to the element at 1-indexed position `i`. O(log n).
    void update(int i, long long delta) {
        for (; i <= n; i += i & (-i)) {
            tree[i] += delta;
        }
    }

    // Sum of elements [1, i] (1-indexed prefix sum). O(log n).
    long long prefixSum(int i) const {
        long long sum = 0;
        for (; i > 0; i -= i & (-i)) {
            sum += tree[i];
        }
        return sum;
    }

    // Sum of elements [l, r] (1-indexed, inclusive). O(log n).
    long long rangeSum(int l, int r) const {
        return prefixSum(r) - prefixSum(l - 1);   // the "inverse" trick sum uniquely allows
    }

    // Build from an existing 0-indexed array. O(n log n) via repeated point updates.
    static FenwickTree buildFromArray(const std::vector<int>& arr) {
        FenwickTree ft(arr.size());
        for (size_t i = 0; i < arr.size(); ++i) {
            ft.update(static_cast<int>(i) + 1, arr[i]);   // convert to 1-indexed
        }
        return ft;
    }
};

// Example usage
int main() {
    std::vector<int> arr = {2, 4, 5, 7, 8, 9};   // 0-indexed input
    FenwickTree ft = FenwickTree::buildFromArray(arr);

    std::cout << "Sum [1,4] (0-indexed, i.e. 1-indexed [2,5]): "
              << ft.rangeSum(2, 5) << "\n";   // 4+5+7+8 = 24 (matches Segment Tree chapter's example)

    // Point update: arr[2] (0-indexed) changes from 5 to 10 → delta = +5, at 1-indexed position 3
    ft.update(3, 5);
    std::cout << "After update, Sum [1,6] (all elements): " << ft.prefixSum(6) << "\n";   // 40
    std::cout << "Sum [1,4] (0-indexed [2,5]) after update: " << ft.rangeSum(2, 5) << "\n"; // 29

    return 0;
}
```

---

## 10. Code Walkthrough

- **1-indexing throughout:** This is a deliberate, standard convention — the `i & (-i)` trick relies on `i`'s binary representation, and index 0 has *no* set bits at all, which would break the loop termination logic (`i -= i & (-i)` would never change from 0). Starting at 1 avoids this entirely.
- **`i & (-i)` (isolating the lowest set bit):** In two's-complement representation, `-i` is the bitwise NOT of `i` plus 1; ANDing `i` with `-i` isolates exactly the lowest set bit. This one expression is the entire "magic" behind both `update` and `prefixSum` — no explicit tree traversal is needed because this arithmetic *implicitly* walks the tree structure encoded in the binary index.
- **`update`'s loop (`i += i & (-i)`):** Moves to the next index whose "responsibility range" also covers the updated position — visually, this is climbing "up" the implicit tree toward larger ranges.
- **`prefixSum`'s loop (`i -= i & (-i)`):** Moves to the previous index needed to complete the prefix sum — visually, this is descending through the implicit tree, picking up pre-computed range sums along the way.
- **`rangeSum` via two prefix sums subtracted:** This single line is *why* Fenwick Trees are naturally suited to sum (and other operations with a clean inverse) — `sum(rangeL,R) = prefixSum(R) - prefixSum(L-1)` only works because subtraction correctly "undoes" addition. Min/max have no equivalent trick (`min` has no inverse operation that lets you "remove" a value's contribution this way).

**Common mistakes to watch for here:**
- Using 0-indexing without adjustment — breaks the `i & (-i)` logic at index 0.
- Confusing `update` (adds a delta) with a naive "set" operation — remember you must compute the delta yourself if you want to *set* a value rather than add to it.
- Forgetting the `-1` in `rangeSum(l, r) = prefixSum(r) - prefixSum(l-1)` — an extremely common off-by-one.

---

## 11. Dry Run

**Build from `[2, 4, 5, 7, 8, 9]`** (0-indexed), converting to 1-indexed updates: `update(1,2)`, `update(2,4)`, `update(3,5)`, `update(4,7)`, `update(5,8)`, `update(6,9)`.

**Trace `update(3, 5)`:**
```
i=3 (011): tree[3] += 5
i = 3 + (3 & -3) = 3 + 1 = 4 (100): tree[4] += 5
i = 4 + (4 & -4) = 4 + 4 = 8 → 8 > n=6, STOP
```
Only `tree[3]` and `tree[4]` touched — O(log n) = O(3) steps for n=6, matching the bound.

**Trace `prefixSum(5)`** (sum of elements [1..5], which in original terms is [2,4,5,7,8] = 26):
```
i=5 (101): sum += tree[5]
i = 5 - (5 & -5) = 5 - 1 = 4 (100): sum += tree[4]
i = 4 - (4 & -4) = 4 - 4 = 0, STOP

Result: tree[5] + tree[4]
```
After all the builds above, `tree[4]` holds the cumulative contribution for range [1,4] = 2+4+5+7=18, and `tree[5]` holds just position 5's value = 8 (since 5's binary is 101, lowest set bit =1, meaning it's responsible for a range of length 1 — just itself). Sum = 18 + 8 = 26. ✓ Matches manual sum of [2,4,5,7,8].

---

## 12. Interview Questions

**Conceptual:**
1. Explain how `i & (-i)` isolates the lowest set bit, and why that's the key to Fenwick Tree operations.
2. Why must Fenwick Trees be 1-indexed?
3. Compare Fenwick Tree vs. Segment Tree — memory, flexibility, and implementation complexity trade-offs.
4. Why can't a standard Fenwick Tree efficiently support range MIN/MAX queries the way it supports range SUM?
5. How would you use a Fenwick Tree to count inversions in an array?

**Coding:**
1. Range Sum Query - Mutable (LeetCode 307) — solvable with either Segment Tree or Fenwick Tree; implement with Fenwick Tree here for contrast.
2. Count of Smaller Numbers After Self (LeetCode 315) — classic Fenwick-over-ranks application.
3. Count Inversions in an array.
4. Range Addition (using a Fenwick Tree for the "difference array" range-update trick).

**Follow-ups / interviewer traps:**
- "Can you extend your Fenwick Tree to support range updates as well as range queries?" (expects the "two Fenwick Trees" or difference-array trick — noticeably more involved than the point-update version)
- "Why would you choose a Fenwick Tree over a Segment Tree here?" (tests whether they understand it's about memory/simplicity trade-off when only sum-like aggregates are needed, not raw speed — both are O(log n))

---

## 13. Practice Problems

**Easy**
- Range Sum Query - Immutable (LeetCode 303) — good baseline before adding mutability.

**Medium**
- Range Sum Query - Mutable (LeetCode 307)
- Count of Range Sum (LeetCode 327)

**Hard**
- Count of Smaller Numbers After Self (LeetCode 315)
- Count of Range Sum (LeetCode 327, harder variant)
- Create Sorted Array through Instructions (LeetCode 1649)

Also recommended: Codeforces problems tagged `data structures` + `fenwick`/`bit` (1400-1900 rating range), GeeksforGeeks "Binary Indexed Tree" practice set.

---

## 14. Common Mistakes

- **Forgetting 1-indexing**, silently breaking the bit-manipulation logic at index 0.
- **Off-by-one in `rangeSum(l, r) = prefixSum(r) - prefixSum(l-1)`** — a very common bug.
- **Confusing `update` (add a delta) with a `set` operation** — must compute and pass the delta, not the new absolute value directly.
- **Assuming Fenwick Trees can trivially handle min/max range queries** — they cannot, without significantly more complex extensions, precisely because min/max lack a usable inverse operation.
- **Reaching for a Fenwick Tree when the array never needs updates** — a simple prefix sum array is simpler and just as fast (O(1) query) in that case.

---

## 15. Summary

**Key takeaways:**
- A Fenwick Tree achieves the same O(log n) query/update as a Segment Tree, but with a single flat array and elegant bit-manipulation instead of an explicit tree — at the cost of only working cleanly for aggregates with a usable inverse (sum being the classic case).
- `i & (-i)` isolates the lowest set bit — the single arithmetic trick underlying both `update` and `prefixSum`.
- 1-indexing is mandatory, not optional, for the bit-manipulation logic to work correctly.

**Complexity recap:**

| Operation | Time | Space |
|---|---|---|
| Update | O(log n) | O(1) extra |
| Prefix Sum Query | O(log n) | O(1) extra |
| Range Sum Query | O(log n) | O(1) extra |
| Overall Storage | — | O(n) |

**Decision guideline:** Choose a Fenwick Tree when your problem is a prefix-sum/frequency-count-style range query with point updates — it's simpler and lighter than a Segment Tree for this common case. Choose a Segment Tree instead when you need range min/max/GCD, custom non-invertible aggregates, or lazy-propagation-style range updates.

---

*Next chapter: `16_disjoint_set_union.md`*
