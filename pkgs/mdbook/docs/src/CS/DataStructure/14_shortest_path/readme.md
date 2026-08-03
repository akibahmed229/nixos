# Chapter 13: Shortest Path (Dijkstra's & Bellman-Ford's)

*Study time: ~7-8 hours | Prerequisite: Graphs, Heap | Difficulty: Intermediate-Advanced*

---

## 1. Introduction

**Definition:** The single-source shortest path problem asks: given a weighted graph and a starting vertex, what is the minimum total-weight path from the start to every other vertex? **Dijkstra's Algorithm** solves this efficiently when all edge weights are non-negative. **Bellman-Ford's Algorithm** solves the more general case, including graphs with **negative** edge weights, and can detect negative-weight cycles (where no shortest path even exists, since you could loop forever accumulating negative cost).

**Purpose:** To find the cheapest route between locations in a weighted network — not just "fewest hops" (that's BFS, for unweighted graphs) but "lowest total cost," where different edges can have very different costs.

**Real-world analogy:** A GPS navigation app doesn't just count intersections — it finds the route with the lowest total *time* or *distance*, where some road segments (edges) take much longer than others. Dijkstra's is exactly this: "always expand toward whichever reachable point currently has the cheapest known total cost so far."

**Motivation:** BFS (Chapter 10) finds the shortest path in *unweighted* graphs (or graphs where every edge costs exactly the same). Real-world networks almost never have uniform costs — flights have different prices, roads have different travel times, network links have different latencies. We need an algorithm that accounts for these varying weights.

**History:** Dijkstra's algorithm was devised by Edsger Dijkstra in 1956 (published 1959) — one of the most famous and widely taught algorithms in all of computer science. Bellman-Ford's was developed independently by Richard Bellman and Lester Ford Jr. around the same era, specifically to handle negative weights that Dijkstra's cannot.

---

## 2. Why Do We Need It?

**Problem it solves:** Finding minimum-total-cost paths in a weighted graph, from one source to all (or one specific) destination(s).

**Why BFS is insufficient:** BFS treats every edge as costing exactly 1 — it has no concept of "this edge is more expensive than that one." Running plain BFS on a weighted graph can return a path with *more total weight* but *fewer edges*, which is simply the wrong answer to "what's cheapest?"

**Trade-offs:**
- **Dijkstra's** gains excellent performance — O(E log V) with a heap — but *requires* non-negative edge weights; it can silently produce wrong answers on a graph with negative edges (it greedily "finalizes" a vertex's shortest distance once popped from the heap, an assumption that breaks if a not-yet-explored negative edge could later reduce that distance further).
- **Bellman-Ford's** handles negative weights correctly (and detects negative cycles) but is slower — O(V·E) — because it must be more conservative, re-checking all edges repeatedly rather than greedily trusting any single vertex's distance as final.

---

## 3. Internal Working

**Dijkstra's Algorithm — "always expand the closest known vertex next," using a Min-Heap:**

```
Graph (directed, weighted):
A --4--> B
A --1--> C
C --2--> B
C --5--> D
B --1--> D

Start: A. dist[A]=0, all others = infinity.

Step 1: Heap: [(0,A)]. Pop A (dist 0). Relax neighbors:
        B: dist[B] = min(inf, 0+4) = 4. Push (4,B).
        C: dist[C] = min(inf, 0+1) = 1. Push (1,C).
Step 2: Heap: [(1,C),(4,B)]. Pop C (dist 1, the smallest). Relax neighbors:
        B: candidate = dist[C]+2 = 1+2 = 3. 3 < current dist[B]=4 → UPDATE dist[B]=3. Push (3,B).
        D: candidate = dist[C]+5 = 1+5 = 6. dist[D]=6. Push (6,D).
Step 3: Heap: [(3,B),(4,B),(6,D)]. Pop B (dist 3 — the smaller of the two B entries). Relax neighbors:
        D: candidate = dist[B]+1 = 3+1 = 4. 4 < current dist[D]=6 → UPDATE dist[D]=4. Push (4,D).
Step 4: Heap: [(4,B)(stale),(4,D),(6,D)(stale)]. Pop (4,B) — but B already finalized at dist 3 → STALE, discard.
Step 5: Pop (4,D) — finalize dist[D]=4.
Step 6: Remaining heap entries are all stale, discard.

Final: dist[A]=0, dist[B]=3, dist[C]=1, dist[D]=4.
```

