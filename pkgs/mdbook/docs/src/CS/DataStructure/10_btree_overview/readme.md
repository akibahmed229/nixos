# Chapter 9: B-Tree (Overview)

*Study time: ~3-4 hours | Prerequisite: BST, AVL Tree | Difficulty: Intermediate*
*(Marked "Overview" in the roadmap — this chapter emphasizes conceptual understanding over from-scratch implementation, since B-Trees are rarely hand-rolled outside database/filesystem internals.)*

---

## 1. Introduction

**Definition:** A B-Tree is a self-balancing tree where each node can hold **multiple keys** (not just one, unlike a BST) and have **multiple children** (not just two). Keys within a node are kept sorted, and all leaves sit at the same depth.

**Purpose:** To minimize the number of **disk reads** needed to find data, by packing many keys into each node so the tree stays extremely short (shallow) even for enormous datasets.

**Real-world analogy:** A B-Tree node is like a single page in a massive multi-volume encyclopedia index — instead of one entry per page (like a BST node holding one key), each page lists dozens of entries with pointers to which volume/page to check next. You flip far fewer pages to find anything.

**Motivation:** An AVL or Red-Black Tree is optimized assuming memory access is roughly uniform in cost (RAM). But **disk access is dramatically slower than RAM access** — and each disk read typically pulls a whole fixed-size block regardless of how much you actually need. A B-Tree node is designed to exactly fill one disk block, so each disk read retrieves the maximum useful number of keys, minimizing the total number of (slow) disk reads for a search.

**History:** Introduced by Rudolf Bayer and Ed McCreight in 1972 at Boeing Research Labs, specifically to optimize large database and filesystem index structures.

---

## 2. Why Do We Need It?

**Problem it solves:** Efficient search/insert/delete on datasets too large to fit in memory, where the dominant cost is the *number of disk block reads*, not raw comparison count.

**Why AVL/Red-Black Trees are insufficient here:** A binary tree with n keys has height ≈ log₂(n) — for a billion keys, that's ~30 levels, meaning up to 30 separate disk reads (each disk read can be milliseconds — extremely slow compared to RAM). A B-Tree with, say, 100 keys per node has height ≈ log₁₀₀(n) — for the same billion keys, only ~5 levels, meaning as few as 5 disk reads.

