# Chapter 1: Arrays

*Study time: ~4-6 hours | Prerequisite: Big-O basics | Difficulty: Beginner*

---

## 1. Introduction

**Definition:** An array is a collection of elements of the same type, stored in **contiguous memory locations**, accessed by an integer index.

**Purpose:** To store multiple values under one variable name while allowing O(1) direct access to any element via its position.

**Real-world analogy:** Think of a row of numbered mailboxes on a street. If you know a box's number (index), you walk straight to it — you don't check every box before it. That's what makes array access O(1): the address of box `i` is simply `base_address + i * size_of_one_box`.

**Motivation:** Before arrays, programs stored related data in separate named variables (`score1`, `score2`, `score3`...). This doesn't scale — you can't loop over "score1 through score1000" without an indexable structure.

**History:** Arrays are as old as computing itself — they map directly onto how RAM is physically addressed (a flat sequence of byte addresses), making them the most "native" data structure a computer understands.

---

## 2. Why Do We Need It?

**Problem it solves:** Grouping related data and accessing any element in constant time without traversal.

**Why simpler alternatives fail:** Using individual variables means you can't parameterize access (`get element number i` becomes impossible without an if-else chain), and you can't easily pass "all the data" to a function.

**Trade-offs:**
- You gain O(1) random access and excellent cache locality (data sits next to each other in memory, which CPUs love).
- You pay for it with **expensive insertion/deletion in the middle** (everything after must shift) and, for static arrays, a **fixed size** decided upfront.

This trade-off — fast reads, slow structural changes — is the first and most important trade-off you'll see repeated (in different forms) throughout this entire guide.

---

## 3. Internal Working

A static array of 5 integers in memory looks like this:

```
Index:        0     1     2     3     4
            +-----+-----+-----+-----+-----+
Value:      | 10  | 22  | 5   | 47  | 8   |
            +-----+-----+-----+-----+-----+
Address:   1000  1004  1008  1012  1016     (assuming 4-byte ints)
```

**Address calculation** (why access is O(1)):
```
address(i) = base_address + i * element_size
address(3) = 1000 + 3 * 4 = 1012   → directly computed, no traversal needed
```

**Dynamic array (e.g., `std::vector`) growth**, which is what makes amortized O(1) append possible:

```
Capacity 4, size 4:  [A][B][C][D]           ← full, next push_back triggers growth

Step 1: Allocate new block of double capacity (8)
        [ ][ ][ ][ ][ ][ ][ ][ ]

Step 2: Copy old elements over
        [A][B][C][D][ ][ ][ ][ ]

Step 3: Free old block, insert new element
        [A][B][C][D][E][ ][ ][ ]   ← size 5, capacity 8
```

Because capacity doubles each time, the *total* copying cost across n insertions sums to O(n), which spread over n operations gives O(1) **amortized** per insertion — even though any single insertion that triggers a resize costs O(n).

---

## 4. Operations

**Insert**
- *At the end (dynamic array, capacity available):* Place at `size`, increment size. O(1).
- *At the end (capacity full):* Trigger resize (see above), then insert. O(n) worst case, O(1) amortized.
- *At index i:* Shift all elements from i to end one position right, then place. O(n).
- Edge case: inserting at index 0 is the worst case (shifts everything); inserting at `size` is the best case.

**Delete**
- *From the end:* Decrement size. O(1).
- *At index i:* Shift all elements after i one position left to close the gap. O(n).
- Edge case: deleting from an empty array must be guarded against (underflow).

**Update**
- `arr[i] = value` — direct address computation. O(1).

**Search**
- *Unsorted:* Linear scan, O(n).
- *Sorted:* Binary search, O(log n) — only possible because arrays support O(1) random access, which is what lets binary search jump to the middle instantly.

**Traverse**
- Visit each element once, O(n). Cache-friendly because of contiguous memory (sequential memory access is much faster than random access on real hardware due to CPU cache lines and prefetching).

**Peek**
- Look at first/last element without removing: O(1) if you track size.

---

## 5. Time & Space Complexity