Notice: the direct A→B edge (weight 4) looked cheapest at first, but going A→C→B (1+2=3) turned out cheaper — Dijkstra's correctly finds this by always expanding the *globally* cheapest known frontier vertex next, not just greedily following the first edge seen.

**Bellman-Ford's Algorithm — "relax every edge, V-1 times, guaranteed to converge":**

```
Same graph. dist[A]=0, others=infinity.

Pass 1: relax every edge once, in any order (say: A-B, A-C, C-B, C-D, B-D):
  A-B: dist[B]=min(inf,0+4)=4
  A-C: dist[C]=min(inf,0+1)=1
  C-B: dist[B]=min(4,1+2)=3   ← improved!
  C-D: dist[D]=min(inf,1+5)=6
  B-D: dist[D]=min(6,3+1)=4   ← improved!

Pass 2: relax every edge again — check if anything STILL improves:
  A-B: 0+4=4, not better than 3. A-C: 0+1=1, no change. C-B: 1+2=3, no change.
  C-D: 1+5=6, not better than 4. B-D: 3+1=4, no change.
  Nothing improved → we could stop early here.

(In the worst case, up to V-1 passes are needed — this graph converged faster.)

Final: same result as Dijkstra's — dist[A]=0, dist[B]=3, dist[C]=1, dist[D]=4.
```

**Why V-1 passes are the guaranteed upper bound:** the shortest path between any two vertices in a graph with V vertices can use **at most V-1 edges** (a simple path visits each vertex at most once). Each full pass of relaxing every edge is guaranteed to correctly extend the "settled" shortest-path length by at least one more edge — so after V-1 passes, every shortest path (however many edges it uses, up to V-1) is guaranteed correct.

