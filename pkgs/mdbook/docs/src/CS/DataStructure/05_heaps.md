# Chapter 4: Heaps (Max-Heap & Min-Heap)

*Study time: ~6-8 hours | Prerequisite: Arrays, Binary Trees (conceptually), Recursion | Difficulty: Intermediate*

---

## 1. Introduction

**Definition:** A heap is a specialized tree-based structure that satisfies the **heap property**:
- **Max-Heap:** every parent node's value ≥ its children's values (the maximum is always at the root).
- **Min-Heap:** every parent node's value ≤ its children's values (the minimum is always at the root).

A heap is also a **complete binary tree** — every level is fully filled except possibly the last, which fills left to right with no gaps. This completeness is *why* a heap can be stored efficiently in a plain array with no pointers at all.

**Purpose:** To provide O(1) access to the current minimum (or maximum) element, with O(log n) insertion and removal — dramatically better than the O(n) it would take to find the min/max in an unsorted array, or the O(n) it costs to insert into a fully sorted array.

**Real-world analogy:** A hospital emergency room triage queue. It's not FIFO (first come, first served) — the *most critical* patient is always seen next, regardless of arrival order. New patients can arrive and jump ahead of less critical ones already waiting, but only the very top of the priority list is ever pulled.

**Motivation:** Many problems need repeated access to "the current best/worst item so far" while the set of items keeps changing (dynamic scheduling, streaming top-k, graph algorithms). Sorting the whole set every time is wasteful; a heap keeps just enough order to answer "what's the min/max right now?" instantly while staying cheap to update.

**History:** Invented by J.W.J. Williams in 1964 as part of introducing Heapsort — the heap was originally a *sorting* tool before becoming a standalone data structure (the Priority Queue).

---

## 2. Why Do We Need It?

**Problem it solves:** "Give me the current smallest/largest element, quickly, over and over, even as elements are added and removed" — this is the **priority queue** problem.

**Why previous structures are insufficient:**
- **Unsorted array:** finding min/max is O(n) every time.
- **Sorted array:** finding min/max is O(1), but inserting a new element to keep it sorted is O(n) (must shift to the correct position).
- **BST:** can find min/max in O(log n) (leftmost/rightmost node) and insert in O(log n) — better, but a heap does the *same* job with a simpler, more memory-efficient array-backed structure, because it doesn't need to maintain *full* sorted order — only the much weaker "parent beats children" property.

**Trade-offs:**
- You gain O(1) peek at the min/max and O(log n) insert/remove, using a compact array with zero pointer overhead.
- You lose the ability to efficiently find or access any *other* element — a heap only "knows" where its min/max is; finding the 2nd-smallest, for instance, is not O(1) or even straightforward.

---

## 3. Internal Working

**Array representation of a complete binary tree.** For a node at array index `i` (0-indexed):

```
left child  = 2*i + 1
right child = 2*i + 2
parent      = (i - 1) / 2   (integer division)
```

**Example Min-Heap**, tree view and array view side by side:

```
Tree:                      Array index:  0   1   2   3   4   5
        3                                [3,  8,  5, 12, 15,  9]
      /   \
     8     5
    / \   /
   12 15 9
```

