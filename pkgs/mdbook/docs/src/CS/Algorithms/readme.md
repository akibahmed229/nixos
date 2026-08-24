# The Algorithms Handbook

### Roadmap, Complexity Primer, Comparison Tables, Decision Guide & Cheat Sheets

---

## How This Guide Is Organized

Like the companion Data Structures guide, this is a multi-file textbook — each algorithm (or tight cluster of related algorithms) gets its own chapter, following a consistent 15-section template (Introduction → Intuition → Step-by-Step Working → Complexity → Advantages/Limitations → Real-World Applications → C++ Implementation → Code Walkthrough → Dry Run → Complexity Table → Common Mistakes → Interview Questions → Practice Problems → Summary). This file is the spine: the roadmap, the complexity-analysis primer every later chapter assumes, the pattern-recognition decision tree, comparison tables, and cheat sheets.

**Status: complete.** All 19 chapters (00-18) are delivered, covering every category from the original roadmap below, including the "Advanced Algorithms" leaf.

**Full table of contents:**

- `00_roadmap_and_strategy.md` ← you are here
- `01_binary_search.md`
- `02_simple_sorts.md` (Bubble, Selection, Insertion)
- `03_merge_sort.md`
- `04_quick_sort.md`
- `05_heap_sort.md`
- `06_non_comparison_sorts.md` (Counting, Radix, Bucket)
- `07_two_pointer.md`
- `08_sliding_window.md`
- `09_prefix_sum.md`
- `10_greedy_algorithms.md`
- `11_backtracking.md`
- `12_dynamic_programming_fundamentals.md`
- `13_dynamic_programming_classic_problems.md` (LCS, LIS, Coin Change)
- `14_graph_algorithms.md` (Floyd-Warshall, cycle detection)
- `15_tree_algorithms.md` (Traversals, LCA, Diameter)
- `16_string_algorithms.md` (pattern recognition capstone, Rolling Hash)
- `17_advanced_dp.md` (Bitmask DP, DP on Trees)
- `18_advanced_techniques.md` (Meet in the Middle, Heavy-Light Decomposition) ← final chapter

---

## Part 1 — The Learning Roadmap

```
Prerequisites
│
├── Programming Fundamentals
├── Mathematics Basics (logs, combinatorics, modular arithmetic)
├── Recursion (call stack, base/recursive case)
├── Big-O Analysis (this file's Part 0, below)
│
├── Searching
│   ├── Linear Search           → baseline, no assumptions about data
│   └── Binary Search            → requires sorted data, halves search space
│
├── Sorting
│   ├── Bubble / Selection / Insertion   → simple, O(n²), good for teaching invariants
│   ├── Merge Sort                        → divide & conquer, stable, O(n log n) guaranteed
│   ├── Quick Sort                         → divide & conquer, in-place, O(n log n) average
│   ├── Heap Sort                           → uses the Heap (Data Structures guide, Ch.5)
│   ├── Counting / Radix / Bucket            → non-comparison sorts, O(n+k) under constraints
│
├── Recursion & Divide-and-Conquer          → foundation for Merge/Quick Sort, many tree/graph algos
│
├── Array/String Techniques
│   ├── Two Pointer                          → opposite/same direction, fast-slow
│   ├── Sliding Window                        → fixed/variable window
│   └── Prefix Sum                             → 1D/2D range-sum precomputation
│
├── Greedy Algorithms                          → needs proof-of-correctness thinking (exchange argument, cut property)
│
├── Backtracking                                → needs recursion + state-space thinking
│
├── Dynamic Programming                          → needs recursion + overlapping-subproblem recognition
│
├── Graph Algorithms                              → needs Stack/Queue/Heap/DSU (Data Structures guide)
│
├── Tree Algorithms                                → needs Binary Tree/BST (Data Structures guide)
│
├── String Algorithms                               → needs arrays + hashing (KMP/Z/Rabin-Karp already
│                                                        covered in the Data Structures guide, Ch.2 —
│                                                        this guide's String chapter cross-references it)
│
└── Advanced Algorithms                              → Bitmask DP, DP on trees, meet-in-the-middle,
                                                          heavy-light decomposition (overview-level)
```

