# Chapter 13: Dynamic Programming — Classic Problems (LCS, LIS, Coin Change)

*Study time: ~8-9 hours | Prerequisite: DP Fundamentals (Ch. 12) | Difficulty: Advanced*

---

## 1. Introduction

**Definition:** This chapter covers three of the most widely-applicable DP problem *shapes* — Longest Common Subsequence (LCS, a 2D string/sequence-alignment DP), Longest Increasing Subsequence (LIS, a 1D sequence DP with two different solution approaches of different complexity), and Coin Change (an unbounded-knapsack-shaped counting/optimization DP) — each a template that dozens of other interview problems are secretly variations of.

**Purpose:** To build a working library of recognizable DP *patterns*, since a huge fraction of real DP interview questions are disguised variants of these three underlying shapes rather than genuinely novel problems.

**Problem solved:** Sequence alignment/comparison (LCS — diffing files, DNA matching), finding structure within a sequence (LIS — trend detection, patience sorting), and optimal combination-counting under repeatable choices (Coin Change — the unbounded knapsack family).

---

## 2. Intuition

**LCS:** given two sequences, find the longest sequence of characters that appears in both, in order (not necessarily contiguous). The natural recursive question at any pair of positions `(i, j)`: "if the current characters match, they must be part of the LCS — extend by 1 and recurse on the rest of both strings. If they don't match, the LCS must come from either skipping a character in the first string or skipping one in the second — try both, take the better." This branching, applied at every position pair, is exactly the 2D `dp[i][j]` state Knapsack-style problems use.

**LIS:** given a sequence, find the longest subsequence that's strictly increasing. The naive recursive question at position `i`: "for every earlier position `j` with a smaller value, could I extend *that* increasing subsequence by including position `i`?" — this gives an O(n²) DP directly. A cleverer O(n log n) approach (patience sorting, named after the card game) maintains a list of "smallest possible tail value for an increasing subsequence of each length," updated via binary search (directly reusing Chapter 1) as you scan the sequence.

