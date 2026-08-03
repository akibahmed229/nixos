# Chapter 16: Disjoint Set Union (Union-Find)

*Study time: ~5-6 hours | Prerequisite: Arrays, basic amortized analysis | Difficulty: Intermediate-Advanced*

---

## 1. Introduction

**Definition:** A Disjoint Set Union (DSU), also called Union-Find, is a data structure that maintains a collection of disjoint (non-overlapping) sets and supports two core operations extremely efficiently: **Find** (which set does element X belong to?) and **Union** (merge the sets containing X and Y).

**Purpose:** To answer "are these two elements connected/in the same group?" and to merge groups together, both in near-constant amortized time — dramatically faster than re-running a full graph traversal (BFS/DFS) every time connectivity needs checking.

**Real-world analogy:** Think of merging companies. Each company has a CEO (the "representative" of that set). When two companies merge, one CEO becomes the overall boss, and everyone can trace up their reporting chain to find out who their ultimate boss is now. "Are Alice and Bob in the same company?" is answered by tracing both up to their ultimate boss and checking if it's the same person — you don't need to know every intermediate connection, just who's at the top.

**Motivation:** Graph connectivity questions ("are u and v connected?", "does adding this edge create a cycle?") could be answered by re-running BFS/DFS each time — O(V+E) per query. When you need to answer *many* such queries as a graph evolves (edges added incrementally), DSU answers each one in near O(1) amortized instead, after some efficient bookkeeping.

**History:** The core idea dates to the 1960s; the two critical optimizations — **union by rank** and **path compression** — were analyzed and popularized in the 1970s-80s, with the resulting near-O(1) amortized bound (formally O(α(n)), where α is the inverse Ackermann function) proven by Tarjan.

---

## 2. Why Do We Need It?

**Problem it solves:** Efficiently tracking and merging groups of connected elements, and answering "are these two in the same group?" repeatedly, as connections are added over time.

**Why previous structures are insufficient:**
- **Re-running BFS/DFS per query:** correct, but O(V+E) *every single time* — far too slow if you need to answer many connectivity queries, especially as edges keep being added.
- **Hash Map tracking group IDs directly:** naive approaches (relabeling every member of a merged group) cost O(size of group) per union — can degrade to O(n) per merge in the worst case if done carelessly.

**Trade-offs:**
- You gain near-O(1) amortized Find and Union — a massive improvement enabling algorithms like Kruskal's MST (Chapter 11) to work efficiently.
- You pay for it with a structure that only answers "same group?" — it cannot enumerate a group's members efficiently, tell you the *path* between two connected elements, or handle *disconnection* (removing an edge/splitting a group) at all; DSU is fundamentally a "merge-only" structure.

---

## 3. Internal Working

**Representation:** an array `parent[]`, where `parent[i]` points to `i`'s parent in an implicit tree; a root points to itself (`parent[root] == root`).

**Initial state** (5 elements, all separate):
```
parent = [0, 1, 2, 3, 4]   (everyone is their own root — 5 separate sets)
```

**Union(0, 1):** make one root point to the other:
```
parent = [1, 1, 2, 3, 4]   (0's root is now 1; set {0,1} formed)
```

**Union(2, 3):**
```
parent = [1, 1, 3, 3, 4]   (set {2,3} formed)
```

**Find(0):** follow parent pointers until reaching a self-pointing root: `0 → 1` (1 points to itself) → root is 1.

**Without optimization**, repeated unions can create long chains (a "linked-list" worst case), making `Find` degrade to O(n):
```
parent = [1, 2, 3, 4, 4]   (0→1→2→3→4, a long chain — Find(0) takes 4 steps)
```

**Optimization 1 — Path Compression:** during `Find`, make every node on the path point *directly* to the root, flattening the tree for all future queries:
```
Before Find(0): 0→1→2→3→4
After Find(0) with path compression: 0→4, 1→4, 2→4, 3→4  (all flattened directly to root)
```

**Optimization 2 — Union by Rank (or Size):** when merging two sets, always attach the *smaller* tree's root under the *larger* tree's root — this prevents chains from forming in the first place, keeping trees shallow.

```
Union by rank example: merging a tree of rank 3 with a tree of rank 1 →
attach the rank-1 tree's root under the rank-3 tree's root (not the other way around),
since attaching the bigger tree under the smaller one would needlessly increase overall height.
```

**Together**, path compression + union by rank give the famous near-O(1) amortized bound — proven to be O(α(n)), where α (inverse Ackermann function) grows so slowly that it's less than 5 for any n you could ever practically encounter, making it "effectively constant" in every real-world sense.

---

## 4. Operations