**Trade-offs:**
- You gain drastically fewer disk reads for large, disk-resident datasets — the *actual* bottleneck in real database/filesystem performance.
- You pay for it with more complex node-splitting/merging logic, and more wasted comparisons *within* a node (though these happen in fast RAM/cache, not on slow disk, so they're relatively cheap).

---

## 3. Internal Working

**A B-Tree of order (max children) 4** — meaning each node holds up to 3 keys and 4 children:

```
                    [ 30 | 60 ]
                   /      |      \
          [10|20]     [40|50]    [70|80|90]
```

Searching for 45: compare against root keys (30, 60) → 45 is between 30 and 60 → follow the middle child pointer → land on `[40|50]` → compare → 45 is between 40 and 50 → but this is a leaf with no more children, and 45 isn't among {40,50} → not found (in a real B-Tree, this leaf might actually contain 45 depending on order; the point is each node comparison narrows the search across *multiple* keys per step, not just one).

**Node splitting (insertion overflow):** When a node would exceed its maximum key count, it **splits** into two nodes, and its middle key moves **up** to the parent:

```
Before (node full with 5 keys, max allowed is 3, inserting a 6th triggers split):
[10|20|30|40|50]  ← overflow

Split into two nodes, middle key (30) promoted to parent:
        [30]
       /    \
   [10|20] [40|50]
```

This splitting can cascade upward if the parent also overflows — in the worst case, all the way to the root, which is the *only* way a B-Tree's height ever increases (uniformly across the whole tree, keeping it always perfectly balanced across all leaves).

**Node merging (deletion underflow):** When a node drops below its minimum key count after a deletion, it either **borrows** a key from a sibling (via the parent) or **merges** with a sibling — the mirror-image operation of splitting.

---

## 4. Operations

**Search:**
- Within a node, scan (or binary-search) its sorted keys to find the right child pointer to follow, or find the key itself.
- Recurse into the appropriate child until found or a leaf is exhausted without a match.

**Insert:**
- Find the correct leaf for the new key (same downward walk as search).
- Insert into the leaf's sorted key list.
- If the leaf now exceeds its maximum key count, **split** it and promote the middle key to the parent — this may cascade upward.

**Delete:**
- Find the key (possibly in an internal node, not just a leaf — B-Trees allow keys at any level).
- If deleting from an internal node, replace it with a predecessor/successor key from a leaf (similar in spirit to BST deletion's in-order successor), then delete that leaf key.
- If a node drops below the minimum key count, borrow from a sibling or merge — this may cascade upward.

**Traverse:**
- In-order-style traversal (recursively visiting all children between consecutive keys) yields sorted output, just like a BST.

---

## 5. Time & Space Complexity

| Operation | Time Complexity | Notes |
|---|---|---|
| Search | O(log_m n) | m = max children per node (order); far fewer *levels* than a binary tree for large m |
| Insert | O(log_m n) | May trigger O(log_m n) splits cascading upward, each O(m) to redistribute keys |
| Delete | O(log_m n) | May trigger O(log_m n) merges/borrows cascading upward |
| Space | O(n) | Similar asymptotic space to any balanced tree; practical overhead is lower per key due to fewer pointers per key |

**Why these hold:**
- The height of a B-Tree with n keys and minimum degree (branching factor) m is O(log_m n) — and since m is typically large (tuned to match a disk block size, often in the hundreds), log_m n is dramatically smaller than log₂ n for the same n. This is the entire point: **fewer levels = fewer disk reads**, even though the total asymptotic key-comparison work is similar.
- Within a single node, comparing against up to m-1 keys is technically O(m) (or O(log m) with binary search inside the node) — but since this happens in fast memory/cache after one disk read has already brought the whole node in, it's essentially "free" compared to the disk read itself.

---

## 6. Advantages

- Dramatically fewer disk/block reads for large, disk-resident datasets — the primary reason B-Trees dominate database and filesystem index design.
- Always perfectly height-balanced (every leaf at the same depth), unlike AVL (balanced within a factor) — height only changes uniformly via root splits.
- Efficient range queries (like a BST, in-order traversal gives sorted output) at scale.

## 7. Disadvantages

- More complex to implement than a BST/AVL — splitting/merging logic has several edge cases.
- Higher constant-factor overhead in RAM-only scenarios where disk I/O isn't the bottleneck — an AVL/Red-Black tree can be simpler and just as fast when everything already fits in memory.
- Choosing the right "order" (branching factor) requires tuning to the underlying storage medium's block size for maximum benefit.

---

## 8. Real-World Applications

- **Databases:** Nearly every relational database (MySQL's InnoDB, PostgreSQL, Oracle, SQL Server) uses B-Trees (or the closely related B+Tree) as its primary index structure.
- **File Systems:** NTFS, ext4, HFS+, and many modern filesystems use B-Trees (or B+Trees) to index files/directories for fast lookup.
- **Key-Value Stores:** Many embedded databases (e.g., LMDB, older versions of many storage engines) use B-Trees for on-disk storage layout.
- **Operating Systems:** Some kernel data structures indexing large on-disk metadata use B-Tree variants (e.g., Btrfs — literally named for B-Tree).

The unifying theme: **any time the dataset lives primarily on disk (or any slow storage medium) rather than fully in RAM**, a B-Tree (or B+Tree) is the default professional choice.

---

## 9. Implementation Note

Because B-Trees are almost never hand-implemented outside of database/filesystem internals (production code uses battle-tested library or kernel implementations), this "Overview" chapter intentionally skips a full from-scratch C++ implementation in favor of a clear conceptual walkthrough. If you want hands-on practice, the highest-value exercise is implementing **insertion with node splitting** for a small fixed order (e.g., order 4) — that single mechanic (split + promote middle key) is 80% of what makes a B-Tree tick, and is a common systems-interview whiteboard exercise. A skeleton to build from:

```cpp
#include <vector>
#include <algorithm>

// Skeleton only — a full production B-Tree also needs deletion (borrow/merge),
// which is intentionally omitted here since it's rarely asked for in whiteboard form.
class BTreeNode {
public:
    std::vector<int> keys;
    std::vector<BTreeNode*> children;   // children.size() == keys.size() + 1 when internal
    bool isLeaf;
    int maxKeys;   // order - 1

    BTreeNode(int maxKeys, bool leaf) : isLeaf(leaf), maxKeys(maxKeys) {}

    // Insert into THIS node's key list assuming it's not yet full (caller's responsibility
    // to have already split if needed before calling this).
    void insertNonFull(int key) {
        if (isLeaf) {
            auto pos = std::upper_bound(keys.begin(), keys.end(), key);
            keys.insert(pos, key);
        } else {
            // Find the child to descend into, splitting it first if it's already full.
            size_t idx = std::upper_bound(keys.begin(), keys.end(), key) - keys.begin();
            if (children[idx]->keys.size() == static_cast<size_t>(maxKeys)) {
                splitChild(idx);
                if (key > keys[idx]) idx++;   // key may now belong to the newly split-off node
            }
            children[idx]->insertNonFull(key);
        }
    }

    // Split a full child at index `idx`, promoting its middle key up into THIS node.
    void splitChild(size_t idx) {
        BTreeNode* fullChild = children[idx];
        int mid = fullChild->keys.size() / 2;
        int midKey = fullChild->keys[mid];

        BTreeNode* newRight = new BTreeNode(maxKeys, fullChild->isLeaf);
        newRight->keys.assign(fullChild->keys.begin() + mid + 1, fullChild->keys.end());
        fullChild->keys.resize(mid);   // left half keeps [0, mid)

        if (!fullChild->isLeaf) {
            newRight->children.assign(fullChild->children.begin() + mid + 1, fullChild->children.end());
            fullChild->children.resize(mid + 1);
        }

        keys.insert(keys.begin() + idx, midKey);           // promote middle key up
        children.insert(children.begin() + idx + 1, newRight);
    }
};
```

This shows the core mechanic — `splitChild` — without the full class wrapper (root management, search, deletion) that a production implementation would need.

---

## 10. Code Walkthrough (of the Skeleton)

- **`insertNonFull`:** Assumes the node it's called on is not already full — this precondition is why `splitChild` is always called *before* recursing into a full child, never after. This "split-before-descending" strategy is what avoids ever having to propagate a split back up after the fact.
- **`splitChild`:** The middle key (`midKey`) is removed from the full child and promoted into the parent's key list; the child's remaining keys are divided into two halves, becoming two separate children. This is the exact mirror of the ASCII diagram in section 3.
- **Why split preemptively:** By ensuring a node is never full *before* you insert into it (splitting proactively on the way down), the recursion never needs a second pass back up to handle overflow — a cleaner alternative to some textbook presentations that split after-the-fact.

---

## 11. Dry Run (Conceptual)

Given a B-Tree of order 4 (max 3 keys per node), inserting 10, 20, 30, 40, 50 in order:

| Insert | Result |
|---|---|
| 10, 20, 30 | Single node `[10,20,30]` — fits within max 3 keys |
| 40 | Node would become `[10,20,30,40]` — overflow! Split: middle key (30, using mid=len/2=2, keys[2]=30) promotes to a new root. Result: root `[30]`, left child `[10,20]`, right child `[40]` |
| 50 | 50 > 30, descend right to `[40]`. Insert: `[40,50]` — fits, no split needed |

Final structure: root `[30]`, left `[10,20]`, right `[40,50]` — tree height stayed at 2 despite 5 insertions, and would stay very shallow even for millions of keys with a realistically large order (e.g., order 100+).

---

## 12. Interview Questions

**Conceptual:**
1. Why do databases use B-Trees instead of AVL/Red-Black Trees for disk-based indexes?
2. Explain what happens when a B-Tree node overflows during insertion.
3. What's the difference between a B-Tree and a B+Tree? (B+Tree stores all actual data only in leaves, with internal nodes purely for navigation, and leaves are often linked for fast sequential range scans.)
4. Why does a B-Tree's height only ever grow uniformly (via root splits), unlike an unbalanced BST?
5. How does the choice of "order" relate to the underlying disk block size?

**Coding:**
1. Implement B-Tree insertion with node splitting (as in the skeleton above).
2. Implement B-Tree search.
3. (Advanced) Implement B-Tree deletion with borrow/merge.

**Follow-ups / interviewer traps:**
- "Why not just use a hash table for a database index?" (tests understanding that B-Trees support range queries/sorted iteration, which hash indexes cannot)
- "What's stored in the leaves of a B+Tree vs. a plain B-Tree?" (tests B+Tree vs B-Tree distinction — a very common systems-design follow-up)

---

## 13. Practice Problems

B-Trees are rarely LeetCode-style coding problems (they're more of a systems/database-design topic), but related concepts appear in:
- Design a simple in-memory database index (system design exercise).
- GeeksforGeeks "B-Tree" practice/theory set for implementation practice.
- Study MySQL InnoDB's or PostgreSQL's actual B+Tree index documentation for real-world grounding.

---

## 14. Common Mistakes

- **Confusing B-Tree with Binary Tree** — the "B" does not stand for "Binary"; a B-Tree node can have many more than 2 children.
- **Splitting after overflow instead of before descending** — leads to more complex "propagate split back up" logic; pre-emptive splitting (as in the skeleton) is simpler to reason about.
- **Forgetting that internal nodes can store keys too** (unlike a B+Tree, where only leaves hold actual data) — this affects how deletion of an internal key must borrow a replacement from a leaf.
- **Choosing an arbitrarily small order** in a real system — the whole point is tuning the order to match disk block size; a tiny order gives you all the complexity with none of the disk-read benefit.

---

## 15. Summary

**Key takeaways:**
- A B-Tree generalizes a BST to multiple keys and children per node, specifically to minimize the number of disk reads for huge, disk-resident datasets.
- Height is O(log_m n) where m is the branching factor — large m means very shallow trees even for billions of keys.
- Splitting (insertion) and merging/borrowing (deletion) keep the tree perfectly height-balanced at all times.
- This is the default index structure for virtually every production relational database and many filesystems.

**Complexity recap:**

| Operation | Time |
|---|---|
| Search / Insert / Delete | O(log_m n) |

**Decision guideline:** Reach for a B-Tree (or, in practice, use whatever your database/filesystem already provides) whenever your dataset is too large for RAM and minimizing disk/block reads is the dominant performance concern. For in-memory-only workloads, an AVL or Red-Black Tree is usually simpler and sufficiently fast.

---

*Next chapter: `10_graphs_part1_representation_bfs_dfs.md`*
