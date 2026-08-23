# Chapter 17: Advanced Dynamic Programming (Bitmask DP, DP on Trees)

*Study time: ~6-7 hours | Prerequisite: DP Fundamentals & Classic Problems (Ch. 12-13), Tree Algorithms (Ch. 15), bitwise operators | Difficulty: Advanced*

---

## 1. Introduction

**Definition:** This chapter extends Dynamic Programming's core idea — cache the answer to each distinct subproblem, solve each exactly once — to two more sophisticated **state representations**: **Bitmask DP**, where the DP state includes a bitmask encoding "which subset of items/vertices has been used so far," and **DP on Trees**, where the DP state is defined per tree node and combines information from that node's children (a direct generalization of Tree Diameter's "combine a bottom-up value with something" pattern from Chapter 15).

**Purpose:** Many real optimization problems can't be solved with the simple 1D or 2D DP states from Chapters 12-13 — they need to track "exactly which subset of elements have I already committed to" (Bitmask DP) or need an answer computed *for every node* of a hierarchical structure, incorporating each node's children's answers (DP on Trees). This chapter shows how the same core DP methodology — state, transition, base case — extends cleanly to both.

**Problem solved:** Optimization problems over small (typically n ≤ ~20) sets where the specific subset used matters (Traveling Salesman Problem, assignment problems) — Bitmask DP; and optimization/counting problems defined recursively over a tree's structure (maximum independent set in a tree, counting subtrees with a property) — DP on Trees.

---

## 2. Intuition

**Bitmask DP:** if you need to track "which specific subset of n items has been used" as part of your DP state (not just "how many," but *which ones*), and n is small (typically ≤ 20 or so), you can represent that subset as a single integer — bit `i` set to 1 means "item i is included." This integer becomes part of your DP state alongside whatever else you're tracking (e.g., `dp[mask][i]` = "best value achievable having used exactly the items in `mask`, currently positioned at item `i`"). The reason this works at all is that a bitmask is just a compact, O(1)-comparable, O(1)-updatable encoding of a subset — checking "is item j in this subset?" or "add item j to this subset" are both single bitwise operations.

**DP on Trees:** this is the direct generalization of Tree Diameter (Chapter 15) — instead of computing one global number (the diameter), you compute a DP value **at every node**, where that node's value depends on combining its children's already-computed DP values. The recursive structure "process children first (post-order), then combine their results to compute the current node's answer" is identical to Tree Diameter's height computation — DP on Trees is really "DP where the state graph happens to be a tree" rather than a fundamentally different technique.

---

## 3. Step-by-Step Working

### (a) Traveling Salesman Problem (TSP) via Bitmask DP — 4 cities

```
Distance matrix (4 cities, 0-indexed), start/end at city 0:
     0   1   2   3
0 [  0,  10, 15, 20]
1 [ 10,   0, 35, 25]
2 [ 15,  35,  0, 30]
3 [ 20,  25, 30,  0]

STATE: dp[mask][i] = minimum cost to have visited exactly the cities in `mask`,
                       currently standing at city i (having started at city 0).

BASE CASE: dp[{0}][0] = 0  (mask with only bit 0 set, standing at city 0, cost 0 — haven't moved yet)

TRANSITION: dp[mask][i] = min over all j in mask, j != i, where mask WITHOUT i
            was reachable ending at j:
            dp[mask][i] = min( dp[mask ^ (1<<i)][j] + dist[j][i] )  for all valid j

Building up (mask represented in binary, bit i = "city i visited"):

dp[0001][0] = 0   (just city 0)

dp[0011][1] = dp[0001][0] + dist[0][1] = 0+10 = 10   (visited {0,1}, at city 1)
dp[0101][2] = dp[0001][0] + dist[0][2] = 0+15 = 15   (visited {0,2}, at city 2)
dp[1001][3] = dp[0001][0] + dist[0][3] = 0+20 = 20   (visited {0,3}, at city 3)

dp[0111][2] = min( dp[0011][1]+dist[1][2] ) = 10+35 = 45   (visited {0,1,2}, at city 2, via 1)
dp[1011][3] = min( dp[0011][1]+dist[1][3] ) = 10+25 = 35   (visited {0,1,3}, at city 3, via 1)
dp[1101][3] = min( dp[0101][2]+dist[2][3] ) = 15+30 = 45   (visited {0,2,3}, at city 3, via 2)
dp[1101][1] = min( dp[1001][3]+dist[3][1] ) = 20+25 = 45   ... (continuing all valid combinations)

dp[1111][3] = min over ways to reach {0,1,2,3} ending at 3:
            = min( dp[0111][2]+dist[2][3], dp[1011][1]+dist[1][3], ... )
            = min( 45+30, ... ) = 75  (one candidate; full computation checks all predecessors)

FINAL ANSWER = min over all i of ( dp[1111][i] + dist[i][0] )   — return to start!
```

**Why this beats brute-force permutation checking:** brute force tries all (n-1)! orderings of the remaining cities — for n=4, that's 6, trivial, but for n=15 it's over 87 billion. Bitmask DP instead has `2ⁿ × n` states (mask × current city), each computed in O(n) — for n=15, that's `2^15 × 15 × 15 ≈ 7.4` million operations, dramatically more tractable.

### (b) Maximum Independent Set in a Tree — DP on Trees

```
Tree:        1
            / \
           2   3
          / \
         4   5

GOAL: select a subset of nodes such that no two selected nodes are directly
connected (an edge), maximizing the COUNT of selected nodes.

STATE (per node, two values): 
  dp[node][0] = max independent set size in this node's subtree, NODE NOT INCLUDED
  dp[node][1] = max independent set size in this node's subtree, NODE INCLUDED

TRANSITION (post-order — children computed first):
  dp[node][1] = 1 + sum( dp[child][0] for every child )    (if we include node, children CANNOT be included)
  dp[node][0] = sum( max(dp[child][0], dp[child][1]) for every child )   (if we exclude node, children are free to choose either)

Leaves first:
dp[4][0]=0, dp[4][1]=1   (leaf: including it gives 1, excluding gives 0)
dp[5][0]=0, dp[5][1]=1

Node 2 (children 4, 5):
dp[2][1] = 1 + dp[4][0] + dp[5][0] = 1+0+0 = 1
dp[2][0] = max(dp[4][0],dp[4][1]) + max(dp[5][0],dp[5][1]) = 1+1 = 2

Node 3 (leaf):
dp[3][0]=0, dp[3][1]=1

Node 1 (children 2, 3):
dp[1][1] = 1 + dp[2][0] + dp[3][0] = 1+2+0 = 3
dp[1][0] = max(dp[2][0],dp[2][1]) + max(dp[3][0],dp[3][1]) = max(2,1) + max(0,1) = 2+1 = 3

FINAL ANSWER = max(dp[1][0], dp[1][1]) = max(3,3) = 3
(e.g., select {4, 5, 3} — none of these three are directly connected — size 3)
```

---

## 4. Complexity Analysis

**Bitmask DP (TSP-style):** O(2ⁿ · n²) time — `2ⁿ` possible masks, `n` possible "current city" values per mask (so `2ⁿ·n` states total), and each state's transition checks up to `n` possible predecessors — giving `2ⁿ · n · n = O(2ⁿ · n²)`. Space: O(2ⁿ · n) for the DP table.

**Why this is a massive improvement over brute force's O(n!):** for even modest n (15-20), `2ⁿ·n²` is dramatically smaller than `n!` — this is the entire value proposition of recognizing a problem as Bitmask-DP-shaped rather than attempting brute-force permutation enumeration. That said, Bitmask DP's own exponential factor (`2ⁿ`) means it's only practical for **small n** (typically ≤ 20-22 given realistic time limits) — it doesn't escape exponential complexity entirely, it just has a much better exponential base/exponent combination than raw permutation enumeration.

**DP on Trees:** O(n) time — a single post-order traversal, computing O(1) (or O(number of children) for the summation) work at each node, summing to O(n) total across the whole tree, identical in spirit to Tree Diameter's O(n) complexity (Chapter 15) — the tree-shaped state space, visited exactly once via post-order, is what keeps this linear rather than exponential.

---

## 5. Advantages

- Bitmask DP makes previously-infeasible small-to-medium subset-optimization problems (TSP, assignment problems) tractable, extending DP's reach to state spaces that a simple 1D/2D array can't represent.
- DP on Trees directly reuses the post-order "combine children's results" pattern already familiar from Tree Diameter — no fundamentally new mental model needed, just a broader recognition of when a problem's natural recursive structure follows a tree.
- Both techniques demonstrate that "define the right state" (Chapter 12's central lesson) generalizes far beyond simple array-indexed states — a state can be a bitmask, a tree node, or in principle any efficiently-comparable/hashable representation of "what matters about where I am in the problem."

## 6. Limitations

- Bitmask DP's `O(2ⁿ)` factor makes it fundamentally impractical beyond roughly n=20-22 (2^22 ≈ 4 million masks, already substantial when multiplied by n and further transition costs) — it's a tool for *small* subset-sensitive problems, not a general-purpose optimization technique.
- DP on Trees requires the underlying problem to genuinely decompose along the tree structure (a node's answer depends only on its subtree, or can be correctly computed via a second pass for "answers depending on the rest of the tree too," a more advanced technique called re-rooting, beyond this chapter's scope).
- Both techniques require correctly identifying a genuinely more complex state than Chapters 12-13's simpler DP problems — a harder skill requiring more practice to internalize.

---

## 7. Real-World Applications

- **Bitmask DP:** the Traveling Salesman Problem itself has direct applications in logistics/delivery route optimization (for small numbers of stops), circuit board drilling path optimization (minimizing tool travel distance), and DNA fragment assembly (finding optimal orderings of small numbers of overlapping fragments).
- **Assignment Problems (also Bitmask-DP-solvable for small n):** assigning a small number of workers to tasks to minimize total cost, used in specialized small-scale resource allocation scenarios.
- **DP on Trees:** network design problems (e.g., minimum cost to cover a tree-structured network with monitoring stations), organizational optimization problems (maximum independent set in an org chart — e.g., "select employees such that no manager-report pair is both selected," directly relevant to certain incentive/survey-design problems), and phylogenetic tree analysis in bioinformatics.
- **Compilers:** register allocation and certain code-generation optimizations for expression trees use tree-structured DP.
- **Game Development:** skill-tree/tech-tree optimization (maximum value selectable subject to prerequisite/exclusivity constraints, when the tree is small) can use DP on Trees directly.

---

## 8. C++ Implementation

```cpp
#include <iostream>
#include <vector>
#include <climits>

// ---------- BITMASK DP: Traveling Salesman Problem ----------
// O(2^n * n^2) time, O(2^n * n) space.
int tsp(const std::vector<std::vector<int>>& dist) {
    int n = static_cast<int>(dist.size());
    int fullMask = (1 << n) - 1;

    // dp[mask][i] = min cost to visit exactly the cities in `mask`, currently at city i.
    std::vector<std::vector<int>> dp(1 << n, std::vector<int>(n, INT_MAX));
    dp[1][0] = 0;   // start: only city 0 visited, standing at city 0, cost 0

    for (int mask = 1; mask <= fullMask; ++mask) {
        for (int i = 0; i < n; ++i) {
            if (!(mask & (1 << i)) || dp[mask][i] == INT_MAX) continue;   // city i not in mask, or unreachable

            for (int j = 0; j < n; ++j) {
                if (mask & (1 << j)) continue;   // j already visited — can't revisit

                int newMask = mask | (1 << j);
                int newCost = dp[mask][i] + dist[i][j];
                if (newCost < dp[newMask][j]) {
                    dp[newMask][j] = newCost;   // found a cheaper way to reach (newMask, j)
                }
            }
        }
    }

    // Return to the starting city (0) from wherever the tour ended, minimizing over all endpoints.
    int best = INT_MAX;
    for (int i = 1; i < n; ++i) {
        if (dp[fullMask][i] != INT_MAX) {
            best = std::min(best, dp[fullMask][i] + dist[i][0]);
        }
    }
    return best;
}

// ---------- DP ON TREES: Maximum Independent Set ----------
struct TreeNode {
    int id;
    std::vector<TreeNode*> children;
};

// Returns {excluded, included} best sizes for the subtree rooted at `node`. O(n) overall.
std::pair<int,int> maxIndependentSetHelper(TreeNode* node) {
    int excludedSum = 0, includedSum = 1;   // includedSum starts at 1 for THIS node being included

    for (TreeNode* child : node->children) {
        auto [childExcluded, childIncluded] = maxIndependentSetHelper(child);
        excludedSum += std::max(childExcluded, childIncluded);   // excluding this node: children are free to choose
        includedSum += childExcluded;                              // including this node: children MUST be excluded
    }
    return {excludedSum, includedSum};
}

int maxIndependentSet(TreeNode* root) {
    auto [excluded, included] = maxIndependentSetHelper(root);
    return std::max(excluded, included);
}

// Example usage
int main() {
    std::vector<std::vector<int>> dist = {
        {0, 10, 15, 20},
        {10, 0, 35, 25},
        {15, 35, 0, 30},
        {20, 25, 30, 0}
    };
    std::cout << "TSP minimum tour cost: " << tsp(dist) << "\n";   // 80 (0->1->3->2->0)

    // Build the tree: 1 -> (2 -> (4, 5)), (3)
    TreeNode n4{4, {}}, n5{5, {}}, n3{3, {}};
    TreeNode n2{2, {&n4, &n5}};
    TreeNode n1{1, {&n2, &n3}};
    std::cout << "Max Independent Set size: " << maxIndependentSet(&n1) << "\n";   // 3

    return 0;
}
```

---

## 9. Code Walkthrough

- **`tsp`'s `dp[mask][i]` table:** Exactly the state described in section 3(a) — `mask` (an integer up to `2ⁿ-1`) encodes exactly which cities have been visited, and `i` tracks the current position. The double nested loop (`mask`, then `i`, then `j`) tries extending every reachable `(mask, i)` state by visiting every not-yet-visited city `j`, updating `dp[newMask][j]` if this route is cheaper than any previously found.
- **`mask & (1 << i)` and `mask | (1 << i)`:** These are the two fundamental bitmask operations this entire technique relies on — `&` checks membership ("is city i in this subset?"), `|` adds membership ("mark city i as now visited"). Both are O(1), which is exactly what makes representing a subset as an integer so efficient compared to, say, a `std::set<int>`.
- **The final loop returning to city 0:** TSP requires a complete *cycle* (return to the start), so after finding the cheapest way to visit all cities ending at each possible city `i`, we add the direct return-trip cost `dist[i][0]` and take the minimum across all such completions.
- **`maxIndependentSetHelper`'s structured binding return `{excluded, included}`:** Directly mirrors Tree Diameter's dual-purpose recursive return (Chapter 15) — this function returns TWO values needed by the parent's own computation, rather than a single aggregate, because the parent needs to know both "what's the best subtree answer if I DON'T include myself" and "...if I DO include myself" to correctly compute its own two values in turn.
- **`includedSum += childExcluded` (not `childIncluded`)**: This is the entire independent-set constraint encoded in one line — if the current node IS included, none of its direct children can also be included (that would create a forbidden adjacent pair), so we're forced to add each child's `excluded` value specifically, never its `included` value.

**Common mistakes to watch for here:**
- Off-by-one or incorrect bit-shift arithmetic when checking/setting mask bits — always double-check `1 << i` vs `1 << (i-1)` conventions match your indexing scheme consistently.
- In Bitmask DP, forgetting to skip already-visited cities (`if (mask & (1<<j)) continue;`) when considering transitions, which would allow revisiting a city — invalid for TSP.
- In DP on Trees, using `childIncluded` instead of `childExcluded` when computing `includedSum` — this single swap breaks the core independent-set constraint entirely, silently allowing adjacent selected nodes.
- Not initializing unreachable `dp[mask][i]` states to a proper "infinity" sentinel, risking incorrect `min` comparisons.

---

## 10. Dry Run

**`maxIndependentSet`, fully traced in section 3(b)** — leaves 4 and 5 each contribute `(excluded=0, included=1)`; node 2 combines them into `(excluded=2, included=1)`; node 3 (leaf) is `(excluded=0, included=1)`; node 1 combines node 2 and node 3 into `(excluded=3, included=3)`; final answer `max(3,3)=3`. This matches the code's expected output exactly, confirming the recursive combination logic.

---

## 11. Complexity Table

| Technique | Time | Space | Practical limit |
|---|---|---|---|
| Bitmask DP (TSP-style) | O(2ⁿ · n²) | O(2ⁿ · n) | n ≲ 20-22 |
| DP on Trees | O(n) | O(h) recursion stack | No practical limit beyond tree size/recursion depth |

**Every entry explained:** Bitmask DP's exponential factor is unavoidable for exact TSP-style solutions (TSP itself is NP-hard; Bitmask DP is a genuine improvement over brute-force permutations, but doesn't escape exponential complexity, only a better exponential base) — this caps its practical applicability to small n. DP on Trees, by contrast, is genuinely linear, since the tree structure itself (visited once via post-order) bounds total work, with no combinatorial explosion analogous to Bitmask DP's subset-tracking.

---

## 12. Common Mistakes

- **Attempting Bitmask DP on problems with n much larger than ~20** — the exponential blowup makes this simply infeasible; recognize this limit before committing to the approach.
- **Bitwise operator precedence errors** — `mask & 1 << i` without parentheses can silently misbehave due to operator precedence; always parenthesize bitwise operations explicitly (`mask & (1 << i)`).
- **Confusing which child value to use in DP on Trees' inclusion/exclusion transitions** — always re-derive the constraint from scratch (what does including THIS node force about its children?) rather than pattern-matching from memory.
- **Not handling the tree's root correctly** — DP on Trees' final answer typically needs `max(dp[root][0], dp[root][1])` or similar, since the root has no parent constraining it either way.
- **Forgetting that Bitmask DP's mask must be initialized/interpreted consistently** (bit i = city/item i) across the entire implementation — inconsistent conventions between different parts of the code are a common source of confusion.

---

## 13. Interview Questions

**Conceptual:**
1. Why does Bitmask DP improve on brute-force permutation enumeration for TSP, despite still being exponential?
2. What's the practical size limit for Bitmask DP, and why?
3. Explain how DP on Trees' state design directly generalizes Tree Diameter's approach from Chapter 15.
4. Why does including a node in a Maximum Independent Set force its children to be excluded, and how is this encoded in the DP transition?
5. When would you recognize a problem as "Bitmask-DP-shaped" versus a simpler 1D/2D DP?

**Coding:**
1. Implement TSP via Bitmask DP, including path reconstruction (not just the minimum cost).
2. Partition to K Equal Sum Subsets (LeetCode 698) — a Bitmask DP application.
3. Maximum Independent Set in a Tree (as implemented above).
4. House Robber III (LeetCode 337) — Maximum Independent Set applied to a binary tree specifically.
5. Shortest Hamiltonian Path (a TSP variant without the return-to-start requirement).

**Follow-ups / interviewer traps:**
- "Your Bitmask DP works for n=15 — what about n=25?" (tests recognizing the fundamental exponential limit and knowing to pivot to an approximation algorithm or heuristic instead of forcing an infeasible exact approach)
- "Can DP on Trees handle a node's answer depending on information from OUTSIDE its own subtree (e.g., the rest of the tree)?" (tests awareness of re-rooting techniques, an advanced extension beyond this chapter's basic treatment)
- "House Robber III — how does this map exactly onto Maximum Independent Set?" (tests recognizing that "houses form a binary tree, can't rob two directly connected houses" is a verbatim restatement of the Maximum Independent Set problem)

---

## 14. Practice Problems

**Medium**
- House Robber III (LeetCode 337)
- Partition to K Equal Sum Subsets (LeetCode 698)

**Hard**
- Traveling Salesman Problem (GeeksforGeeks classic; also appears in various forms across competitive programming judges)
- Shortest Path Visiting All Nodes (LeetCode 847) — Bitmask DP applied to a graph traversal
- Maximum Students Taking Exam (LeetCode 1349) — Bitmask DP over grid rows
- Binary Tree Cameras (LeetCode 968) — a DP-on-Trees variant with a three-state transition

Also recommended: GeeksforGeeks "Bitmasking and Dynamic Programming" and "DP on Trees" practice sets; implement TSP for n up to 15-18 and observe the practical runtime scaling firsthand.

---

## 15. Summary

**Key takeaways:**
- Bitmask DP extends DP's state to include "exactly which subset has been used," valid and efficient specifically for small n (≤ ~20-22) where 2ⁿ is computationally manageable.
- DP on Trees is not a fundamentally new technique — it's DP Fundamentals' state-transition-base-case methodology applied where the natural recursive structure happens to be a tree, directly generalizing Tree Diameter's post-order "combine children's results" pattern.
- Both techniques reinforce this guide's central DP lesson from Chapter 12: correctly identifying the STATE is everything — a state can be an array index, a bitmask, or a tree node, as long as it's a well-defined, efficiently comparable representation of "what matters right now."

**Complexity recap:**

| | Time | Practical limit |
|---|---|---|
| Bitmask DP | O(2ⁿ · poly(n)) | n ≲ 20-22 |
| DP on Trees | O(n) | Tree size / recursion depth |

**Decision guide:** Reach for Bitmask DP when a problem's state genuinely needs to track "which specific subset" (not just a count) AND the relevant set size is small (≤20ish). Reach for DP on Trees whenever a problem's natural structure is hierarchical and each node's optimal answer depends on combining its children's optimal answers — recognize this by asking "does this problem's recursive structure decompose along parent-child relationships?"

---

*Next chapter: `18_advanced_techniques.md` — Meet in the Middle and Heavy-Light Decomposition (overview).*