| Operation | Time Complexity | Space Complexity |
|---|---|---|
| Access by index | O(1) | O(1) |
| Search (unsorted) | O(n) | O(1) |
| Search (sorted, binary search) | O(log n) | O(1) |
| Insert at end (dynamic array) | O(1) amortized | O(1) extra (occasionally O(n) during resize) |
| Insert at beginning/middle | O(n) | O(1) extra |
| Delete at end | O(1) | O(1) |
| Delete at beginning/middle | O(n) | O(1) extra |
| Overall storage | — | O(n) |

**Why these hold:**
- Access is O(1) because the address formula is a single multiplication + addition — no dependency on array size.
- Insert/delete at arbitrary position is O(n) because, on average, half the elements must shift to preserve contiguity — there is no way around this without abandoning the "contiguous memory" property (which is exactly what a Linked List does instead).
- Amortized O(1) append comes from the geometric doubling strategy: the sum of a geometric series (1+2+4+...+n) is O(n), spread across n insertions = O(1) each on average.

---

## 6. Advantages

- O(1) random access by index.
- Excellent cache locality → fast in practice, not just in theory.
- Simple, low memory overhead (no pointers needed per element).
- Predictable memory layout, easy to reason about and debug.

---

## 7. Disadvantages

- Fixed size for static arrays (must know size upfront, or pay for resizing).
- Expensive insert/delete in the middle or at the front — O(n).
- Wasted space if over-allocated, or costly reallocation if under-allocated.
- Not ideal when the structure changes shape frequently.

---

## 8. Real-World Applications

- **Operating Systems:** Process tables, page tables — indexed lookup of fixed-size records.
- **Databases:** Columnar storage engines use arrays for contiguous column data (cache-friendly scans).
- **Browsers:** The DOM's `NodeList`, image pixel buffers (a 2D array of pixel values).
- **Search Engines:** Inverted index postings lists are often stored as sorted arrays for fast intersection.
- **Game Development:** Grids/tilemaps, entity component arrays (Data-Oriented Design relies heavily on arrays for cache performance).
- **Networking:** Packet buffers are fixed-size byte arrays.
- **Compilers:** Symbol tables and instruction arrays (bytecode arrays in VMs).
- **AI/ML:** Tensors (the core data structure of ML frameworks like NumPy/PyTorch) are fundamentally multi-dimensional arrays optimized for contiguous, vectorized access.

Arrays show up everywhere real performance matters, because CPUs are physically optimized for sequential memory access.

---

## 9. Implementation (C++17)

