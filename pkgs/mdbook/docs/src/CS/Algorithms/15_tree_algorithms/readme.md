# Chapter 15: Tree Algorithms

*Study time: ~5-6 hours | Prerequisite: Binary Tree/BST (Data Structures guide, Ch. 7), Recursion | Difficulty: Intermediate*

---

## 1. Introduction

**Definition:** This chapter covers the essential *algorithmic* techniques applied to trees, building on the Data Structures guide's Binary Tree/BST/AVL chapters (which covered the structures themselves): the four traversal orders, the **Lowest Common Ancestor (LCA)** problem, and **Tree Diameter** — three of the most frequently-tested tree-algorithm patterns in interviews.

**Purpose:** To move from "I know what a tree is and how to insert/search/delete" (Data Structures guide) to "I can solve non-trivial algorithmic questions about a tree's structure and relationships between its nodes" — the kind of question interviewers ask once they've confirmed basic tree fluency.

**Problem solved:** Visiting tree nodes in a specific meaningful order (traversal), finding the deepest shared ancestor of two nodes (LCA — useful for "how are these two things related in a hierarchy" queries), and finding the longest path between any two nodes in a tree (Diameter — useful for "what's the worst-case distance in this hierarchical structure" queries).

---

## 2. Intuition

**Traversals** are simply "in what order do I visit a tree's nodes" — and the four standard orders (pre-order, in-order, post-order, level-order) each serve a different natural purpose: pre-order visits a node before its children (useful for copying/serializing a tree, since you can reconstruct it by processing parents before their children); in-order visits left-subtree, then node, then right-subtree (useful specifically for BSTs, since it produces sorted output — covered in the Data Structures guide); post-order visits children before the node itself (useful for safely deleting a tree, or for any computation that needs a node's children's results before computing the node's own result — directly foreshadowing Tree Diameter below); level-order visits nodes level by level (useful for anything requiring breadth-first, "closest first" processing, using a Queue exactly as BFS does on graphs).

**LCA's intuition:** the lowest common ancestor of two nodes is the deepest node that has both as descendants (a node can be its own ancestor for this purpose). The key recursive insight: **search both subtrees of the current node for the two targets; if one target is found in the left subtree and the other in the right subtree, the current node itself IS the LCA** (it's the point where their paths from the root diverge); if both are found in the same subtree, the LCA must be deeper within that subtree, so recurse further.

**Tree Diameter's intuition:** the diameter (longest path between any two nodes, not necessarily through the root) at *any* given node can be computed as "the height of its left subtree + the height of its right subtree" (the longest path that passes *through* this node) — and the overall answer is the maximum of this quantity across *every* node in the tree, not just the root. This is why computing diameter naturally pairs with a post-order traversal: you need each subtree's height already computed before you can evaluate whether the current node offers the best "left height + right height" path.

---

## 3. Step-by-Step Working

### (a) Four Traversals on this tree:
```
        1
       / \
      2   3
     / \
    4   5
```

```
Pre-order  (Node, Left, Right): 1, 2, 4, 5, 3
In-order   (Left, Node, Right):  4, 2, 5, 1, 3
Post-order (Left, Right, Node):  4, 5, 2, 3, 1
Level-order (BFS, level by level): 1, 2, 3, 4, 5
```

### (b) Lowest Common Ancestor — find LCA(4, 5) and LCA(4, 3) in the same tree

```
LCA(4, 5):
Start at 1. Search left subtree (rooted at 2) for {4,5}: found BOTH 4 and 5 there.
Search right subtree (rooted at 3): found NEITHER.
Since both targets are in the LEFT subtree only, recurse into node 2's subtree specifically.
At node 2: search left (4): found 4. search right (5): found 5.
Found ONE in each subtree of node 2 → node 2 IS the LCA.
Answer: LCA(4,5) = 2

LCA(4, 3):
Start at 1. Search left subtree (2): found 4 (not 3).
Search right subtree (3): found 3 (not 4).
Found ONE target in EACH subtree of node 1 → node 1 IS the LCA.
Answer: LCA(4,3) = 1
```

### (c) Tree Diameter — find the longest path in this tree:
```
        1
       / \
      2   3
     / \
    4   5
   /
  6
```

