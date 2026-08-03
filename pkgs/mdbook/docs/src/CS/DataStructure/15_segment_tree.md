# Chapter 14: Segment Tree

*Study time: ~7-9 hours | Prerequisite: Binary Tree, Recursion, Arrays | Difficulty: Advanced*

---

## 1. Introduction

**Definition:** A Segment Tree is a binary tree built over an array where each node represents the aggregate (sum, min, max, gcd, etc.) of a contiguous **range (segment)** of the array. The root represents the whole array; each node's two children split its range in half.

**Purpose:** To answer **range queries** ("what's the sum/min/max of elements from index L to R?") and support **point or range updates**, both in O(log n) — dramatically better than the O(n) a plain array requires for range queries.

**Real-world analogy:** Think of a company's org chart where every manager's "total headcount" is the sum of their direct reports' headcounts (recursively). If one employee joins or leaves, you only need to update the counts along that one employee's chain of managers up to the CEO — not recount the entire company from scratch. A Segment Tree is exactly this "hierarchical running total" idea applied to array ranges.

**Motivation:** A plain array answers "sum of range [L,R]" in O(n) (must add every element) or, with a **prefix sum** array, in O(1) — but a prefix sum array requires O(n) to *update* if any element changes (every prefix sum after that index must shift). A Segment Tree is the structure that supports **both** range queries **and** updates efficiently — the prefix-sum approach breaks down the moment updates are required.

**History:** Segment trees emerged from computational geometry research in the 1970s-80s, and became a competitive-programming staple due to their flexibility for arbitrary associative range operations.

---

## 2. Why Do We Need It?

**Problem it solves:** "Query an aggregate over a range, AND update elements" — both efficiently, at the same time. This combination is what no simpler structure handles well.

**Why previous structures are insufficient:**
- **Plain array:** O(1) point update, but O(n) range query.
- **Prefix sum array:** O(1) range query, but O(n) point update (shifting all subsequent prefix sums).
- **Fenwick Tree (next chapter):** handles prefix sums and point updates in O(log n) elegantly, but is naturally suited to simpler aggregate operations (mainly sums/frequency counts) and is less flexible for complex custom range operations (range min/max, GCD, or operations needing **lazy propagation** for range updates).

**Trade-offs:**
- You gain O(log n) for both range queries and updates, plus flexibility for *any* associative operation (sum, min, max, gcd, XOR, custom combine function).
- You pay for it with roughly 4x the array's memory (a common implementation convention, explained in section 3), and meaningfully more implementation complexity than a Fenwick Tree for the simple-sum case.

---

## 3. Internal Working

**Array:** `[2, 4, 5, 7, 8, 9]` (indices 0-5). **Segment Tree for range SUM**, built recursively — each node covers a range `[lo, hi]`, and its value is the sum of that range:

```
                          [0,5]=35
                        /          \
                 [0,2]=11         [3,5]=24
                /       \          /       \
          [0,1]=6    [2,2]=5  [3,4]=15   [5,5]=9
          /    \                /    \
      [0,0]=2 [1,1]=4       [3,3]=7 [4,4]=8
```

Each internal node's value = sum of its two children — exactly like the org-chart headcount analogy. Leaves correspond to individual array elements.

**Array representation (common convention):** stored in a flat array of size ~4n, where for a node at index `i`: left child = `2i+1`, right child = `2i+2` (same indexing scheme as a Heap — Chapter 4 — though a Segment Tree isn't a *complete* binary tree, so it needs roughly double the heap's array size to safely accommodate all possible node positions).

**Range query for sum([1,4])** — decompose the query range into segments that exactly match existing nodes, recursing only where necessary:

```
Query [1,4] against root [0,5]: partially overlaps → recurse into both children.
  [0,2]: partially overlaps [1,4] → recurse into children.
    [0,1]: partially overlaps → recurse.
      [0,0]: outside [1,4] entirely → contribute 0, stop.
      [1,1]: fully inside [1,4] → contribute value 4, stop (no need to go deeper!)
    [2,2]: fully inside [1,4] → contribute value 5, stop.
  [3,5]: partially overlaps [1,4] → recurse into children.
    [3,4]: fully inside [1,4] → contribute value 15, stop.
    [5,5]: outside [1,4] → contribute 0, stop.

Total: 4 + 5 + 15 = 24
```

Notice how, the moment a node's range is **fully inside** the query range, recursion stops immediately (no need to descend further) — this "early stop at full containment" is exactly why the query is O(log n) rather than O(n): at most O(log n) nodes are fully contained per level, and there are O(log n) levels.

**Point update** — update index 2 from 5 to 10, propagating the change up:

```
Leaf [2,2]: 5 → 10
Parent [0,2]: recompute as sum of children [0,1]=6 and [2,2]=10 → 16
Root [0,5]: recompute as sum of children [0,2]=16 and [3,5]=24 → 40
```
Only the O(log n) ancestors of the updated leaf need recomputation — everything else is untouched.

---

## 4. Operations

**Build:**
- Recursively split `[lo, hi]` into `[lo, mid]` and `[mid+1, hi]`, build each half, then combine (e.g., sum) their results into the current node.
- O(n) total — every node is computed exactly once, and there are O(n) nodes total (roughly 2n-1 for a full binary tree over n leaves).

**Range Query (e.g., sum/min/max over [L,R]):**
- If the current node's range is entirely outside [L,R], return the "identity" (0 for sum, +∞ for min, etc.) — contributes nothing.
- If the current node's range is entirely inside [L,R], return its stored value directly — no need to recurse further.
- Otherwise (partial overlap), recurse into both children and combine their results.
- O(log n) — as shown in the dry run above.

**Point Update:**
- Recurse down to the specific leaf, update it, then recompute every ancestor on the way back up as the combination of its two children.
- O(log n) — only one path from root to leaf is touched.

**Range Update (with Lazy Propagation — an important extension):**
- Naively updating every element in a range one at a time would be O(range size × log n) — too slow for large ranges.
- **Lazy propagation** defers updates: mark a node as "pending an update" without immediately recursing into its children; only push the pending update down when that subtree is actually visited by a later query/update. This brings range updates down to O(log n) as well.

---

## 5. Time & Space Complexity

| Operation | Time Complexity | Space Complexity |
|---|---|---|
| Build | O(n) | O(n) (~4n array, common convention) |
| Range Query | O(log n) | O(log n) recursion stack |
| Point Update | O(log n) | O(log n) recursion stack |
| Range Update (with lazy propagation) | O(log n) | O(n) extra for the lazy array |
| Range Update (without lazy propagation, naive) | O(range size × log n) | — |

**Why these hold:**
- Build is O(n) because each of the ~2n-1 nodes is computed exactly once via a single combine operation from its two children — a classic "sum of a geometric-like recursive structure" that totals linear work.
- Range Query is O(log n) because, at each level of the tree, the query range boundary can only "split" the range into partial-overlap segments at most twice (once on the left edge, once on the right edge) — everything else is either fully inside (stop immediately) or fully outside (stop immediately). This bounds the number of nodes visited to O(log n) per level × O(log n) levels... more precisely, it works out to O(log n) total visited nodes, not O(log² n), due to how the partial-overlap nodes telescope.
- Point Update is O(log n) because it only touches the single root-to-leaf path, which has length equal to the tree's height, O(log n).

---

## 6. Advantages

- O(log n) for both range queries **and** updates — the combination neither a plain array nor a prefix-sum array can offer simultaneously.
- Extremely flexible — works for any associative operation with an identity element (sum, min, max, GCD, XOR, custom combiners), unlike some more specialized structures.
- Lazy propagation extends it to efficient **range** updates (not just point updates), a capability few simpler structures have at all.

## 7. Disadvantages

- More complex to implement correctly than a Fenwick Tree, especially with lazy propagation.
- Roughly 4x memory overhead compared to the raw array (common array-based implementation convention) — though pointer-based or dynamically-sized variants can reduce this.
- Overkill for problems that only need simple prefix sums with point updates — a Fenwick Tree (next chapter) is simpler and sufficient there.

---

## 8. Real-World Applications

- **Databases:** Range-aggregate query optimization (e.g., "sum of sales between these dates") in specialized analytical engines.
- **Competitive Programming:** A staple for range-query problems — arguably the single most common "advanced data structure" in competitive programming contests.
- **Computational Geometry:** Interval/range problems (finding overlapping intervals, stabbing queries).
- **Gaming/Graphics:** Range-based collision or visibility queries over spatial data.
- **Financial Systems:** Real-time range aggregation over time-series data (e.g., "max stock price in this time window," updated as new prices stream in).
- **Bioinformatics:** Range queries over genomic sequence data.

---

## 9. Implementation (C++17)

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
#include <climits>

// A Segment Tree for RANGE SUM queries with POINT updates.
// (For range min/max, just change the combine function and identity value.)
class SegmentTree {
private:
    std::vector<long long> tree;
    int n;

    // Build the tree recursively. node covers array range [lo, hi].
    void build(const std::vector<int>& arr, int node, int lo, int hi) {
        if (lo == hi) {
            tree[node] = arr[lo];   // leaf: directly the array value
            return;
        }
        int mid = lo + (hi - lo) / 2;
        build(arr, 2 * node + 1, lo, mid);
        build(arr, 2 * node + 2, mid + 1, hi);
        tree[node] = tree[2 * node + 1] + tree[2 * node + 2];   // combine children
    }