```cpp
#include <iostream>
#include <stdexcept>
#include <algorithm>

// A minimal dynamic array implementation, similar in spirit to std::vector.
// Demonstrates manual memory management, resizing, and amortized O(1) append.
class DynamicArray {
private:
    int* data;          // pointer to heap-allocated block
    size_t sz;          // current number of elements
    size_t cap;         // current allocated capacity

    // Doubles capacity and copies existing elements into the new block.
    void resize(size_t newCapacity) {
        int* newData = new int[newCapacity];
        for (size_t i = 0; i < sz; ++i) {
            newData[i] = data[i];   // copy old elements
        }
        delete[] data;               // free old memory
        data = newData;
        cap = newCapacity;
    }

public:
    // Constructor: start with small capacity to demonstrate growth behavior.
    DynamicArray() : data(new int[1]), sz(0), cap(1) {}

    // Destructor: release heap memory to avoid leaks.
    ~DynamicArray() {
        delete[] data;
    }

    // Insert at the end. Amortized O(1).
    void push_back(int value) {
        if (sz == cap) {
            resize(cap * 2);   // double capacity when full
        }
        data[sz] = value;
        sz++;
    }

    // Remove last element. O(1).
    void pop_back() {
        if (sz == 0) throw std::underflow_error("pop_back on empty array");
        sz--;
    }

    // Insert at arbitrary index. O(n) due to shifting.
    void insert_at(size_t index, int value) {
        if (index > sz) throw std::out_of_range("insert index out of range");
        if (sz == cap) resize(cap * 2);
        for (size_t i = sz; i > index; --i) {
            data[i] = data[i - 1];   // shift elements right
        }
        data[index] = value;
        sz++;
    }

    // Delete at arbitrary index. O(n) due to shifting.
    void delete_at(size_t index) {
        if (index >= sz) throw std::out_of_range("delete index out of range");
        for (size_t i = index; i < sz - 1; ++i) {
            data[i] = data[i + 1];   // shift elements left
        }
        sz--;
    }

    // Access by index. O(1). Bounds-checked for safety.
    int& operator[](size_t index) {
        if (index >= sz) throw std::out_of_range("index out of range");
        return data[index];
    }

    // Linear search. O(n).
    int find(int value) const {
        for (size_t i = 0; i < sz; ++i) {
            if (data[i] == value) return static_cast<int>(i);
        }
        return -1;   // not found
    }

    size_t size() const { return sz; }
    size_t capacity() const { return cap; }
    bool empty() const { return sz == 0; }

    void print() const {
        std::cout << "[ ";
        for (size_t i = 0; i < sz; ++i) std::cout << data[i] << " ";
        std::cout << "] (size=" << sz << ", capacity=" << cap << ")\n";
    }
};

// Example usage
int main() {
    DynamicArray arr;
    arr.push_back(10);
    arr.push_back(20);
    arr.push_back(30);
    arr.print();                 // [ 10 20 30 ] (size=3, capacity=4)

    arr.insert_at(1, 15);
    arr.print();                 // [ 10 15 20 30 ] (size=4, capacity=4)

    arr.delete_at(2);
    arr.print();                 // [ 10 15 30 ] (size=3, capacity=4)

    std::cout << "Index of 30: " << arr.find(30) << "\n";  // 2
    return 0;
}
```

---

## 10. Code Walkthrough

- **`data` (int\*):** A raw pointer to a contiguous heap block. This is the actual "array" — everything else is bookkeeping around it.
- **`sz` vs `cap`:** `sz` is how many slots are *used*; `cap` is how many slots *exist*. This distinction is what makes amortized growth possible — we over-allocate so future pushes don't always need a new allocation.
- **`resize()`:** Allocates a new, larger block, copies every element over (O(n)), then frees the old block. This is the expensive operation that happens rarely (only when `sz == cap`), which is why its cost "amortizes away" across many cheap O(1) pushes.
- **`push_back`:** Checks capacity first. This ordering (check-then-write) is a common pattern — always validate before mutating.
- **`insert_at` / `delete_at`:** The shifting loops are the heart of why these are O(n). Note the direction of shifting: insert shifts *right-to-left* (to avoid overwriting data you still need to move), delete shifts *left-to-right*. Getting this direction backwards is a classic bug that silently corrupts data.
- **`operator[]` with bounds checking:** Real `std::vector::operator[]` does *not* bounds-check (for performance) — that's what `.at()` is for. Here we bounds-check for teaching safety.
- **Destructor:** Without `delete[] data`, every `DynamicArray` would leak its heap block — a classic C++ memory-management mistake covered in section 14.

**Common mistakes to watch for here:**
- Off-by-one errors in loop bounds (`i <= sz` instead of `i < sz`).
- Forgetting to check `sz == cap` before writing, causing a buffer overflow.
- Shifting in the wrong direction during insert/delete, corrupting adjacent data.

---

## 11. Dry Run

**Input:** `push_back(10)`, `push_back(20)`, `push_back(30)`, `insert_at(1, 15)`, `delete_at(2)`

| Step | Operation | State (cap in parens) | Notes |
|---|---|---|---|
| 0 | init | `[]` (cap 1) | sz=0 |
| 1 | push_back(10) | `[10]` (cap 1) | sz=1, fits exactly |
| 2 | push_back(20) | sz==cap(1) → resize to 2 → `[10,20]` (cap 2) | resize triggered |
| 3 | push_back(30) | sz==cap(2) → resize to 4 → `[10,20,30]` (cap 4) | resize triggered |
| 4 | insert_at(1,15) | shift index 2→3 (30), index1→2(20); place 15 at index1 → `[10,15,20,30]` (cap 4) | sz=4, cap full but exactly fits |
| 5 | delete_at(2) | shift index3→2(30) left → `[10,15,30]` (cap 4, sz=3) | element "20" overwritten and logically removed |