**Coin Change:** given a set of coin denominations (each usable an *unlimited* number of times — hence "unbounded," unlike 0/1 Knapsack's "each item at most once"), find the minimum number of coins summing to a target (or count the number of ways). The natural recursive question at amount `a`: "for each coin denomination `c` ≤ a, what if I use one of that coin? The remaining problem is exactly the same shape, just for amount `a - c`" — this self-similarity (the subproblem for a smaller amount looks exactly like the original problem) is the hallmark of unbounded-knapsack-style DP.

---

## 3. Step-by-Step Working

### (a) Longest Common Subsequence — "ABCBDAB" and "BDCABA"

```
STATE: dp[i][j] = length of LCS of the first i characters of string1 and
                   the first j characters of string2.

TRANSITION:
  if string1[i-1] == string2[j-1]:  dp[i][j] = dp[i-1][j-1] + 1   (extend the match)
  else:                              dp[i][j] = max(dp[i-1][j], dp[i][j-1])  (skip one char from either)

Building the table (rows = string1 "ABCBDAB", cols = string2 "BDCABA"):

        ""  B  D  C  A  B  A
    ""   0  0  0  0  0  0  0
    A    0  0  0  0  1  1  1
    B    0  1  1  1  1  2  2
    C    0  1  1  2  2  2  2
    B    0  1  1  2  2  3  3
    D    0  1  2  2  2  3  3
    A    0  1  2  2  3  3  4
    B    0  1  2  2  3  4  4

Final answer: dp[7][6] = 4  (one valid LCS: "BCBA" or "BDAB", both length 4)
```

**Reconstructing the actual subsequence** (not just its length) requires walking backward through the table from `dp[n][m]`: whenever `string1[i-1]==string2[j-1]`, that character is part of the LCS, move diagonally to `dp[i-1][j-1]`; otherwise, move toward whichever of `dp[i-1][j]` or `dp[i][j-1]` was larger.

### (b) Longest Increasing Subsequence — `[10, 9, 2, 5, 3, 7, 101, 18]`

```
O(n²) APPROACH: dp[i] = length of the longest increasing subsequence ENDING at index i.

dp[0]=1 (just [10])
dp[1]=1 (just [9], since 9 < 10 can't extend anything before it)
dp[2]=1 (just [2])
dp[3]: check all j<3 with arr[j]<arr[3]=5: arr[2]=2<5 → dp[3]=dp[2]+1=2  ([2,5])
dp[4]: check j<4 with arr[j]<3: arr[2]=2<3 → dp[4]=dp[2]+1=2  ([2,3])
dp[5]: check j<5 with arr[j]<7: arr[2]=2,arr[3]=5,arr[4]=3 all <7 → best is dp[3]=2 → dp[5]=3 ([2,5,7])
dp[6]: check j<6 with arr[j]<101: ALL qualify → best is dp[5]=3 → dp[6]=4  ([2,5,7,101])
dp[7]: check j<7 with arr[j]<18: arr[2,3,4,5]qualify (not 101) → best is dp[5]=3 → dp[7]=4 ([2,5,7,18])

Answer: max(dp) = 4

O(n log n) APPROACH (patience sorting): maintain `tails[]` = smallest possible
tail value for an increasing subsequence of each length so far.

10: tails=[10]
9:  9<10, replace → tails=[9]
2:  2<9, replace → tails=[2]
5:  5>2, append → tails=[2,5]
3:  3 fits between 2 and 5 → replace 5 → tails=[2,3]
7:  7>3, append → tails=[2,3,7]
101: append → tails=[2,3,7,101]
18: 18<101, replace 101 → tails=[2,3,7,18]

Final tails length = 4 — the ANSWER (length), though tails itself is NOT
necessarily a valid subsequence of the original array — it's a bookkeeping
structure, not the actual answer sequence.
```

### (c) Coin Change (minimum coins) — coins `{1, 3, 4}`, target = 6

```
STATE: dp[a] = minimum number of coins summing to exactly amount a.

dp[0] = 0 (base case: 0 coins for amount 0)
dp[1]: try each coin ≤ 1: coin=1 → dp[1] = dp[0]+1 = 1
dp[2]: coin=1 → dp[2] = dp[1]+1 = 2
dp[3]: coin=1 → dp[2]+1=3; coin=3 → dp[0]+1=1 → BEST = 1
dp[4]: coin=1 → dp[3]+1=2; coin=3 → dp[1]+1=2; coin=4 → dp[0]+1=1 → BEST = 1
dp[5]: coin=1 → dp[4]+1=2; coin=3 → dp[2]+1=3; coin=4 → dp[1]+1=2 → BEST = 2
dp[6]: coin=1 → dp[5]+1=3; coin=3 → dp[3]+1=2; coin=4 → dp[2]+1=3 → BEST = 2  (3+3)

Answer: dp[6] = 2 coins (using two 3-coins) — correctly finds the optimum,
UNLIKE the greedy approach from Chapter 10, which would have grabbed a 4
first and then struggled (4+1+1 = 3 coins, worse than DP's answer of 2).
```

---

## 4. Complexity Analysis

**LCS: O(n·m) time and space**, where n, m are the two sequence lengths — directly analogous to 0/1 Knapsack's O(n·W) table, since both are 2D DP over a pair of "how much of sequence/resource A and B have I considered" parameters.

**LIS:**
- **O(n²) DP approach:** for each of the n positions, scan all previous positions — O(n) work per position, O(n²) total.
- **O(n log n) patience sorting approach:** for each of the n elements, a binary search (Chapter 1) into the `tails` array — O(log n) per element, O(n log n) total. This is a genuinely different (and better) algorithm achieving the same result, not just an optimization of the same DP.

**Coin Change: O(amount × number of denominations)** — for each of the `amount+1` states, try each of the `k` coin denominations — O(1) work per (state, coin) pair.

**Why these complexities hold:** in every case, the complexity is (number of distinct DP states) × (cost to compute each state's transition) — the same general formula from Chapter 12, applied to each problem's specific state space and transition cost.

---

## 5. Advantages

- These three problem shapes (2D sequence alignment, 1D subsequence tracking, unbounded resource combination) cover an enormous fraction of DP problems seen in interviews and real applications — recognizing "this is LCS-shaped" or "this is Coin-Change-shaped" is a massive practical shortcut.
- LIS's O(n log n) solution demonstrates that a DP-shaped problem doesn't always need a DP-table solution — sometimes a cleverer non-DP algorithm (patience sorting) solves the same problem faster.
- Coin Change concretely demonstrates DP correctly solving a problem where greedy (Chapter 10) provably fails — a valuable, memorable illustration of the greedy-vs-DP distinction.

## 6. Limitations

- 2D DP problems (like LCS) cost O(n·m) space in their naive form — can be optimized to O(min(n,m)) using the same "only need the previous row" rolling technique from Chapter 12's Knapsack space optimization, but this sacrifices the ability to reconstruct the actual sequence (only the length remains recoverable).
- LIS's O(n log n) approach, while faster, is less intuitive and doesn't directly generalize as easily to variants (e.g., "count the number of longest increasing subsequences" is far more natural with the O(n²) DP version).
- Coin Change's DP assumes non-negative integer amounts and denominations — doesn't directly extend to real-valued or negative-allowed variants without modification.

---

## 7. Real-World Applications

- **LCS:** the Unix `diff` utility and Git's file-comparison features are built on LCS-family algorithms; DNA/protein sequence alignment in bioinformatics (with scoring-matrix variants like Needleman-Wunsch) is directly LCS-shaped.
- **LIS:** stock trend analysis (longest period of increasing prices), patience sorting's namesake card game, and scheduling problems involving compatible/ordered task sequences.
- **Coin Change:** currency/change-making systems, and more broadly, any "minimum number of resources to reach exactly a target using repeatable unit choices" problem (e.g., minimum number of standard package sizes to ship an exact weight).
- **Version Control:** merge algorithms and diff visualization tools rely on LCS-based sequence alignment.
- **Natural Language Processing:** sequence alignment techniques (related to LCS) appear in spell-checking and machine translation evaluation metrics (e.g., BLEU score calculations use related sequence-matching ideas).
- **Compilers:** some code-diffing and refactoring-detection tools use LCS-style algorithms to identify moved/modified code blocks.

---

## 8. C++ Implementation

```cpp
#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <climits>

// ---------- LONGEST COMMON SUBSEQUENCE ----------
// O(n*m) time and space.
int longestCommonSubsequence(const std::string& s1, const std::string& s2) {
    int n = s1.size(), m = s2.size();
    std::vector<std::vector<int>> dp(n + 1, std::vector<int>(m + 1, 0));

    for (int i = 1; i <= n; ++i) {
        for (int j = 1; j <= m; ++j) {
            if (s1[i - 1] == s2[j - 1]) {
                dp[i][j] = dp[i - 1][j - 1] + 1;         // characters match — extend the diagonal
            } else {
                dp[i][j] = std::max(dp[i - 1][j], dp[i][j - 1]);   // skip one char from either string
            }
        }
    }
    return dp[n][m];
}

// ---------- LONGEST INCREASING SUBSEQUENCE ----------

// O(n^2) DP approach.
int lengthOfLISQuadratic(const std::vector<int>& nums) {
    int n = nums.size();
    if (n == 0) return 0;
    std::vector<int> dp(n, 1);   // dp[i] = length of LIS ending exactly at index i

    for (int i = 1; i < n; ++i) {
        for (int j = 0; j < i; ++j) {
            if (nums[j] < nums[i]) {
                dp[i] = std::max(dp[i], dp[j] + 1);
            }
        }
    }
    return *std::max_element(dp.begin(), dp.end());
}

// O(n log n) patience-sorting approach.
int lengthOfLISOptimal(const std::vector<int>& nums) {
    std::vector<int> tails;   // tails[k] = smallest possible tail value for an increasing subsequence of length k+1

    for (int num : nums) {
        // Binary search (Chapter 1's lowerBound logic) for the first tail >= num.
        auto it = std::lower_bound(tails.begin(), tails.end(), num);
        if (it == tails.end()) {
            tails.push_back(num);   // num extends the longest subsequence so far
        } else {
            *it = num;               // num gives a smaller/equal tail for this length — improves future extensibility
        }
    }
    return static_cast<int>(tails.size());
}

// ---------- COIN CHANGE (minimum coins) ----------
// O(amount * coins.size()) time, O(amount) space.
int coinChange(const std::vector<int>& coins, int amount) {
    std::vector<int> dp(amount + 1, INT_MAX);
    dp[0] = 0;

    for (int a = 1; a <= amount; ++a) {
        for (int coin : coins) {
            if (coin <= a && dp[a - coin] != INT_MAX) {
                dp[a] = std::min(dp[a], dp[a - coin] + 1);
            }
        }
    }
    return dp[amount] == INT_MAX ? -1 : dp[amount];   // -1 signals "no valid combination"
}

// Example usage
int main() {
    std::cout << "LCS(\"ABCBDAB\", \"BDCABA\"): "
              << longestCommonSubsequence("ABCBDAB", "BDCABA") << "\n";   // 4

    std::vector<int> arr = {10, 9, 2, 5, 3, 7, 101, 18};
    std::cout << "LIS quadratic: " << lengthOfLISQuadratic(arr) << "\n";   // 4
    std::cout << "LIS optimal:   " << lengthOfLISOptimal(arr) << "\n";     // 4

    std::vector<int> coins = {1, 3, 4};
    std::cout << "Coin Change (target=6): " << coinChange(coins, 6) << "\n";   // 2

    return 0;
}
```

---

## 9. Code Walkthrough

- **`longestCommonSubsequence`'s diagonal-extend vs. skip logic:** directly implements section 3(a)'s recurrence — a character match extends `dp[i-1][j-1]` diagonally by 1; a mismatch takes the better of skipping a character from either string, exactly mirroring 0/1 Knapsack's "take or skip" structure from Chapter 12.
- **`lengthOfLISQuadratic`'s nested loop:** for each position `i`, scans every earlier position `j`, checking if `nums[j] < nums[i]` (a valid extension point) — this direct translation of the recursive definition ("what's the best increasing subsequence ending here, considering every possible predecessor") is why it costs O(n²).
- **`lengthOfLISOptimal`'s `std::lower_bound`:** This is a **direct reuse of Chapter 1's Binary Search** — `tails` is always maintained in sorted order (a fact worth proving to yourself, though it's not immediately obvious), so binary-searching it for the insertion point of each new number is valid and correct.
- **Why replacing a tail value (rather than just appending) is correct:** finding a *smaller* possible tail value for a given subsequence length doesn't shorten that subsequence — it just makes it more likely that *future* numbers can extend it, since a smaller tail is easier to exceed. This is the non-obvious insight that makes patience sorting work.
- **`coinChange`'s `dp[a-coin] != INT_MAX` guard:** prevents attempting to extend from an amount that's provably unreachable (still at the sentinel `INT_MAX`) — without this check, `dp[a-coin]+1` could silently wrap around or produce a nonsensical result due to integer overflow on `INT_MAX + 1`.

**Common mistakes to watch for here:**
- In LCS, forgetting the "1-indexed dp table vs. 0-indexed strings" offset, leading to off-by-one string-indexing errors.
- Assuming `tails` in the O(n log n) LIS approach directly represents a valid increasing subsequence of the original array — it does not; only its *length* is the meaningful output.
- Forgetting the `INT_MAX` guard in Coin Change, risking overflow or an incorrect "reachable" determination for genuinely unreachable amounts.
- Confusing 0/1 Knapsack's "each item once" constraint with Coin Change's "each coin unlimited times" constraint — this single difference changes the loop structure (Coin Change can reuse the *same* row's already-updated values within a single pass, since a coin can be used again immediately).

---

## 10. Dry Run

**`coinChange({1,3,4}, target=6)`**, already traced in full in section 3(c), arriving at `dp[6]=2` via two uses of the 3-coin. **Cross-check against the greedy failure from Chapter 10:** greedy would grab the largest fitting coin first — 4 — leaving 2, which then needs 1+1 (two more coins), totaling 3 coins overall. DP correctly finds the better 2-coin solution (3+3) by considering all possibilities systematically rather than committing irrevocably to the first "biggest fit" choice.

---

## 11. Complexity Table

| Problem | Time | Space (naive) | Space (optimized) |
|---|---|---|---|
| LCS | O(n·m) | O(n·m) | O(min(n,m)) — length only, loses reconstruction ability |
| LIS (DP) | O(n²) | O(n) | — |
| LIS (patience sorting) | O(n log n) | O(n) | — |
| Coin Change (min coins) | O(amount · k) | O(amount) | — |

**Every entry explained:** LCS and Coin Change follow the same "states × transition cost" formula from Chapter 12. LIS is the interesting case in this chapter: two genuinely *different algorithms* solve the same problem at different complexities — the O(n²) version directly mirrors the natural recursive definition, while the O(n log n) version replaces the DP table entirely with a cleverer greedy-plus-binary-search structure, illustrating that "this problem looks DP-shaped" doesn't always mean "the DP-table approach is the fastest available solution."

---

## 12. Common Mistakes

- **Off-by-one indexing errors in LCS's 2D table** — extremely common given the 1-indexed-table-vs-0-indexed-string mismatch.
- **Misunderstanding what the `tails` array represents** in the O(n log n) LIS approach — it is NOT the actual longest increasing subsequence, only a bookkeeping structure whose *length* happens to equal the answer.
- **Applying 0/1 Knapsack's loop structure to Coin Change (or vice versa)** — the "each item once" vs. "each coin unlimited" distinction changes correct loop nesting/ordering, and mixing them up silently produces wrong answers for one variant or the other.
- **Forgetting the unreachable-amount guard** in Coin Change, risking overflow-related bugs.
- **Assuming greedy would work for Coin Change** without checking whether the denomination system is canonical (directly connects back to Chapter 10's central lesson).

---

## 13. Interview Questions

**Conceptual:**
1. Explain the LCS recurrence and why a character match forces a diagonal move in the DP table.
2. Why does the O(n log n) LIS algorithm's `tails` array not represent an actual valid subsequence?
3. Why does Coin Change need DP rather than greedy, using the {1,3,4} target=6 counterexample?
4. How does Coin Change's "unbounded" (reuse allowed) nature change the DP loop structure compared to 0/1 Knapsack's "bounded" (use once) nature?
5. How would you reconstruct the actual LCS string, not just its length, from the DP table?

**Coding:**
1. Longest Common Subsequence — compute both length and the actual subsequence.
2. Longest Increasing Subsequence — implement both O(n²) and O(n log n) versions.
3. Coin Change (minimum coins) and Coin Change II (count the number of ways — a related but distinct counting variant).
4. Edit Distance (LeetCode 72) — an LCS-family variant with three operations (insert/delete/replace) instead of two.
5. Longest Common Substring — a close relative of LCS requiring *contiguous* matching (subtly different DP transition).
6. Russian Doll Envelopes (LeetCode 354) — a 2D LIS variant.

**Follow-ups / interviewer traps:**
- "Can you reduce LCS's space to O(min(n,m))?" (expects the rolling-row technique, same as Knapsack, but flagging that reconstruction becomes impossible without extra bookkeeping)
- "Coin Change II counts the number of ways — how does the loop order differ from minimum-coins Coin Change, and why?" (tests deep understanding of unbounded-knapsack loop ordering: counting *combinations* requires iterating coins in the OUTER loop to avoid counting the same combination in different orders as distinct)
- "Your LIS solution — can you extend it to also return the actual subsequence, not just its length?" (tests whether the candidate over-relies on the `tails` array without understanding its limitations, expects auxiliary parent-pointer tracking instead)

---

## 14. Practice Problems

**Easy**
- Longest Common Subsequence (LeetCode 1143)

**Medium**
- Longest Increasing Subsequence (LeetCode 300)
- Coin Change (LeetCode 322)
- Coin Change II (LeetCode 518)
- Delete Operation for Two Strings (LeetCode 583) — an LCS variant
- Maximum Length of Repeated Subarray (LeetCode 718) — Longest Common Substring variant

**Hard**
- Edit Distance (LeetCode 72)
- Longest Increasing Path in a Matrix (LeetCode 329) — LIS generalized to 2D with DFS+memoization
- Russian Doll Envelopes (LeetCode 354)
- Distinct Subsequences (LeetCode 115) — an LCS-family counting variant

Also recommended: solve the same LCS/LIS/Coin-Change-shaped problem using both the "obvious" O(n²)-or-worse approach and any faster known alternative — directly experiencing the speedup builds durable intuition for recognizing these shapes in novel problems.

---

## 15. Summary

**Key takeaways:**
- LCS, LIS, and Coin Change are three of the most reusable DP *shapes* in all of algorithmic problem-solving — an enormous fraction of "novel-looking" DP interview problems are secretly one of these three in disguise.
- LIS uniquely demonstrates that a DP-shaped problem can sometimes be solved faster by an entirely different algorithmic idea (patience sorting + binary search) rather than the direct DP table.
- Coin Change is the definitive, concrete illustration of why Greedy (Chapter 10) cannot be trusted without proof — the exact same {1,3,4}-denomination counterexample recurs throughout this guide as a reminder.

**Complexity recap:**

| | Time | Space |
|---|---|---|
| LCS | O(n·m) | O(n·m), or O(min(n,m)) optimized |
| LIS | O(n²) or O(n log n) | O(n) |
| Coin Change | O(amount · k) | O(amount) |

**Decision guide:** Recognize LCS-shaped problems by "comparing two sequences, allowing skips in either." Recognize LIS-shaped problems by "finding structure within one sequence based on an ordering relationship." Recognize Coin-Change-shaped problems by "combining repeatable units to hit an exact target." Once you've correctly identified the shape, the specific transition and complexity analysis for that shape typically follows directly from the template in this chapter.

---

*Next chapter: `14_graph_algorithms.md` — connecting back to and extending the Data Structures guide's Graphs chapters (Ch. 11-14) with additional algorithmic techniques (Floyd-Warshall, cycle detection variants, and more).*
