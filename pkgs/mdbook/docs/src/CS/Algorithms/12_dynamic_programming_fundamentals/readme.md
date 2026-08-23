# Chapter 12: Dynamic Programming — Fundamentals

*Study time: ~8-10 hours | Prerequisite: Recursion, Backtracking (Ch. 11) | Difficulty: Advanced*

---

## 1. Introduction

**Definition:** Dynamic Programming (DP) solves a problem by breaking it into overlapping subproblems, solving each **unique** subproblem only once, and **storing (caching) its result** for reuse — converting what would otherwise be exponential repeated recomputation into polynomial time.

**Purpose:** To recognize and exploit **overlapping subproblems** — cases where plain recursion (or backtracking) would solve the *exact same* smaller subproblem many times over — and eliminate that redundant work via memoization or tabulation.

**Problem solved:** Optimization (min/max), counting, or feasibility problems where the natural recursive formulation revisits the same subproblem repeatedly — Fibonacci-style sequences, Knapsack, Longest Common Subsequence, Coin Change, and hundreds of variations.

---

## 2. Intuition

Consider computing the 5th Fibonacci number recursively: `fib(5) = fib(4) + fib(3)`, but `fib(4) = fib(3) + fib(2)` — notice `fib(3)` gets computed **twice**, once directly for `fib(5)` and once inside `fib(4)`'s computation. As n grows, this redundancy explodes exponentially (the naive recursive Fibonacci is O(2ⁿ)), even though there are only n+1 *distinct* subproblems (`fib(0)` through `fib(n)`) — all that repeated work is solving the same handful of problems over and over.

**The core DP insight:** if you're about to solve a subproblem, first check "have I already solved this exact subproblem before?" If yes, reuse the cached answer instantly (O(1)); if no, solve it once and cache the result for next time. This single idea — **recognize repeated subproblems, solve each exactly once** — converts Fibonacci from O(2ⁿ) to O(n), and does the same transformation for a huge class of related problems.

**Two ways to implement this idea:**
- **Memoization (Top-Down):** write the natural recursive solution, but wrap it with a cache — before computing, check the cache; after computing, store the result. This mirrors how you'd naturally *think* about the problem (start from the goal, recurse toward the base case).
- **Tabulation (Bottom-Up):** iteratively build up a table of subproblem answers, starting from the base cases and working toward the final answer — no recursion at all, just careful iteration order.

---

## 3. Step-by-Step Working

### (a) Fibonacci — Memoization vs. Tabulation vs. Space-Optimized

```
NAIVE RECURSION (no caching) — exponential, recomputes fib(3) twice, fib(2) three
times, etc., for fib(5):

fib(5)
├── fib(4)
│   ├── fib(3)
│   │   ├── fib(2)          ← computed here
│   │   └── fib(1)
│   └── fib(2)               ← RECOMPUTED here — wasted work
└── fib(3)                    ← RECOMPUTED here — wasted work
    ├── fib(2)                  ← RECOMPUTED again
    └── fib(1)

MEMOIZATION (top-down): same recursive shape, but check/fill a cache first:
memo = {}
fib(5) → not in memo → compute fib(4)+fib(3)
  fib(4) → not in memo → compute fib(3)+fib(2)
    fib(3) → not in memo → compute fib(2)+fib(1)
      fib(2) → not in memo → compute fib(1)+fib(0) = 1+0 = 1 → CACHE memo[2]=1
      fib(1) → base case → 1
      fib(3) = 1+1 = 2 → CACHE memo[3]=2
    fib(2) → ALREADY IN MEMO → return 1 instantly, no recomputation!
    fib(4) = 2+1 = 3 → CACHE memo[4]=3
  fib(3) → ALREADY IN MEMO → return 2 instantly!
  fib(5) = 3+2 = 5 → CACHE memo[5]=5

Total unique subproblems solved: fib(0) through fib(5) — exactly 6, not the
exponentially-many redundant calls the naive version made.

TABULATION (bottom-up): build a table iteratively, no recursion:
dp[0]=0, dp[1]=1
dp[2] = dp[1]+dp[0] = 1
dp[3] = dp[2]+dp[1] = 2
dp[4] = dp[3]+dp[2] = 3
dp[5] = dp[4]+dp[3] = 5

SPACE-OPTIMIZED: notice dp[i] only ever needs dp[i-1] and dp[i-2] — no need to
keep the WHOLE table, just the last two values:
prev2=0, prev1=1
i=2: curr=1, shift: prev2=1,prev1=1
i=3: curr=2, shift: prev2=1,prev1=2
i=4: curr=3, shift: prev2=2,prev1=3
i=5: curr=5, shift: prev2=3,prev1=5
Result: 5, using O(1) space instead of O(n).
```