Check the property: parent(3) ≤ children(8,5) ✓; parent(8) ≤ children(12,15) ✓; parent(5) ≤ children(9) ✓. No sibling-to-sibling relationship is guaranteed (8 and 5 aren't compared to each other) — this is what makes a heap "weaker" than a fully sorted structure, and exactly why it's cheaper to maintain.

**Insertion — "bubble up" / "sift up":** Insert 2:

```
Step 1: Append at the end (last array slot):
[3, 8, 5, 12, 15, 9, 2]
                    ▲ new node, index 6, parent index (6-1)/2 = 2 → value 5

Step 2: Compare with parent (5). 2 < 5, so swap.
[3, 8, 2, 12, 15, 9, 5]
              ▲ now at index 2, parent index (2-1)/2 = 0 → value 3

Step 3: Compare with parent (3). 2 < 3, so swap.
[2, 8, 3, 12, 15, 9, 5]
 ▲ now at root — no parent, stop.
```

**Deletion of the root — "bubble down" / "sift down":** Remove min (2) from `[2, 8, 3, 12, 15, 9, 5]`:

```
Step 1: Move the LAST element to the root, shrink the array:
[5, 8, 3, 12, 15, 9]

Step 2: Compare root (5) with children (8, 3). Swap with the SMALLER child if it violates heap property.
5 vs min(8,3)=3 → swap:
[3, 8, 5, 12, 15, 9]

Step 3: Continue sifting down from new position (index 2, value 5). Children of index 2: index 5 → value 9. 5 < 9, property holds. Stop.
Final: [3, 8, 5, 12, 15, 9]
```

---

## 4. Operations

**Insert (push):**
- Append the new element at the end of the array (next open leaf position).
- **Sift up:** repeatedly compare with parent; swap if the heap property is violated; stop when it holds or the root is reached.
- Edge case: inserting into an empty heap — the new element simply becomes the root, no sifting needed.

**Delete (extract-min / extract-max):**
- Save the root value (this is the return value).
- Move the *last* element in the array to the root position, shrink the array by one.
- **Sift down:** repeatedly compare the node with its children; swap with the smaller (min-heap) or larger (max-heap) child if the property is violated; stop when it holds or a leaf is reached.
- Edge case: deleting from a heap with one element — just remove it, no sifting needed. Deleting from an empty heap should throw/guard.

**Update (increase/decrease key):**
- Change the value at a given index, then sift **up** (if the change could violate the parent relationship) or **down** (if it could violate the child relationship) as appropriate. Used heavily in graph algorithms like Dijkstra's.

**Search:**
- Not efficiently supported — O(n) linear scan, since the heap property gives no information about *where* an arbitrary value might be.

**Traverse:**
- Level-order (array order) is trivial — just iterate the array. In-order/sorted traversal is *not* naturally supported (that's what BSTs are for).

**Peek (find-min / find-max):**
- Return `array[0]`. O(1) — this is the entire point of a heap.

**Build-heap (from an unsorted array):**
- Naively: insert each element one by one, O(n log n) total.
- Optimally: **Heapify** from the bottom up, starting at the last non-leaf node and sifting down each — this achieves O(n), not O(n log n) (explained in section 5).

---

## 5. Time & Space Complexity

| Operation | Time Complexity | Space Complexity |
|---|---|---|
| Peek (find min/max) | O(1) | O(1) |
| Insert | O(log n) | O(1) |
| Delete (extract min/max) | O(log n) | O(1) |
| Search (arbitrary value) | O(n) | O(1) |
| Build heap from unsorted array | O(n) | O(1) extra (in-place) |
| Heapsort (repeated extraction) | O(n log n) | O(1) extra (in-place) |

**Why these hold:**
- Insert/Delete are O(log n) because a complete binary tree with n nodes has height ⌊log₂ n⌋ — sifting up or down traverses at most that many levels, one comparison-and-swap per level.
- Peek is O(1) because the heap property *guarantees* the min/max is always physically at index 0 — no search needed, by construction.
- **Build-heap is O(n), not O(n log n)** — this surprises most learners. The naive intuition ("n inserts × O(log n) each = O(n log n)") is *not* how `build-heap` (heapify from the bottom) works. Heapify processes nodes bottom-up, and most nodes are near the bottom where sift-down has very little distance to travel; only a few nodes near the root have far to sift. Summing this "distance × count-of-nodes-at-that-distance" across all levels forms a series that converges to O(n) — a classic (and famous) amortized-analysis result.

---

## 6. Advantages

- O(1) access to current min/max — ideal for "always process the most urgent item" workloads.
- O(log n) insert/delete — much better than maintaining a fully sorted structure.
- Compact array-backed storage — no pointer overhead, excellent cache locality compared to pointer-based trees.
- O(n) construction from an existing array via heapify.

## 7. Disadvantages

- No efficient search for arbitrary elements — O(n).
- No efficient traversal in sorted order (unlike a BST's in-order traversal).
- Only the min *or* max is efficiently accessible — a plain heap can't answer "give me the min AND max quickly" without extra structure (e.g., a min-max heap or two heaps).
- Not stable for equal-priority elements unless explicitly engineered (insertion order among ties isn't preserved by default).

---

## 8. Real-World Applications

- **Operating Systems:** CPU process scheduling by priority (higher-priority processes run first).
- **Networking:** Bandwidth management / QoS — prioritizing certain packet types.
- **Graph Algorithms:** Dijkstra's shortest path and Prim's MST both use a Min-Heap to always expand the "closest" unvisited node next.
- **Databases:** Top-K query optimization (e.g., "top 10 highest-paid employees") — keeping a heap of size K avoids sorting the entire dataset.
- **Game Development:** Event scheduling systems (process the next game event by timestamp).
- **AI/ML:** Beam search in NLP models often uses a heap to track the top-k most probable sequences.
- **Cloud Systems / Task Queues:** Job schedulers (e.g., prioritizing urgent background jobs).
- **Compilers:** Huffman coding (data compression) builds its tree using a Min-Heap.

Heaps are chosen anywhere "always grab the current best/worst" needs to happen repeatedly and efficiently, especially when the underlying data keeps changing.

---

## 9. Implementation (C++17)

```cpp
#include <iostream>
#include <vector>
#include <stdexcept>
#include <algorithm>

// A Min-Heap implementation using std::vector as the backing array.
// (Flip every comparison to build a Max-Heap — see note after the class.)
class MinHeap {
private:
    std::vector<int> heap;

    size_t parent(size_t i) const { return (i - 1) / 2; }
    size_t leftChild(size_t i) const { return 2 * i + 1; }
    size_t rightChild(size_t i) const { return 2 * i + 2; }

    // Sift the element at index i UP toward the root until the heap property holds.
    void siftUp(size_t i) {
        while (i > 0 && heap[i] < heap[parent(i)]) {
            std::swap(heap[i], heap[parent(i)]);
            i = parent(i);
        }
    }

    // Sift the element at index i DOWN toward the leaves until the heap property holds.
    void siftDown(size_t i) {
        size_t n = heap.size();
        while (true) {
            size_t smallest = i;
            size_t l = leftChild(i), r = rightChild(i);

            if (l < n && heap[l] < heap[smallest]) smallest = l;
            if (r < n && heap[r] < heap[smallest]) smallest = r;

            if (smallest == i) break;   // heap property restored, stop

            std::swap(heap[i], heap[smallest]);
            i = smallest;
        }
    }

public:
    // Insert. O(log n): append then sift up.
    void push(int value) {
        heap.push_back(value);
        siftUp(heap.size() - 1);
    }

    // Extract and return the minimum. O(log n).
    int pop() {
        if (heap.empty()) throw std::underflow_error("pop on empty heap");
        int minValue = heap[0];
        heap[0] = heap.back();   // move last element to root
        heap.pop_back();
        if (!heap.empty()) siftDown(0);
        return minValue;
    }

    // Peek at the minimum without removing. O(1).
    int top() const {
        if (heap.empty()) throw std::underflow_error("top on empty heap");
        return heap[0];
    }

    // Build a heap from an existing unsorted array in O(n) — NOT O(n log n).
    // Key insight: start from the last non-leaf node and sift down, bottom-up.
    void buildHeap(std::vector<int> arr) {
        heap = std::move(arr);
        int n = static_cast<int>(heap.size());
        for (int i = n / 2 - 1; i >= 0; --i) {   // last non-leaf index = n/2 - 1
            siftDown(static_cast<size_t>(i));
        }
    }

    bool empty() const { return heap.empty(); }
    size_t size() const { return heap.size(); }

    void print() const {
        std::cout << "[ ";
        for (int v : heap) std::cout << v << " ";
        std::cout << "]\n";
    }
};

// Example usage
int main() {
    MinHeap h;
    h.push(5);
    h.push(3);
    h.push(8);
    h.push(1);
    h.push(9);
    h.print();                          // array-order snapshot, e.g. [1 3 8 5 9]

    std::cout << "Min: " << h.top() << "\n";   // 1

    std::cout << "Extracting all in sorted order: ";
    while (!h.empty()) {
        std::cout << h.pop() << " ";           // 1 3 5 8 9  — this IS heapsort
    }
    std::cout << "\n";

    // Demonstrate O(n) buildHeap
    MinHeap h2;
    h2.buildHeap({9, 4, 7, 1, 3, 8, 2});
    h2.print();
    return 0;
}

/*
 * TO BUILD A MAX-HEAP: flip every "<" to ">" in siftUp and siftDown
 * (i.e., "heap[i] < heap[parent(i)]" becomes "heap[i] > heap[parent(i)]", and
 * siftDown picks the LARGEST child instead of the smallest). Everything else —
 * the index math, the array backing, the O(log n)/O(n) complexities — is identical.
 * In production C++, prefer std::priority_queue<int> for Max-Heap (default) or
 * std::priority_queue<int, std::vector<int>, std::greater<int>> for Min-Heap.
 */
```

---

## 10. Code Walkthrough

- **`parent`/`leftChild`/`rightChild` index formulas:** These three lines of arithmetic are the *entire* reason a heap needs no pointers — the complete-binary-tree shape guarantees these formulas always point to valid relationships, given 0-indexed array storage.
- **`siftUp`:** Called after appending a new element at the end. The loop condition `heap[i] < heap[parent(i)]` is the heap-property check; as long as it's violated, we swap upward. The loop naturally terminates either at the root (`i == 0`) or the moment the property holds.
- **`siftDown`:** The trickiest part — note it computes `smallest` by comparing the current node against *both* children (not just one), because in a min-heap you must swap with whichever child is smaller to correctly restore the property; swapping with the wrong child can leave a smaller value stuck below a larger one.
- **`pop()`:** The "move last element to root, then sift down" pattern is the standard heap-deletion technique. It's O(log n) because only the sift-down step costs anything — moving the last element is O(1).
- **`buildHeap`:** Starting the loop at `n/2 - 1` (the last non-leaf node) and going *backward* to 0 is what makes this O(n) rather than O(n log n) — every leaf is already trivially a valid 1-node heap, so we only need to sift down internal nodes, and we must do so bottom-up so that by the time we sift down node `i`, its subtrees are already valid heaps.
- **Min vs Max flip:** The entire class is symmetric under swapping `<` for `>` — this symmetry is worth internalizing, since interviewers often ask you to convert one to the other on the spot.

**Common mistakes to watch for here:**
- Comparing only one child in `siftDown` instead of both, silently producing an invalid heap.
- Forgetting to check `heap.empty()` before sifting down after `pop()` (sifting down an empty heap is undefined/out-of-bounds).
- Using 1-indexed formulas (`2*i`, `2*i+1`) with a 0-indexed array, or vice versa — these two conventions use different child/parent formulas and mixing them is a very common bug.

---

## 11. Dry Run

**Input:** `push(5)`, `push(3)`, `push(8)`, `push(1)`, `push(9)` on a Min-Heap.

| Step | Action | Array after | Sift trace |
|---|---|---|---|
| 1 | push(5) | [5] | no parent, no sift |
| 2 | push(3) | [3,5] | 3 < parent(5) → swap → [3,5] |
| 3 | push(8) | [3,5,8] | 8 vs parent(3): 8 > 3, stop |
| 4 | push(1) | [3,5,8,1] | 1 at idx3, parent idx1(5): 1<5 swap → [3,1,8,5]; parent idx0(3): 1<3 swap → [1,3,8,5] |
| 5 | push(9) | [1,3,8,5,9] | 9 at idx4, parent idx1(3): 9>3, stop |

Final heap array: `[1, 3, 8, 5, 9]` — root is 1, the true minimum. ✓

**Now `pop()`:**
1. Save root = 1 (return value).
2. Move last element (9) to root: `[9, 3, 8, 5]`.
3. Sift down from index 0: children are idx1(3), idx2(8) → smallest child is 3 (idx1). 9 > 3 → swap → `[3, 9, 8, 5]`.
4. Continue from idx1: children are idx3(5) only (idx4 doesn't exist) → 5 < 9 → swap → `[3, 5, 8, 9]`.
5. Continue from idx3: no children, stop.

Result: heap becomes `[3, 5, 8, 9]`, returned value `1`. ✓ (3 is correctly the new minimum.)

---

## 12. Interview Questions

**Conceptual:**
1. Why is `build-heap` O(n) rather than O(n log n)? Walk through the proof intuition.
2. Why can't a heap efficiently support "search for an arbitrary value"?
3. Compare a heap to a BST for the priority-queue use case — why is a heap usually preferred?
4. Explain the difference between a Min-Heap and a Max-Heap, and how to convert between them.
5. Why does a heap need to be a *complete* binary tree specifically (not just "balanced")?

**Coding:**
1. Implement Heapsort.
2. Find the Kth largest element in an array (using a Min-Heap of size K).
3. Merge K sorted lists using a Min-Heap.
4. Find the median of a data stream (two heaps — one max, one min).
5. Top K frequent elements.
6. Implement a Min Stack or a structure supporting O(1) min/max retrieval with a heap-backed approach.
7. Task Scheduler — schedule tasks with cooldowns using a Max-Heap.

**Follow-ups / interviewer traps:**
- "Can you find the Kth largest in better than O(n log n)?" (expects a heap of size K, giving O(n log K))
- "How do you maintain a running median in O(log n) per insertion?" (expects two heaps — a max-heap for the lower half, min-heap for the upper half, kept balanced in size)
- "What's the time complexity of `std::priority_queue`'s constructor when given n elements at once?" (tests whether they know it uses O(n) heapify internally, not repeated O(log n) inserts)

---

## 13. Practice Problems

**Easy**
- Last Stone Weight (LeetCode 1046)
- Kth Largest Element in a Stream (LeetCode 703)

**Medium**
- Kth Largest Element in an Array (LeetCode 215)
- Top K Frequent Elements (LeetCode 347)
- K Closest Points to Origin (LeetCode 973)
- Task Scheduler (LeetCode 621)
- Ugly Number II (LeetCode 264)

**Hard**
- Merge k Sorted Lists (LeetCode 23)
- Find Median from Data Stream (LeetCode 295)
- Sliding Window Median (LeetCode 480)
- IPO / Maximize Capital (LeetCode 502)

Also recommended: GeeksforGeeks "Heap" practice set, HackerRank "Heap, Priority Queue" track, Codeforces problems tagged `greedy` + `data structures` that reference "always pick the smallest/largest remaining."

---

## 14. Common Mistakes

- **Comparing only one child during sift-down** instead of both, silently breaking the heap property.
- **Mixing 0-indexed and 1-indexed parent/child formulas.**
- **Forgetting the empty-heap check** before `pop()` or `top()`.
- **Assuming a heap is fully sorted** — only the root is guaranteed to be the min/max; sibling order is unspecified (e.g., don't assume `heap[1] < heap[2]`).
- **Reinventing build-heap as repeated single inserts** when a true O(n) heapify is available and expected in interviews for "given an array, build a heap" questions.
- **Confusing a heap with a BST** — a heap gives no efficient in-order (sorted) traversal; that's a different structure with a different (stronger) invariant.
- **Not resetting/rebalancing the two-heap technique** for streaming median problems, letting one heap grow unboundedly larger than the other.

---

## 15. Summary

**Key takeaways:**
- A heap is a complete binary tree stored in a flat array — no pointers required, thanks to simple index arithmetic (`2i+1`, `2i+2`, `(i-1)/2`).
- It enforces a *weak* ordering (parent vs. children only) — just enough to guarantee O(1) access to the min/max, while staying cheaper to maintain than a fully sorted structure.
- `build-heap` is a famous O(n) result — don't default to "insert one at a time" (O(n log n)) when the whole array is available upfront.
- Min-Heap and Max-Heap are mirror images — the same code with comparisons flipped.

**Complexity recap:**

| Operation | Time | Space |
|---|---|---|
| Peek min/max | O(1) | O(1) |
| Insert | O(log n) | O(1) |
| Extract min/max | O(log n) | O(1) |
| Search arbitrary value | O(n) | O(1) |
| Build heap from array | O(n) | O(1) |

**Decision guideline:** Reach for a heap whenever you repeatedly need "the current best/worst item" from a changing collection — priority scheduling, graph shortest-path/MST algorithms, top-K problems, or streaming statistics like running median. If you need sorted *traversal* or search for arbitrary elements, use a BST instead; if you only ever need the single overall min/max once (no updates), a simple linear scan is simpler and just as fast.

---

*Next chapter: `05_hash_tables.md`, or say the word for Trie, BST/AVL, or Graphs instead.*