    // Query the sum of [qlo, qhi]. node covers [lo, hi].
    long long query(int node, int lo, int hi, int qlo, int qhi) {
        if (qhi < lo || hi < qlo) return 0;              // completely outside — identity for sum
        if (qlo <= lo && hi <= qhi) return tree[node];    // completely inside — no need to recurse further
        int mid = lo + (hi - lo) / 2;
        long long leftSum = query(2 * node + 1, lo, mid, qlo, qhi);
        long long rightSum = query(2 * node + 2, mid + 1, hi, qlo, qhi);
        return leftSum + rightSum;                         // partial overlap — combine both halves
    }

    // Point update: set arr[idx] = value. node covers [lo, hi].
    void update(int node, int lo, int hi, int idx, int value) {
        if (lo == hi) {
            tree[node] = value;   // reached the target leaf
            return;
        }
        int mid = lo + (hi - lo) / 2;
        if (idx <= mid) update(2 * node + 1, lo, mid, idx, value);
        else update(2 * node + 2, mid + 1, hi, idx, value);
        tree[node] = tree[2 * node + 1] + tree[2 * node + 2];   // recompute on the way back up
    }

public:
    SegmentTree(const std::vector<int>& arr) : n(arr.size()) {
        tree.assign(4 * n, 0);   // common safe-size convention: 4n covers any n
        if (n > 0) build(arr, 0, 0, n - 1);
    }

    // Public range sum query. O(log n).
    long long rangeSum(int qlo, int qhi) {
        return query(0, 0, n - 1, qlo, qhi);
    }

    // Public point update. O(log n).
    void pointUpdate(int idx, int value) {
        update(0, 0, n - 1, idx, value);
    }
};

