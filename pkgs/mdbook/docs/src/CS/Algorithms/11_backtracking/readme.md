# Chapter 11: Backtracking

*Study time: ~6-7 hours | Prerequisite: Recursion, basic understanding of state-space search | Difficulty: Intermediate*

---

## 1. Introduction

**Definition:** Backtracking is a systematic method for exploring all possible configurations of a problem by building a solution incrementally, one choice at a time, and **abandoning ("backtracking" from) a partial configuration the moment it's discovered to be invalid** — rather than continuing to build on top of a doomed choice.

**Purpose:** To search a combinatorial space (permutations, subsets, board configurations) exhaustively but *efficiently*, by pruning away entire branches of the search tree as soon as they're known to be invalid, instead of generating every full configuration and checking it at the end.

**Problem solved:** "Find one (or all) valid configuration(s) satisfying a set of constraints" — N-Queens, Sudoku, generating permutations/subsets/combinations, and any problem shaped like "make a sequence of choices, some combinations of which are invalid."

---

## 2. Intuition

Imagine navigating a maze by trying each possible direction at every junction, and the moment you hit a dead end, walking back to the last junction and trying a different direction instead of giving up entirely. This is backtracking exactly: **explore, and the instant a choice leads somewhere invalid, undo it and try the next option** — never wasting time fully completing a path you already know is doomed.

