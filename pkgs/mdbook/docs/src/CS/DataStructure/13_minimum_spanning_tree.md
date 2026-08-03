# Chapter 12: Minimum Spanning Tree (Kruskal's & Prim's)

*Study time: ~6-7 hours | Prerequisite: Graphs, Heap, basic Union-Find concept (introduced here, detailed fully in the DSU chapter) | Difficulty: Intermediate-Advanced*

---

## 1. Introduction

**Definition:** A **Spanning Tree** of a connected, undirected graph is a subset of its edges that connects all vertices with no cycles (exactly V-1 edges for V vertices). A **Minimum Spanning Tree (MST)** is the spanning tree whose total edge weight is as small as possible.

**Purpose:** To find the cheapest way to connect every vertex in a weighted graph — the minimum total cost network that still reaches everywhere.

**Real-world analogy:** A telecom company wants to lay fiber-optic cable connecting every city in a region, minimizing total cable length, while still being able to reach every city (directly or through other cities). An MST is exactly this — the cheapest possible fully-connected network, with no redundant/wasteful extra connections (a cycle would mean you've spent money on a redundant path).

**Motivation:** Given a network with costs on every possible connection, connecting *everything to everything* is wasteful. We want minimum total cost while preserving full connectivity — this is the MST problem, and it comes up any time "connect everything as cheaply as possible" is the goal.

**History:** Kruskal's algorithm was published in 1956; Prim's was independently discovered by Jarník in 1930 and rediscovered by Prim in 1957 — both remain the standard MST algorithms taught today, over 60 years later.

---

## 2. Why Do We Need It?

**Problem it solves:** Minimizing total connection cost while guaranteeing full connectivity, with no wasted (redundant/cyclic) edges.

**Why simpler approaches fail:** Trying every possible subset of edges to find the cheapest connected one is exponential (2^E possibilities) — completely infeasible for any real-sized graph. MST algorithms exploit a key mathematical property (the "cut property" — the cheapest edge crossing any partition of vertices is always safe to include) to build the answer greedily in polynomial time.

**Trade-offs:**
- You gain a provably optimal (minimum total weight) connected structure, computed efficiently — O(E log V) or better.
- The requirement is that the graph must be connected to start with (an MST of a disconnected graph doesn't exist in the traditional sense — you'd get a "minimum spanning forest" instead, one tree per connected component).

---

## 3. Internal Working

**Example weighted graph:**
```
        A
     4/   \2
     B     C
    3|  1/  \5
     D-----E
```
Edges: A-B(4), A-C(2), B-D(3), C-D(1), C-E(5), D-E(... let's just say D-E isn't directly connected here for simplicity, keep it as above)

**Kruskal's Algorithm — "sort all edges, greedily add the cheapest that doesn't create a cycle":**
1. Sort all edges by weight: C-D(1), A-C(2), B-D(3), A-B(4), C-E(5).
2. Add C-D(1) — connects C and D, no cycle. MST so far: {C-D}.
3. Add A-C(2) — connects A to the {C,D} group, no cycle. MST so far: {C-D, A-C}.
4. Add B-D(3) — connects B to the {A,C,D} group, no cycle. MST so far: {C-D, A-C, B-D}.
5. Consider A-B(4) — but A and B are *already* connected (both in the same group via C-D and A-C and B-D) → adding this would create a cycle → **skip**.
6. Add C-E(5) — connects E to the group, no cycle. MST so far: {C-D, A-C, B-D, C-E}.
7. Done — 4 edges connect all 5 vertices (V-1 = 4 ✓).

**Total weight: 1+2+3+5 = 11.**

The "no cycle" check is exactly what **Disjoint Set Union (Union-Find)** is built for — each vertex starts in its own set; adding an edge merges two sets; if an edge's two endpoints are *already* in the same set, adding it would create a cycle, so it's skipped. (Full DSU implementation details are in the Advanced Structures chapter — here, we use it as a tool.)

**Prim's Algorithm — "grow one tree from a starting vertex, always adding the cheapest edge that extends the tree":**
1. Start at A. Tree = {A}. Available edges from the tree: A-B(4), A-C(2).
2. Add the cheapest: A-C(2). Tree = {A, C}. Available edges: A-B(4), C-D(1), C-E(5).
3. Add the cheapest: C-D(1). Tree = {A, C, D}. Available edges: A-B(4), C-E(5), D-B(3).
4. Add the cheapest: D-B(3). Tree = {A, C, D, B}. Available edges: A-B(4, but both endpoints already in tree — discard), C-E(5).
5. Add C-E(5). Tree = {A, C, D, B, E}. Done.

**Total weight: 2+1+3+5 = 11** — same total as Kruskal's (MST weight is unique even if the specific edge *set* could theoretically differ with ties, and here it happens to be the identical set too).

Prim's naturally uses a **Min-Heap** to always efficiently retrieve "the cheapest available edge extending the current tree" — the direct link back to the Heap chapter.

---

## 4. Operations

**Kruskal's Algorithm:**
- Sort all E edges by weight — O(E log E).
- Initialize DSU with each vertex in its own set — O(V).
- For each edge (in increasing weight order): if its two endpoints are in different sets, union them and add the edge to the MST; otherwise skip (it would form a cycle).
- Stop early once V-1 edges have been added (optional optimization).

**Prim's Algorithm:**
- Start with any vertex in the "tree so far," and all other vertices "outside."
- Maintain a Min-Heap of candidate edges (weight, destination vertex) crossing from inside the tree to outside.
- Repeatedly extract the minimum-weight edge; if its destination is still outside the tree, add it to the MST and add that vertex's new edges to the heap.
- If the destination is already inside the tree (a stale/outdated heap entry), discard it and continue.

**Edge case for both:** if the input graph is disconnected, neither algorithm can produce a single spanning tree — Kruskal's will simply stop with fewer than V-1 edges (having exhausted all edges that don't form a cycle within isolated components); Prim's, starting from one vertex, will never reach vertices in other components at all.

