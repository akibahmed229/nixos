# Chapter 10: Graphs — Part 1 (Representation, BFS, DFS)

*Study time: ~6-8 hours | Prerequisite: Stack, Queue, Hash Table, Trees | Difficulty: Intermediate*

---

## 1. Introduction

**Definition:** A graph is a collection of **vertices** (nodes) connected by **edges**. Unlike a tree, a graph allows cycles and doesn't require a single root — any vertex can connect to any other, in any pattern.

**Purpose:** To model relationships and connections between entities — networks, dependencies, maps — where a strict hierarchy (tree) is too restrictive.

**Real-world analogy:** A tree is like a corporate org chart — one boss, strict hierarchy, no employee reports to two managers. A graph is like a social network — anyone can be "connected" to anyone else, connections can form cycles (A knows B knows C knows A), and there's no single "root person."

**Motivation:** Countless real problems are naturally about connections rather than hierarchy: road networks, social networks, dependency graphs (build systems, course prerequisites), circuit diagrams. A tree literally cannot represent a cycle; a graph can represent everything a tree can (a tree is just a special, cycle-free, connected graph) *and* far more.

**History:** Graph theory traces to Euler's 1736 solution of the Königsberg bridge problem — arguably the founding problem of the entire field, centuries before computers existed.

---

## 2. Why Do We Need It?

**Problem it solves:** Modeling and traversing arbitrary networks of relationships, including ones with cycles, multiple paths between points, and no natural "root."