**MakeSet(x):**
- Initialize x as its own set: `parent[x] = x`, `rank[x] = 0`.
- O(1).

**Find(x):**
- Follow `parent` pointers until reaching a node that is its own parent (the root).
- **With path compression:** as the recursion unwinds, set every visited node's parent directly to the root — flattening future lookups.
- Amortized O(α(n)) ≈ O(1) with both optimizations; O(log n) with only union-by-rank; O(n) worst case with neither.

**Union(x, y):**
- Find the roots of x and y. If they're already the same root, they're already in the same set — do nothing (this check is also how you detect "would this edge create a cycle" in Kruskal's algorithm).
- Otherwise, attach the smaller-rank root under the larger-rank root (union by rank); if ranks are equal, attach either one and increment the resulting root's rank by 1.
- Amortized O(α(n)) ≈ O(1) with both optimizations.

**Connected(x, y):**
- Simply `Find(x) == Find(y)`. Same complexity as Find.

**What DSU cannot do:** split a set apart (undo a union), efficiently enumerate all members of a given set (would require a separate auxiliary structure), or answer "what is the path between x and y" (only "are they connected," not "how").

---

## 5. Time & Space Complexity

| Operation | With Path Compression + Union by Rank | With Only One Optimization | With Neither | Space |
|---|---|---|---|---|
| Find | O(α(n)) ≈ O(1) amortized | O(log n) | O(n) worst case | O(n) |
| Union | O(α(n)) ≈ O(1) amortized | O(log n) | O(n) worst case | O(1) extra |
| n operations total | O(n·α(n)) ≈ O(n) | O(n log n) | O(n²) worst case | O(n) |

**Why these hold:**
- Without any optimization, repeated unions can form a degenerate chain (as shown in section 3), making `Find` O(n) in the worst case — no better than a plain linked list traversal.
- **Union by rank alone** guarantees tree height stays O(log n), since attaching the smaller tree under the larger one means a tree's height can only increase when merging with an *equal-or-larger* tree, which (by an argument similar to the dynamic array's amortized doubling) can only happen O(log n) times before a tree's size exceeds n.
- **Path compression alone** also provides a strong amortized bound (O(log n) amortized) by flattening paths as they're traversed — repeated `Find` calls on the same elements get progressively cheaper.
- **Combined**, the two optimizations interact synergistically, producing the famous O(α(n)) bound (Tarjan's result) — practically indistinguishable from O(1) for any n that will ever be encountered in practice (α(n) ≤ 4 for n up to numbers vastly larger than the number of atoms in the observable universe).

---

## 6. Advantages

- Near-O(1) amortized Find/Union — among the fastest possible structures for the specific "track and merge groups" problem.
- Extremely simple to implement (a single array, two short functions) relative to its algorithmic power.
- Essential building block for several classic graph algorithms (Kruskal's MST, cycle detection in undirected graphs, connected components tracking).

## 7. Disadvantages

- Cannot undo a union (no efficient "split" operation) — fundamentally a merge-only structure.
- Cannot enumerate a set's members efficiently without an auxiliary structure (e.g., a separate list per root, maintained alongside).
- Doesn't store or reveal *why* two elements are connected (no path information) — only *whether* they are.
- The near-O(1) bound requires *both* optimizations to be implemented correctly; naive implementations can silently degrade to much worse performance.

---

## 8. Real-World Applications

- **Kruskal's MST algorithm** (Chapter 11): DSU is the mechanism for efficiently checking "would adding this edge create a cycle?"
- **Network Connectivity:** Determining if two computers/nodes are on the same network segment, as connections are added incrementally.
- **Image Processing:** Connected-component labeling (grouping adjacent pixels of the same color/region) can be implemented efficiently with DSU.
- **Social Networks:** "Are these two people in the same friend group/community?" as friendships (edges) are added over time.
- **Percolation Theory / Physics Simulations:** Modeling whether a fluid can "percolate" through a randomly-connected grid — a classic DSU application in computational physics.
- **Compiler Design:** Some register-allocation and variable-aliasing analyses use union-find-like structures to track equivalence classes.
- **Games:** Puzzle games involving connected regions (e.g., minesweeper-style flood detection, some maze-generation algorithms like Kruskal's-based random maze generation).

---

## 9. Implementation (C++17)

```cpp
#include <iostream>
#include <vector>
#include <numeric>

class DisjointSetUnion {
private:
    std::vector<int> parent;
    std::vector<int> rank_;   // "rank_" to avoid shadowing std::rank
    int numSets;               // tracks how many distinct sets currently exist

public:
    DisjointSetUnion(int n) : parent(n), rank_(n, 0), numSets(n) {
        std::iota(parent.begin(), parent.end(), 0);   // parent[i] = i initially
    }

    // Find with PATH COMPRESSION. Amortized O(alpha(n)).
    int find(int x) {
        if (parent[x] != x) {
            parent[x] = find(parent[x]);   // recursively find the root, then attach x DIRECTLY to it
        }
        return parent[x];
    }

    // Union with UNION BY RANK. Amortized O(alpha(n)). Returns false if x,y already connected.
    bool unite(int x, int y) {
        int rootX = find(x);
        int rootY = find(y);

        if (rootX == rootY) return false;   // already in the same set — union would be a no-op (or "creates a cycle" in MST context)

        // Attach the smaller-rank tree under the larger-rank tree's root.
        if (rank_[rootX] < rank_[rootY]) {
            parent[rootX] = rootY;
        } else if (rank_[rootX] > rank_[rootY]) {
            parent[rootY] = rootX;
        } else {
            parent[rootY] = rootX;   // equal ranks: pick either as new root
            rank_[rootX]++;          // and increment the resulting root's rank
        }
        numSets--;
        return true;
    }

    bool connected(int x, int y) {
        return find(x) == find(y);
    }

    int countSets() const { return numSets; }
};

// Example usage
int main() {
    DisjointSetUnion dsu(6);   // elements 0..5, initially 6 separate sets

    dsu.unite(0, 1);
    dsu.unite(1, 2);
    dsu.unite(3, 4);

    std::cout << "connected(0,2)? " << dsu.connected(0, 2) << "\n";   // 1 (true) — 0-1-2 merged
    std::cout << "connected(0,3)? " << dsu.connected(0, 3) << "\n";   // 0 (false) — different groups
    std::cout << "Number of sets: " << dsu.countSets() << "\n";        // 3: {0,1,2}, {3,4}, {5}

    dsu.unite(2, 3);   // merges {0,1,2} and {3,4} into one group
    std::cout << "connected(0,4)? " << dsu.connected(0, 4) << "\n";    // 1 (true) now
    std::cout << "Number of sets: " << dsu.countSets() << "\n";         // 2: {0,1,2,3,4}, {5}

    return 0;
}
```

---

## 10. Code Walkthrough

- **`parent` initialized via `std::iota`:** every element starts as its own root — n separate singleton sets, matching the "everyone is their own boss" starting state from section 3.
- **`find`'s recursive path compression:** `parent[x] = find(parent[x])` first recursively finds the true root, *then* reassigns `x`'s parent directly to that root as the recursion unwinds — this is what flattens the tree over successive calls. The very next `find(x)` call will take O(1) — a direct hop.
- **`unite`'s rank comparison:** The three-way branch (`<`, `>`, `==`) implements union-by-rank exactly as described in section 3 — the smaller-rank tree always attaches under the larger, and rank only increases when two *equal*-rank trees merge (this specific condition is what keeps the O(log n) bound tight even without path compression).
- **`rootX == rootY` early return:** This single check is doing double duty — in a general DSU context it means "no-op, already connected"; in Kruskal's MST context (Chapter 11), this exact same check is what identifies "this edge would create a cycle, skip it."
- **`numSets` bookkeeping:** Decremented only on a *successful* merge (not a no-op union) — this lets `countSets()` answer "how many connected components exist" in O(1), a common and useful auxiliary capability.

**Common mistakes to watch for here:**
- Forgetting path compression (`parent[x] = find(parent[x])` instead of just `return find(parent[x])` without reassignment) — the *return* is easy to get right, but forgetting the *reassignment* silently loses all the flattening benefit.
- Always attaching by a fixed convention (e.g., "smaller index always becomes the new root") instead of by rank/size — this can recreate long chains and lose the balance guarantee.
- Not checking `rootX == rootY` before merging — attempting to "union" two elements already in the same set should be a safe no-op, not cause incorrect rank bookkeeping.

---

## 11. Dry Run

**6 elements. Operations:** `unite(0,1)`, `unite(1,2)`, `unite(3,4)`, `find(0)`, `unite(2,3)`

| Step | Action | parent[] | rank_[] | Notes |
|---|---|---|---|---|
| init | — | [0,1,2,3,4,5] | [0,0,0,0,0,0] | 6 separate sets |
| unite(0,1) | find(0)=0, find(1)=1, ranks equal | [1,1,2,3,4,5] | [0,1,0,0,0,0] | 1 becomes root, rank[1]++ |
| unite(1,2) | find(1)=1 (rank1), find(2)=2(rank0) → 2 attaches under 1 | [1,1,1,3,4,5] | [0,1,0,0,0,0] | rank[1] stays 1 (merging with a STRICTLY smaller rank doesn't increment) |
| unite(3,4) | find(3)=3, find(4)=4, ranks equal | [1,1,1,4,4,5] | [0,1,0,0,1,0] | 4 becomes root, rank[4]++ |
| find(0) | 0→1 (root, since parent[1]=1) → path compression sets parent[0]=1 directly (already direct here, minimal effect this time) | [1,1,1,4,4,5] | unchanged | root = 1 |
| unite(2,3) | find(2)=1 (rank1), find(3)=4(rank1) → ranks EQUAL → 4 attaches under 1, rank[1]++ | [1,1,1,4,1,5] | [0,2,0,0,1,0] | now {0,1,2,3,4} all connected, root=1 |

Final: `connected(0,4)` → find(0)=1, find(4): parent[4]=1 → root 1. Match! True. ✓

---

## 12. Interview Questions

**Conceptual:**
1. Explain path compression and union by rank — why does combining both give a near-O(1) bound?
2. Why can't DSU efficiently "undo" a union (split a set back apart)?
3. How does DSU detect a cycle when building an MST with Kruskal's algorithm?
4. What is the inverse Ackermann function, and why is O(α(n)) considered "effectively constant"?
5. Compare using DSU vs. running BFS/DFS repeatedly for connectivity queries on a graph with incrementally added edges.

**Coding:**
1. Number of Provinces / Number of Connected Components in an Undirected Graph.
2. Redundant Connection — find the edge that creates a cycle.
3. Accounts Merge — group accounts by shared emails using DSU.
4. Number of Islands II — dynamic connectivity as land is added over time.
5. Implement Kruskal's MST using your own DSU (ties back to Chapter 11).

**Follow-ups / interviewer traps:**
- "What if you need to support removing an edge/disconnecting elements — does DSU still work?" (no — DSU fundamentally doesn't support efficient splitting; a different structure or a full graph rebuild would be needed)
- "Can you track the SIZE of each set efficiently, not just connectivity?" (yes — maintain a size array alongside, updated during union, very similar to rank)
- "Why not just always attach by array index instead of rank?" (tests whether they understand this can recreate long chains, losing the balance guarantee entirely)

---

## 13. Practice Problems

**Easy**
- Number of Provinces (LeetCode 547)
- Find if Path Exists in Graph (LeetCode 1971)

**Medium**
- Redundant Connection (LeetCode 684)
- Accounts Merge (LeetCode 721)
- Number of Operations to Make Network Connected (LeetCode 1319)
- Graph Valid Tree (LeetCode 261)

**Hard**
- Number of Islands II (LeetCode 305)
- Regions Cut By Slashes (LeetCode 959)
- Minimize Malware Spread (LeetCode 924)

Also recommended: GeeksforGeeks "Union-Find/Disjoint Set" practice set, Codeforces problems tagged `dsu` (1300-1800 rating range).

---

## 14. Common Mistakes

- **Forgetting path compression** — a functionally correct but performance-degraded DSU.
- **Attaching roots by a fixed rule (always attach b under a) instead of by rank/size** — can silently recreate chains and lose the balance guarantee.
- **Not checking for "already connected" before merging** in cycle-detection contexts — this check IS the cycle detector; skipping it breaks Kruskal's MST correctness.
- **Confusing rank with actual tree size** — rank is an upper-bound approximation of height, not a literal count of elements (a "union by size" variant exists too, tracking actual element counts, and is equally valid).
- **Assuming DSU can answer "what is the connecting path"** — it can only answer "are they connected," never "how."

---

## 15. Summary

**Key takeaways:**
- DSU tracks disjoint groups and merges them, with `Find` and `Union` both running in near-O(1) amortized time when combining path compression and union by rank.
- The `rootX == rootY` check in `Union` is doing double duty as both "no-op detection" and — in graph algorithms — "cycle detection."
- DSU is a merge-only structure: no splitting, no path/route information, no efficient member enumeration without extra bookkeeping.
- It's the essential engine behind Kruskal's MST and any "track connectivity as edges are added incrementally" problem.

**Complexity recap:**

| Operation | Time (with both optimizations) |
|---|---|
| Find | O(α(n)) ≈ O(1) amortized |
| Union | O(α(n)) ≈ O(1) amortized |
| Connected | O(α(n)) ≈ O(1) amortized |

**Decision guideline:** Reach for DSU whenever you need to repeatedly answer "are these connected?" or merge groups as a graph/relation grows incrementally — especially for cycle detection (Kruskal's) and connected-component tracking. If you need to *remove* connections or trace the actual path between elements, DSU is the wrong tool — use a different graph representation with BFS/DFS instead.

---

*Next chapter: `17_skip_list.md`* (or say the word for Bloom Filter / the LRU Cache capstone instead)