---

## 5. Time & Space Complexity

| Algorithm | Time Complexity | Space Complexity | Best suited for |
|---|---|---|---|
| Kruskal's | O(E log E) — dominated by sorting edges | O(V) for DSU + O(E) for edge list | Sparse graphs (few edges relative to vertices) |
| Prim's (with Min-Heap) | O(E log V) | O(V) for heap + visited tracking | Dense graphs (many edges relative to vertices) |

**Why these hold:**
- Kruskal's cost is dominated by the initial sort — O(E log E). The subsequent DSU operations (union/find) are nearly O(1) amortized each (using path compression and union by rank, detailed in the DSU chapter), so E union/find operations add only O(E) or O(E log*V) — negligible next to the sort.
- Prim's uses a Min-Heap to always extract the cheapest crossing edge in O(log V) (or O(log E), same order), and each of the E edges is pushed into the heap at most once — giving O(E log V) total.
- Kruskal's tends to be simpler and often faster in practice for **sparse** graphs (E close to V) since sorting a smaller edge list is cheap; Prim's (with a good heap) tends to edge out for **dense** graphs (E close to V²) since it never needs to sort the (much larger) full edge list upfront.

---

## 6. Advantages

- Both provably produce a **globally minimum** total weight spanning tree — not just a locally good one — thanks to the cut property's greedy-choice guarantee.
- Both run in polynomial time (E log E or E log V), vastly better than the exponential brute-force alternative.
- Kruskal's is conceptually simple once DSU is understood — "sort, then greedily skip cycles."
- Prim's naturally extends to streaming/incremental scenarios where the graph is discovered edge by edge.

## 7. Disadvantages

- Only defined for connected graphs (or must be run per-component for disconnected ones, yielding a "minimum spanning forest").
- Kruskal's requires sorting all edges upfront — potentially wasteful if you only need a partial answer or the graph is extremely large.
- Prim's, in its naive (non-heap) form, is O(V²) — the heap-based version requires more implementation complexity to get the O(E log V) improvement.
- Neither directly gives the *shortest path* between two specific vertices — a completely different problem (see the next chapter) that MST is sometimes mistakenly conflated with.