**Why trees are insufficient:** A tree cannot represent a cycle (A→B→C→A) or a vertex with multiple "parents" (e.g., a file that's a dependency of two other files) without breaking its own definition. Graphs generalize away both restrictions.

**Trade-offs:**
- You gain the ability to model arbitrary connection patterns, including cycles and multiple paths.
- You pay for it with more complex traversal logic (must explicitly track "visited" vertices to avoid infinite loops in cyclic graphs — trees never need this, since there's only ever one path down from the root).

---

## 3. Internal Working

**Two standard representations:**

**(a) Adjacency Matrix** — a 2D array where `matrix[i][j] = 1` (or edge weight) if an edge exists from vertex i to vertex j:

```
Graph:  0 -- 1
        |    |
        2 -- 3

     0  1  2  3
  0 [0, 1, 1, 0]
  1 [1, 0, 0, 1]
  2 [1, 0, 0, 1]
  3 [0, 1, 1, 0]
```

**(b) Adjacency List** — each vertex stores a list of its directly connected neighbors (far more common in practice for sparse graphs):

```
0: [1, 2]
1: [0, 3]
2: [0, 3]
3: [1, 2]
```

**Directed vs. Undirected:** In an undirected graph, an edge (0,1) implies you can go both 0→1 and 1→0 (shown symmetrically above). In a **directed** graph, an edge only goes one way — adjacency list entries are not mirrored.

```
Directed: 0 → 1 → 2
Adjacency list:
0: [1]
1: [2]
2: []      (2 has no outgoing edges)
```

**Weighted graphs** store a cost alongside each edge (used heavily in shortest-path algorithms, covered in Part 2):
```
0: [(1, weight=4), (2, weight=1)]
```

---

## 4. Operations — Breadth-First Search (BFS)

**BFS explores level by level** — visit all neighbors of the start node first, then all neighbors-of-neighbors, and so on. It uses a **Queue** (FIFO) — this is the direct, essential link back to Chapter 3.

**Why BFS finds shortest paths in unweighted graphs:** because it exhausts every vertex at distance 1 before touching any vertex at distance 2, and so on — the *first* time it reaches a vertex is guaranteed to be via the shortest (fewest-edges) path.

```
Graph:      0
           / \
          1   2
         /     \
        3       4

BFS from 0:
Step 1: visit 0. Queue: [1, 2]. Visited: {0}
Step 2: dequeue 1, visit. Queue: [2, 3]. Visited: {0,1}
Step 3: dequeue 2, visit. Queue: [3, 4]. Visited: {0,1,2}
Step 4: dequeue 3, visit. Queue: [4]. Visited: {0,1,2,3}
Step 5: dequeue 4, visit. Queue: []. Visited: {0,1,2,3,4}

Order visited: 0, 1, 2, 3, 4  ← level by level
```

## 4b. Operations — Depth-First Search (DFS)

**DFS explores as deep as possible down one branch before backtracking** — it uses a **Stack** (LIFO), either explicitly or implicitly via recursion (the call stack itself is a stack — the direct link back to Chapter 3's "why is it called a stack" discussion).

```
Same graph, DFS from 0 (using recursion):
visit 0 → go to neighbor 1 → visit 1 → go to neighbor 3 → visit 3 (dead end, backtrack)
→ back to 1 (no more neighbors, backtrack) → back to 0 → go to neighbor 2 → visit 2
→ go to neighbor 4 → visit 4 (dead end, backtrack) → done

Order visited: 0, 1, 3, 2, 4  ← deep before wide
```

**Both BFS and DFS require a `visited` set** (typically a hash set or boolean array) — without it, a cyclic graph would cause infinite traversal, re-visiting the same vertices forever.

---

## 5. Time & Space Complexity

| Operation | Time Complexity | Space Complexity |
|---|---|---|
| BFS (full traversal) | O(V + E) | O(V) — queue + visited set |
| DFS (full traversal) | O(V + E) | O(V) — recursion stack / explicit stack + visited set |
| Adjacency Matrix space | O(V²) | — |
| Adjacency List space | O(V + E) | — |
| Edge lookup (matrix) | O(1) | — |
| Edge lookup (list) | O(degree of vertex) | — |

**Why these hold:**
- BFS/DFS are O(V + E) because each vertex is visited exactly once (thanks to the `visited` set preventing re-visits — O(V) total), and each edge is examined exactly once (or twice for undirected, still a constant factor) while exploring neighbors — O(E) total.
- Adjacency Matrix uses O(V²) space regardless of how many edges actually exist — wasteful for **sparse** graphs (few edges relative to V²) but O(1) edge-existence lookup makes it good for **dense** graphs or when "is there an edge between i and j?" is queried very frequently.
- Adjacency List uses O(V + E) space — proportional to what's actually there — making it the default choice for most real-world (typically sparse) graphs.

---

## 6. Advantages

**Graphs in general:**
- Model arbitrary relationships that trees cannot (cycles, multiple paths, no single root).
- A rich, well-studied algorithmic toolkit (BFS, DFS, and — Part 2 — shortest path, MST, topological sort) covers an enormous range of real problems.

**BFS specifically:** guarantees shortest path in unweighted graphs; naturally explores "closest things first" (useful for level-based problems like "degrees of separation").

**DFS specifically:** simpler to implement recursively; naturally suited to problems involving exhaustive exploration, backtracking, and structural analysis (cycle detection, connected components, topological sort — Part 2).

## 7. Disadvantages

- Both BFS and DFS require O(V) extra space for the visited set/queue/stack — can be significant for huge graphs.
- BFS can use more memory at any given moment than DFS for wide graphs (the queue can hold an entire "level" of vertices at once).
- DFS's recursive implementation risks stack overflow on very deep graphs (mitigated by converting to an explicit iterative stack-based version).
- Neither is "faster" than the other in Big-O terms (both O(V+E)) — the choice depends entirely on the problem's requirements (shortest path → BFS; exhaustive/structural exploration → DFS), not raw speed.

---

## 8. Real-World Applications

- **Social Networks:** "Degrees of separation" / "people you may know" features — BFS from a user finds friends-of-friends level by level.
- **Networking:** Network broadcast/routing protocols that need to reach all nodes with minimum hop count use BFS-like flooding.
- **Web Crawlers:** Crawling links breadth-first (or depth-first) to discover a website's structure.
- **Maze/Puzzle Solvers:** BFS finds the shortest solution path; DFS explores all possible paths (useful when *any* valid solution, not necessarily shortest, is needed).
- **Compilers:** DFS is used to detect cycles in dependency graphs (e.g., circular imports) and for topological sort (Part 2).
- **Game Development:** Pathfinding on grid-based maps (BFS for unweighted grids; more advanced algorithms like A* for weighted ones).
- **Operating Systems:** Deadlock detection (a cycle in a "waits-for" resource graph) uses DFS-based cycle detection.

---

## 9. Implementation (C++17)

```cpp
#include <iostream>
#include <vector>
#include <queue>
#include <unordered_set>
#include <stack>

// A simple undirected graph using an adjacency list.
class Graph {
private:
    int numVertices;
    std::vector<std::vector<int>> adjList;

public:
    Graph(int n) : numVertices(n), adjList(n) {}

    // Add an undirected edge. O(1).
    void addEdge(int u, int v) {
        adjList[u].push_back(v);
        adjList[v].push_back(u);   // undirected: add both directions
    }

    // Breadth-First Search from a start vertex. O(V + E).
    std::vector<int> bfs(int start) {
        std::vector<int> order;
        std::vector<bool> visited(numVertices, false);
        std::queue<int> q;

        visited[start] = true;
        q.push(start);

        while (!q.empty()) {
            int current = q.front();
            q.pop();
            order.push_back(current);

            for (int neighbor : adjList[current]) {
                if (!visited[neighbor]) {
                    visited[neighbor] = true;   // mark visited when ENQUEUED, not when dequeued —
                    q.push(neighbor);            // this avoids adding the same vertex twice to the queue
                }
            }
        }
        return order;
    }

    // Depth-First Search from a start vertex, RECURSIVE version. O(V + E).
    void dfsRecursiveHelper(int current, std::vector<bool>& visited, std::vector<int>& order) {
        visited[current] = true;
        order.push_back(current);
        for (int neighbor : adjList[current]) {
            if (!visited[neighbor]) {
                dfsRecursiveHelper(neighbor, visited, order);
            }
        }
    }

    std::vector<int> dfsRecursive(int start) {
        std::vector<int> order;
        std::vector<bool> visited(numVertices, false);
        dfsRecursiveHelper(start, visited, order);
        return order;
    }

    // Depth-First Search, ITERATIVE version using an explicit stack (avoids recursion-depth limits).
    std::vector<int> dfsIterative(int start) {
        std::vector<int> order;
        std::vector<bool> visited(numVertices, false);
        std::stack<int> s;

        s.push(start);
        while (!s.empty()) {
            int current = s.top();
            s.pop();
            if (visited[current]) continue;   // may be pushed multiple times before being visited
            visited[current] = true;
            order.push_back(current);

            // Push neighbors in reverse to roughly match recursive DFS's visiting order.
            for (auto it = adjList[current].rbegin(); it != adjList[current].rend(); ++it) {
                if (!visited[*it]) s.push(*it);
            }
        }
        return order;
    }
};

// Example usage
int main() {
    Graph g(5);   // vertices 0..4
    g.addEdge(0, 1);
    g.addEdge(0, 2);
    g.addEdge(1, 3);
    g.addEdge(2, 4);

    std::cout << "BFS from 0: ";
    for (int v : g.bfs(0)) std::cout << v << " ";
    std::cout << "\n";   // 0 1 2 3 4

    std::cout << "DFS (recursive) from 0: ";
    for (int v : g.dfsRecursive(0)) std::cout << v << " ";
    std::cout << "\n";   // 0 1 3 2 4

    std::cout << "DFS (iterative) from 0: ";
    for (int v : g.dfsIterative(0)) std::cout << v << " ";
    std::cout << "\n";   // 0 1 3 2 4
    return 0;
}
```

---

## 10. Code Walkthrough

- **`adjList` as `vector<vector<int>>`:** The standard sparse-graph representation — `adjList[u]` holds every vertex directly reachable from `u`. `addEdge` pushes to both `adjList[u]` and `adjList[v]` for an undirected edge; a directed graph would push only one direction.
- **`bfs`'s "mark visited when enqueued, not dequeued":** This is a subtle but important detail — if you waited until dequeuing to mark a vertex visited, the same vertex could be pushed onto the queue multiple times (once from each neighbor that discovers it) before it's ever processed, wasting time and potentially corrupting the traversal order.
- **`dfsRecursiveHelper`:** The recursion itself acts as the "stack" — each call frame holds `current`, and returning from a call is exactly the "pop and backtrack" step DFS needs. This is why DFS is so naturally expressed recursively, unlike BFS.
- **`dfsIterative`:** Explicitly manages a `std::stack<int>` instead of relying on the call stack — necessary for very deep graphs where recursion could overflow. Note the `if (visited[current]) continue;` check — because a vertex can be pushed multiple times (once per edge pointing to it) before being popped and processed, we must re-check visited status *after* popping, not just before pushing.
- **Order difference (BFS vs both DFS versions):** Running the example shows BFS visiting `0,1,2,3,4` (level by level) versus DFS visiting `0,1,3,2,4` (deep into the 1-branch before backtracking to explore 2) — a direct visual confirmation of the "level by level" vs. "deep first" distinction from section 4.

**Common mistakes to watch for here:**
- Forgetting the `visited` array/set entirely — causes infinite loops on any graph with a cycle.
- Marking visited at the wrong time in BFS (on dequeue instead of enqueue), allowing duplicate queue entries.
- Assuming DFS order is unique/deterministic — it depends on the order neighbors are stored/iterated, which can vary.

---

## 11. Dry Run

**Graph:** `0-1, 0-2, 1-3, 2-4` (as in the code example). **BFS from 0:**

| Step | Dequeue | Visit order so far | Queue after processing |
|---|---|---|---|
| 1 | (start) 0 | [0] | enqueue 1,2 → [1,2] |
| 2 | 1 | [0,1] | enqueue 3 (2 already queued, 0 already visited) → [2,3] |
| 3 | 2 | [0,1,2] | enqueue 4 → [3,4] |
| 4 | 3 | [0,1,2,3] | no new neighbors → [4] |
| 5 | 4 | [0,1,2,3,4] | no new neighbors → [] |

**DFS (recursive) from 0:**

| Call | Action |
|---|---|
| dfs(0) | visit 0. Neighbors: 1, 2. Recurse into 1 first. |
| dfs(1) | visit 1. Neighbors: 0(visited), 3. Recurse into 3. |
| dfs(3) | visit 3. Neighbors: 1(visited). Dead end, return. |
| (back in dfs(1)) | no more neighbors, return. |
| (back in dfs(0)) | continue to neighbor 2. Recurse into 2. |
| dfs(2) | visit 2. Neighbors: 0(visited), 4. Recurse into 4. |
| dfs(4) | visit 4. Neighbors: 2(visited). Dead end, return. |

Final order: 0, 1, 3, 2, 4 — matches the code output. ✓

---

## 12. Interview Questions

**Conceptual:**
1. Why does BFS guarantee the shortest path in an unweighted graph, but DFS does not?
2. Compare adjacency matrix vs. adjacency list — when would you pick each?
3. Why is a `visited` set essential for graph traversal but never needed for tree traversal?
4. What's the space/time trade-off between recursive and iterative DFS?
5. How would you detect a cycle in an undirected graph vs. a directed graph? (Different techniques — undirected uses simple visited-tracking with parent-skip; directed needs a third "currently in recursion stack" state to distinguish a back-edge from a cross-edge.)

**Coding:**
1. Number of Islands — count connected components in a grid using BFS or DFS.
2. Detect a cycle in an undirected graph.
3. Detect a cycle in a directed graph.
4. Clone a graph (deep copy with cycles).
5. Find all connected components in an undirected graph.
6. Word Ladder — shortest transformation sequence (BFS on an implicit graph).
7. Rotting Oranges — multi-source BFS.

**Follow-ups / interviewer traps:**
- "What if the graph is disconnected — does a single BFS/DFS call from one vertex cover everything?" (no — need to iterate over all unvisited vertices and re-run traversal from each)
- "Can you do BFS with multiple starting points simultaneously?" (yes — multi-source BFS, seed the queue with all sources before starting; used in Rotting Oranges-style problems)
- "Your recursive DFS — what happens on a graph with a million vertices in a single chain?" (tests awareness of stack overflow risk, expects the iterative version)

---

## 13. Practice Problems

**Easy**
- Find the Town Judge (LeetCode 997) — light graph modeling
- Flood Fill (LeetCode 733)

**Medium**
- Number of Islands (LeetCode 200)
- Clone Graph (LeetCode 133)
- Course Schedule (LeetCode 207) — previews topological sort, Part 2
- Rotting Oranges (LeetCode 994)
- Word Ladder (LeetCode 127)

**Hard**
- Word Ladder II (LeetCode 126)
- Bus Routes (LeetCode 815)
- Minimum Height Trees (LeetCode 310)

Also recommended: GeeksforGeeks "Graph Data Structure" practice set, Codeforces problems tagged `graphs` + `dfs and similar` (start around 1000-1300 rating).

---

## 14. Common Mistakes

- **Forgetting the `visited` tracker**, causing infinite loops on cyclic graphs.
- **Only traversing from one starting vertex** when the graph might be disconnected, missing entire components.
- **Marking visited at the wrong point** in BFS (on dequeue vs. enqueue), causing duplicate processing.
- **Confusing directed and undirected edge handling** — forgetting to add both directions for undirected graphs, or accidentally adding both for a directed graph.
- **Assuming DFS/BFS visiting order is unique** — it depends on adjacency list ordering, which can differ between implementations even for the same graph.
- **Recursion depth issues** on deep/large graphs with recursive DFS — not considering the iterative alternative when it matters.

---

## 15. Summary

**Key takeaways:**
- Graphs generalize trees by allowing cycles and multiple paths — this power requires explicit cycle-avoidance (`visited` tracking) that trees never need.
- BFS (Queue-based) explores level by level and guarantees shortest path in unweighted graphs.
- DFS (Stack/recursion-based) explores deep before wide — better suited to exhaustive/structural problems (cycle detection, connected components, topological sort).
- Adjacency List is the default representation for most real-world (sparse) graphs; Adjacency Matrix suits dense graphs or frequent O(1) edge-existence checks.

**Complexity recap:**

| | Time | Space |
|---|---|---|
| BFS | O(V + E) | O(V) |
| DFS | O(V + E) | O(V) |

**Decision guideline:** Use BFS when you need the shortest path in an unweighted graph or need to process things "closest first" (level by level). Use DFS when you need exhaustive exploration, structural analysis (cycles, components), or when recursion naturally fits the problem (backtracking-style search).

---

*Next chapter: `11_graphs_part2_topological_sort_mst_shortest_path.md` — covers Topological Sort, Minimum Spanning Tree (Kruskal/Prim), and Shortest Path (Dijkstra/Bellman-Ford), which build directly on BFS/DFS plus the Heap and DSU structures.*