**Negative cycle detection (Bellman-Ford only):** run one *extra* (V-th) pass — if **any** distance still improves, a negative-weight cycle exists somewhere reachable from the source (since a legitimate shortest path can never need more than V-1 edges; still finding improvement means you're looping around a negative cycle to keep reducing "cost" indefinitely).

---

## 4. Operations

**Dijkstra's:**
- Initialize `dist[source] = 0`, all others = infinity.
- Push `(0, source)` onto a Min-Heap.
- Repeatedly pop the minimum-distance vertex; if already finalized (visited), skip (stale entry).
- Otherwise, finalize it, and **relax** every outgoing edge: for each neighbor, if `dist[current] + edge_weight < dist[neighbor]`, update `dist[neighbor]` and push the new candidate onto the heap.
- Continue until the heap is empty.
- Edge case: unreachable vertices retain `dist = infinity`.

**Bellman-Ford's:**
- Initialize `dist[source] = 0`, all others = infinity.
- Repeat **V-1 times**: for every edge (u,v,weight) in the graph, relax it — if `dist[u] + weight < dist[v]`, update `dist[v]`.
- Optional (V-th pass): if any edge can still be relaxed, a negative cycle exists reachable from the source.
- Edge case: if a vertex is unreachable, its distance simply never updates from infinity — no special handling needed.

---

## 5. Time & Space Complexity

| Algorithm | Time Complexity | Space Complexity | Handles negative weights? |
|---|---|---|---|
| Dijkstra's (Min-Heap) | O(E log V) | O(V) for distances + heap | No |
| Bellman-Ford's | O(V · E) | O(V) for distances | Yes (and detects negative cycles) |

**Why these hold:**
- Dijkstra's processes each vertex once (finalized when popped) and each edge is relaxed (potentially pushing a heap entry) at most once per edge traversal — giving O(E) heap operations, each O(log V) — total O(E log V).
- Bellman-Ford's must relax **every** edge, **V-1 times**, in the worst case — giving O(V · E). This is significantly slower than Dijkstra's for large graphs, which is exactly the price paid for correctness under negative weights.
- **Why Dijkstra's breaks with negative weights (the key conceptual point):** Dijkstra's *finalizes* a vertex's distance the moment it's popped from the heap, trusting that no future discovery could ever improve it — this trust is only valid because, with non-negative weights, any path found later can only be *longer* (weight only adds, never subtracts). A single negative edge could let a longer *hop-count* path have a *lower* total weight, discovered only after a vertex was already (wrongly) finalized.

---

## 6. Advantages

**Dijkstra's:**
- Efficient — O(E log V) scales well even for large sparse graphs.
- Straightforward extension of BFS's "expand the frontier" idea, just prioritized by actual cost instead of hop count.

**Bellman-Ford's:**
- Correctly handles negative edge weights, which Dijkstra's cannot.
- Detects negative-weight cycles — valuable in its own right (e.g., flagging arbitrage opportunities in currency exchange graphs, or invalid/exploitable cost models).
- Simpler to implement correctly (no heap, no "stale entry" subtlety) — just a straightforward nested loop.

## 7. Disadvantages

**Dijkstra's:** produces silently *wrong* answers on graphs with negative edges (no error, no crash — just an incorrect result) — a genuinely dangerous failure mode if you're not certain about your input data.

**Bellman-Ford's:** significantly slower (O(V·E) vs O(E log V)) — impractical for very large graphs where Dijkstra's would suffice.

---

## 8. Real-World Applications

- **GPS/Navigation:** Finding fastest/shortest driving, walking, or transit routes (Dijkstra's, or more advanced variants like A* which add heuristics).
- **Networking:** Routing protocols (OSPF — Open Shortest Path First — literally uses Dijkstra's algorithm to compute routing tables).
- **Airlines/Logistics:** Cheapest flight/shipping route calculations, sometimes with negative "weights" representing discounts or rebates, requiring Bellman-Ford.
- **Finance:** Detecting arbitrage opportunities in currency exchange (a cycle of trades that nets a profit corresponds to a negative-weight cycle in a graph of exchange rates — Bellman-Ford's cycle detection is directly applicable).
- **Telecommunications:** Finding lowest-latency paths through a network.
- **Game Development:** Pathfinding in weighted terrain (different terrain types cost different movement points).

---

## 9. Implementation (C++17)

```cpp
#include <iostream>
#include <vector>
#include <queue>
#include <limits>

const int INF = std::numeric_limits<int>::max();

struct WeightedEdge {
    int to;
    int weight;
};

// Dijkstra's Algorithm. O(E log V). Requires non-negative weights.
std::vector<int> dijkstra(int numVertices, const std::vector<std::vector<WeightedEdge>>& adjList, int source) {
    std::vector<int> dist(numVertices, INF);
    dist[source] = 0;

    // Min-heap of (distance, vertex)
    std::priority_queue<std::pair<int,int>, std::vector<std::pair<int,int>>, std::greater<>> pq;
    pq.push({0, source});

    std::vector<bool> finalized(numVertices, false);

    while (!pq.empty()) {
        auto [d, u] = pq.top();
        pq.pop();

        if (finalized[u]) continue;   // stale entry — u already has its final shortest distance
        finalized[u] = true;

        for (const WeightedEdge& edge : adjList[u]) {
            int candidate = d + edge.weight;
            if (candidate < dist[edge.to]) {
                dist[edge.to] = candidate;      // relax: found a cheaper path to edge.to
                pq.push({candidate, edge.to});
            }
        }
    }
    return dist;
}

struct SimpleEdge {
    int from, to, weight;
};

// Bellman-Ford's Algorithm. O(V * E). Handles negative weights; detects negative cycles.
// Returns {distances, hasNegativeCycle}.
std::pair<std::vector<int>, bool> bellmanFord(int numVertices, const std::vector<SimpleEdge>& edges, int source) {
    std::vector<int> dist(numVertices, INF);
    dist[source] = 0;

    // Relax all edges V-1 times — guaranteed sufficient for any negative-cycle-free graph.
    for (int i = 0; i < numVertices - 1; ++i) {
        for (const SimpleEdge& e : edges) {
            if (dist[e.from] != INF && dist[e.from] + e.weight < dist[e.to]) {
                dist[e.to] = dist[e.from] + e.weight;
            }
        }
    }

    // One more pass: if anything STILL improves, a negative cycle exists.
    bool hasNegativeCycle = false;
    for (const SimpleEdge& e : edges) {
        if (dist[e.from] != INF && dist[e.from] + e.weight < dist[e.to]) {
            hasNegativeCycle = true;
            break;
        }
    }

    return {dist, hasNegativeCycle};
}

// Example usage
int main() {
    // Graph: A=0, B=1, C=2, D=3
    // A->B(4), A->C(1), C->B(2), C->D(5), B->D(1)
    std::vector<std::vector<WeightedEdge>> adjList(4);
    adjList[0] = {{1,4}, {2,1}};
    adjList[2] = {{1,2}, {3,5}};
    adjList[1] = {{3,1}};

    auto distDijkstra = dijkstra(4, adjList, 0);
    std::cout << "Dijkstra's distances from A: ";
    for (int d : distDijkstra) std::cout << d << " ";
    std::cout << "\n";   // 0 3 1 4  (matches the section 3 dry run)

    std::vector<SimpleEdge> edges = {
        {0,1,4}, {0,2,1}, {2,1,2}, {2,3,5}, {1,3,1}
    };
    auto [distBF, hasNegCycle] = bellmanFord(4, edges, 0);
    std::cout << "Bellman-Ford's distances from A: ";
    for (int d : distBF) std::cout << d << " ";
    std::cout << "\nNegative cycle? " << (hasNegCycle ? "yes" : "no") << "\n";   // 0 3 1 4, no

    // Now with a NEGATIVE edge Dijkstra's would get wrong: add C->B(-3) instead of +2
    std::vector<SimpleEdge> edgesNeg = {
        {0,1,4}, {0,2,1}, {2,1,-3}, {2,3,5}, {1,3,1}
    };
    auto [distBFNeg, hasNegCycle2] = bellmanFord(4, edgesNeg, 0);
    std::cout << "Bellman-Ford's with negative edge: ";
    for (int d : distBFNeg) std::cout << d << " ";
    std::cout << "\n";   // 0 -2 1 -1  — correctly propagates the negative weight
    return 0;
}
```

---

## 10. Code Walkthrough

- **Dijkstra's `finalized` array + "check on pop, not on push":** Exactly the same pattern as Prim's algorithm in the previous chapter — because a vertex can have multiple candidate distances pushed onto the heap before the cheapest one is actually popped and processed, we must discard stale (already-finalized) entries *after* popping, not try to prevent them at push time.
- **The relax operation (`if candidate < dist[edge.to]`)**: this single line — "is going through the current vertex cheaper than what I already knew?" — is the fundamental operation both algorithms are built entirely out of. Dijkstra's does it opportunistically (only from the current cheapest frontier vertex); Bellman-Ford's does it exhaustively (every edge, every pass).
- **Bellman-Ford's `numVertices - 1` outer loop:** This is the mathematically guaranteed bound from section 3 — any shortest path uses at most V-1 edges, so V-1 full relaxation passes are always sufficient (assuming no negative cycle).
- **The extra (V-th) pass for cycle detection:** If a distance can *still* improve after V-1 guaranteed-sufficient passes, the only explanation is a negative cycle letting costs decrease without bound — this check is simply "run the exact same relaxation logic one more time and see if anything changes."
- **`dist[e.from] != INF` guard:** Prevents integer overflow/nonsensical arithmetic from adding a weight to an "unreachable" (infinity) distance — a subtle but important correctness detail, especially in real code where `INF` is a large finite sentinel value, not literal infinity.

**Common mistakes to watch for here:**
- Using Dijkstra's on a graph that might have negative weights — it won't crash, it will just silently return a wrong answer, which is far more dangerous than an error.
- Forgetting the `INF` guard in Bellman-Ford's relaxation check, causing overflow when adding a weight to an unreachable vertex's sentinel value.
- Running only V-2 (one too few) Bellman-Ford passes, missing the longest possible shortest path.
- Checking `finalized` before pushing in Dijkstra's instead of after popping — this can (rarely, but incorrectly) skip pushing a genuinely useful candidate.

---

## 11. Dry Run

Already fully traced in section 3 for both algorithms on the same example graph — both correctly converge on `dist = [0, 3, 1, 4]` for A, B, C, D respectively. The key comparative dry-run insight: **Dijkstra's reaches this answer in one efficient heap-guided pass (never revisiting a finalized vertex)**, while **Bellman-Ford's reaches the same answer by brute-force repeating full edge relaxation passes** — slower, but robust enough to also correctly handle the negative-edge variant shown in the code's third example (`dist = [0, -2, 1, -1]`), which Dijkstra's would get wrong if naively run on that same graph.

---

## 12. Interview Questions

**Conceptual:**
1. Why does Dijkstra's algorithm fail on graphs with negative edge weights? Walk through a concrete counterexample.
2. Why does Bellman-Ford's need exactly V-1 passes (and why is a V-th pass useful)?
3. Compare the time complexities of Dijkstra's and Bellman-Ford's, and explain the source of the difference.
4. How would you reconstruct the actual shortest *path* (not just distance) from either algorithm's output? (Track a `predecessor` array alongside distances.)
5. What's the relationship between BFS and Dijkstra's algorithm? (BFS is Dijkstra's specialized to uniform edge weight = 1, where a plain queue suffices instead of a priority queue.)

**Coding:**
1. Implement Dijkstra's algorithm with path reconstruction.
2. Implement Bellman-Ford's algorithm with negative cycle detection.
3. Network Delay Time — Dijkstra's applied directly (LeetCode 743).
4. Cheapest Flights Within K Stops — a Bellman-Ford-style bounded-relaxation variant.
5. Path with Maximum Probability — Dijkstra's variant with multiplicative (not additive) edge "weights."

**Follow-ups / interviewer traps:**
- "What if you need shortest paths between ALL pairs of vertices, not just from one source?" (tests awareness of Floyd-Warshall, O(V³), as the natural extension beyond this chapter's scope)
- "Your graph has up to K allowed stops — how do you bound the search?" (tests adapting Bellman-Ford-style layered relaxation, exactly the Cheapest Flights problem above)
- "Can Dijkstra's be used with a graph that has zero-weight edges?" (yes — zero is non-negative, works fine; the failure mode is specifically *negative* weights)

---

## 13. Practice Problems

**Easy**
- Find the City With the Smallest Number of Neighbors at a Threshold Distance (LeetCode 1334)

**Medium**
- Network Delay Time (LeetCode 743)
- Cheapest Flights Within K Stops (LeetCode 787)
- Path with Maximum Probability (LeetCode 1514)

**Hard**
- Swim in Rising Water (LeetCode 778) — Dijkstra's-style with a twist
- Minimum Cost to Make at Least One Valid Path in a Grid (LeetCode 1368)
- Shortest Path Visiting All Nodes (LeetCode 847) — combines shortest path with bitmask state

Also recommended: GeeksforGeeks "Shortest Path Algorithms" practice set, Codeforces problems tagged `shortest-paths`, and studying Floyd-Warshall as a natural follow-up for all-pairs shortest paths.

---

## 14. Common Mistakes

- **Using Dijkstra's on a graph that might have negative weights** without verifying that assumption first — the single most dangerous mistake in this chapter, since it fails silently.
- **Off-by-one in Bellman-Ford's pass count** — using V instead of V-1 (technically harmless extra work) or V-2 (genuinely wrong, may miss the longest valid shortest path).
- **Forgetting the `INF`/unreachable guard** before adding to a distance, causing overflow or nonsensical relaxation.
- **Confusing "shortest path" with "minimum spanning tree"** — they solve different problems (MST minimizes total network cost; shortest path minimizes cost between two specific points) and can produce completely different edge sets on the same graph.
- **Not handling the stale-heap-entry case in Dijkstra's**, leading to reprocessing already-finalized vertices (usually harmless due to the guard, but wasteful and a sign of misunderstanding if omitted).

---

## 15. Summary

**Key takeaways:**
- Dijkstra's is the fast, standard choice (O(E log V)) for non-negative-weight shortest-path problems — think of it as "BFS with a Min-Heap instead of a Queue, prioritizing by cost instead of hop count."
- Bellman-Ford's is slower (O(V·E)) but strictly more general — it correctly handles negative weights and can detect negative cycles, which fundamentally break Dijkstra's greedy "finalize on pop" assumption.
- Both are built from the same core "relax an edge" operation — the difference is *how systematically* (Dijkstra's: opportunistically via a heap; Bellman-Ford's: exhaustively via repeated full passes) that relaxation is applied.

**Complexity recap:**

| Algorithm | Time | Negative weights? |
|---|---|---|
| Dijkstra's | O(E log V) | No |
| Bellman-Ford's | O(V · E) | Yes, plus cycle detection |

**Decision guideline:** Use Dijkstra's whenever you can guarantee non-negative edge weights — it's faster and simpler to reason about. Use Bellman-Ford's when negative weights are possible, or when you specifically need to detect negative cycles (e.g., arbitrage detection). For all-pairs shortest paths (every vertex to every other), look beyond this chapter to Floyd-Warshall (O(V³)).

---

*Next: Advanced Data Structures — `14_segment_tree.md`, `15_fenwick_tree.md`, `16_disjoint_set_union.md`, `17_skip_list.md`, `18_bloom_filter.md`, and the capstone `19_lru_cache.md`. Say the word for the next 3.*