---

## 8. Real-World Applications

- **Networking:** Designing minimum-cost network topologies (telecom cable layouts, computer network backbones) connecting all required locations.
- **Utility Grids:** Minimum-cost electrical grid or pipeline layout connecting all service points.
- **Cluster Analysis:** Some clustering algorithms use MST-based approaches (e.g., single-linkage clustering is directly related to Kruskal's algorithm's edge-processing order).
- **Image Segmentation:** Certain computer vision algorithms use MST-based region-growing techniques.
- **Circuit Design:** Minimizing wire length connecting circuit components.
- **Approximation Algorithms:** MST is a building block in approximation algorithms for other NP-hard problems (e.g., a 2-approximation for the Traveling Salesman Problem via MST-based construction).

---

## 9. Implementation (C++17)

```cpp
#include <iostream>
#include <vector>
#include <queue>
#include <algorithm>
#include <numeric>

// A minimal Union-Find used by Kruskal's algorithm.
// (Full details — path compression, union by rank/size — covered in the DSU chapter.)
class UnionFind {
private:
    std::vector<int> parent;
public:
    UnionFind(int n) : parent(n) {
        std::iota(parent.begin(), parent.end(), 0);   // each vertex is its own parent initially
    }
    int find(int x) {
        if (parent[x] != x) parent[x] = find(parent[x]);   // path compression
        return parent[x];
    }
    bool unite(int x, int y) {
        int rx = find(x), ry = find(y);
        if (rx == ry) return false;   // already connected — this edge would form a cycle
        parent[rx] = ry;
        return true;
    }
};

struct Edge {
    int u, v, weight;
};

// Kruskal's Algorithm. O(E log E).
std::vector<Edge> kruskalMST(int numVertices, std::vector<Edge> edges) {
    std::sort(edges.begin(), edges.end(),
              [](const Edge& a, const Edge& b) { return a.weight < b.weight; });

    UnionFind uf(numVertices);
    std::vector<Edge> mst;

    for (const Edge& e : edges) {
        if (uf.unite(e.u, e.v)) {     // returns true only if u and v were in different sets
            mst.push_back(e);           // safe to add — no cycle created
        }
        if (static_cast<int>(mst.size()) == numVertices - 1) break;   // MST complete
    }
    return mst;
}

// Prim's Algorithm using a Min-Heap. O(E log V).
std::vector<Edge> primMST(int numVertices, const std::vector<std::vector<std::pair<int,int>>>& adjList) {
    // adjList[u] = list of (neighbor, weight)
    std::vector<bool> inMST(numVertices, false);
    // Min-heap of (weight, to_vertex, from_vertex)
    std::priority_queue<std::tuple<int,int,int>, std::vector<std::tuple<int,int,int>>, std::greater<>> pq;

    std::vector<Edge> mst;
    pq.push({0, 0, -1});   // start at vertex 0, no "from" vertex

    while (!pq.empty() && static_cast<int>(mst.size()) < numVertices - 1) {
        auto [weight, u, from] = pq.top();
        pq.pop();

        if (inMST[u]) continue;   // stale entry — u already added via a cheaper/earlier path
        inMST[u] = true;
        if (from != -1) mst.push_back({from, u, weight});   // skip the synthetic starting entry

        for (auto [neighbor, w] : adjList[u]) {
            if (!inMST[neighbor]) {
                pq.push({w, neighbor, u});
            }
        }
    }
    return mst;
}

// Example usage
int main() {
    // Graph: A=0, B=1, C=2, D=3, E=4
    std::vector<Edge> edges = {
        {0,1,4}, {0,2,2}, {1,3,3}, {2,3,1}, {2,4,5}
    };

    auto mstK = kruskalMST(5, edges);
    int totalK = 0;
    std::cout << "Kruskal's MST edges: ";
    for (auto& e : mstK) { std::cout << "(" << e.u << "-" << e.v << ":" << e.weight << ") "; totalK += e.weight; }
    std::cout << "\nTotal weight: " << totalK << "\n";   // 11

    // Build adjacency list for Prim's from the same edges (undirected).
    std::vector<std::vector<std::pair<int,int>>> adjList(5);
    for (auto& e : edges) {
        adjList[e.u].push_back({e.v, e.weight});
        adjList[e.v].push_back({e.u, e.weight});
    }

    auto mstP = primMST(5, adjList);
    int totalP = 0;
    std::cout << "Prim's MST edges: ";
    for (auto& e : mstP) { std::cout << "(" << e.u << "-" << e.v << ":" << e.weight << ") "; totalP += e.weight; }
    std::cout << "\nTotal weight: " << totalP << "\n";   // 11 — same total as Kruskal's
    return 0;
}
```