### (b) 0/1 Knapsack — a 2D state-space example

```
Items: (weight, value) = (2,3), (3,4), (4,5), (5,6). Capacity = 5.

STATE: dp[i][w] = maximum value achievable using the first i items, with
capacity limit w.

TRANSITION at each item: either SKIP it (dp[i-1][w]) or, if it fits (weight <= w),
TAKE it (value + dp[i-1][w - weight]) — take whichever is better:

dp[i][w] = max( dp[i-1][w],                              // skip item i
                (weight[i] <= w) ? value[i] + dp[i-1][w-weight[i]] : -infinity )  // take item i

Building the table (rows = items considered so far, cols = capacity 0..5):

           w=0  w=1  w=2  w=3  w=4  w=5
no items:   0    0    0    0    0    0
+(2,3):     0    0    3    3    3    3
+(3,4):     0    0    3    4    4    7
+(4,5):     0    0    3    4    5    7
+(5,6):     0    0    3    4    5    7

Final answer: dp[4][5] = 7  (achieved by taking items (2,3) and (3,4): weight 2+3=5, value 3+4=7)
```

**Why this is DP and not just backtracking:** the *same* subproblem `dp[i][w]` (e.g., "best value using the first 2 items with capacity 3") might be reached via multiple different decision paths in a naive recursive exploration — DP recognizes this and computes each distinct `(i, w)` pair's answer exactly once, storing it for reuse, rather than re-deriving it every time it's needed.

---

## 4. Complexity Analysis

**Fibonacci:** Naive recursion O(2ⁿ) time, O(n) space (call stack). Memoization/Tabulation: **O(n) time**, O(n) space (or O(1) with the space-optimized rolling-variables version).

**0/1 Knapsack:** O(n·W) time and space, where n = number of items, W = capacity — this is the size of the `dp[i][w]` table, and each cell is computed in O(1) from at most two previously-computed cells.

