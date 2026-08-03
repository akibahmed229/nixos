# Chapter 11: Topological Sort

*Study time: ~4-5 hours | Prerequisite: Graphs (Representation, BFS, DFS) | Difficulty: Intermediate*

---

## 1. Introduction

**Definition:** A topological sort is a linear ordering of the vertices of a **Directed Acyclic Graph (DAG)** such that for every directed edge u → v, vertex u appears **before** vertex v in the ordering. It only exists for graphs with no cycles — hence "acyclic" being a hard requirement.

**Purpose:** To determine a valid processing order for tasks with dependencies — "do this before that."

**Real-world analogy:** Getting dressed. You must put on socks before shoes, and underwear before pants — some tasks have hard prerequisites. A topological sort is exactly "give me a valid order to put my clothes on" — there might be multiple valid orders (socks and underwear can be done in either order relative to each other), but shoes can never come before socks.

**Motivation:** Whenever tasks have dependency constraints (course prerequisites, build systems compiling files in the right order, spreadsheet formula evaluation order, package manager install order), you need an ordering that respects every "must come before" rule simultaneously — checking this by hand becomes infeasible as the dependency graph grows.

**History:** Formalized as a standard graph algorithm in the early days of computer science, closely tied to DFS (via Kahn's contemporaries) and to Kahn's 1962 BFS-based algorithm (covered below) developed for job-scheduling problems.

---

## 2. Why Do We Need It?

**Problem it solves:** Producing a valid execution/processing order for a set of tasks with directed "must precede" dependencies, or detecting that no valid order exists (i.e., a cycle — a genuine circular dependency, like "A depends on B depends on A," which is unsatisfiable).

**Why plain BFS/DFS aren't enough on their own:** BFS/DFS traverse a graph, but a *traversal order* isn't automatically a valid dependency order — you need extra bookkeeping (either counting incoming edges, or tracking finish times) specifically designed to respect the "before" relationship.

**Trade-offs:**
- You gain a provably valid processing order (or a clear signal that no valid order exists, due to a cycle).
- The cost is modest — topological sort is still O(V + E), just BFS/DFS with a bit of extra bookkeeping — there's no significant trade-off here beyond the requirement that the graph must be acyclic and directed.

---

## 3. Internal Working

**Two standard algorithms — both O(V+E):**

**(a) Kahn's Algorithm (BFS-based):**
1. Compute the **in-degree** (number of incoming edges) of every vertex.
2. Start with all vertices that have in-degree 0 (no prerequisites) in a queue.
3. Repeatedly dequeue a vertex, add it to the result, and decrement the in-degree of all its neighbors. Any neighbor whose in-degree drops to 0 gets enqueued.
4. If the result includes all vertices, it's a valid topological order. If not (some vertices never reach in-degree 0), the graph has a cycle.

```
Graph:  A → B → D
        A → C → D

In-degrees:  A=0, B=1, C=1, D=2

Step 1: queue = [A] (only in-degree-0 vertex)
Step 2: dequeue A, add to result [A]. Decrement B(→0), C(→0). Queue = [B, C]
Step 3: dequeue B, add to result [A,B]. Decrement D(→1). D not 0 yet. Queue = [C]
Step 4: dequeue C, add to result [A,B,C]. Decrement D(→0). Queue = [D]
Step 5: dequeue D, add to result [A,B,C,D]. Queue = []

Result: A, B, C, D — a valid order (B/C order could also swap; both are valid).
```

**(b) DFS-based Algorithm:**
1. Run DFS from every unvisited vertex.
2. When a vertex finishes exploring **all** its descendants (i.e., DFS is about to return/backtrack from it), push it onto a stack.
3. After all DFS calls finish, pop the stack — that pop order is the topological order.

**Why this works:** if u → v, DFS starting at u will fully explore v (and everything reachable from v) *before* u finishes and gets pushed — so v always gets pushed (and therefore popped) in a position consistent with coming after... wait, more precisely: v finishes *before* u (since u waits for v's subtree to complete), so v is pushed first, meaning u ends up *above* v on the stack, and therefore popped *before* v — giving u before v in the final order, exactly satisfying the requirement.

```
Same graph, DFS from A:
DFS(A) → DFS(B) → DFS(D) [no unvisited neighbors, push D] → back to B [push B]
       → DFS(C) [D already visited] [push C]
       → back to A [push A]

Stack (bottom to top): D, B, C, A
Pop order: A, C, B, D  — a valid topological order (A first, D last)
```

---

## 4. Operations

**Build the graph:** Standard adjacency list, but must be **directed** (edges represent one-way "must precede" relationships).

**Compute topological order (Kahn's):**
- Compute in-degrees for all vertices — O(V + E).
- Initialize queue with all in-degree-0 vertices.
- Process the queue: dequeue, output, decrement neighbors' in-degrees, enqueue any that reach 0.
- Edge case: if the final output size < total vertex count, a cycle exists — no valid topological order.

**Compute topological order (DFS-based):**
- Track visited vertices.
- For each unvisited vertex, run DFS; on finishing a vertex (all its neighbors processed), push it to a result stack.
- After all vertices are processed, reverse the stack (or pop it) for the final order.
- Edge case: detecting a cycle requires an additional "currently in recursion stack" marker per vertex (distinct from plain "visited") — if DFS revisits a vertex that's still in its own current recursion path, that's a back-edge, confirming a cycle.

**Cycle detection:** A natural byproduct of both algorithms — Kahn's signals a cycle if not all vertices get processed; DFS signals a cycle if it ever encounters a vertex still "in progress" on the current path.

---

## 5. Time & Space Complexity

| Algorithm | Time Complexity | Space Complexity |
|---|---|---|
| Kahn's (BFS-based) | O(V + E) | O(V) for in-degree array + queue |
| DFS-based | O(V + E) | O(V) for visited tracking + recursion stack + result stack |

**Why these hold:** Both algorithms are fundamentally BFS or DFS with O(1) extra bookkeeping per vertex/edge (tracking in-degree or push/pop timing) — so the complexity remains exactly the same as plain graph traversal: every vertex processed once (O(V)), every edge examined once (O(E)).

---

## 6. Advantages

- Provides a valid, deterministic-enough (up to tie ordering) processing order for dependency-based problems.
- Naturally detects cycles (unsatisfiable dependency sets) as a side effect — extremely useful for validating input before attempting to process it.
- Both algorithms are simple extensions of BFS/DFS, so no new fundamental machinery is required once those are understood.

## 7. Disadvantages

- Only defined for Directed Acyclic Graphs — a single cycle anywhere makes the entire concept undefined (though detecting that cycle is itself valuable information).
- Multiple valid topological orders can exist for the same graph — if a *specific* order matters (not just *any* valid one), topological sort alone isn't sufficient; you'd need additional tie-breaking criteria.

---

## 8. Real-World Applications

- **Build Systems:** Compilers/build tools (Make, Bazel, Webpack) determine the order to compile/bundle files based on their `#include`/`import` dependency graph.
- **Package Managers:** npm, pip, apt determine installation order so dependencies are installed before the packages that need them.
- **Course Scheduling:** University course registration systems determine a valid order to take courses given prerequisite chains.
- **Spreadsheet Software:** Excel/Google Sheets determine the order to recalculate cells based on formula dependencies (cell A2 depends on A1, so A1 must be computed first).
- **Task Scheduling / CI/CD Pipelines:** Determining the order to run build/test/deploy stages that depend on each other.
- **Compilers:** Instruction scheduling and dependency resolution in some compiler optimization passes.

---

## 9. Implementation (C++17)

```cpp
#include <iostream>
#include <vector>
#include <queue>
#include <stack>

class DirectedGraph {
private:
    int numVertices;
    std::vector<std::vector<int>> adjList;

public:
    DirectedGraph(int n) : numVertices(n), adjList(n) {}

    // Directed edge: u must come before v.
    void addEdge(int u, int v) {
        adjList[u].push_back(v);
    }

    // Kahn's Algorithm (BFS-based). O(V + E).
    // Returns empty vector if a cycle exists (no valid topological order).
    std::vector<int> topoSortKahn() {
        std::vector<int> inDegree(numVertices, 0);
        for (int u = 0; u < numVertices; ++u) {
            for (int v : adjList[u]) {
                inDegree[v]++;
            }
        }

        std::queue<int> q;
        for (int v = 0; v < numVertices; ++v) {
            if (inDegree[v] == 0) q.push(v);   // no prerequisites — can go first
        }

        std::vector<int> result;
        while (!q.empty()) {
            int u = q.front();
            q.pop();
            result.push_back(u);

            for (int v : adjList[u]) {
                inDegree[v]--;               // u is "done," remove its influence on v
                if (inDegree[v] == 0) {
                    q.push(v);                 // v's prerequisites are now all satisfied
                }
            }
        }

        if (static_cast<int>(result.size()) != numVertices) {
            return {};   // cycle detected — not all vertices could be processed
        }
        return result;
    }

    // DFS-based topological sort. O(V + E). Also detects cycles via a "in-progress" marker.
    bool dfsTopoHelper(int u, std::vector<int>& state, std::stack<int>& finishOrder) {
        // state: 0 = unvisited, 1 = in progress (on current DFS path), 2 = fully finished
        state[u] = 1;
        for (int v : adjList[u]) {
            if (state[v] == 1) return false;          // back-edge to an in-progress vertex → CYCLE
            if (state[v] == 0 && !dfsTopoHelper(v, state, finishOrder)) {
                return false;                            // cycle detected deeper in the recursion
            }
        }
        state[u] = 2;
        finishOrder.push(u);   // push AFTER all descendants are fully processed
        return true;
    }

    std::vector<int> topoSortDFS() {
        std::vector<int> state(numVertices, 0);
        std::stack<int> finishOrder;

        for (int v = 0; v < numVertices; ++v) {
            if (state[v] == 0) {
                if (!dfsTopoHelper(v, state, finishOrder)) {
                    return {};   // cycle detected
                }
            }
        }

        std::vector<int> result;
        while (!finishOrder.empty()) {
            result.push_back(finishOrder.top());
            finishOrder.pop();
        }
        return result;
    }
};

// Example usage
int main() {
    DirectedGraph g(4);   // vertices: 0=A, 1=B, 2=C, 3=D
    g.addEdge(0, 1);   // A -> B
    g.addEdge(0, 2);   // A -> C
    g.addEdge(1, 3);   // B -> D
    g.addEdge(2, 3);   // C -> D

    std::cout << "Kahn's topo order: ";
    for (int v : g.topoSortKahn()) std::cout << v << " ";
    std::cout << "\n";   // 0 1 2 3  (A B C D)

    std::cout << "DFS-based topo order: ";
    for (int v : g.topoSortDFS()) std::cout << v << " ";
    std::cout << "\n";   // 0 2 1 3  (a different but equally valid order)

    // Introduce a cycle: D -> A
    DirectedGraph gCycle(4);
    gCycle.addEdge(0, 1);
    gCycle.addEdge(1, 2);
    gCycle.addEdge(2, 3);
    gCycle.addEdge(3, 0);   // creates a cycle: 0->1->2->3->0

    auto result = gCycle.topoSortKahn();
    std::cout << "Cyclic graph result size: " << result.size() << " (0 means cycle detected)\n";
    return 0;
}
```

---

## 10. Code Walkthrough

- **`inDegree` computation:** A single pass over every edge increments the destination vertex's in-degree — this is the "how many prerequisites does each vertex have" count that Kahn's algorithm is built around.
- **Kahn's queue seeding:** Only vertices with `inDegree == 0` start in the queue — these are tasks with *no* unmet prerequisites, i.e., valid starting points.
- **Kahn's main loop:** Each time a vertex `u` is processed, we decrement in-degree for all its neighbors (simulating "u's prerequisite is now satisfied for v") — and any neighbor reaching exactly 0 becomes newly eligible.
- **`result.size() != numVertices` check:** If a cycle exists, at least one vertex's in-degree will *never* reach 0 (since its prerequisite chain loops back on itself), so it never enters the queue — meaning the final `result` is smaller than the total vertex count. This is the cycle-detection mechanism, entirely for free from the algorithm's natural behavior.
- **DFS's three-state tracking (`0/1/2`):** This is the key upgrade over plain DFS's simple visited/unvisited boolean. State `1` ("in progress," i.e., currently on the active recursion path) is what lets us distinguish a genuine cycle (an edge back to a vertex still `1`) from simply revisiting an already-fully-processed vertex (state `2`, perfectly normal in a DAG with multiple paths converging on the same vertex, like both B and C leading to D above).
- **Pushing onto `finishOrder` only after the `for` loop completes:** This ensures a vertex is only marked "finished" once every single one of its dependents (things it points to) has *also* finished — guaranteeing the pop order respects all "before" constraints.

**Common mistakes to watch for here:**
- Using a simple 2-state (visited/unvisited) check for DFS cycle detection instead of 3-state — this incorrectly flags convergent (non-cyclic) paths as cycles.
- Forgetting to reverse/pop-order the DFS finish stack — pushing order and topological order are exact opposites.
- Not handling disconnected components — must loop over *all* vertices as potential DFS starting points, not just vertex 0.

---

## 11. Dry Run

**Graph:** A→B, A→C, B→D, C→D (0=A,1=B,2=C,3=D). **Kahn's Algorithm:**

| Step | inDegree[0..3] | Queue | Result |
|---|---|---|---|
| init | [0,1,1,2] | [0] | [] |
| process 0 | [0,0,0,2] | [1,2] | [0] |
| process 1 | [0,0,0,1] | [2] | [0,1] |
| process 2 | [0,0,0,0] | [3] | [0,1,2] |
| process 3 | [0,0,0,0] | [] | [0,1,2,3] |

Result: `[A, B, C, D]` — valid (both B and C only need A, so either could technically go first; this particular run happened to process B before C due to insertion order).

---

## 12. Interview Questions

**Conceptual:**
1. Why must a topological sort only exist for a Directed *Acyclic* Graph?
2. Compare Kahn's algorithm and the DFS-based approach — when might you prefer one over the other?
3. How does each algorithm detect a cycle, and what does that detection mean practically (e.g., for a build system)?
4. Can a graph have more than one valid topological order? Give an example of when it would have exactly one.
5. How would you find the *lexicographically smallest* topological order among all valid ones? (Hint: use a min-heap instead of a plain queue in Kahn's algorithm.)

**Coding:**
1. Course Schedule — determine if all courses can be finished given prerequisites (cycle detection).
2. Course Schedule II — return a valid course order.
3. Alien Dictionary — derive character ordering from a list of words (build a graph from adjacent-letter constraints, then topological sort).
4. Minimum Height Trees — related tree-centroid problem using topological-sort-like peeling of leaves.
5. Sequence Reconstruction — determine if a given sequence is the unique topological order of a graph.

**Follow-ups / interviewer traps:**
- "What if there are multiple valid orders — how would you find the lexicographically smallest?" (expects swapping the queue for a min-heap, giving O(E log V) instead of O(E))
- "Your graph has a self-loop (u → u) — does your cycle detection catch it?" (tests edge-case robustness — a self-loop is a cycle of length 1)
- "How would you parallelize task execution given a topological order?" (tests understanding that all in-degree-0 vertices at any given "wave" of Kahn's algorithm can run concurrently)

---

## 13. Practice Problems

**Easy**
- Minimum Number of Vertices to Reach All Nodes (LeetCode 1557)

**Medium**
- Course Schedule (LeetCode 207)
- Course Schedule II (LeetCode 210)
- Sequence Reconstruction (LeetCode 444)
- Sort Items by Groups Respecting Dependencies (LeetCode 1203)

**Hard**
- Alien Dictionary (LeetCode 269)
- Parallel Courses III (LeetCode 2050)

Also recommended: GeeksforGeeks "Topological Sorting" practice set, HackerRank problems tagged "Topological Sort."

---

## 14. Common Mistakes

- **Attempting topological sort on a graph that might have cycles** without first checking/handling that case — always design for the "no valid order exists" possibility.
- **Using 2-state visited tracking for DFS-based cycle detection** instead of 3-state (unvisited/in-progress/finished), causing false positives on legitimately convergent (non-cyclic) paths.
- **Forgetting to iterate over all vertices as potential starting points** (for disconnected graphs) in the DFS-based approach.
- **Confusing push order with the final answer** in the DFS-based method — the stack must be popped (or the push list reversed) to get the correct order.
- **Not decrementing in-degree correctly** or decrementing the wrong vertex's in-degree in Kahn's algorithm.

---

## 15. Summary

**Key takeaways:**
- Topological sort produces a valid "dependency-respecting" order for a DAG — and both standard algorithms (Kahn's/BFS-based and DFS-based) are simple extensions of traversals already covered in Chapter 10.
- Cycle detection falls out naturally from both algorithms — an unsatisfiable dependency set (a cycle) is detected as a side effect, not as separate extra work.
- Multiple valid orders often exist; if a specific tie-breaking order matters, additional constraints (like a min-heap for lexicographic order) must be layered on top.

**Complexity recap:**

| Algorithm | Time | Space |
|---|---|---|
| Kahn's (BFS-based) | O(V + E) | O(V) |
| DFS-based | O(V + E) | O(V) |

**Decision guideline:** Use topological sort whenever you have a "must happen before" dependency graph and need either a valid processing order or a way to detect unsatisfiable (cyclic) dependencies — build systems, task scheduling, course planning, package installation order.

---

*Next chapter: `12_minimum_spanning_tree.md` — Kruskal's and Prim's algorithms.*