---

## 10. Code Walkthrough

- **`UnionFind::find` with path compression:** `parent[x] = find(parent[x])` doesn't just find the root — it *rewires* every visited node directly to the root on the way, so future `find` calls on those same nodes are much faster. This single line is what keeps Kruskal's DSU operations nearly O(1) amortized.
- **`UnionFind::unite`:** Returns `false` if `x` and `y` are already in the same set (same root) — this return value is exactly what Kruskal's main loop uses to decide "would this edge create a cycle?"
- **Kruskal's sort + greedy loop:** Sorting once upfront (O(E log E)) lets the rest of the algorithm simply walk the list in order, trusting that any edge reached is the cheapest remaining option — this is the "greedy" part, justified by the cut property (a proof beyond this guide's scope, but intuitively: the globally cheapest edge can never be wrong to include, since excluding it and using a more expensive alternative to connect the same two components can only increase total weight).
- **Prim's `priority_queue` of `(weight, to, from)` tuples:** Ordered by weight (smallest first, via `std::greater<>`) — every time we pop, we get the cheapest known edge crossing into an unvisited vertex. The `inMST[u]` check on pop (not on push) handles the fact that a vertex might have multiple candidate edges pushed before any of them get processed — we only care about the first (cheapest) one that gets popped; subsequent (more expensive, "stale") entries for the same vertex are simply discarded.
- **`from != -1` check:** The synthetic starting entry `(0, 0, -1)` seeds the heap without corresponding to a real edge — this check filters it out of the final edge list.

**Common mistakes to watch for here:**
- Forgetting path compression in `find`, making Kruskal's DSU operations degrade toward O(n) each in the worst case.
- In Prim's, checking `inMST` before pushing instead of after popping — this can miss the cheapest edge if a more expensive one to the same vertex happens to be pushed and popped first (actually the check *should* be on pop, exactly as shown — pushing extra "soon to be stale" entries is fine and expected).
- Assuming Kruskal's and Prim's always produce the *identical* edge set — they always produce the same *total weight*, but with weight ties, the specific edges chosen can differ.

---

## 11. Dry Run

**Graph:** A-B(4), A-C(2), B-D(3), C-D(1), C-E(5). **Kruskal's, step by step:**

| Step | Edge considered | Same set already? | Action | MST so far |
|---|---|---|---|---|
| 1 | C-D (1) | No (C,D separate) | Add | {C-D} |
| 2 | A-C (2) | No (A separate, C in {C,D}) | Add | {C-D, A-C} |
| 3 | B-D (3) | No (B separate, D in {A,C,D}) | Add | {C-D, A-C, B-D} |
| 4 | A-B (4) | **Yes** (A and B both now in {A,B,C,D}) | Skip (would cycle) | unchanged |
| 5 | C-E (5) | No (E separate) | Add | {C-D, A-C, B-D, C-E} |

4 edges for 5 vertices — MST complete. Total: 1+2+3+5 = 11. ✓ (Matches the code output.)

---