```
Post-order computation (compute height bottom-up, track best diameter seen so far):

Node 6 (leaf): height=1. No children, diameter candidate = 0.
Node 4: left child = 6 (height 1), no right child (height 0).
        height(4) = 1 + max(1,0) = 2.
        diameter candidate at node 4 = leftHeight + rightHeight = 1 + 0 = 1.
Node 5 (leaf): height=1. diameter candidate = 0.
Node 2: left child = 4 (height 2), right child = 5 (height 1).
        height(2) = 1 + max(2,1) = 3.
        diameter candidate at node 2 = 2 + 1 = 3.   ← path 6-4-2-5, length 3 edges
Node 3 (leaf): height=1. diameter candidate = 0.
Node 1: left child = 2 (height 3), right child = 3 (height 1).
        height(1) = 1 + max(3,1) = 4.
        diameter candidate at node 1 = 3 + 1 = 4.   ← path 6-4-2-1-3, length 4 edges — the OVERALL best

Final diameter = max(all candidates seen) = 4  (the path 6→4→2→1→3)
```

**Critical insight:** the overall diameter (4, through node 1) is NOT the same as the best candidate at just the root — node 2 had a candidate of 3, but the true maximum (4) only appears when comparing across ALL nodes, which is exactly why the algorithm must track a running "best seen so far" across the entire post-order traversal, not just return the root's own candidate.

---

## 4. Complexity Analysis

