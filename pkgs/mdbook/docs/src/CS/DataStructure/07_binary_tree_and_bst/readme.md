# Chapter 6: Binary Tree & Binary Search Tree (BST)

*Study time: ~7-9 hours | Prerequisite: Recursion, Linked Lists | Difficulty: Intermediate*

---

## 1. Introduction

**Definition:** A **Binary Tree** is a hierarchical structure where each node has at most two children, referred to as *left* and *right*. A **Binary Search Tree (BST)** is a binary tree with an added ordering invariant: for every node, all values in its left subtree are smaller, and all values in its right subtree are larger.

**Purpose:** Binary trees model hierarchical relationships (file systems, org charts, decision processes). BSTs specifically add the ability to search, insert, and delete in O(log n) *while keeping data in sorted order* — something neither arrays (O(log n) search but O(n) insert) nor hash tables (O(1) but unordered) can do simultaneously.

**Real-world analogy:** A BST is like a well-organized filing cabinet where, at each drawer, a label tells you "everything before M is to the left, everything after M is to the right." You can find any file by repeatedly halving your search space — never opening every drawer.

**Motivation:** We want the *sorted-order* benefits of a sorted array (in-order traversal, range queries, "find next larger value") combined with the *fast-insert/delete* benefits of a linked structure. A BST achieves both — as long as it stays reasonably balanced (which motivates the AVL Tree in the next chapter).

**History:** BSTs emerged from 1960s work formalizing efficient search structures; they underpin the C++ `std::map`/`std::set` (technically Red-Black Trees, a BST variant) and database indexing structures.

---

## 2. Why Do We Need It?

**Problem it solves:** Maintaining data in sorted order while supporting O(log n) search, insert, and delete — and enabling range queries ("all values between 10 and 50") and ordered traversal, which hash tables cannot do.

**Why previous structures are insufficient:**
- **Sorted array:** O(log n) search via binary search, but O(n) insert/delete (must shift elements).
- **Hash table:** O(1) average search, but no ordering — can't do range queries or "next greater element" efficiently.
- **Linked list:** O(n) for everything.

**Trade-offs:**
- You gain O(log n) (average case, assuming reasonable balance) for search/insert/delete *plus* sorted-order traversal and range queries.
- You pay for it with O(n) worst case if the tree becomes skewed (e.g., inserting sorted data one at a time turns it into a degenerate linked list), and extra memory for two pointers per node.

---

## 3. Internal Working

**A valid BST:**

```
              50
            /    \
          30      70
         /  \    /  \
       20   40  60   80
```

Check: everything left of 50 (30,20,40) is < 50; everything right (70,60,80) is > 50. This holds recursively at every subtree — 20 < 30 < 40, 60 < 70 < 80.

**Node structure (pointer-based):**
```
struct Node {
    int data;
    Node* left;
    Node* right;
};
```

**Search for 60**, step by step:
```
Start at root (50). 60 > 50 → go right.
At 70. 60 < 70 → go left.
At 60. Match! Found.
```
Three comparisons to find one node among seven — this is the O(log n) behavior: each comparison eliminates roughly half the remaining nodes.

**Insertion of 45:**
```
Start at root (50). 45 < 50 → go left.
At 30. 45 > 30 → go right.
At 40. 45 > 40 → go right, but 40 has no right child → insert here.

Result:
              50
            /    \
          30      70
         /  \    /  \
       20   40  60   80
              \
              45
```

**Deletion — the tricky case (deleting a node with two children):** To delete 30 (which has children 20 and 40), you can't just remove it — you'd orphan both children. The standard technique: replace 30's value with its **in-order successor** (the smallest value in its right subtree — here, 40, since 30's right subtree is just {40}), then delete that successor node from its original position (which is now guaranteed to have at most one child).

```
Before deleting 30:        After replacing 30's value with 40, then removing the original 40 node:
        30                            40
       /  \                          /  \
     20    40                      20   (nothing — original 40 had no children, simply removed)
```

**In-order traversal** (Left → Node → Right) — the traversal that visits nodes in **sorted order**, which is the defining useful property of a BST:
```
Traversing the tree above: 20, 30, 40, 45, 50, 60, 70, 80  ← sorted!
```

---

## 4. Operations