## 12. Interview Questions

**Conceptual:**
1. Explain the "cut property" that justifies both Kruskal's and Prim's greedy choices.
2. When would you prefer Kruskal's over Prim's, and vice versa?
3. What happens if you run Kruskal's or Prim's on a disconnected graph?
4. Why does Kruskal's need Union-Find specifically, rather than a simple visited array?
5. Is the Minimum Spanning Tree always unique? Under what condition might there be multiple valid MSTs with the same total weight?

**Coding:**
1. Implement Kruskal's Algorithm using Union-Find.
2. Implement Prim's Algorithm using a Min-Heap.
3. Min Cost to Connect All Points (LeetCode 1584) — MST on a complete graph of points.
4. Find Critical and Pseudo-Critical Edges in MST (LeetCode 1489).
5. Optimize Water Distribution in a Village (LeetCode 1168) — MST with virtual source node.

**Follow-ups / interviewer traps:**
- "What if edge weights can be negative — does MST still work correctly?" (yes — MST algorithms work fine with negative weights, unlike some shortest-path algorithms covered next chapter)
- "How would you find the *second-best* MST?" (tests deeper algorithmic thinking — typically involves trying to swap each MST edge with the next-best alternative)
- "Can you adapt Prim's to run without a heap, and what's the complexity then?" (O(V²) — tests understanding of the heap's specific contribution)

---

## 13. Practice Problems

**Easy**
- Find if Path Exists in Graph (LeetCode 1971) — foundational connectivity check

**Medium**
- Min Cost to Connect All Points (LeetCode 1584)
- Connecting Cities With Minimum Cost (LeetCode 1135)
- Optimize Water Distribution in a Village (LeetCode 1168)

**Hard**
- Find Critical and Pseudo-Critical Edges in MST (LeetCode 1489)
- Minimum Cost to Make at Least One Valid Path in a Grid (related connectivity/shortest-path hybrid)

Also recommended: GeeksforGeeks "Minimum Spanning Tree" practice set, Codeforces problems tagged `dsu` + `graphs`.

---

## 14. Common Mistakes

- **Forgetting to sort edges** before running Kruskal's greedy loop — the entire correctness argument depends on always considering the next-cheapest remaining edge.
- **Using a plain visited array instead of Union-Find in Kruskal's**, which can't efficiently detect "these two vertices are already connected through some indirect path" (that's precisely what DSU is for).
- **Not handling stale heap entries in Prim's** — forgetting the `if (inMST[u]) continue;` check after popping leads to incorrect edge counts or double-processing.
- **Assuming MST gives shortest paths** between arbitrary vertex pairs — it does not; MST minimizes *total* connection cost, not any individual pairwise path (that's the Shortest Path problem, next chapter).
- **Running MST algorithms on disconnected graphs** without checking connectivity first, and being surprised when fewer than V-1 edges result.

---

## 15. Summary

**Key takeaways:**
- An MST is the minimum-total-weight way to connect every vertex in a graph, with no redundant (cycle-forming) edges.
- Kruskal's greedily picks the globally cheapest remaining edge that doesn't form a cycle (needs sorting + Union-Find); Prim's greedily grows one tree, always adding the cheapest edge that extends it (needs a Min-Heap).
- Both are correct because of the cut property — a proof that the cheapest edge crossing any cut is always safe to include.
- Kruskal's tends to suit sparse graphs; Prim's tends to suit dense graphs, though both are broadly applicable.

**Complexity recap:**

| Algorithm | Time |
|---|---|
| Kruskal's | O(E log E) |
| Prim's (heap-based) | O(E log V) |

**Decision guideline:** Use Kruskal's when the edge list is naturally available and relatively small (sparse graphs), or when you're already thinking in terms of Union-Find. Use Prim's when working with adjacency-list-heavy, dense graphs, or when you want to grow the MST incrementally from a specific starting point.

---

*Next chapter: `13_shortest_path.md` — Dijkstra's and Bellman-Ford's algorithms.*