**General DP complexity formula: O(number of distinct states × cost to compute each state's transition).** This is *the* formula to derive complexity for any new DP problem you encounter — first identify how many distinct `(parameters)` combinations exist (the state space size), then multiply by how much work each individual transition costs.

**Why DP complexity is usually much better than naive recursion's:** naive recursion's cost is (number of leaf calls in the recursion tree), which can be exponential even when the number of *distinct* subproblems is only polynomial — DP's entire value proposition is collapsing "exponentially many redundant calls" down to "polynomially many unique subproblems, each solved once."

---

## 5. Advantages

- Converts exponential naive recursion into polynomial time whenever overlapping subproblems exist — often the difference between "computationally infeasible" and "instant."
- The systematic "define state, define transition, define base case" methodology generalizes to an enormous range of problems once internalized.
- Space-optimization (rolling variables, as in Fibonacci) frequently reduces memory from O(n) or O(n·m) down to O(1) or O(m), once you recognize that only a small, fixed window of previous states is ever needed.

## 6. Limitations

- Requires correctly identifying the **state** (what parameters uniquely define a subproblem) and the **transition** (how to compute a state from smaller/previously-solved states) — this is a genuine skill that takes deliberate practice, and getting the state definition wrong leads to either incorrect results or a solution that doesn't actually collapse the redundant work.
- Memoization's recursive implementation risks stack overflow for very deep recursion (mirroring the same concern raised for recursive tree/graph traversal in the Data Structures guide).
- Not every problem with "choices" has overlapping subproblems — if every decision path leads to a genuinely distinct subproblem (no overlap), DP provides no advantage over plain backtracking/recursion, and the added bookkeeping (cache management) is pure overhead.

---

## 7. Real-World Applications

- **Bioinformatics:** DNA/protein sequence alignment (edit distance, longest common subsequence) is fundamentally a DP problem, foundational to tools like BLAST.
- **Finance:** option pricing models (binomial tree models) and certain portfolio optimization formulations use DP.
- **Operations Research:** resource allocation, inventory management, and scheduling problems with additive/multiplicative cost structures are classic DP applications.
- **Compilers:** optimal instruction selection and certain register allocation subproblems use DP-based approaches.
- **Networking:** certain routing cost-optimization problems (though many practical routing algorithms are greedy/Dijkstra-based, some optimal offline variants use DP).
- **Natural Language Processing:** Viterbi algorithm (used in speech recognition and part-of-speech tagging) is a direct DP application over sequences.
- **Game Development/AI:** many turn-based game evaluation strategies use DP-based memoization over game states.
- **Version Control:** the `diff` algorithm computing minimal edit sequences between file versions is a Longest Common Subsequence-style DP problem.

---

## 8. C++ Implementation

```cpp
#include <iostream>
#include <vector>
#include <unordered_map>
#include <algorithm>

// ---------- FIBONACCI: three implementations for comparison ----------

// Memoization (Top-Down). O(n) time, O(n) space.
long long fibMemo(int n, std::unordered_map<int, long long>& memo) {
    if (n <= 1) return n;
    if (memo.count(n)) return memo[n];       // already solved — reuse instantly

    long long result = fibMemo(n - 1, memo) + fibMemo(n - 2, memo);
    memo[n] = result;                         // cache before returning
    return result;
}

// Tabulation (Bottom-Up). O(n) time, O(n) space.
long long fibTabulation(int n) {
    if (n <= 1) return n;
    std::vector<long long> dp(n + 1);
    dp[0] = 0; dp[1] = 1;
    for (int i = 2; i <= n; ++i) {
        dp[i] = dp[i - 1] + dp[i - 2];
    }
    return dp[n];
}

// Space-Optimized. O(n) time, O(1) space.
long long fibOptimized(int n) {
    if (n <= 1) return n;
    long long prev2 = 0, prev1 = 1;
    for (int i = 2; i <= n; ++i) {
        long long curr = prev1 + prev2;
        prev2 = prev1;
        prev1 = curr;
    }
    return prev1;
}

// ---------- 0/1 KNAPSACK ----------

// O(n * W) time and space.
int knapsack01(const std::vector<int>& weights, const std::vector<int>& values, int capacity) {
    int n = static_cast<int>(weights.size());
    std::vector<std::vector<int>> dp(n + 1, std::vector<int>(capacity + 1, 0));

    for (int i = 1; i <= n; ++i) {
        for (int w = 0; w <= capacity; ++w) {
            dp[i][w] = dp[i - 1][w];   // option 1: skip item i-1 (0-indexed weights/values)
            if (weights[i - 1] <= w) {
                dp[i][w] = std::max(dp[i][w], values[i - 1] + dp[i - 1][w - weights[i - 1]]);   // option 2: take it
            }
        }
    }
    return dp[n][capacity];
}

// Example usage
int main() {
    std::unordered_map<int, long long> memo;
    std::cout << "fib(30) memoized: " << fibMemo(30, memo) << "\n";
    std::cout << "fib(30) tabulated: " << fibTabulation(30) << "\n";
    std::cout << "fib(30) optimized: " << fibOptimized(30) << "\n";   // all three: 832040

    std::vector<int> weights = {2, 3, 4, 5};
    std::vector<int> values = {3, 4, 5, 6};
    std::cout << "0/1 Knapsack (capacity=5): " << knapsack01(weights, values, 5) << "\n";   // 7

    return 0;
}
```

---

## 9. Code Walkthrough

- **`fibMemo`'s cache check (`if (memo.count(n))`)**: This single check is what prevents the exponential blowup — every time a subproblem would otherwise be recomputed, this line intercepts it and returns the cached answer in O(1) instead.
- **`fibMemo` caching AFTER computing, BEFORE returning:** The order matters — the cache must be populated before the function returns, so that any *other* call frame (a sibling in the recursion tree) that later needs `fib(n)` finds it already cached.
- **`fibTabulation`'s iteration order (`i` from 2 up to n):** Bottom-up DP requires computing subproblems in an order that guarantees every dependency (`dp[i-1]`, `dp[i-2]`) is already computed before it's needed — this is the "figure out the correct iteration order" challenge mentioned as tabulation's main extra difficulty versus memoization.
- **`fibOptimized`'s rolling variables:** Recognizing that `dp[i]` only ever depends on the two immediately preceding values (never anything further back) is what allows collapsing an O(n)-space table down to two O(1) variables — this pattern (looking at a DP transition and asking "how far back do I actually need to look?") is one of the most valuable space-optimization skills in this entire chapter.
- **`knapsack01`'s two-option `dp[i][w]` transition:** Directly implements the recurrence from section 3(b) — `dp[i][w]` is always the better of "don't take item i" (`dp[i-1][w]`) and "take item i, if it fits" (`values[i-1] + dp[i-1][w-weights[i-1]]`). The `i-1` indexing throughout reflects that `dp` uses 1-indexed "number of items considered" while `weights`/`values` arrays are 0-indexed — a common source of off-by-one confusion worth tracing carefully.

**Common mistakes to watch for here:**
- Forgetting to cache a computed result in memoization (or caching before, rather than after, computing — which would cache an incomplete/wrong value).
- Getting tabulation's iteration order wrong, referencing a `dp` cell that hasn't been computed yet.
- Off-by-one errors in Knapsack's 1-indexed-items-vs-0-indexed-arrays indexing.
- Attempting the space optimization (rolling variables) before verifying which previous states a transition actually depends on — collapsing too aggressively can silently produce wrong answers if a transition needs more history than the optimization preserves.

---

## 10. Dry Run

**`knapsack01` table build, fully shown in section 3(b).** Tracing just the final row transition for item (5,6) at `w=5`:

```
dp[4][5] = max( dp[3][5],                                    // skip (5,6): dp[3][5] = 7
                weights[3]=5 <= 5 ? values[3] + dp[3][5-5] : skip )
         = max( 7, 6 + dp[3][0] )
         = max( 7, 6 + 0 )
         = max( 7, 6 )
         = 7
```

Item (5,6) doesn't improve on the existing best of 7 (from items (2,3)+(3,4)) — confirming the table's final entry `dp[4][5] = 7` is correctly derived from its two possible predecessor states.

---

## 11. Complexity Table

| Problem | Time | Space (naive) | Space (optimized) |
|---|---|---|---|
| Fibonacci | O(n) | O(n) | O(1) |
| 0/1 Knapsack | O(n·W) | O(n·W) | O(W) — since each row only needs the previous row |

**Every entry explained:** Fibonacci's O(n) comes from exactly n+1 distinct subproblems, each computed once in O(1) from its predecessors. Knapsack's O(n·W) comes from the table having exactly (n+1)×(W+1) cells, each computed in O(1) — the space optimization to O(W) is possible because, just like Fibonacci, row `i` of the Knapsack table only ever depends on row `i-1`, never anything further back, so only the most recent row needs to be retained (a very common DP space-optimization pattern worth recognizing generally).

---

## 12. Common Mistakes

- **Attempting DP without first identifying the state clearly** — jumping straight to code without articulating "what does `dp[i]` (or `dp[i][j]`) actually represent?" is the single most common source of DP bugs.
- **Forgetting to cache in memoization**, silently reverting to exponential naive recursion despite superficially "having" a memo table.
- **Wrong iteration order in tabulation**, referencing not-yet-computed table cells.
- **Premature space optimization** before confirming exactly which previous states a transition depends on.
- **Confusing "optimal substructure exists" with "overlapping subproblems exist"** — DP needs BOTH properties; a problem can have optimal substructure (like plain divide-and-conquer, e.g., Merge Sort) without overlapping subproblems, in which case memoization provides no benefit at all.

---

## 13. Interview Questions

**Conceptual:**
1. What are the two necessary properties (overlapping subproblems + optimal substructure) for DP to apply, and how do you check for each?
2. Compare memoization and tabulation — when would you prefer one over the other?
3. Why is naive recursive Fibonacci O(2ⁿ) but memoized Fibonacci O(n)? Walk through the exact mechanism.
4. How do you recognize when a DP table's space usage can be optimized (rolling array technique)?
5. Give an example of a problem with optimal substructure but NOT overlapping subproblems — why wouldn't DP help there?

**Coding:**
1. Implement Fibonacci three ways (naive, memoized, tabulated, space-optimized) and benchmark them.
2. 0/1 Knapsack.
3. Climbing Stairs (LeetCode 70) — a Fibonacci-shaped DP in disguise.
4. House Robber (LeetCode 198) — a 1D DP with a simple two-state transition.
5. Minimum Path Sum in a grid (2D DP, directly analogous to Knapsack's table structure).

**Follow-ups / interviewer traps:**
- "Can you reduce your Knapsack solution's space from O(nW) to O(W)?" (expects recognizing the rolling-row optimization, iterating capacity in the correct — often reverse — order to avoid overwriting values still needed within the same row)
- "Your memoized solution works but stack-overflows for large n — how do you fix it?" (expects converting to tabulation, which removes recursion entirely)
- "What's the difference between this problem and one that's solvable with plain divide-and-conquer (like Merge Sort) without any memoization?" (tests the overlapping-subproblems distinction directly)

---

## 14. Practice Problems

**Easy**
- Climbing Stairs (LeetCode 70)
- Fibonacci Number (LeetCode 509)
- Min Cost Climbing Stairs (LeetCode 746)

**Medium**
- House Robber (LeetCode 198)
- House Robber II (LeetCode 213) — circular variant
- Coin Change (LeetCode 322) — previewed here, full treatment in the next chapter
- Unique Paths (LeetCode 62)
- Minimum Path Sum (LeetCode 64)

**Hard**
- 0/1 Knapsack (GeeksforGeeks classic; not directly on LeetCode as a standalone problem, but underlies many harder problems)
- Partition Equal Subset Sum (LeetCode 416) — a Knapsack variant
- Target Sum (LeetCode 494) — a Knapsack-shaped counting problem

Also recommended: for every DP problem, explicitly write out the state definition and transition BEFORE coding — this habit dramatically reduces bugs and is exactly what strong interview candidates do out loud.

---

## 15. Summary

**Key takeaways:**
- DP applies when a problem has BOTH overlapping subproblems (the same smaller problem recurs across different decision paths) AND optimal substructure (the optimal solution can be built from optimal solutions to subproblems).
- Memoization (top-down, cache-as-you-recurse) and Tabulation (bottom-up, iteratively fill a table) solve the same underlying problem two different ways — memoization mirrors natural recursive thinking; tabulation avoids recursion entirely and often allows further space optimization.
- The "rolling variables" space-optimization pattern (Fibonacci needing only the last 2 values, Knapsack needing only the last row) recurs constantly once you know to look for it.

**Complexity recap:**

| | Time | Space (before optimization) |
|---|---|---|
| DP (general) | O(states × transition cost) | O(number of states) |

**Decision guide:** Reach for DP the moment you notice a recursive/backtracking solution re-solving the *identical* subproblem multiple times — that's the unmistakable signal. If every recursive call explores a genuinely distinct subproblem with zero overlap, plain recursion or backtracking is already optimal, and adding memoization would only add overhead with no benefit.

---

*Next chapter: `13_dynamic_programming_classic_problems.md` — Knapsack variants, LCS, LIS, Coin Change, and the broader DP pattern library.*