**Insert:**
- Start at root; at each node, go left if the new value is smaller, right if larger.
- When you reach a NULL pointer, place the new node there.
- Edge case: inserting a duplicate — convention varies (reject, count, or allow as right child); must be decided upfront and applied consistently.
- Worst case O(n) if the tree is skewed (e.g., inserting 1,2,3,4,5 in order creates a tree that's really just a linked list leaning right).

**Delete:**
- **Leaf node (no children):** simply remove it.
- **One child:** replace the node with its single child.
- **Two children:** replace the node's value with its in-order successor (or predecessor), then delete that successor node (which now has at most one child, reducing to a simpler case).

**Search:**
- Compare target with current node; go left if smaller, right if larger, until found or a NULL is hit (not present).

**Update:**
- Typically implemented as delete + insert (changing a node's value in place could violate the BST property if not done carefully).

**Traverse:**
- **In-order** (Left, Node, Right): sorted order.
- **Pre-order** (Node, Left, Right): useful for copying/serializing a tree.
- **Post-order** (Left, Right, Node): useful for safely deleting a tree (children before parent).
- **Level-order** (BFS, using a Queue): useful for visualizing tree shape level by level.

**Peek (find min/max):**
- Min: follow left pointers until NULL. Max: follow right pointers until NULL. O(h) where h is tree height.

---

## 5. Time & Space Complexity

| Operation | Average (Balanced) | Worst (Skewed) | Space Complexity |
|---|---|---|---|
| Search | O(log n) | O(n) | O(1) iterative, O(h) recursive (call stack) |
| Insert | O(log n) | O(n) | O(1) iterative, O(h) recursive |
| Delete | O(log n) | O(n) | O(1) iterative, O(h) recursive |
| Find min/max | O(log n) | O(n) | O(1) |
| In-order traversal (full) | O(n) | O(n) | O(h) for recursion stack |

**Why these hold:**
- A **balanced** BST has height h ≈ log₂(n), since each level can hold up to twice as many nodes as the level above — so n nodes require only about log₂(n) levels, and every search/insert/delete walks at most one path from root to a leaf (length = height).
- A **skewed** tree (e.g., built by inserting already-sorted data) degenerates toward a linked list with height ≈ n, making every operation O(n) — this single fact is the entire motivation for the AVL Tree (next chapter), which *guarantees* balance.
- Traversal is always O(n) because every node must be visited exactly once, regardless of tree shape.

---

## 6. Advantages

- Maintains sorted order automatically — in-order traversal gives sorted output "for free."
- O(log n) search/insert/delete *when balanced* — the best of both sorted-array and linked-list worlds.
- Supports range queries and "next greater/smaller" operations naturally.
- Flexible size — grows/shrinks node by node, no bulk reallocation.

## 7. Disadvantages

- No balance guarantee by default — a naive BST can degrade to O(n) with unlucky/adversarial insert order.
- More complex deletion logic than simpler structures (three distinct cases to handle).
- Pointer-based nodes mean extra memory overhead and worse cache locality compared to array-backed structures.
- Recursive implementations risk stack overflow on very deep/skewed trees.

---

## 8. Real-World Applications

- **Databases:** Index structures (though production databases typically use B-Trees, a generalization covered in Chapter 8, optimized for disk I/O).
- **File Systems:** Directory structures are naturally tree-shaped; some indexing structures use BST-like designs.
- **Compilers:** Abstract Syntax Trees (ASTs) representing parsed code are binary/n-ary trees; expression trees for evaluating arithmetic.
- **Networking:** IP routing tables sometimes use tree structures for prefix matching.
- **AI/ML:** Decision trees (a generalization to n-ary, but rooted in the same recursive-partitioning idea) for classification/regression.
- **Standard Libraries:** `std::map`/`std::set` in C++ and `TreeMap`/`TreeSet` in Java are (self-balancing) BSTs under the hood.
- **Game Development:** Spatial partitioning (though k-d trees / quad-trees, generalizations of BSTs to multiple dimensions, are more common there).

---

## 9. Implementation (C++17)

```cpp
#include <iostream>
#include <memory>
#include <vector>

// A Binary Search Tree using smart pointers for automatic memory management.
class BST {
private:
    struct Node {
        int data;
        std::unique_ptr<Node> left;
        std::unique_ptr<Node> right;
        Node(int val) : data(val), left(nullptr), right(nullptr) {}
    };

    std::unique_ptr<Node> root;

    // Recursive helper for insertion. Returns the (possibly new) subtree root.
    std::unique_ptr<Node> insertHelper(std::unique_ptr<Node> node, int value) {
        if (!node) {
            return std::make_unique<Node>(value);   // found the insertion point
        }
        if (value < node->data) {
            node->left = insertHelper(std::move(node->left), value);
        } else if (value > node->data) {
            node->right = insertHelper(std::move(node->right), value);
        }
        // if value == node->data, we silently ignore duplicates (a design choice)
        return node;
    }

    // Recursive helper for deletion. Returns the (possibly new) subtree root.
    std::unique_ptr<Node> deleteHelper(std::unique_ptr<Node> node, int value) {
        if (!node) return nullptr;   // value not found, nothing to do

        if (value < node->data) {
            node->left = deleteHelper(std::move(node->left), value);
        } else if (value > node->data) {
            node->right = deleteHelper(std::move(node->right), value);
        } else {
            // Found the node to delete.
            if (!node->left) return std::move(node->right);    // 0 or 1 child (right)
            if (!node->right) return std::move(node->left);    // 1 child (left)

            // Two children: find in-order successor (leftmost node of right subtree).
            Node* successor = node->right.get();
            while (successor->left) successor = successor->left.get();
            node->data = successor->data;   // copy successor's value up
            node->right = deleteHelper(std::move(node->right), successor->data);  // remove the duplicate
        }
        return node;
    }

    void inOrderHelper(const Node* node, std::vector<int>& result) const {
        if (!node) return;
        inOrderHelper(node->left.get(), result);
        result.push_back(node->data);
        inOrderHelper(node->right.get(), result);
    }

    const Node* searchHelper(const Node* node, int value) const {
        if (!node || node->data == value) return node;
        return value < node->data ? searchHelper(node->left.get(), value)
                                   : searchHelper(node->right.get(), value);
    }

public:
    BST() : root(nullptr) {}

    // Insert. O(log n) average, O(n) worst (skewed tree).
    void insert(int value) {
        root = insertHelper(std::move(root), value);
    }

    // Delete. O(log n) average, O(n) worst.
    void remove(int value) {
        root = deleteHelper(std::move(root), value);
    }

    // Search. O(log n) average, O(n) worst.
    bool contains(int value) const {
        return searchHelper(root.get(), value) != nullptr;
    }

    // In-order traversal returns elements in SORTED order — the defining BST property.
    std::vector<int> inOrder() const {
        std::vector<int> result;
        inOrderHelper(root.get(), result);
        return result;
    }

    // Find minimum value. O(log n) average.
    int findMin() const {
        const Node* current = root.get();
        while (current->left) current = current->left.get();
        return current->data;
    }
};

// Example usage
int main() {
    BST tree;
    for (int v : {50, 30, 70, 20, 40, 60, 80}) {
        tree.insert(v);
    }

    std::cout << "In-order (sorted): ";
    for (int v : tree.inOrder()) std::cout << v << " ";
    std::cout << "\n";   // 20 30 40 50 60 70 80

    std::cout << "Contains 60? " << (tree.contains(60) ? "yes" : "no") << "\n";  // yes
    std::cout << "Min value: " << tree.findMin() << "\n";                        // 20

    tree.remove(30);   // two-children deletion case
    std::cout << "After deleting 30: ";
    for (int v : tree.inOrder()) std::cout << v << " ";
    std::cout << "\n";   // 20 40 50 60 70 80

    return 0;
}
```

---

## 10. Code Walkthrough

- **`std::unique_ptr<Node>`:** Using smart pointers means we never manually `delete` — when a `unique_ptr` goes out of scope (e.g., a subtree is replaced), its destructor recursively frees the whole subtree automatically. This eliminates an entire class of memory-leak bugs common in raw-pointer BST implementations.
- **`insertHelper`'s "return the subtree root" pattern:** Rather than tracking parent pointers, each recursive call returns what the subtree root *should be* after the operation, and the caller reattaches it (`node->left = insertHelper(std::move(node->left), value)`). This functional style avoids a whole category of "did I update the parent's pointer correctly?" bugs.
- **`deleteHelper`'s three cases:** No children *and* one child are actually the same code path here (`!node->left` returns `node->right`, which is `nullptr` if there's truly no child) — a neat simplification. The two-children case is the only one requiring extra work: find the in-order successor (leftmost node of the right subtree — guaranteed to have no left child), copy its value up, then recursively delete the now-duplicate successor from its original position.
- **`std::move(node->left)`:** Required because `unique_ptr` can't be copied — ownership must be explicitly transferred into the recursive call, and the function's return value transfers it back.
- **`searchHelper`:** A clean ternary-based recursive binary search — notice it's structurally identical to array-based binary search, just navigating pointers instead of array indices.

**Common mistakes to watch for here:**
- Forgetting to reattach the result of `insertHelper`/`deleteHelper` to the parent's pointer — this silently drops the change.
- In deletion, deleting the *found* successor node incorrectly instead of the duplicate now sitting in its original position, corrupting the tree.
- Assuming deletion is O(log n) worst case — it's O(log n) only if the tree is balanced; a skewed BST makes it O(n), same as search/insert.

---

## 11. Dry Run

**Insert sequence:** 50, 30, 70, 20, 40, 60, 80 (as in the example tree above). Each insertion follows the "compare and go left/right until NULL" path shown in section 3.

**Now `remove(30)`** (two children: 20 and 40):

| Step | Action |
|---|---|
| 1 | Search reaches node 30 — matches target. |
| 2 | 30 has both left (20) and right (40) children → two-children case. |
| 3 | Find in-order successor: go right to 40, then check its left — none, so 40 IS the successor. |
| 4 | Copy successor's value (40) into node 30's data field → node now holds value 40. |
| 5 | Recursively delete the original "40" node from the right subtree — it has no children, so it's simply removed. |

**Resulting tree:**
```
              50
            /    \
          40      70
         /       /  \
       20       60   80
```

**In-order traversal check:** 20, 40, 50, 60, 70, 80 — still sorted. ✓

---

## 12. Interview Questions

**Conceptual:**
1. Why does a BST degrade to O(n) when built from already-sorted input?
2. Explain the three deletion cases (no child, one child, two children) and why the two-children case needs an in-order successor/predecessor.
3. What's the difference between in-order, pre-order, post-order, and level-order traversal, and when would you use each?
4. Why is `std::map` in C++ typically a Red-Black Tree rather than a plain BST?
5. How would you check if a given binary tree is a *valid* BST?

**Coding:**
1. Validate whether a binary tree is a valid BST.
2. Find the Lowest Common Ancestor (LCA) of two nodes in a BST.
3. Convert a sorted array into a balanced BST.
4. Find the Kth smallest element in a BST.
5. Serialize and deserialize a binary tree.
6. Check if two binary trees are identical / symmetric.
7. Find the in-order successor of a given node.

**Follow-ups / interviewer traps:**
- "Can you validate a BST in O(n) with O(1) extra space (no recursion, no array)?" (expects Morris traversal or careful iterative in-order with bounds tracking)
- "What if the BST allows duplicates — does your LCA/traversal logic still work?" (tests edge-case robustness)
- "Your delete function — what's its worst-case time complexity, and when does that worst case occur?" (tests whether they conflate average and worst case)

---

## 13. Practice Problems

**Easy**
- Invert Binary Tree (LeetCode 226)
- Maximum Depth of Binary Tree (LeetCode 104)
- Same Tree (LeetCode 100)
- Search in a Binary Search Tree (LeetCode 700)

**Medium**
- Validate Binary Search Tree (LeetCode 98)
- Lowest Common Ancestor of a BST (LeetCode 235)
- Kth Smallest Element in a BST (LeetCode 230)
- Delete Node in a BST (LeetCode 450)
- Binary Tree Level Order Traversal (LeetCode 102)

**Hard**
- Serialize and Deserialize Binary Tree (LeetCode 297)
- Recover Binary Search Tree (LeetCode 99)
- Binary Tree Maximum Path Sum (LeetCode 124)

Also recommended: GeeksforGeeks "Binary Search Tree" practice set, HackerRank "Trees" track.

---

## 14. Common Mistakes

- **Not reattaching pointers after recursive insert/delete calls**, silently losing changes.
- **Confusing average and worst case** — assuming O(log n) always holds without considering tree balance.
- **Mishandling the two-children deletion case** — deleting the wrong node or forgetting to copy the successor's value up first.
- **Off-by-one / wrong comparison direction** — going right when you meant left (swapping the BST invariant accidentally).
- **Recursive stack overflow** on deep/skewed trees for very large n — an iterative approach or self-balancing tree avoids this.
- **Forgetting duplicate-handling policy** — inconsistent duplicate handling (sometimes inserting left, sometimes right) can silently break the BST invariant.

---

## 15. Summary

**Key takeaways:**
- A BST combines sorted-order maintenance with O(log n) operations — but *only* when balanced; an unbalanced BST is no better than a linked list.
- In-order traversal is the "free" benefit that unlocks sorted iteration, range queries, and "next/previous" operations that hash tables cannot offer.
- Deletion's two-children case (in-order successor/predecessor) is the trickiest part and a very common interview probe point.
- The BST's Achilles' heel — no balance guarantee — is exactly what the next chapter (AVL Tree) fixes.

**Complexity recap:**

| | Average (balanced) | Worst (skewed) |
|---|---|---|
| Search / Insert / Delete | O(log n) | O(n) |
| Traversal (any type) | O(n) | O(n) |

**Decision guideline:** Use a BST when you need sorted-order maintenance with reasonably fast search/insert/delete, and you can either control insertion order (avoiding worst-case skew) or you'll use a self-balancing variant. If you don't need ordering, a Hash Table is faster on average; if you need *guaranteed* worst-case O(log n), use an AVL or Red-Black Tree (next chapter).

---

*Next chapter: `07_avl_tree.md`*