The key structural insight: backtracking is recursion with two extra ingredients — (1) a way to make a **choice**, recurse, and then **undo** that choice before trying the next option (so sibling branches don't see stale state from a previous branch), and (2) a **pruning check** that abandons a branch as soon as it's provably invalid, rather than only checking validity once a full configuration is built.

---

## 3. Step-by-Step Working

### (a) Generating all subsets of `{1, 2, 3}`

```
Decision at each element: INCLUDE it or EXCLUDE it. Recursion tree:

                        {}
                /                    \
          include 1                exclude 1
          {1}                        {}
        /       \                  /        \
   incl 2      excl 2         incl 2       excl 2
   {1,2}        {1}           {2}           {}
   /    \       /   \         /   \         /   \
incl3  excl3  incl3 excl3  incl3 excl3   incl3  excl3
{1,2,3}{1,2} {1,3}  {1}    {2,3}  {2}    {3}    {}

All 8 (=2³) leaves are the complete power set:
{}, {3}, {2}, {2,3}, {1}, {1,3}, {1,2}, {1,2,3}
```

No pruning is needed here (every subset is "valid"), but this tree structure — make a choice, recurse into both branches, implicitly "undo" by simply returning — is the skeleton every backtracking problem builds on.

### (b) N-Queens (N=4) — place 4 queens on a 4×4 board so none attack each other

```
Place queens row by row. At each row, try each column; check if it's SAFE
(no queen in the same column, or same diagonal, as any already-placed queen).
If safe, place and recurse to the next row. If the recursive call fails to
find a full solution, UNDO (remove the queen) and try the next column.

Row 0: try col 0 → place. Row 1: try col 0 → SAME COLUMN as row 0, invalid.
       try col 1 → SAME DIAGONAL as row 0's queen (row0,col0)-(row1,col1), invalid.
       try col 2 → safe! place. Row 2: try col 0 → same column as row0, invalid.
                   try col 1 → diagonal with row1's queen, invalid.
                   try col 2 → same column as row1, invalid.
                   try col 3 → diagonal with row0? (0,0)-(2,3)? no. diagonal with row1?
                               (1,2)-(2,3)? YES diagonal, invalid.
                   ALL columns fail for row 2 → BACKTRACK to row 1.
       Row 1: try col 3 → safe (not same col/diag as row0's (0,0)). place.
              Row 2: try col 0 → same col as row0, invalid.
                     try col 1 → diagonal with row1's (1,3)? no... continue checking →
                     eventually finds col 1 is safe. place.
                     Row 3: try each column, find one safe from all three previous queens.

...continuing this process (with further backtracks as needed) eventually yields:
Solution: (0,1), (1,3), (2,0), (3,2)  — one of the 2 valid solutions for N=4.
```

**The critical efficiency insight:** the moment row 2 has NO safe column given rows 0-1's placement, we immediately abandon that entire subtree (we never even consider row 3 at all) — this pruning is what separates backtracking from brute-force generate-all-then-check, which would waste enormous time completing full (but doomed) board configurations.

---

## 4. Complexity Analysis

**General time complexity: O(b^d)** where b is the branching factor (choices per step) and d is the depth (number of decisions) — this is the size of the full search tree if NO pruning occurred at all.

**Why pruning matters so much in practice, despite not changing the worst-case Big-O:** for many real problems (N-Queens, Sudoku), the *actual* number of nodes explored is dramatically smaller than b^d because invalid branches are abandoned early, often just one or two levels deep — this doesn't change the theoretical worst-case bound (which assumes an adversarial input where pruning rarely helps), but it's the difference between "instant" and "computationally infeasible" for typical/practical inputs.

**Subsets/Permutations generation:** generating all 2^n subsets is inherently Θ(2^n) (there are exactly that many subsets to output, so you can't do better); generating all n! permutations is inherently Θ(n!) — these aren't cases where pruning helps reduce the *count* of outputs, only cases where backtracking provides a clean, correct way to enumerate them without redundant work.

**Space: O(d)** for the recursion stack (one call frame per decision level) — backtracking's memory footprint is proportional to the *depth* of the search, not the *breadth*, since only one path through the tree is "active" (on the call stack) at any given moment.

---

## 5. Advantages

- Systematically explores an entire combinatorial search space with a guarantee of correctness (finds a valid solution if one exists, or all solutions if that's the goal).
- Pruning can turn a theoretically exponential search into a practically fast one for many real problem instances — often the difference between infeasible and instant.
- The "choose, recurse, undo" template is highly reusable — once learned, it applies to a huge range of superficially different problems (permutations, subsets, board games, path-finding with constraints).

## 6. Limitations

- Worst-case time remains exponential (O(b^d)) — pruning helps in practice but provides no asymptotic guarantee for adversarial inputs.
- Easy to introduce subtle bugs by forgetting to "undo" a choice before trying the next option — this corrupts sibling branches with stale state from a previous branch.
- Not suitable for optimization problems with **overlapping subproblems** (where the same sub-configuration is reached via multiple different paths) — that scenario calls for Dynamic Programming instead, which can memoize and avoid redundant recomputation that backtracking alone would repeat.

---

## 7. Real-World Applications

- **Constraint Satisfaction Systems:** Sudoku solvers, scheduling systems with hard constraints (no two conflicting events at the same time/resource).
- **Compilers:** Type inference and certain parsing algorithms use backtracking-style exploration when multiple parse interpretations are possible.
- **Games/Puzzles:** Solving/generating puzzles (crosswords, Sudoku, N-Queens-style placement puzzles) and implementing game-tree search for simple combinatorial games.
- **Circuit Design/VLSI:** Component placement and routing problems with hard constraints sometimes use backtracking-based search.
- **Natural Language Processing:** Certain parsing algorithms (e.g., for context-free grammars) use backtracking to explore ambiguous parse trees.
- **Robotics/Path Planning:** Exploring possible movement sequences under hard constraints (obstacles, resource limits) in simplified/discretized planning problems.
- **AI:** Classic AI search problems (constraint satisfaction problems, CSPs) are directly modeled and solved via backtracking with various pruning heuristics (forward checking, arc consistency).

---

## 8. C++ Implementation

```cpp
#include <iostream>
#include <vector>
#include <string>

// Generate all subsets of a set. O(2^n) — inherent to the output size.
void generateSubsets(std::vector<int>& nums, int index, std::vector<int>& current,
                      std::vector<std::vector<int>>& result) {
    if (index == static_cast<int>(nums.size())) {
        result.push_back(current);   // reached the end — record this complete subset
        return;
    }

    // CHOICE 1: exclude nums[index]
    generateSubsets(nums, index + 1, current, result);

    // CHOICE 2: include nums[index]
    current.push_back(nums[index]);
    generateSubsets(nums, index + 1, current, result);
    current.pop_back();   // UNDO — critical, so the next sibling call sees clean state

}

// N-Queens: return true if a solution exists, filling `board` with column positions per row.
bool isSafe(const std::vector<int>& board, int row, int col) {
    for (int prevRow = 0; prevRow < row; ++prevRow) {
        int prevCol = board[prevRow];
        if (prevCol == col) return false;                              // same column
        if (std::abs(prevCol - col) == std::abs(prevRow - row)) return false;   // same diagonal
    }
    return true;
}

bool solveNQueens(std::vector<int>& board, int row, int n) {
    if (row == n) return true;   // all n queens placed successfully

    for (int col = 0; col < n; ++col) {
        if (isSafe(board, row, col)) {
            board[row] = col;                    // CHOICE: place queen at (row, col)

            if (solveNQueens(board, row + 1, n)) {
                return true;                        // found a full solution — propagate success up
            }

            board[row] = -1;                     // UNDO (backtrack) — this placement didn't lead to a solution
        }
    }
    return false;   // no column in this row works — signal failure to the caller, which will also backtrack
}

// Example usage
int main() {
    std::vector<int> nums = {1, 2, 3};
    std::vector<int> current;
    std::vector<std::vector<int>> subsets;
    generateSubsets(nums, 0, current, subsets);

    std::cout << "All subsets of {1,2,3}:\n";
    for (auto& s : subsets) {
        std::cout << "{ ";
        for (int x : s) std::cout << x << " ";
        std::cout << "}\n";
    }

    int n = 4;
    std::vector<int> board(n, -1);
    if (solveNQueens(board, 0, n)) {
        std::cout << "\n4-Queens solution (column per row): ";
        for (int col : board) std::cout << col << " ";
        std::cout << "\n";   // e.g., 1 3 0 2
    }
    return 0;
}
```

---

## 9. Code Walkthrough

- **`generateSubsets`'s two recursive calls (exclude, then include):** This is the "choose, recurse, undo" template in its purest form — for each element, we explore BOTH the "not in the subset" branch and the "in the subset" branch, and crucially, `current.pop_back()` **undoes** the inclusion before the function returns, ensuring the parent's next sibling call (or the parent itself continuing) sees `current` exactly as it was before this call started.
- **Why the `pop_back()` placement matters:** if it were missing, every subsequent subset generated after the first "include" branch would incorrectly retain that element — this single line is what prevents state from leaking between sibling branches in the recursion tree.
- **`isSafe`'s column and diagonal checks:** Same column is checked directly (`prevCol == col`); same diagonal is checked via the classic `abs(prevCol - col) == abs(prevRow - row)` trick — two cells are on the same diagonal exactly when their row difference equals their column difference in absolute value. No need to check "same row" explicitly, since we only ever place one queen per row by construction.
- **`solveNQueens`'s `board[row] = -1` undo:** After a recursive call fails to complete a solution, resetting `board[row]` to "unplaced" is the explicit backtracking step — without it, `isSafe` checks for later rows could be misled by a "phantom" queen placement that's no longer actually part of the current candidate solution.
- **The `if (solveNQueens(...)) return true;` early-exit:** Once a valid full solution is found, we propagate `true` all the way back up through every recursive call frame, avoiding any further unnecessary exploration — critical for "find *any* one solution" problems (versus "find *all* solutions," which would instead continue exploring after each success).

**Common mistakes to watch for here:**
- Forgetting to undo a choice (`pop_back()`, resetting a board cell, etc.) before trying the next option — this is the single most common backtracking bug, and it silently corrupts results in ways that can be hard to spot.
- Checking validity only at the very end (after a full configuration is built) instead of pruning early — this technically still works but throws away most of backtracking's practical performance benefit.
- Confusing "find one solution" (early-exit on success) with "find all solutions" (must continue exploring even after finding one) — these require different control flow.

---

## 10. Dry Run

**`generateSubsets({1,2}, ...)`, full recursion trace:**

| Call | index | current before | Action | current after |
|---|---|---|---|---|
| generateSubsets(0) | 0 | [] | exclude nums[0]=1 → recurse | [] |
| → generateSubsets(1) | 1 | [] | exclude nums[1]=2 → recurse | [] |
| → → generateSubsets(2) | 2 | [] | index==size → RECORD {} | — |
| → (back) include nums[1]=2 | 1 | [] | push 2 → [2] → recurse | [2] |
| → → generateSubsets(2) | 2 | [2] | index==size → RECORD {2} | — |
| → (back) pop → [] | 1 | [2]→[] | undo, return | [] |
| (back at index 0) include nums[0]=1 | 0 | [] | push 1 → [1] → recurse | [1] |
| → generateSubsets(1) | 1 | [1] | exclude nums[1]=2 → recurse | [1] |
| → → generateSubsets(2) | 2 | [1] | RECORD {1} | — |
| → include nums[1]=2 → [1,2] → recurse | 1 | [1,2] | RECORD {1,2} | — |
| → pop → [1] | | | undo | [1] |
| (back) pop → [] | 0 | [1]→[] | undo, return | [] |

Final subsets recorded, in order: `{}, {2}, {1}, {1,2}` — all 4 (=2²) subsets of `{1,2}`, confirming the pattern from section 3 scales correctly. ✓

---

## 11. Complexity Table

| Problem | Time (worst case) | Space |
|---|---|---|
| Generate all subsets | Θ(2ⁿ) | O(n) recursion depth |
| Generate all permutations | Θ(n!) | O(n) recursion depth |
| N-Queens | O(n!) worst case (loose bound; pruning makes actual runtime far smaller) | O(n) recursion depth |
| Sudoku | O(9^(number of empty cells)) worst case (extremely loose; constraint propagation prunes drastically in practice) | O(number of empty cells) |

**Every entry explained:** Subsets/permutations have their complexity fixed by the sheer number of valid outputs (there's no way to enumerate 2ⁿ subsets in better than Θ(2ⁿ), since you must at minimum output each one). N-Queens and Sudoku's *stated* worst-case bounds are extremely loose upper bounds assuming essentially no effective pruning — in practice, the constraint checks (`isSafe`, Sudoku's row/column/box rules) prune the vast majority of the naive search tree, making real-world runtime dramatically better than the loose theoretical bound suggests.

---

## 12. Common Mistakes

- **Forgetting to undo a choice before the next sibling branch** — the most common and most subtle backtracking bug, since the code often still "runs" without crashing, just silently produces wrong results.
- **Checking constraints only at the end** instead of pruning incrementally — loses most of the practical performance benefit that makes backtracking viable for problems like N-Queens or Sudoku at meaningful sizes.
- **Confusing "any one solution" vs. "all solutions"** control flow — using early-exit (`return true` propagation) when all solutions are actually needed, or vice versa.
- **Not recognizing when a problem actually needs Dynamic Programming instead** — if the same sub-configuration is reachable via multiple different decision paths (overlapping subproblems), plain backtracking will redundantly re-explore it every time, where DP would memoize and reuse the result.
- **Off-by-one or incorrect base-case conditions**, causing the recursion to either terminate too early (missing valid configurations) or never terminate (infinite recursion).

---

## 13. Interview Questions

**Conceptual:**
1. What are the two essential ingredients of backtracking beyond plain recursion?
2. Why doesn't pruning change the worst-case Big-O, and why does it matter anyway in practice?
3. Compare Backtracking and Dynamic Programming — what problem characteristic determines which is appropriate?
4. Explain why N-Queens' "same diagonal" check works with the `abs(row difference) == abs(col difference)` formula.
5. What's the difference in control flow between "find any one valid solution" and "find all valid solutions"?

**Coding:**
1. Generate all subsets of a set (Power Set).
2. Generate all permutations of an array.
3. N-Queens — return one solution, or count all solutions.
4. Sudoku Solver.
5. Combination Sum — find all combinations summing to a target (allows repeated elements).
6. Word Search — find if a word exists in a grid via backtracking DFS.
7. Generate Parentheses — all valid combinations of n pairs of parentheses.

**Follow-ups / interviewer traps:**
- "Can you optimize N-Queens further with additional pruning (e.g., tracking used columns/diagonals in O(1) sets instead of scanning previous rows)?" (tests awareness of further optimization beyond the basic correct-but-simple approach)
- "Combination Sum — how do you avoid generating duplicate combinations?" (tests understanding of sorting + skip-duplicate-at-same-level logic, a common refinement)
- "Word Search — why do you need to 'un-mark' a visited cell after backtracking?" (tests the same undo-the-choice principle applied to grid traversal rather than array/board state)

---

## 14. Practice Problems

**Easy**
- Subsets (LeetCode 78)
- Binary Watch (LeetCode 401)

**Medium**
- Permutations (LeetCode 46)
- Combination Sum (LeetCode 39)
- Generate Parentheses (LeetCode 22)
- Word Search (LeetCode 79)
- Palindrome Partitioning (LeetCode 131)

**Hard**
- N-Queens (LeetCode 51) / N-Queens II (LeetCode 52, count only)
- Sudoku Solver (LeetCode 37)
- Word Search II (LeetCode 212) — combines backtracking with a Trie (Data Structures guide, Ch. 9)

Also recommended: GeeksforGeeks "Backtracking" practice set, Codeforces problems tagged `dfs and similar` + `brute force` for additional practice recognizing when pruning-heavy exhaustive search applies.

---

## 15. Summary

**Key takeaways:**
- Backtracking = recursion + (a) explicit choice/undo bookkeeping and (b) early pruning of invalid branches — the undo step is what prevents state from leaking between sibling branches.
- Worst-case complexity remains exponential, but pruning can make real-world performance dramatically better than the loose theoretical bound suggests.
- The line between Backtracking and Dynamic Programming is overlapping subproblems: if the same sub-configuration can be reached multiple ways and is worth memoizing, that's DP's territory, not backtracking's.

**Complexity recap:**

| | Time (worst case) | Space |
|---|---|---|
| Backtracking (general) | O(b^d) | O(d) |

**Decision guide:** Reach for Backtracking when you need to enumerate all valid configurations, or find any one configuration satisfying hard constraints, and there's no meaningful overlap between different branches of the search (each decision path is essentially independent). The moment you notice the same sub-state recurring across different decision paths and being worth caching, that's your signal to move to Dynamic Programming (next chapter) instead.

---

*Next chapter: `12_dynamic_programming_fundamentals.md`*
