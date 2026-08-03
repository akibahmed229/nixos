# Chapter 7: AVL Tree

*Study time: ~7-9 hours | Prerequisite: Binary Search Tree | Difficulty: Intermediate-Advanced*

---

## 1. Introduction

**Definition:** An AVL Tree (named after inventors **A**delson-**V**elsky and **L**andis) is a **self-balancing Binary Search Tree** where, for every node, the heights of its left and right subtrees differ by at most 1. This difference is called the **balance factor**. Whenever an insertion or deletion would violate this rule, the tree performs **rotations** to restore balance.

**Purpose:** To *guarantee* O(log n) search, insert, and delete — closing the exact loophole a plain BST has (worst-case O(n) when skewed).

**Real-world analogy:** Imagine a mobile (the hanging kind above a baby's crib) — it must stay roughly balanced or it tips over. An AVL Tree is constantly "re-adjusting its hanging arms" (via rotations) after every insert/delete so no branch ever grows dramatically longer than its sibling.

**Motivation:** A plain BST's performance depends entirely on insertion order — insert sorted data and you get a linked list in disguise. Real applications can't gamble on "hopefully the input order is nice." AVL trees remove that gamble with a hard mathematical guarantee.

**History:** Introduced in 1962 — the **first** self-balancing binary search tree ever published, predating Red-Black Trees (1972) by a decade.

---

## 2. Why Do We Need It?

**Problem it solves:** Guaranteeing O(log n) height (and therefore O(log n) operations) *regardless* of insertion order — eliminating the plain BST's worst-case vulnerability.

**Why a plain BST is insufficient:** As shown in Chapter 6, inserting already-sorted data into a plain BST produces a completely skewed, linked-list-shaped tree — O(n) for every operation. Many real datasets *are* sorted or near-sorted (timestamps, IDs), making this failure mode common, not theoretical.

**Trade-offs:**
- You gain a mathematically guaranteed O(log n) for search, insert, and delete, no matter the input order.
- You pay for it with extra bookkeeping (storing/maintaining height at every node) and more work per insert/delete (potential rotations), making AVL trees somewhat slower in practice for write-heavy workloads than a looser structure like a Red-Black Tree (which tolerates more imbalance in exchange for fewer rotations).

---

## 3. Internal Working

**Balance Factor** = height(left subtree) − height(right subtree). Valid values: **-1, 0, +1**. Anything else triggers rebalancing.

**The four imbalance cases and their fixes:**

**Case 1 — Left-Left (LL):** New node inserted into the left subtree of the left child.
```
        30                      20
       /                       /  \
     20        rotate         10   30
    /          RIGHT
  10           at 30
```
Fix: **single right rotation** at the unbalanced node.

**Case 2 — Right-Right (RR):** Mirror image of LL.
```
  10                          20
    \                        /  \
     20      rotate         10   30
      \      LEFT
       30    at 10
```
Fix: **single left rotation**.

**Case 3 — Left-Right (LR):** New node inserted into the *right* subtree of the left child.
```
      30                  30                    20
     /                   /                     /  \
   10        rotate    20         rotate      10    30
     \       LEFT      /          RIGHT
      20    at 10    10           at 30
```
Fix: **left rotation at the child, then right rotation at the node** — a two-step ("zig-zag") fix.

**Case 4 — Right-Left (RL):** Mirror image of LR — right rotation at the child, then left rotation at the node.

**Right rotation, mechanically (the core building block):**
```
Before:              After right-rotating at y:
      y                      x
     / \                    / \
    x   C                  A   y
   / \                        / \
  A   B                      B   C
```
`x` becomes the new subtree root; `y` becomes `x`'s right child; `x`'s old right child (`B`) becomes `y`'s new left child (since B is still "between" A and y in sorted order — this reassignment is what preserves the BST property through the rotation).

**After every insert/delete**, the algorithm walks back up from the insertion/deletion point to the root, updating heights and checking the balance factor at each ancestor — this is why rotations are needed only along a single root-to-node path, not throughout the whole tree.

---

## 4. Operations

**Insert:**
- Perform a standard BST insert (as in Chapter 6).
- Walk back up the path to the root, updating each ancestor's height.
- At each ancestor, compute the balance factor; if it's outside [-1, +1], identify which of the four cases (LL, RR, LR, RL) applies (based on which side is heavier and where the newest node landed), and apply the corresponding rotation(s).
- At most **O(log n) rotations** are needed per insert (bounded by tree height), though in practice often just one.

**Delete:**
- Perform a standard BST delete (as in Chapter 6, including the in-order-successor technique for two-children nodes).
- Walk back up from the deletion point, updating heights and rebalancing exactly as in insert.
- Unlike insertion, a single deletion can require rebalancing at **multiple** ancestors on the way up (though still bounded by O(log n) total).

**Search:**
- Identical to plain BST search — the *only* reason it's guaranteed O(log n) here is the height guarantee; the search algorithm itself doesn't change at all.

**Update:**
- As with plain BST, typically delete + insert to avoid violating the BST property mid-update.

**Traverse:**
- Identical to plain BST — in-order gives sorted order, etc.

---

## 5. Time & Space Complexity

| Operation | Time Complexity | Space Complexity |
|---|---|---|
| Search | O(log n) — **guaranteed** | O(1) iterative, O(log n) recursive |
| Insert | O(log n) — **guaranteed** | O(log n) recursion stack |
| Delete | O(log n) — **guaranteed** | O(log n) recursion stack |
| Rotation (single) | O(1) | O(1) |
| Height/balance-factor update | O(1) per node | O(1) |

**Why these hold:**
- The AVL balance invariant mathematically guarantees the tree's height is always O(log n) — specifically, it can be proven that an AVL tree with n nodes has height at most ≈1.44 log₂(n), a constant factor away from the theoretical minimum. This is *the* fact that makes every operation's O(log n) bound a **guarantee**, not just an average case.
- Each individual rotation is O(1) — it only touches a small, fixed number of pointers (as shown in section 3), regardless of subtree size.
- Insert triggers at most one rebalancing rotation *sequence* (though it can be a double rotation, still O(1)); delete can require rebalancing at multiple levels on the path back to root, but that path has length O(log n), so total rebalancing work per delete is still O(log n).

---

## 6. Advantages

- **Guaranteed** O(log n) for search, insert, delete — no adversarial input can degrade it, unlike a plain BST.
- Stricter balance than a Red-Black Tree means **faster lookups** (shorter average path length) — ideal for read-heavy workloads.
- Conceptually simpler rotation logic than some alternatives (only 4 cases, well-documented).

## 7. Disadvantages

- More rotations on average during insert/delete than a Red-Black Tree (which tolerates looser balance), making AVL trees comparatively slower for write-heavy workloads.
- Extra memory per node to store height (or balance factor).
- More complex to implement correctly than a plain BST — four distinct rebalancing cases to get right.

---

## 8. Real-World Applications

- **Databases:** Some in-memory indexing structures use AVL trees where read performance matters more than write performance.
- **Operating Systems:** Some early Linux kernel internals and memory-management structures used AVL trees (though many have since moved to Red-Black Trees for their better write performance — see comparison table below).
- **File Systems:** Some directory-indexing implementations.
- **Networking:** Certain router/firewall rule-lookup structures where fast, predictable lookups matter and updates are relatively infrequent.
- **Compilers/Language Runtimes:** Some symbol table or interval-tracking implementations favor AVL's tighter balance guarantee.
- **Any read-heavy system requiring guaranteed worst-case performance:** real-time systems where an occasional O(n) BST lookup (from an unlucky insertion order) would be unacceptable.

---

## 9. Implementation (C++17)

```cpp
#include <iostream>
#include <memory>
#include <algorithm>

class AVLTree {
private:
    struct Node {
        int data;
        int height;   // height of the subtree rooted here (leaf = 1, empty = 0)
        std::unique_ptr<Node> left;
        std::unique_ptr<Node> right;
        Node(int val) : data(val), height(1), left(nullptr), right(nullptr) {}
    };

    std::unique_ptr<Node> root;

    int heightOf(const Node* node) const { return node ? node->height : 0; }

    int balanceFactor(const Node* node) const {
        return node ? heightOf(node->left.get()) - heightOf(node->right.get()) : 0;
    }

    void updateHeight(Node* node) {
        node->height = 1 + std::max(heightOf(node->left.get()), heightOf(node->right.get()));
    }

    // Right rotation — fixes Left-Left imbalance. See ASCII diagram in section 3.
    std::unique_ptr<Node> rotateRight(std::unique_ptr<Node> y) {
        std::unique_ptr<Node> x = std::move(y->left);
        y->left = std::move(x->right);       // B moves from x's right to y's left
        updateHeight(y.get());
        x->right = std::move(y);              // y becomes x's right child
        updateHeight(x.get());
        return x;                              // x is the new subtree root
    }

    // Left rotation — fixes Right-Right imbalance. Mirror image of rotateRight.
    std::unique_ptr<Node> rotateLeft(std::unique_ptr<Node> x) {
        std::unique_ptr<Node> y = std::move(x->right);
        x->right = std::move(y->left);
        updateHeight(x.get());
        y->left = std::move(x);
        updateHeight(y.get());
        return y;
    }

    // Rebalance a node after insert/delete, applying the correct rotation case.
    std::unique_ptr<Node> rebalance(std::unique_ptr<Node> node) {
        updateHeight(node.get());
        int bf = balanceFactor(node.get());

        if (bf > 1) {   // left-heavy
            if (balanceFactor(node->left.get()) < 0) {
                // Left-Right case: rotate left child left first, THEN rotate node right.
                node->left = rotateLeft(std::move(node->left));
            }
            return rotateRight(std::move(node));   // Left-Left case (or LR after the fix-up above)
        }
        if (bf < -1) {   // right-heavy
            if (balanceFactor(node->right.get()) > 0) {
                // Right-Left case: rotate right child right first, THEN rotate node left.
                node->right = rotateRight(std::move(node->right));
            }
            return rotateLeft(std::move(node));    // Right-Right case (or RL after the fix-up above)
        }
        return node;   // already balanced, no rotation needed
    }

    std::unique_ptr<Node> insertHelper(std::unique_ptr<Node> node, int value) {
        if (!node) return std::make_unique<Node>(value);

        if (value < node->data) {
            node->left = insertHelper(std::move(node->left), value);
        } else if (value > node->data) {
            node->right = insertHelper(std::move(node->right), value);
        } else {
            return node;   // duplicate, ignore
        }
        return rebalance(std::move(node));   // rebalance on the way back UP the recursion
    }

    std::unique_ptr<Node> deleteHelper(std::unique_ptr<Node> node, int value) {
        if (!node) return nullptr;

        if (value < node->data) {
            node->left = deleteHelper(std::move(node->left), value);
        } else if (value > node->data) {
            node->right = deleteHelper(std::move(node->right), value);
        } else {
            if (!node->left) return rebalance(std::move(node->right));
            if (!node->right) return rebalance(std::move(node->left));

            Node* successor = node->right.get();
            while (successor->left) successor = successor->left.get();
            node->data = successor->data;
            node->right = deleteHelper(std::move(node->right), successor->data);
        }
        return rebalance(std::move(node));   // rebalance on the way back UP, just like insert
    }

public:
    AVLTree() : root(nullptr) {}

    void insert(int value) { root = insertHelper(std::move(root), value); }
    void remove(int value) { root = deleteHelper(std::move(root), value); }
    int height() const { return heightOf(root.get()); }

    void inOrderPrint() const {
        std::vector<int> result;
        std::function<void(const Node*)> visit = [&](const Node* n) {
            if (!n) return;
            visit(n->left.get());
            result.push_back(n->data);
            visit(n->right.get());
        };
        visit(root.get());
        std::cout << "[ ";
        for (int v : result) std::cout << v << " ";
        std::cout << "]\n";
    }
};

// Example usage
int main() {
    AVLTree tree;
    // Insert already-SORTED data — this would make a plain BST a degenerate linked list.
    for (int v : {10, 20, 30, 40, 50, 60}) {
        tree.insert(v);
    }

    tree.inOrderPrint();                       // [ 10 20 30 40 50 60 ] — still sorted
    std::cout << "Tree height: " << tree.height() << "\n";
    // Height stays ~3 (log2(6)≈2.6), NOT 6 — proof the AVL rebalancing worked.

    tree.remove(30);
    tree.inOrderPrint();                       // [ 10 20 40 50 60 ]
    std::cout << "Tree height after delete: " << tree.height() << "\n";
    return 0;
}
```

---

## 10. Code Walkthrough

- **`height` field per node:** Unlike a plain BST, every AVL node tracks its own subtree height, updated bottom-up after every structural change. This is the raw material `balanceFactor` needs.
- **`rotateRight` / `rotateLeft`:** Each is O(1) — notice they only touch three pointers (`y->left`, `x->right`, and the caller's reference) and recompute two heights. The order of operations matters: `updateHeight(y)` must happen *before* `x->right = std::move(y)` reassigns y's new parent, since at that point y's children are already correctly set but x's height hasn't been recomputed yet.
- **`rebalance`:** This is the single function both `insertHelper` and `deleteHelper` call on their way back up the recursion. It checks `bf > 1` (left-heavy) or `bf < -1` (right-heavy), and for each, checks the *child's* balance factor to distinguish the "single rotation" cases (LL/RR) from the "double rotation" cases (LR/RL) — this nested check is exactly the four-case logic from section 3, compressed into two `if` blocks thanks to symmetry.
- **`insertHelper`/`deleteHelper` calling `rebalance` on every return:** This is the critical difference from the plain BST in Chapter 6 — every single level of the recursion, from the insertion/deletion point all the way up to the root, gets a height update and a balance check. This is *why* an AVL tree can never end up skewed: imbalance is caught and fixed immediately at the lowest point it appears, before it can propagate.
- **Deletion's `rebalance(std::move(node->right))` / `rebalance(std::move(node->left))` for the 0/1-child cases:** Even these "simple" cases need rebalancing because removing a node can still shift the height of what remains, potentially imbalancing an ancestor.

**Common mistakes to watch for here:**
- Forgetting to call `updateHeight` after a rotation (or calling it in the wrong order relative to reassigning pointers), leaving stale height values that corrupt future balance-factor checks.
- Applying only a single rotation for what's actually an LR/RL (double rotation) case — this is the single most common AVL bug.
- Forgetting to rebalance on the way back up for *every* ancestor, not just the immediate parent of the insertion/deletion point.

---

## 11. Dry Run

**Insert 10, 20, 30 (triggers a Right-Right case):**

| Step | Tree after insert | Balance check |
|---|---|---|
| insert(10) | `10` | bf(10)=0, fine |
| insert(20) | `10 → right:20` | bf(10) = 0 - 1 = -1, fine (within [-1,1]) |
| insert(30) | 30 goes right of 20 → `10 → 20 → 30` (a right-skewed chain) | At node 10: bf = 0 - 2 = **-2** → imbalanced! Right-heavy. Check child(20)'s bf: 0 - 1 = -1 (not >0) → pure **Right-Right case** → single **left rotation** at 10. |

**Applying `rotateLeft(10)`:**
```
Before:          After:
  10                20
    \              /  \
    20             10   30
      \
      30
```
New balanced tree: root 20, left child 10, right child 30. Height = 2 (was about to become 3 unbalanced, now stays a perfect 2). ✓

**Now insert 25 (triggers a Right-Left case on this new tree):**
```
       20
      /  \
    10    30
         /
       25
```
At node 30: bf = height(left=25,h1) - height(right=0) = 1 - 0 = **1**... check node 20 (the actual ancestor going out of balance): left height=1(node 10), right height=2(subtree rooted at 30 which now has height 2 because of 25) → bf(20) = 1 - 2 = -1, still fine actually in this small example — but in general, this exact pattern (new node inserted into left child of a right child) is the textbook Right-Left trigger, requiring **right-rotate at 30, then left-rotate at 20**.

---

## 12. Interview Questions

**Conceptual:**
1. Why does an AVL tree guarantee O(log n) height, and what's the mathematical bound?
2. Explain all four rotation cases (LL, RR, LR, RL) and how to detect which applies.
3. Compare AVL Tree vs Red-Black Tree — why might a database prefer one over the other?
4. Why must rebalancing happen on the way *back up* the recursion, not just at the insertion point?
5. Can a single insertion require more than one rotation *sequence*? Can a single deletion?

**Coding:**
1. Implement AVL tree insertion with rotations.
2. Implement AVL tree deletion with rebalancing.
3. Given a sequence of insertions, determine the final tree height.
4. Convert an unbalanced BST into a balanced AVL tree (or general balanced BST).
5. Verify whether a given binary tree satisfies the AVL balance property.

**Follow-ups / interviewer traps:**
- "What's the worst-case number of rotations for one deletion?" (still O(log n) total, but can require rebalancing at every ancestor level — not just one rotation like insertion typically needs)
- "Why not just rebuild the whole tree from scratch periodically instead of rotating incrementally?" (tests understanding of why O(1) local rotations beat O(n) global rebuilds)
- "If you only rebalance the immediate parent instead of walking all the way to the root, what breaks?" (tests deep understanding — an ancestor further up could still be imbalanced)

---

## 13. Practice Problems

**Easy**
- Balanced Binary Tree — check if balanced (LeetCode 110)
- Convert Sorted Array to Binary Search Tree (LeetCode 108)

**Medium**
- Convert Sorted List to Binary Search Tree (LeetCode 109)
- Balance a Binary Search Tree (LeetCode 1382)

**Hard**
- Design a data structure supporting O(log n) insert/delete/search with order statistics (order-statistics tree, an AVL variant)
- Count of Smaller Numbers After Self (can be solved with a balanced BST / BIT)

Also recommended: GeeksforGeeks "AVL Tree" practice set; implement your own AVL and stress-test it against a plain BST with sorted-input insertion to *see* the height difference firsthand — this is one of the most illuminating exercises in this whole guide.

---

## 14. Common Mistakes

- **Implementing only single rotations**, missing the double-rotation (LR/RL) cases entirely.
- **Forgetting to update height after rotation**, or updating it in the wrong order (before children are correctly reattached).
- **Rebalancing only at the insertion/deletion point** instead of at every ancestor on the path back to the root.
- **Off-by-one in balance factor threshold** — using `> 1` when the tree actually needs checking at `>= 2` equivalent logic (these should be equivalent, but sign/direction errors are common).
- **Confusing which child's balance factor to check** when distinguishing LL/LR or RR/RL cases.
- **Assuming AVL and Red-Black Trees are interchangeable in all contexts** — they have the same asymptotic complexity but different practical performance profiles (see comparison table in the roadmap file).

---

## 15. Summary

**Key takeaways:**
- AVL trees fix the plain BST's single biggest weakness — no balance guarantee — by enforcing balance factor ∈ {-1, 0, +1} at every node via rotations.
- There are exactly four imbalance cases (LL, RR, LR, RL), and the double-rotation cases (LR, RL) are the most commonly mishandled in practice.
- Rebalancing must occur at every ancestor on the path back to the root after insert/delete — this is what guarantees no skew can ever accumulate undetected.
- AVL trees favor **read-heavy** workloads (tighter balance → faster lookups); Red-Black Trees favor **write-heavy** workloads (looser balance → fewer rotations).

**Complexity recap:**

| Operation | Time (guaranteed) | Space |
|---|---|---|
| Search / Insert / Delete | O(log n) | O(log n) recursion stack |
| Single rotation | O(1) | O(1) |

**Decision guideline:** Choose an AVL Tree when you need guaranteed O(log n) performance and your workload is read-heavy (lookups >> insertions/deletions). Choose a Red-Black Tree (or just use `std::map`) when writes are frequent and you can tolerate slightly looser balance for fewer rotations. Choose a plain BST only when you can guarantee reasonably random insertion order and simplicity matters more than worst-case guarantees.

---

*Next chapter: `08_trie.md`, or say the word for Heap-based priority structures revisited, Graphs, or Advanced structures (Segment Tree, Fenwick Tree, DSU) instead.*