### Why this order?

| Stage                                     | Why it comes here                                                                                               | Prerequisites                  | Learning Outcome                                                                             |
| ----------------------------------------- | --------------------------------------------------------------------------------------------------------------- | ------------------------------ | -------------------------------------------------------------------------------------------- |
| Big-O primer                              | Every later chapter's "why this complexity" section assumes fluency here                                        | Basic programming              | Ability to derive, not just quote, an algorithm's complexity                                 |
| Searching                                 | Simplest possible algorithms; binary search is the first real "why does halving work" insight                   | Big-O                          | Recognize when sorted structure enables faster search                                        |
| Sorting                                   | Comparison-based sorts teach recursion (merge/quick), invariants (bubble/insertion), and heap reuse (heap sort) | Big-O, arrays                  | Understand the O(n log n) comparison-sort lower bound and how non-comparison sorts escape it |
| Recursion/D&C                             | Merge sort and quick sort are the cleanest possible teaching examples of divide-and-conquer                     | Recursion basics               | Recognize the "divide, solve, combine" pattern everywhere                                    |
| Two Pointer / Sliding Window / Prefix Sum | Lightweight array techniques that solve a huge fraction of "easy/medium" interview problems                     | Arrays, recursion              | Instant pattern recognition for a whole problem class                                        |
| Greedy                                    | Needs the discipline of proving local choices lead to a global optimum                                          | Sorting, basic proof intuition | Recognize when greedy is provably correct vs. when it's just a heuristic                     |
| Backtracking                              | Systematic exhaustive search — a generalization of recursion with pruning                                       | Recursion                      | Build state-space search with correct pruning                                                |
| Dynamic Programming                       | Requires recognizing overlapping subproblems — the single hardest pattern-recognition skill in this guide       | Recursion, backtracking        | Convert exponential recursion into polynomial time via memoization/tabulation                |
| Graph Algorithms                          | Needs Stack/Queue/Heap/DSU already built in the Data Structures guide                                           | Data Structures Ch.3,4,5,17    | Model and solve connectivity, shortest-path, and ordering problems                           |
| Tree Algorithms                           | Needs BST/Binary Tree fluency                                                                                   | Data Structures Ch.7           | Solve hierarchical structure problems (LCA, diameter, traversal-based DP)                    |
| String Algorithms                         | Builds directly on Data Structures Ch.2 (KMP/Z/Rabin-Karp)                                                      | Data Structures Ch.2           | Recognize and apply pattern-matching techniques beyond simple search                         |
| Advanced                                  | Combines everything above in novel ways                                                                         | All prior stages               | Handle competitive-programming-level and system-scale problems                               |

### Suggested Timeline (self-paced, ~14-16 weeks at 1-2 hrs/day)

| Week  | Focus                                         | Mini Project                                                                     |
| ----- | --------------------------------------------- | -------------------------------------------------------------------------------- |
| 1     | Big-O primer, Linear/Binary Search            | Implement binary search + all its variants (lower/upper bound, search on answer) |
| 2     | Bubble, Selection, Insertion Sort             | Visualize each sort's swap count on the same input                               |
| 3     | Merge Sort, Quick Sort                        | Benchmark both on random vs. adversarial (sorted, reverse-sorted) input          |
| 4     | Heap Sort, Counting/Radix/Bucket Sort         | Sort 1M integers with each algorithm, compare wall-clock time                    |
| 5     | Two Pointer, Sliding Window                   | Solve 10 problems using each pattern                                             |
| 6     | Prefix Sum (1D and 2D)                        | Build a range-query answering tool for a matrix                                  |
| 7     | Greedy Algorithms                             | Implement Huffman Coding end-to-end (encode + decode a real file)                |
| 8     | Backtracking                                  | N-Queens and Sudoku solvers with pruning visualization                           |
| 9-10  | Dynamic Programming (1D, 2D, knapsack-family) | Solve the "DP 100" style progressive problem set                                 |
| 11    | Graph Algorithms — traversal & shortest path  | Build a mini route-planner using Dijkstra                                        |
| 12    | Graph Algorithms — MST, topological sort, DSU | Implement Kruskal's + a build-system dependency resolver                         |
| 13    | Tree Algorithms                               | LCA + tree diameter on a randomly generated tree                                 |
| 14    | String Algorithms                             | Implement KMP/Z/Rabin-Karp from scratch, benchmark against `std::string::find`   |
| 15-16 | Advanced topics + full mock interviews        | Timed mixed problem sets across all patterns                                     |