Final array: `[10, 15, 30]`, size 3, capacity 4.

---

## 12. Interview Questions

**Conceptual:**
1. Why is array access O(1) but linked list access O(n)?
2. Explain amortized time complexity using dynamic array `push_back` as an example.
3. Why does `std::vector` typically grow by doubling rather than adding a fixed amount each time?
4. What's the difference between a static array and a dynamic array?
5. Why is inserting at the front of an array worse than inserting at the back?

**Coding:**
1. Reverse an array in-place.
2. Find the maximum subarray sum (Kadane's Algorithm).
3. Rotate an array by k positions in-place.
4. Find the missing number in an array of 1..n.
5. Merge two sorted arrays in-place.
6. Move all zeros to the end while maintaining relative order.
7. Find the two numbers that sum to a target (Two Sum).

**Follow-ups / interviewer traps:**
- "Can you do it without extra space?" (tests in-place manipulation skill)
- "What if the array is sorted — can you do better than O(n)?" (tests binary search intuition)
- "What if there are duplicates?" (tests edge-case handling)
- After Two Sum: "What if the array is sorted?" → expects two-pointer O(n) instead of hash map O(n) with O(n) space.

---

## 13. Practice Problems

**Easy**
- Two Sum (LeetCode 1)
- Remove Duplicates from Sorted Array (LeetCode 26)
- Best Time to Buy and Sell Stock (LeetCode 121)
- Move Zeroes (LeetCode 283)

**Medium**
- Rotate Array (LeetCode 189)
- Product of Array Except Self (LeetCode 238)
- 3Sum (LeetCode 15)
- Kadane's Algorithm — Maximum Subarray (LeetCode 53)
- Next Permutation (LeetCode 31)

**Hard**
- Trapping Rain Water (LeetCode 42)
- First Missing Positive (LeetCode 41)
- Median of Two Sorted Arrays (LeetCode 4)

Also recommended: HackerRank "Arrays" track, Codeforces problems tagged `implementation` + `arrays` (start around 800-1200 rating), GeeksforGeeks "Array Data Structure" practice set.

---

## 14. Common Mistakes

- **Off-by-one errors:** using `<=` instead of `<` in loop bounds, or vice versa.
- **Not checking capacity before writing**, causing buffer overflows in manual implementations.
- **Forgetting to free heap memory** (memory leaks) or double-freeing (undefined behavior).
- **Assuming O(1) insert everywhere** — many beginners forget that inserting anywhere but the end is O(n).
- **Confusing size and capacity** in dynamic arrays, leading to reading garbage/uninitialized memory.
- **Shifting in the wrong direction** during insert/delete operations, silently corrupting data.
- **Ignoring cache effects** — assuming a linked list with the "same Big-O" will perform the same as an array in practice; contiguous memory is often 2-10x faster in real benchmarks due to CPU cache behavior.

---

## 15. Summary

**Key takeaways:**
- Arrays trade *flexibility* for *speed*: O(1) access, but O(n) structural changes.
- Dynamic arrays achieve amortized O(1) append via geometric (doubling) growth.
- Arrays are the foundation for almost every other data structure covered in this guide (heaps, hash tables, and even trees are often array-backed under the hood).

**Complexity recap:**

| Access | Search | Insert (end) | Insert (middle) | Delete (end) | Delete (middle) |
|---|---|---|---|---|---|
| O(1) | O(n) / O(log n) sorted | O(1) amortized | O(n) | O(1) | O(n) |

**Decision guideline:** Reach for an array (or dynamic array/vector) when you need fast random access and your insertions/deletions are mostly at the end. Reach for something else (Linked List, Deque) when you need frequent insert/delete at arbitrary positions.

---

*Next chapter: `02_strings.md` (String — arrays of characters plus pattern-matching algorithms) or `03_linked_lists.md`, whichever you'd like built next.*