// Example usage
int main() {
    std::vector<int> arr = {2, 4, 5, 7, 8, 9};
    SegmentTree segTree(arr);

    std::cout << "Sum [1,4]: " << segTree.rangeSum(1, 4) << "\n";   // 4+5+7+8 = 24

    segTree.pointUpdate(2, 10);   // arr[2]: 5 -> 10
    std::cout << "After update, Sum [0,5]: " << segTree.rangeSum(0, 5) << "\n";   // 2+4+10+7+8+9 = 40
    std::cout << "Sum [1,4] after update: " << segTree.rangeSum(1, 4) << "\n";    // 4+10+7+8 = 29

    return 0;
}
```

---

## 10. Code Walkthrough

- **`tree` sized `4 * n`:** This is a well-known safe upper bound for the array representation of a segment tree over n leaves, accounting for the tree not necessarily being a *perfectly* complete binary tree (unlike a Heap) — using `2i+1`/`2i+2` indexing can "waste" some slots when n isn't a power of 2, and 4n comfortably covers the worst case.
- **`build`'s base case (`lo == hi`):** A single-element range is a leaf — directly copy the array value, no combining needed. The recursive case builds both halves first, *then* combines — this bottom-up combination is what makes each node's value correct by construction.
- **`query`'s three-way branch:** This is the heart of the O(log n) query complexity — "completely outside" and "completely inside" both terminate immediately without further recursion; only "partial overlap" recurses into both children. Most of the recursion tree's nodes hit one of the two immediate-return cases, not the recursive case — which is exactly why total work stays O(log n).
- **`update`'s "recompute on the way back up" (`tree[node] = tree[2*node+1] + tree[2*node+2]`):** Executed *after* the recursive call returns, ensuring children are already updated before the parent recomputes — this bottom-up recompute pattern mirrors `build`'s combination step exactly.
- **Swapping for a different aggregate:** To convert this into a range-MIN segment tree, you'd change `return 0` (outside case) to `return INT_MAX` (the identity for min), and change every `+` combination to `std::min(...)`. This symmetry — just swap the combine function and identity — is what makes segment trees so flexible.

**Common mistakes to watch for here:**
- Using the wrong "identity" value for the aggregate (0 for sum is correct, but would be catastrophically wrong for min/max, where you need +∞/-∞ respectively).
- Off-by-one errors in `mid` calculation or range boundaries (`qlo <= lo && hi <= qhi` vs. `<` mistakes) — segment trees are notoriously easy to get subtly wrong here.
- Under-sizing the `tree` array (using `2n` instead of `4n`), causing out-of-bounds access for certain n.

---

## 11. Dry Run

**Array:** `[2, 4, 5, 7, 8, 9]`. Query `rangeSum(1, 4)`:

Matches the section 3 walkthrough exactly:
- Node `[0,5]`: partial overlap with `[1,4]` → recurse both children.
- Node `[0,2]`: partial overlap → recurse.
  - Node `[0,1]`: partial overlap → recurse.
    - Node `[0,0]`: `[0,0]` vs query `[1,4]` → `hi(0) < qlo(1)` → completely outside → return 0.
    - Node `[1,1]`: `qlo(1) <= lo(1)` and `hi(1) <= qhi(4)` → completely inside → return 4.
  - Node `[2,2]`: completely inside `[1,4]` → return 5.
- Node `[3,5]`: partial overlap → recurse.
  - Node `[3,4]`: completely inside `[1,4]` → return 15.
  - Node `[5,5]`: `lo(5) > qhi(4)` → completely outside → return 0.

Sum: 0 + 4 + 5 + 15 + 0 = 24. ✓ (Manually: 4+5+7+8 = 24.)

**Now `pointUpdate(2, 10)`:** Recurse down to leaf `[2,2]`, set to 10. Recompute `[0,2]` = tree[0,1](=6) + tree[2,2](=10) = 16. Recompute `[0,5]` = tree[0,2](=16) + tree[3,5](=24) = 40. Only 2 ancestor nodes recomputed — O(log n) work, not O(n).

---

## 12. Interview Questions

**Conceptual:**
1. Why is a Segment Tree's range query O(log n) rather than O(n) or O(log² n)?
2. Compare Segment Tree vs. Fenwick Tree — when would you choose each?
3. What is lazy propagation, and why is it necessary for efficient range updates?
4. Why does a Segment Tree need ~4n space instead of exactly 2n?
5. How would you adapt a sum Segment Tree into a min/max/GCD Segment Tree?

**Coding:**
1. Range Sum Query - Mutable (LeetCode 307) — the canonical Segment Tree problem.
2. Range Minimum/Maximum Query with point updates.
3. Count of Smaller Numbers After Self (using a Segment Tree over value ranks).
4. Implement lazy propagation for range-update, range-sum-query.
5. Falling Squares (interval max-height queries).

**Follow-ups / interviewer traps:**
- "Can you support range updates without lazy propagation, and what's the complexity cost?" (naive per-element update: O(range × log n) — expects you to identify this as too slow for large ranges, and know lazy propagation as the fix)
- "How would this differ if the array itself could change size (insertions/deletions), not just values?" (a plain segment tree assumes fixed size; dynamic sizing needs a different structure entirely, like a balanced-tree-based segment tree)

---

## 13. Practice Problems

**Easy**
- Range Sum Query - Immutable (LeetCode 303) — simpler prefix-sum suffices here, but good grounding.

**Medium**
- Range Sum Query - Mutable (LeetCode 307)
- Count of Range Sum (LeetCode 327)

**Hard**
- Falling Squares (LeetCode 699)
- Count of Smaller Numbers After Self (LeetCode 315)
- The Skyline Problem (LeetCode 218) — often solved with a Segment Tree variant

Also recommended: Codeforces problems tagged `data structures` + `segment tree` (1500-2000 rating range), GeeksforGeeks "Segment Tree" practice set.

---

## 14. Common Mistakes

- **Using the wrong identity value** for the aggregate operation (0 for sum ≠ correct identity for min/max).
- **Off-by-one errors** in range boundaries and midpoint calculations — the single most common source of Segment Tree bugs.
- **Under-allocating the tree array** — always use the safe 4n convention unless you've proven a tighter bound is safe for your specific n.
- **Forgetting to recompute ancestors after an update** — or recomputing in the wrong order (must happen bottom-up, after children are already updated).
- **Reaching for a Segment Tree when a simpler Fenwick Tree (or even a plain prefix sum, if there are no updates) would suffice** — added complexity should be justified by an actual need for range updates or non-sum aggregates.

---

## 15. Summary

**Key takeaways:**
- A Segment Tree stores range aggregates hierarchically, enabling O(log n) range queries **and** updates simultaneously — a combination plain arrays and prefix sums cannot achieve together.
- The query algorithm's "stop at full containment, recurse only on partial overlap" logic is what bounds total work to O(log n).
- Lazy propagation extends the structure to efficient range (not just point) updates.
- It's flexible for any associative operation with an identity — sum, min, max, GCD, XOR, or custom combiners.

**Complexity recap:**

| Operation | Time | Space |
|---|---|---|
| Build | O(n) | O(n) |
| Range Query | O(log n) | O(log n) |
| Point Update | O(log n) | O(log n) |
| Range Update (lazy) | O(log n) | O(n) extra |

**Decision guideline:** Reach for a Segment Tree when you need both range queries and updates on an array, especially for non-sum aggregates (min, max, GCD) or when you anticipate needing range (not just point) updates via lazy propagation. If you only need prefix sums with point updates, the simpler and lighter-weight Fenwick Tree (next chapter) is usually the better choice.

---

*Next chapter: `15_fenwick_tree.md`*