---

## Part 0 — Complexity Analysis Primer

_(Every later chapter's "why does this complexity occur" explanation assumes this section.)_

**Big-O (Ο)** describes an **upper bound** on growth rate — "this algorithm's cost grows _no faster than_ this function, for large enough input." It's the most commonly cited bound because it describes the worst case guarantee.

**Big-Omega (Ω)** describes a **lower bound** — "this algorithm's cost grows _at least as fast as_ this function." Used to prove a problem's inherent difficulty (e.g., "any comparison-based sort is Ω(n log n)").

**Big-Theta (Θ)** describes a **tight bound** — both upper and lower simultaneously; "this algorithm's cost grows _exactly_ at this rate." When people casually say "O(n log n)" for merge sort, they usually mean the tighter Θ(n log n), since merge sort's best, average, and worst case are all the same order.

```
Growth rate intuition (small → large, for input size n):
O(1) < O(log n) < O(n) < O(n log n) < O(n²) < O(n³) < O(2ⁿ) < O(n!)

Concretely, for n = 1,000,000:
O(log n)   ≈ 20
O(n)       = 1,000,000
O(n log n) ≈ 20,000,000
O(n²)      = 1,000,000,000,000        ← already impractical
O(2ⁿ)      = astronomically larger than atoms in the universe
```

**Time Complexity** measures operations as a function of input size. **Space Complexity** measures extra memory used (beyond the input itself) as a function of input size — always ask "does this include the input, or just auxiliary space?" (convention varies; this guide always states which explicitly).

**Amortized Analysis** answers "what's the _average_ cost per operation across a whole sequence, even if individual operations vary wildly?" The canonical example (from the Data Structures guide): a dynamic array's `push_back` is O(n) on the rare occasion it triggers a resize, but O(1) amortized across all pushes, because resizes become exponentially rarer as the array grows — the total cost of all resizes across n pushes sums to O(n), i.e., O(1) each on average.

**Why "why" matters more than "what":** knowing merge sort is "O(n log n)" is memorization. Knowing it's O(n log n) because the recursion splits the array into log n levels, and each level does O(n) total work merging — that's understanding, and it's what lets you derive the complexity of an algorithm you've never seen before, which is exactly what interviews and novel real-world problems demand.

---

## Part 4 — Algorithm Pattern Recognition (Decision Tree)

```
START: What does the problem look like?
│
├── Is the input already sorted, or can you sort it cheaply, and you need to find something?
│   ├── Exact value → Binary Search — O(log n)
│   ├── Boundary/count ("first index ≥ X", "count of elements ≤ X") → Lower/Upper Bound Binary Search
│   └── The "found value" itself is monotonic in some parameter you control → Binary Search on the Answer
│
├── Do you need to reorder the data itself?
│   ├── Need stability + guaranteed O(n log n) + don't mind extra memory → Merge Sort
│   ├── Need in-place + good average case, memory-constrained → Quick Sort
│   ├── Already have (or can build) a heap, or need O(n log n) worst-case + in-place → Heap Sort
│   └── Keys are small integers / bounded range → Counting Sort / Radix Sort / Bucket Sort (O(n+k))
│
├── Does the problem involve a contiguous subarray/substring with a running condition?
│   ├── Fixed-size window ("max sum of any k consecutive elements") → Sliding Window (fixed)
│   ├── Variable-size window ("smallest window containing X") → Sliding Window (variable)
│   └── Need repeated range-sum queries over a static array → Prefix Sum
│
├── Does the problem involve pairs/triples in a sorted array, or a cycle/midpoint in a sequence?
│   ├── "Find pair summing to target" in sorted array → Two Pointer (opposite direction)
│   ├── "Remove duplicates in-place", "partition" → Two Pointer (same direction)
│   └── "Detect a cycle", "find the middle" → Fast & Slow Pointer
│
├── Are you making a sequence of choices, and does picking the LOCALLY best option provably lead to
│   the GLOBALLY best outcome (provable via exchange argument or matroid/cut-property structure)?
│   ├── Yes, and you can prove it → Greedy
│   └── Not provable, but choices interact / overlap → likely Dynamic Programming instead
│
├── Do you need to explore ALL valid configurations (or find one that satisfies constraints),
│   with the ability to abandon a branch early once it's clearly invalid?
│   └── Backtracking (N-Queens, Sudoku, generating permutations/subsets/combinations)
│
├── Does the problem ask for an optimal value (min/max/count) over choices, AND do smaller
│   subproblems repeat/overlap when you try to solve it recursively?
│   ├── Yes → Dynamic Programming (memoization if recursion is natural, tabulation for full control)
│   └── No overlap → plain recursion or divide-and-conquer is enough, no DP needed
│
├── Does the problem involve a network of connections (vertices/edges)?
│   ├── Need to visit everything / find connectivity → BFS or DFS
│   ├── Need shortest path, non-negative weights → Dijkstra
│   ├── Need shortest path, negative weights possible → Bellman-Ford
│   ├── Need shortest path between ALL pairs → Floyd-Warshall
│   ├── Need cheapest way to connect everything → MST (Kruskal's or Prim's)
│   ├── Need a valid processing order given "must precede" constraints → Topological Sort
│   └── Need to repeatedly answer "are these connected?" as edges are added → Union-Find (DSU)
│
├── Does the problem involve a hierarchical (tree) structure specifically?
│   ├── Need to visit nodes in a specific order → Tree Traversal (pre/in/post/level-order)
│   ├── Need the common ancestor of two nodes → Lowest Common Ancestor
│   └── Need the longest path between any two nodes → Tree Diameter
│
└── Does the problem involve matching/searching within text?
    ├── Single pattern, need airtight worst-case guarantee → KMP or Z-Function
    ├── Multiple patterns, or approximate/hash-based matching acceptable → Rabin-Karp / Rolling Hash
    └── Many prefix queries against a fixed dictionary → Trie (see Data Structures guide, Ch.9)
```

**Reasoning behind key decisions:**

- **Binary Search requires monotonicity, not just sorted data** — the real requirement is "can I define a yes/no predicate that's false-then-true (or true-then-false) across the search space?" Sorted arrays are the most common such space, but "binary search on the answer" applies the same halving logic to any monotonic predicate, even without an explicit array (e.g., "can I complete all tasks within X hours?").
- **Greedy vs. DP is the single most-tested distinction in interviews:** greedy commits to a choice and never revisits it, which only works when you can _prove_ no future information could ever make an earlier greedy choice regrettable. The moment a locally-best choice can be invalidated by later context, you need DP's "try all options, remember the best" approach instead.
- **Backtracking vs. DP:** both explore a state space, but backtracking is for _enumeration/existence_ problems (find all/any valid configurations) with pruning, while DP is for _optimization/counting_ problems with overlapping subproblems where memoizing repeated states turns exponential exploration into polynomial time.

---

## Part 5 — Comparison Tables

### Linear Search vs. Binary Search

| Aspect           | Linear Search                       | Binary Search                                |
| ---------------- | ----------------------------------- | -------------------------------------------- |
| Precondition     | None                                | Data must be sorted (or monotonic predicate) |
| Time Complexity  | O(n)                                | O(log n)                                     |
| Space Complexity | O(1)                                | O(1) iterative, O(log n) recursive           |
| Use case         | Unsorted/small data, one-off search | Repeated searches on sorted/static data      |

### Merge Sort vs. Quick Sort

| Aspect            | Merge Sort                                                          | Quick Sort                                                                     |
| ----------------- | ------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| Worst-case time   | O(n log n) — guaranteed                                             | O(n²) — rare with good pivot strategy, but possible                            |
| Average-case time | O(n log n)                                                          | O(n log n)                                                                     |
| Space             | O(n) extra (not in-place)                                           | O(log n) extra (in-place, recursion stack)                                     |
| Stability         | Stable                                                              | Not stable (standard implementation)                                           |
| Practical speed   | Slightly slower (memory allocation, copying)                        | Usually faster in practice (better cache locality, in-place)                   |
| Use case          | Need stability, guaranteed worst case, external/linked-list sorting | General-purpose, memory-constrained, average-case matters more than worst-case |

### Greedy vs. Dynamic Programming

| Aspect                  | Greedy                                                                                                | Dynamic Programming                                                 |
| ----------------------- | ----------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------- |
| Decision process        | Commit to locally optimal choice, never revisit                                                       | Explore/remember all relevant sub-decisions                         |
| Correctness requirement | Must PROVE local optimality → global optimality                                                       | Requires identifying overlapping subproblems + optimal substructure |
| Time complexity         | Usually faster (O(n log n) or O(n))                                                                   | Usually slower (O(n²), O(n·k), etc. depending on state space)       |
| Example                 | Activity Selection, Huffman Coding                                                                    | Knapsack, LCS, LIS, Coin Change                                     |
| When greedy fails       | Coin Change with arbitrary denominations (not canonical system) — greedy can give a suboptimal answer | —                                                                   |

### Backtracking vs. Branch and Bound

| Aspect            | Backtracking                                                           | Branch and Bound                                                                                     |
| ----------------- | ---------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| Goal              | Find any/all valid solutions satisfying constraints                    | Find the OPTIMAL solution among many valid ones                                                      |
| Pruning criterion | Constraint violation (this branch is invalid)                          | Bound comparison (this branch can't beat the best found so far, even if valid)                       |
| Typical problems  | N-Queens, Sudoku, permutations/subsets                                 | Traveling Salesman, job scheduling with cost bounds                                                  |
| Complexity        | Still exponential worst case, but pruning helps enormously in practice | Also exponential worst case, but bound-based pruning can eliminate huge portions of the search space |

### Binary Search vs. Linear Search — see above (kept together intentionally for quick reference)

### Prim's vs. Kruskal's — see the Data Structures guide, Chapter 13, for the full comparison (MST algorithms are covered there since they're graph-structure-driven)

### Dijkstra's vs. Bellman-Ford's — see the Data Structures guide, Chapter 14, for the full comparison

### Memoization vs. Tabulation

| Aspect                          | Memoization (Top-Down)                                          | Tabulation (Bottom-Up)                                                  |
| ------------------------------- | --------------------------------------------------------------- | ----------------------------------------------------------------------- |
| Direction                       | Start from the original problem, recurse down, cache results    | Start from base cases, build up to the original problem                 |
| Implementation style            | Recursive + a cache (map/array)                                 | Iterative, filling a table (usually an array)                           |
| Stack usage                     | Uses the call stack — risk of stack overflow for deep recursion | No recursion — no stack overflow risk                                   |
| Solves only needed subproblems? | Yes — only computes states actually reached                     | No — typically computes all states up to the target, even unneeded ones |
| Ease of writing                 | Often more intuitive — mirrors the natural recursive definition | Requires figuring out the correct iteration order upfront               |
| Typical performance             | Slightly slower (function call overhead)                        | Slightly faster (no call overhead, better cache behavior)               |

---

## Part 6 — Master Cheat Sheet

### Complexity Recap Across Categories

| Category                        | Typical Best Case           | Typical Worst Case                           | Typical Space                              |
| ------------------------------- | --------------------------- | -------------------------------------------- | ------------------------------------------ |
| Linear Search                   | O(1)                        | O(n)                                         | O(1)                                       |
| Binary Search                   | O(1)                        | O(log n)                                     | O(1)                                       |
| Bubble/Selection/Insertion Sort | O(n) or O(n²) (varies)      | O(n²)                                        | O(1)                                       |
| Merge Sort                      | O(n log n)                  | O(n log n)                                   | O(n)                                       |
| Quick Sort                      | O(n log n)                  | O(n²)                                        | O(log n)                                   |
| Heap Sort                       | O(n log n)                  | O(n log n)                                   | O(1)                                       |
| Counting/Radix Sort             | O(n+k)                      | O(n+k)                                       | O(n+k)                                     |
| Two Pointer / Sliding Window    | O(n)                        | O(n)                                         | O(1)                                       |
| Prefix Sum (query after build)  | O(1) query, O(n) build      | O(1) query                                   | O(n)                                       |
| Backtracking (general)          | Problem-dependent           | O(bᵏ) (branching factor b, depth k)          | O(k)                                       |
| Dynamic Programming             | O(states × transition cost) | Same (DP has no "lucky" best case typically) | O(states) or O(1D slice) with optimization |
| BFS / DFS                       | O(V+E)                      | O(V+E)                                       | O(V)                                       |
| Dijkstra's                      | O(E log V)                  | O(E log V)                                   | O(V)                                       |
| Floyd-Warshall                  | O(V³)                       | O(V³)                                        | O(V²)                                      |

### Memory Tricks

- "Binary Search halves; Linear Search crawls."
- "Merge Sort divides evenly and merges smartly (guaranteed, not in-place); Quick Sort divides unevenly around a pivot but usually wins the speed race (in-place, not guaranteed)."
- "Greedy: prove first, then trust. DP: don't trust, try everything, remember what worked."
- "Backtracking asks 'is this valid?' Branch and Bound asks 'can this still win?'"
- "If subproblems overlap, memoize. If they don't, plain recursion/divide-and-conquer is already optimal."

---

## Interview Readiness Checklist (fill in as you complete each chapter)

- [ ] Searching — binary search + all boundary variants implemented, 10+ problems solved
- [ ] Sorting — all 9 algorithms implemented, can explain stability/in-place trade-offs, 10+ problems
- [ ] Two Pointer / Sliding Window / Prefix Sum — instant pattern recognition, 15+ problems
- [ ] Greedy — can construct an exchange-argument proof for at least 2 classic problems
- [ ] Backtracking — N-Queens and Sudoku implemented with pruning, 10+ problems
- [ ] Dynamic Programming — comfortable converting recursion → memoization → tabulation → space-optimized, 20+ problems
- [ ] Graph Algorithms — all traversal/shortest-path/MST/topo-sort algorithms implemented, 15+ problems
- [ ] Tree Algorithms — LCA and diameter implemented, 10+ problems
- [ ] String Algorithms — KMP/Z/Rabin-Karp implemented, 10+ problems
- [ ] Advanced DP — Bitmask DP and DP on Trees implemented, 5+ problems
- [ ] Advanced Techniques — can describe Meet in the Middle and Heavy-Light Decomposition and when each applies
- [ ] Mixed mock interviews — can identify the correct pattern within 2 minutes of reading a new problem

---

**The guide is complete.** Start at `01_binary_search.md` and work through in order, or jump straight to whichever chapter matches what you're studying — every chapter cross-references the others it builds on (both within this guide and in the companion Data Structures guide), so you can also navigate by following those references. See `18_advanced_techniques.md` for the closing reflection tying the whole guide together.