**All four traversals: O(n) time, O(h) space** (h = tree height, for the recursion call stack; O(n) for level-order's explicit queue, since a queue can hold an entire tree "level," which in the worst case — a very wide, shallow tree — can be O(n) wide).

**LCA (recursive, single query): O(n) time, O(h) space** — in the worst case, the recursive search must visit every node once (if the targets are deep in different branches, or the tree is a single long chain), and the recursion stack depth equals the tree's height.

**Tree Diameter: O(n) time, O(h) space** — a single post-order traversal, visiting every node exactly once, with O(1) work at each node (computing height and updating the running-best diameter) — this is why pairing "compute height" and "check diameter candidate" into a SINGLE traversal (rather than two separate passes) is the efficient approach; a naive "compute diameter separately at every node by re-traversing its subtrees" would cost O(n²).

**Why combining height-computation and diameter-checking into one pass matters:** if you computed each node's subtree height with a *separate* traversal call for every node (a natural but naive first attempt), you'd redundantly re-traverse the same subtrees over and over — O(n) work per node, times n nodes, giving O(n²) total. Returning the height as part of the same recursive call that also updates the diameter candidate avoids this entirely, collapsing back to a single O(n) pass — an important, broadly-applicable lesson: **whenever a tree recursion needs both "a value from below" and "a global answer," try to compute both in the same traversal rather than two separate ones.**

---

## 5. Advantages

- Traversals are simple, foundational building blocks reused throughout virtually every other tree algorithm (LCA and Diameter both build directly on post-order-style recursive thinking).
- LCA's recursive approach is elegant and handles the general case (not just BSTs) in one clean O(n) pass, correctly identifying the exact divergence point of two nodes' root-to-node paths.
- Tree Diameter demonstrates a broadly reusable pattern — combining a "bottom-up value" (height) with a "global running best" (diameter) in a single traversal — that generalizes to many other tree problems beyond diameter specifically.

## 6. Limitations

- The general LCA algorithm shown here is O(n) **per query** — for a workload with many repeated LCA queries on a *static* tree, preprocessing techniques (binary lifting, Euler tour + Sparse Table) can answer each query in O(log n) or even O(1) after O(n log n) preprocessing, at the cost of significantly more implementation complexity.
- BST-specific LCA can be solved more simply (and faster per query, O(h) rather than O(n)) by exploiting the BST ordering property directly — using the general tree algorithm on a BST specifically would be needlessly conservative.
- Tree Diameter's approach, while efficient, requires careful handling of the "global best" variable across the recursion (commonly via a reference parameter or a class member) — a common source of subtle bugs for learners unfamiliar with this pattern.

---

## 7. Real-World Applications

- **File Systems:** directory traversal (listing all files, computing total sizes) is a direct application of tree traversal (typically post-order, so a directory's size can be computed after all its contents are known).
- **Compilers:** Abstract Syntax Tree (AST) traversal for code generation (typically post-order, generating code for sub-expressions before the operations that combine them) and static analysis.
- **Organizational Charts / Hierarchies:** LCA directly answers "what's the lowest common manager of these two employees?" — a natural real-world framing of the exact algorithm.
- **Version Control:** finding the common ancestor commit of two branches (Git's merge-base computation) is conceptually an LCA problem over the commit history DAG (a generalization of tree LCA to DAGs).
- **Network Topology:** finding the point where two network paths converge (useful for routing/multicast tree construction) is an LCA-style computation.
- **Phylogenetics (Biology):** finding the most recent common ancestor species of two organisms in an evolutionary tree is a direct, literal application of the LCA algorithm.
- **UI/DOM Trees:** finding the common ancestor element of two DOM nodes (used internally by browsers for event bubbling/capturing logic) is an LCA computation.

---

## 8. C++ Implementation

```cpp
#include <iostream>
#include <vector>
#include <queue>
#include <algorithm>

struct TreeNode {
    int val;
    TreeNode* left;
    TreeNode* right;
    TreeNode(int v) : val(v), left(nullptr), right(nullptr) {}
};

// ---------- TRAVERSALS ----------

void preOrder(TreeNode* node, std::vector<int>& result) {
    if (!node) return;
    result.push_back(node->val);   // NODE first
    preOrder(node->left, result);
    preOrder(node->right, result);
}

void inOrder(TreeNode* node, std::vector<int>& result) {
    if (!node) return;
    inOrder(node->left, result);
    result.push_back(node->val);   // NODE in the middle
    inOrder(node->right, result);
}

void postOrder(TreeNode* node, std::vector<int>& result) {
    if (!node) return;
    postOrder(node->left, result);
    postOrder(node->right, result);
    result.push_back(node->val);   // NODE last
}

std::vector<int> levelOrder(TreeNode* root) {
    std::vector<int> result;
    if (!root) return result;
    std::queue<TreeNode*> q;
    q.push(root);
    while (!q.empty()) {
        TreeNode* curr = q.front(); q.pop();
        result.push_back(curr->val);
        if (curr->left) q.push(curr->left);
        if (curr->right) q.push(curr->right);
    }
    return result;
}

// ---------- LOWEST COMMON ANCESTOR ----------
// O(n) per query. Works for any binary tree (not just BST).
TreeNode* lowestCommonAncestor(TreeNode* node, TreeNode* p, TreeNode* q) {
    if (!node || node == p || node == q) return node;   // found one of the targets, or hit a dead end

    TreeNode* left = lowestCommonAncestor(node->left, p, q);
    TreeNode* right = lowestCommonAncestor(node->right, p, q);

    if (left && right) return node;   // found one target in EACH subtree — this node is the LCA
    return left ? left : right;         // otherwise, propagate whichever side found something (or nullptr)
}

// ---------- TREE DIAMETER ----------
// O(n). Combines height-computation and diameter-tracking into a single post-order pass.
int diameterHelper(TreeNode* node, int& diameter) {
    if (!node) return 0;

    int leftHeight = diameterHelper(node->left, diameter);
    int rightHeight = diameterHelper(node->right, diameter);

    diameter = std::max(diameter, leftHeight + rightHeight);   // update global best with THIS node's candidate

    return 1 + std::max(leftHeight, rightHeight);   // return height, for the PARENT's use
}

int treeDiameter(TreeNode* root) {
    int diameter = 0;
    diameterHelper(root, diameter);
    return diameter;
}

// Example usage
int main() {
    //        1
    //       / \
    //      2   3
    //     / \
    //    4   5
    TreeNode* root = new TreeNode(1);
    root->left = new TreeNode(2);
    root->right = new TreeNode(3);
    root->left->left = new TreeNode(4);
    root->left->right = new TreeNode(5);

    std::vector<int> pre, in, post;
    preOrder(root, pre); inOrder(root, in); postOrder(root, post);
    auto level = levelOrder(root);

    auto print = [](const std::string& label, const std::vector<int>& v) {
        std::cout << label << ": ";
        for (int x : v) std::cout << x << " ";
        std::cout << "\n";
    };
    print("Pre-order", pre);     // 1 2 4 5 3
    print("In-order", in);       // 4 2 5 1 3
    print("Post-order", post);   // 4 5 2 3 1
    print("Level-order", level); // 1 2 3 4 5

    TreeNode* lca = lowestCommonAncestor(root, root->left->left, root->left->right);
    std::cout << "LCA(4,5) = " << lca->val << "\n";   // 2

    // Add node 6 under 4 for the diameter example
    root->left->left->left = new TreeNode(6);
    std::cout << "Tree Diameter = " << treeDiameter(root) << "\n";   // 4

    return 0;
}
```

---

## 9. Code Walkthrough

- **The three DFS-based traversals (`preOrder`/`inOrder`/`postOrder`):** all three share an identical recursive skeleton — the ONLY difference is *where* `result.push_back(node->val)` appears relative to the two recursive calls. This makes the three traversal orders trivially easy to remember once you see them side by side: node-first, node-middle, node-last.
- **`levelOrder`'s queue-based approach:** Directly mirrors BFS on a graph (Data Structures guide, Ch. 11) — a tree is, after all, just a special (acyclic, single-parent) graph, so the same Queue-based level-by-level exploration applies unchanged.
- **`lowestCommonAncestor`'s base case `node == p || node == q`:** Returning the node itself the moment either target is found (rather than continuing to search deeper) is what correctly handles the case where one target is an ancestor of the other (e.g., LCA(2, 5) where 2 is 5's direct parent) — the function returns 2 immediately upon reaching it, without needing to separately search for 5 further down.
- **`lowestCommonAncestor`'s `if (left && right) return node;`:** This is the exact moment the algorithm identifies the LCA — finding one target on each side means the current node is precisely where the two targets' paths from the root diverge.
- **`diameterHelper`'s dual return/reference-parameter pattern:** The function `return`s the height (for the parent call to use in its OWN height computation), while separately updating `diameter` (passed by reference) as a global running best across the entire traversal — this dual-purpose design is exactly the "compute both a bottom-up value and a global answer in one pass" pattern flagged as broadly reusable in section 4.

**Common mistakes to watch for here:**
- Mixing up the three traversal orders' node-placement (a very easy slip when writing them quickly without care).
- In LCA, returning too early or too late relative to checking `node == p || node == q`, causing incorrect results when one target is an ancestor of the other.
- In Tree Diameter, forgetting that the diameter can be found at ANY node, not just the root — only checking the root's own left-height + right-height would miss diameters entirely contained within a subtree (as shown in section 3(c), where the true diameter passes through node 1, but a naive root-only check would have needed to correctly identify node 1 as involved — always compute and compare at every single node, not just the root).

---

## 10. Dry Run

**`treeDiameter` on the 6-node tree from section 3(c)**, matching that section's full trace exactly:

| Node | leftHeight | rightHeight | diameter candidate | height returned | Running max diameter |
|---|---|---|---|---|---|
| 6 | 0 | 0 | 0 | 1 | 0 |
| 4 | 1 (from 6) | 0 | 1 | 2 | 1 |
| 5 | 0 | 0 | 0 | 1 | 1 |
| 2 | 2 (from 4) | 1 (from 5) | 3 | 3 | 3 |
| 3 | 0 | 0 | 0 | 1 | 3 |
| 1 | 3 (from 2) | 1 (from 3) | 4 | 4 | **4** |

Final diameter = 4, confirmed matching section 3(c)'s manual derivation. ✓

---

## 11. Complexity Table

| Algorithm | Time | Space |
|---|---|---|
| Pre/In/Post-order Traversal | O(n) | O(h) recursion stack |
| Level-order Traversal | O(n) | O(n) worst case (wide tree, queue holds a full level) |
| LCA (general binary tree, single query) | O(n) | O(h) |
| LCA (BST-specific, single query) | O(h) | O(h) or O(1) iterative |
| Tree Diameter | O(n) | O(h) |

**Every entry explained:** All traversals and Tree Diameter visit every node exactly once, giving O(n) — the only variation is space, which depends on recursion depth (O(h)) versus the widest single level (O(n) for level-order in the worst case of a very wide, shallow tree). BST-specific LCA is faster (O(h) rather than O(n)) because the BST ordering property lets you immediately decide "go left or right" at each step, exactly like BST search, rather than needing to search both subtrees as the general algorithm does.

---

## 12. Common Mistakes

- **Confusing the three DFS traversal orders** — always double check where the "visit node" step falls relative to the two recursive calls.
- **Using the general O(n) LCA algorithm on a BST** when the much faster O(h) BST-specific version (exploiting the ordering property) would suffice — a missed optimization opportunity, not incorrect, but worth recognizing.
- **Computing Tree Diameter with a separate height-computation call at every node** (rather than combining height and diameter-tracking into one pass) — silently degrades from O(n) to O(n²).
- **Checking diameter only at the root** instead of at every node during the traversal — misses diameters that lie entirely within a subtree, not passing through the root.
- **Forgetting that a node can be its own ancestor** in the LCA definition — LCA(node, node's descendant) should correctly return `node` itself, not fail or search further.

---

## 13. Interview Questions

**Conceptual:**
1. Explain the difference between the three DFS traversal orders and give a real use case for each.
2. Why does LCA's recursive algorithm correctly identify the divergence point of two nodes' paths from the root?
3. Why must Tree Diameter's computation check every node, not just the root?
4. How would you speed up LCA for a static tree with many repeated queries?
5. How does BST-specific LCA differ from and improve upon the general binary tree LCA algorithm?

**Coding:**
1. Implement all four traversals (iterative versions too, using an explicit stack for pre/in/post-order).
2. Lowest Common Ancestor of a Binary Tree (LeetCode 236) and of a BST (LeetCode 235) — implement both, compare.
3. Diameter of Binary Tree (LeetCode 543).
4. Binary Tree Level Order Traversal (LeetCode 102) and its zigzag variant (LeetCode 103).
5. Serialize and Deserialize a Binary Tree (uses pre-order traversal as its core mechanism — connects back to the Data Structures guide's BST chapter).
6. Path Sum problems — natural extensions of the post-order "compute from children" pattern.

**Follow-ups / interviewer traps:**
- "Can you find LCA without extra space, for a very deep tree?" (tests awareness of iterative traversal techniques, or Morris-traversal-style O(1)-space approaches for advanced variants)
- "Your tree has parent pointers available — does that change your LCA approach?" (yes — with parent pointers, LCA can be solved similarly to the linked-list-intersection problem, walking both paths to the root and finding where they converge)
- "Diameter of Binary Tree — what if edge weights aren't uniform (weighted diameter)?" (tests generalizing the height-tracking pattern to weighted sums instead of simple edge counts)

---

## 14. Practice Problems

**Easy**
- Binary Tree Preorder/Inorder/Postorder Traversal (LeetCode 144/94/145)
- Binary Tree Level Order Traversal (LeetCode 102)
- Diameter of Binary Tree (LeetCode 543)

**Medium**
- Lowest Common Ancestor of a Binary Tree (LeetCode 236)
- Lowest Common Ancestor of a BST (LeetCode 235)
- Binary Tree Zigzag Level Order Traversal (LeetCode 103)
- Path Sum II (LeetCode 113)

**Hard**
- Binary Tree Maximum Path Sum (LeetCode 124) — a weighted generalization of the Diameter pattern
- Serialize and Deserialize Binary Tree (LeetCode 297)
- Vertical Order Traversal of a Binary Tree (LeetCode 987)

Also recommended: GeeksforGeeks "Tree Traversals" and "Lowest Common Ancestor" practice sets; implement iterative (non-recursive, explicit-stack) versions of all three DFS traversals as a valuable exercise in understanding what recursion is doing "under the hood."

---

## 15. Summary

**Key takeaways:**
- The three DFS traversal orders (pre/in/post) differ only in WHEN the current node is visited relative to its children — a simple distinction with significant downstream implications for which problems each order naturally solves.
- LCA's recursive elegance comes from recognizing that finding one target in each subtree of a node means that node IS the divergence point — the LCA.
- Tree Diameter demonstrates the powerful, broadly-reusable pattern of combining a "value needed by the parent" (height) with a "global running best" (diameter) in a single traversal pass, avoiding redundant re-traversal.

**Complexity recap:**

| | Time | Space |
|---|---|---|
| Traversals | O(n) | O(h) or O(n) for level-order |
| LCA (general) | O(n) | O(h) |
| Tree Diameter | O(n) | O(h) |

**Decision guide:** Use pre-order for copying/serializing a tree top-down; in-order specifically for BSTs when you need sorted output; post-order whenever a computation needs children's results before the parent's (deletion, height/diameter-style aggregation); level-order whenever you need breadth-first, level-by-level processing. Use the general LCA algorithm for arbitrary binary trees; switch to the faster BST-specific version when you know the tree is a BST. Recognize Tree-Diameter-shaped problems by their "combine a bottom-up value with a global best across all nodes" structure — this same shape recurs in many other tree problems beyond diameter itself.

---

*Next chapter: `16_string_algorithms.md` — completing the guide by connecting to and extending the Data Structures guide's String chapter (KMP, Z-Function, Rabin-Karp).*
