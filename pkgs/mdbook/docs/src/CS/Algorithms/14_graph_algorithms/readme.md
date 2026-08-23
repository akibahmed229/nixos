# Chapter 14: Graph Algorithms

*Study time: ~6-7 hours | Prerequisite: BFS/DFS, Dijkstra's, MST, Topological Sort (Data Structures guide, Ch. 11-14) | Difficulty: Intermediate-Advanced*

---

## 1. Introduction

**Definition:** This chapter completes the graph algorithm toolkit started in the Data Structures guide (Chapters 11-14 there cover representation, BFS, DFS, Topological Sort, MST via Kruskal's/Prim's, and Shortest Path via Dijkstra's/Bellman-Ford's). Here we add **Floyd-Warshall** (all-pairs shortest path) and a systematic treatment of **cycle detection** across both directed and undirected graphs — the remaining pieces needed for a complete graph-algorithms picture.

**Purpose:** Dijkstra's and Bellman-Ford's (already covered) answer "shortest path **from one source** to everywhere" — but many real problems need "shortest path between **every pair** of vertices" simultaneously, which calls for a fundamentally different algorithm shape. Cycle detection, meanwhile, is a recurring sub-problem embedded inside many other graph algorithms (Topological Sort's correctness depends on it, deadlock detection needs it directly), so it deserves its own systematic treatment.

**Problem solved:** "What's the shortest path between every pair of vertices in a graph?" (Floyd-Warshall), and "does this graph contain a cycle, and if so, can I find it?" (cycle detection, with different techniques for directed vs. undirected graphs).

---

## 2. Intuition

**Floyd-Warshall's core insight:** instead of thinking "what's the shortest path from A to B," think **"what's the shortest path from A to B, allowed to pass through only vertices {1, 2, ..., k}?"** — and build up the answer by incrementally allowing one more "intermediate vertex" at a time. If allowing vertex `k` as a new intermediate stop ever creates a shorter path than what was known before (`dist[i][k] + dist[k][j] < dist[i][j]`), update it. After considering all n vertices as potential intermediates, every pair's shortest path is guaranteed correct — this is dynamic programming applied directly to a graph problem, with the "state" being `(source, destination, allowed intermediate vertices so far)`.

**Cycle detection's core insight differs by graph type:**
- **Undirected graphs:** during a DFS, if you reach an already-visited vertex that is **not** the immediate parent you just came from, you've found a cycle — the "don't count the edge you just came from" exception is essential, since in an undirected graph, every edge naturally looks like it goes "back" to where you came from.
- **Directed graphs:** a back-edge to *any* ancestor still on the current DFS path (not just the immediate parent) indicates a cycle — this requires the three-state (unvisited/in-progress/finished) tracking introduced for Topological Sort in the Data Structures guide, since a directed graph can have an edge back to a vertex visited via a completely different branch (that's fine, no cycle) versus back to a vertex still actively on the current path (that's a genuine cycle).

---

## 3. Step-by-Step Working

### (a) Floyd-Warshall — all-pairs shortest path

```
Graph (directed, weighted), 4 vertices A=0,B=1,C=2,D=3:
A→B(3), A→C(8), A→D(-4), B→D(1), B→A(4), C→B(7), D→C(6), D→A(2)

Initialize dist[i][j] = direct edge weight (or infinity if no edge, 0 if i==j):

     A    B    C    D
A [  0,   3,   8,  -4]
B [  4,   0,  inf,  1]
C [ inf,  7,   0,  inf]
D [  2,  inf,  6,   0]

ITERATION k=0 (allow A as intermediate): check if dist[i][A]+dist[A][j] < dist[i][j] for all i,j.
  e.g., dist[B][A]+dist[A][C] = 4+8=12, current dist[B][C]=inf → UPDATE to 12
  e.g., dist[C][A]... dist[C][A] is inf, skip (no path through A helps here)
  ... (continue for all pairs)

ITERATION k=1 (allow B as intermediate): check dist[i][B]+dist[B][j] < dist[i][j]
  e.g., dist[A][B]+dist[B][D] = 3+1=4, current dist[A][D]=-4 → NO improvement (4 > -4)
  e.g., dist[D][B]... 

ITERATION k=2 (allow C as intermediate): similar checks...

ITERATION k=3 (allow D as intermediate): 
  e.g., dist[A][D]+dist[D][C] = -4+6=2, current dist[A][C]=8 → UPDATE to 2!
  e.g., dist[B][D]+dist[D][A] = 1+2=3, current dist[B][A]=4 → UPDATE to 3!
  e.g., dist[B][D]+dist[D][C] = 1+6=7, current dist[B][C]=12 (from k=0) → UPDATE to 7!

Final dist[][] gives the shortest path between EVERY pair, having considered
routing through every possible intermediate vertex.
```

### (b) Cycle Detection in an Undirected Graph

```
Graph: 0-1, 1-2, 2-0 (a triangle — contains a cycle)

DFS from 0, tracking parent:
visit 0 (parent=-1). Neighbor 1: not visited, recurse (parent=0).
  visit 1 (parent=0). Neighbor 0: visited, but 0 IS the parent — not a cycle, skip.
  Neighbor 2: not visited, recurse (parent=1).
    visit 2 (parent=1). Neighbor 0: visited, and 0 is NOT the parent (parent is 1) → CYCLE DETECTED!
    Neighbor 1: visited, but 1 IS the parent — not a cycle, skip.

Result: cycle found (0-1-2-0).
```

### (c) Cycle Detection in a Directed Graph

```
Graph: 0→1, 1→2, 2→0 (a directed cycle)

DFS with 3-state tracking (0=unvisited, 1=in-progress, 2=finished):
visit 0, state[0]=1 (in-progress). Neighbor 1: unvisited, recurse.
  visit 1, state[1]=1. Neighbor 2: unvisited, recurse.
    visit 2, state[2]=1. Neighbor 0: state[0]=1 (IN-PROGRESS, meaning it's an
    ancestor still on the current path) → CYCLE DETECTED (a back-edge to an
    active ancestor)!

Contrast with a DAG like 0→1, 0→2, 1→3, 2→3 (no cycle, but 3 is reached via
TWO different paths): when DFS reaches 3 via the 0→1→3 path and marks it
FINISHED (state=2), the later arrival via 0→2→3 sees state[3]=2 (finished,
NOT in-progress) → correctly recognized as NOT a cycle, just a convergence.
```

---

## 4. Complexity Analysis

**Floyd-Warshall: O(V³) time, O(V²) space.** Three nested loops (choice of intermediate vertex k, source i, destination j), each O(1) work inside — V×V×V = O(V³). Space is O(V²) for the distance matrix itself (can be done in-place, updating the same matrix across iterations, since each `dist[i][j]` update only ever needs values from the *current* iteration's matrix state, not a separate "previous iteration" copy — a subtle but important correctness detail proven in the algorithm's original derivation).

**Why O(V³) is actually good for the all-pairs problem:** running Dijkstra's from every single vertex would cost O(V · E log V) — for a dense graph where E ≈ V², that's O(V³ log V), *worse* than Floyd-Warshall's clean O(V³), and Floyd-Warshall additionally handles negative edges correctly (though not negative cycles, which it can detect but not "solve around"), which per-vertex Dijkstra's cannot.

**Cycle Detection (either type): O(V + E)** — a single DFS traversal, with O(1) extra bookkeeping per vertex (a parent reference, or a 3-state marker) — identical complexity to plain DFS itself, since cycle detection adds no additional asymptotic cost, only a constant-factor bookkeeping overhead.

---

## 5. Advantages

- Floyd-Warshall answers ALL-PAIRS shortest path in one clean, simple-to-implement algorithm — no repeated single-source calls needed, and it naturally handles negative edge weights (unlike Dijkstra's).
- Cycle detection techniques are lightweight (O(V+E), the same as plain traversal) and form an essential building block embedded inside many other algorithms (Topological Sort, deadlock detection, dependency validation).
- Floyd-Warshall's triple-nested-loop structure is remarkably simple to implement correctly compared to its conceptual power — a rare case where an elegant algorithm is also genuinely easy to code.

## 6. Limitations

- Floyd-Warshall's O(V³) becomes impractical for very large graphs (tens of thousands of vertices or more) — it's specifically suited to all-pairs queries on moderately-sized graphs, not a substitute for single-source algorithms when only one source's distances are actually needed.
- Floyd-Warshall can detect a negative cycle (if any `dist[i][i]` becomes negative after all iterations) but cannot produce a meaningful "shortest path" in the presence of one — shortest paths are undefined when negative cycles are reachable, since you could loop forever accumulating negative cost.
- Cycle detection's specific technique (parent-tracking vs. 3-state) is graph-type-dependent — applying the undirected technique to a directed graph (or vice versa) produces incorrect results, since the two graph types have fundamentally different notions of what a "back edge" means.

---

## 7. Real-World Applications

- **Networking:** precomputing all-pairs shortest paths (or path costs) for network routing tables, when the network is small/stable enough that full recomputation is affordable.
- **Transitive Closure Computation:** Floyd-Warshall's structure directly generalizes to computing "is vertex i reachable from vertex j at all" (a boolean variant) — used in database query optimization and static analysis tools.
- **Compilers:** circular dependency detection (e.g., circular imports/includes) is a direct directed-cycle-detection application.
- **Operating Systems:** deadlock detection (a cycle in a "process waits for resource held by process" graph) is a direct directed-cycle-detection application, and is genuinely used in real database/OS deadlock detectors.
- **Build Systems:** validating that a dependency graph is truly acyclic (before even attempting Topological Sort) is directly cycle detection.
- **Finance:** all-pairs shortest path (with edge weights as negative log-exchange-rates) is a classic technique for detecting arbitrage opportunities across an entire currency network simultaneously, extending the single-source Bellman-Ford arbitrage detection mentioned in the Data Structures guide.
- **Game Development:** precomputed all-pairs distances between key locations on a small, static game map for instant pathfinding queries at runtime.

---

## 8. C++ Implementation

```cpp
#include <iostream>
#include <vector>
#include <limits>

const int INF = std::numeric_limits<int>::max() / 2;   // avoid overflow when summing two INFs

// Floyd-Warshall: all-pairs shortest path. O(V^3) time, O(V^2) space.
// dist[i][j] should be pre-initialized to the direct edge weight, INF if no edge, 0 if i==j.
void floydWarshall(std::vector<std::vector<int>>& dist) {
    int V = static_cast<int>(dist.size());

    for (int k = 0; k < V; ++k) {              // try allowing vertex k as an intermediate stop
        for (int i = 0; i < V; ++i) {
            for (int j = 0; j < V; ++j) {
                if (dist[i][k] + dist[k][j] < dist[i][j]) {
                    dist[i][j] = dist[i][k] + dist[k][j];   // routing through k is shorter — update
                }
            }
        }
    }
    // After all iterations: if any dist[i][i] < 0, a negative cycle exists reachable through i.
}

// Cycle Detection in an UNDIRECTED graph. O(V+E).
bool hasCycleUndirectedHelper(int u, int parent, std::vector<bool>& visited,
                                const std::vector<std::vector<int>>& adjList) {
    visited[u] = true;
    for (int neighbor : adjList[u]) {
        if (!visited[neighbor]) {
            if (hasCycleUndirectedHelper(neighbor, u, visited, adjList)) return true;
        } else if (neighbor != parent) {
            return true;   // visited AND not the parent we just came from — a genuine cycle
        }
    }
    return false;
}

bool hasCycleUndirected(int V, const std::vector<std::vector<int>>& adjList) {
    std::vector<bool> visited(V, false);
    for (int v = 0; v < V; ++v) {
        if (!visited[v]) {
            if (hasCycleUndirectedHelper(v, -1, visited, adjList)) return true;
        }
    }
    return false;
}

// Cycle Detection in a DIRECTED graph. O(V+E). Reuses the 3-state technique from Topological Sort.
bool hasCycleDirectedHelper(int u, std::vector<int>& state, const std::vector<std::vector<int>>& adjList) {
    state[u] = 1;   // in-progress (on the current DFS path)
    for (int neighbor : adjList[u]) {
        if (state[neighbor] == 1) return true;                                   // back-edge to an ACTIVE ancestor — cycle
        if (state[neighbor] == 0 && hasCycleDirectedHelper(neighbor, state, adjList)) return true;
    }
    state[u] = 2;   // finished
    return false;
}

bool hasCycleDirected(int V, const std::vector<std::vector<int>>& adjList) {
    std::vector<int> state(V, 0);
    for (int v = 0; v < V; ++v) {
        if (state[v] == 0) {
            if (hasCycleDirectedHelper(v, state, adjList)) return true;
        }
    }
    return false;
}

// Example usage
int main() {
    // Floyd-Warshall example (4 vertices, from section 3(a))
    int V = 4;
    std::vector<std::vector<int>> dist(V, std::vector<int>(V, INF));
    for (int i = 0; i < V; ++i) dist[i][i] = 0;
    dist[0][1] = 3; dist[0][2] = 8; dist[0][3] = -4;
    dist[1][3] = 1; dist[1][0] = 4;
    dist[2][1] = 7;
    dist[3][2] = 6; dist[3][0] = 2;

    floydWarshall(dist);
    std::cout << "All-pairs shortest distances:\n";
    for (auto& row : dist) {
        for (int d : row) std::cout << (d >= INF ? -1 : d) << " ";
        std::cout << "\n";
    }

    // Undirected cycle detection
    std::vector<std::vector<int>> undirectedAdj(3);
    undirectedAdj[0] = {1, 2}; undirectedAdj[1] = {0, 2}; undirectedAdj[2] = {0, 1};
    std::cout << "Undirected graph has cycle? " << hasCycleUndirected(3, undirectedAdj) << "\n";   // 1 (true)

    // Directed cycle detection
    std::vector<std::vector<int>> directedAdj(3);
    directedAdj[0] = {1}; directedAdj[1] = {2}; directedAdj[2] = {0};
    std::cout << "Directed graph has cycle? " << hasCycleDirected(3, directedAdj) << "\n";   // 1 (true)

    return 0;
}
```

---

## 9. Code Walkthrough

- **`floydWarshall`'s triple loop order (`k` outermost):** This ordering is not arbitrary — `k` MUST be the outermost loop, because iteration `k` represents "shortest paths allowed to use intermediates {0,...,k}," and each iteration's correctness depends on the previous iteration (`k-1`) having already been fully completed for ALL `(i,j)` pairs before `k` is considered as a new intermediate. Swapping the loop order breaks this dependency and produces incorrect results.
- **`INF/2` instead of the raw maximum int value:** Adding two `INF` values (`dist[i][k] + dist[k][j]` when neither path exists) could overflow if using the true maximum representable integer — dividing by 2 upfront leaves enough headroom for one addition without wrapping around.
- **`hasCycleUndirectedHelper`'s `neighbor != parent` check:** This is the critical distinction from directed cycle detection — in an undirected graph, the edge you just traversed to arrive at the current vertex will always appear as a "visited neighbor" when you look back, and this is expected, not a cycle; only a visited neighbor that ISN'T your immediate parent indicates a genuine additional cycle-forming edge.
- **`hasCycleDirectedHelper`'s 3-state check (`state[neighbor] == 1`):** This is exactly the Topological Sort cycle-detection logic from the Data Structures guide, reused verbatim — a back-edge to a vertex still marked "in-progress" (actively on the current recursion path, state 1) is a genuine cycle; a back-edge to a "finished" vertex (state 2) is just a harmless convergence of two different paths onto the same vertex, common in any DAG with multiple valid routes to the same node.
- **Both cycle-detection functions looping over all vertices as potential start points:** neither assumes the graph is connected — disconnected components are each given their own DFS starting point, ensuring the whole graph (not just one component) is checked.

**Common mistakes to watch for here:**
- Placing Floyd-Warshall's `k` loop anywhere other than outermost, silently producing incorrect shortest-path results.
- Using the undirected "parent-tracking" cycle detection technique on a directed graph (or vice versa) — these are genuinely different algorithms suited to genuinely different graph semantics, not interchangeable.
- Forgetting to check all vertices as potential DFS starting points in either cycle-detection function, missing cycles hidden in a disconnected component.

---

## 10. Dry Run

**Floyd-Warshall, k=3 (vertex D) iteration**, continuing from section 3(a)'s setup:

| Check | dist[i][k]+dist[k][j] | Current dist[i][j] | Update? |
|---|---|---|---|
| i=A,j=C via D | dist[A][D]+dist[D][C] = -4+6 = 2 | 8 | YES → dist[A][C]=2 |
| i=B,j=A via D | dist[B][D]+dist[D][A] = 1+2 = 3 | 4 | YES → dist[B][A]=3 |
| i=B,j=C via D | dist[B][D]+dist[D][C] = 1+6 = 7 | 12 (updated at k=0) | YES → dist[B][C]=7 |

These three updates match section 3(a)'s trace exactly, confirming the final all-pairs distance matrix correctly reflects the benefit of routing through D as an intermediate stop. ✓

---

## 11. Complexity Table

| Algorithm | Time | Space |
|---|---|---|
| Floyd-Warshall | O(V³) | O(V²) |
| Cycle Detection (undirected or directed) | O(V+E) | O(V) |

**Every entry explained:** Floyd-Warshall's O(V³) comes directly from its triple-nested-loop structure, with no shortcuts possible in the general case (this is provably close to optimal for dense graphs, though sparse-graph-specific algorithms can sometimes do better). Cycle detection's O(V+E) is identical to plain DFS, since the extra bookkeeping (a parent reference or a 3-state array) adds only O(1) work per vertex/edge examined.

---

## 12. Common Mistakes

- **Wrong loop order in Floyd-Warshall** — `k` must be outermost; this is the single most common implementation bug for this algorithm.
- **Integer overflow from adding two INF sentinel values** — always leave headroom (e.g., `INF/2`) rather than using the raw maximum representable value.
- **Confusing undirected and directed cycle-detection techniques** — applying the wrong one to the wrong graph type produces silently incorrect results (a directed graph checked with the "parent-only" undirected technique can miss legitimate cycles that don't involve the immediate parent).
- **Not checking all vertices as DFS starting points**, missing cycles in disconnected components.
- **Assuming Floyd-Warshall handles negative cycles gracefully** — it can *detect* one (a negative value appearing on the diagonal), but the resulting "shortest paths" involving that cycle are meaningless, since no finite shortest path exists when a negative cycle is reachable.

---

## 13. Interview Questions

**Conceptual:**
1. Why must Floyd-Warshall's intermediate-vertex loop (`k`) be the outermost of the three loops?
2. Compare running Dijkstra's V times versus Floyd-Warshall for the all-pairs shortest path problem — when is each preferable?
3. Explain why undirected and directed graphs need fundamentally different cycle-detection techniques.
4. How does Floyd-Warshall detect a negative cycle, and why can't it produce meaningful shortest paths once one exists?
5. Why is a back-edge to a "finished" vertex in directed-graph DFS NOT necessarily a cycle, while a back-edge to an "in-progress" vertex always is?

**Coding:**
1. Implement Floyd-Warshall and detect negative cycles.
2. Implement cycle detection for both undirected and directed graphs.
3. Course Schedule (LeetCode 207) — directed cycle detection applied directly.
4. Redundant Connection (LeetCode 684) — undirected cycle detection, finding the specific edge that creates a cycle (naturally solved with DSU too — connecting back to the Data Structures guide).
5. Find the City With the Smallest Number of Neighbors at a Threshold Distance (LeetCode 1334) — a direct Floyd-Warshall application.

**Follow-ups / interviewer traps:**
- "Your graph has up to 500 vertices — is Floyd-Warshall or repeated Dijkstra's better here?" (tests recognizing that for moderate V, O(V³) is fine, while for large V, repeated Dijkstra's — or a smarter all-pairs approach — would be needed instead)
- "Can Floyd-Warshall detect WHICH cycle is negative, not just that one exists?" (tests deeper algorithmic thinking — requires additional bookkeeping/backtracking beyond the basic algorithm)
- "Redundant Connection — can you solve it with DSU instead of cycle-detection DFS? Which is more natural here?" (tests recognizing that DSU's "are these already connected?" check is often a cleaner fit for this specific problem shape than a full DFS-based cycle check)

---

## 14. Practice Problems

**Easy**
- Find the Town Judge (LeetCode 997) — light graph/cycle-adjacent reasoning

**Medium**
- Course Schedule (LeetCode 207) / Course Schedule II (LeetCode 210)
- Redundant Connection (LeetCode 684)
- Find the City With the Smallest Number of Neighbors at a Threshold Distance (LeetCode 1334)

**Hard**
- Redundant Connection II (LeetCode 685) — the directed-graph variant, genuinely harder
- Minimum Cost to Make at Least One Valid Path in a Grid (mixed shortest-path/graph-modeling problem)

Also recommended: GeeksforGeeks "Floyd Warshall Algorithm" and "Detect Cycle in a Graph" practice sets; implement transitive closure (boolean reachability) as a Floyd-Warshall variant for additional practice with the pattern.

---

## 15. Summary

**Key takeaways:**
- Floyd-Warshall solves all-pairs shortest path in O(V³) via dynamic programming over "which vertices are allowed as intermediates" — a fundamentally different algorithmic shape than the single-source algorithms (Dijkstra's, Bellman-Ford's) covered in the Data Structures guide.
- Cycle detection requires genuinely different techniques for undirected graphs (parent-tracking) versus directed graphs (3-state in-progress/finished tracking) — these are not interchangeable, and this distinction underlies Topological Sort's own correctness check.
- Together with the Data Structures guide's BFS/DFS/Dijkstra's/Bellman-Ford's/MST/Topological Sort, this chapter completes a comprehensive graph-algorithms toolkit covering traversal, shortest paths (single-source and all-pairs), minimum connectivity, ordering, and structural validation.

**Complexity recap:**

| | Time | Space |
|---|---|---|
| Floyd-Warshall | O(V³) | O(V²) |
| Cycle Detection | O(V+E) | O(V) |

**Decision guide:** Use Floyd-Warshall when you need shortest paths between EVERY pair of vertices and the graph is small/moderate in size (a few hundred to a few thousand vertices, depending on performance requirements). Use cycle detection whenever validating a dependency graph, checking for deadlock conditions, or as a building block before attempting Topological Sort. For single-source shortest paths, prefer Dijkstra's/Bellman-Ford's (Data Structures guide, Ch. 14) over running Floyd-Warshall and discarding unused rows.

---

*Next chapter: `15_tree_algorithms.md`*
