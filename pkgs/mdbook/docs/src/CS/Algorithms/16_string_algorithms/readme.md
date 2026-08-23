# Chapter 16: String Algorithms (Capstone)

*Study time: ~4-5 hours | Prerequisite: Data Structures guide Ch. 2 (KMP, Z-Function, Rabin-Karp) and Ch. 9 (Trie) | Difficulty: Intermediate*
*This chapter completes the Algorithms Handbook — it connects the pattern-matching algorithms already built in the Data Structures guide into the broader algorithmic pattern-recognition framework this guide has developed.*

---

## 1. Introduction

**Definition:** String Algorithms are techniques for efficiently searching, comparing, and analyzing sequences of characters. The core pattern-matching algorithms — **KMP**, the **Z-Function**, and **Rabin-Karp** — were already built in full depth in the Data Structures guide's Chapter 2, alongside **Trie** in Chapter 9. This chapter's job is different: to make sure you can *recognize* which technique a given string problem calls for, to formalize **Rolling Hash** as a standalone reusable concept (it's the engine inside Rabin-Karp, but useful far beyond it), and to place string algorithms within this guide's broader pattern-recognition framework.

**Purpose:** Knowing how KMP works is not the same as recognizing, three months later, that a brand-new problem is secretly a KMP problem. This chapter's purpose is that second, harder skill.

**Problem solved:** Given a new, unfamiliar string problem, correctly identify whether it calls for exact pattern matching (KMP/Z), approximate/multi-pattern/hash-based matching (Rabin-Karp/Rolling Hash), or prefix-structure exploitation (Trie) — and know why.

---

## 2. Intuition

Revisit the core intuition from the Data Structures guide's String chapter: brute-force string matching wastes time because it "forgets" everything it learned about a partial match the moment a mismatch occurs, and starts over from scratch. **Every efficient string algorithm's entire value proposition is finding a way to NOT forget that information:**
- **KMP's LPS array** remembers "how much of what I've already matched is also a valid prefix, so I can resume from there instead of restarting."
- **The Z-Function** remembers "how far does the match against the string's own prefix extend at every position," a single array answering many different structural questions at once.
- **Rabin-Karp's rolling hash** remembers a numeric fingerprint of the current window, updatable in O(1) as the window slides, rather than re-fingerprinting from scratch.
- **A Trie** remembers shared prefixes structurally, so a family of strings sharing a prefix only pays for that prefix's storage/traversal once.

Recognizing *which* piece of "memory" a new problem needs is the actual skill this chapter targets.

---

## 3. Step-by-Step Working

### (a) Rolling Hash, formalized as its own tool (the engine inside Rabin-Karp)

A rolling hash lets you maintain a hash of a sliding window in O(1) per slide, rather than O(window size). The general technique (already shown in the Data Structures guide for Rabin-Karp) generalizes beyond exact pattern matching:

```
Polynomial rolling hash of a string s (treating characters as digits in base B, modulo M):
hash(s) = (s[0]*B^(L-1) + s[1]*B^(L-2) + ... + s[L-1]*B^0) mod M

Sliding from window [i, i+L-1] to [i+1, i+L]:
newHash = ( (oldHash - s[i]*B^(L-1)) * B + s[i+L] ) mod M
          "remove the outgoing character's contribution"   "shift everything up, add the new character"
```

**Beyond simple pattern matching, rolling hash directly enables:**
- **Finding the longest duplicated substring** in a text (binary search on the length — Chapter 1 — combined with a rolling-hash-based set of all substrings of that length, checking for a collision).
- **Comparing substrings for equality in O(1)** after O(n) preprocessing (precompute all prefix hashes; then any substring's hash is derivable in O(1) via the same subtraction trick prefix sums use — directly connecting back to Chapter 9's Prefix Sum, since a rolling/prefix hash IS structurally a prefix sum in a different number base).
- **Detecting duplicate substrings/plagiarism** across large documents by comparing hash sets rather than raw substrings.

### (b) Pattern Recognition — mapping problem phrasing to the right technique

```
"Does text contain pattern, find all occurrences" (single pattern, exact)
  → KMP or Z-Function (Data Structures guide, Ch. 2)

"Does text contain ANY of these many patterns" (multi-pattern)
  → Rabin-Karp with multiple hashes, or Aho-Corasick (a Trie + KMP-failure-function hybrid,
    an advanced extension worth knowing exists even without full implementation here)

"Compare many substrings for equality repeatedly" / "find longest duplicated substring"
  → Rolling Hash (precomputed prefix hashes + O(1) substring hash queries)

"Autocomplete", "does any word start with this prefix", "longest common prefix of many strings"
  → Trie (Data Structures guide, Ch. 9)

"Find the longest palindromic substring/subsequence"
  → Expand-around-center (O(n²)) for substring; Dynamic Programming (Ch. 12-13, LCS-style —
    a palindrome IS the LCS of a string and its reverse) for subsequence; Manacher's algorithm
    (an advanced O(n) technique, overview-level: uses a similar "don't recompute known
    information" insight as KMP, applied to palindrome radii instead of prefix matches)

"Edit distance between two strings" (insert/delete/replace operations)
  → Dynamic Programming (Ch. 13's LCS family, generalized to three operations instead of two)

"Anagram / character frequency matching within a sliding window"
  → Sliding Window (Ch. 8) + a frequency array/hash map
```

---

## 4. Complexity Analysis

**Rolling Hash (build + query):** O(n) to precompute all prefix hashes of a string of length n; **O(1) per substring-equality query** afterward (via the same subtraction-based range trick as Prefix Sum, Chapter 9) — though note this is a **probabilistic** guarantee (hash collisions are possible, if rare with a good modulus), unlike KMP/Z's airtight worst-case correctness.

**Why rolling hash queries are O(1) — the same reasoning as Prefix Sum:** once prefix hashes are precomputed, any substring's hash is derivable via subtraction from two precomputed values, exactly like a range-sum query — this is not a coincidence; a polynomial rolling hash IS mathematically a prefix sum, just computed in a different base with modular arithmetic.

**Recap of the core three algorithms' complexities (fully derived in the Data Structures guide, Chapter 2):**

| Algorithm | Time | Guarantee |
|---|---|---|
| KMP | O(n+m) | Worst-case guaranteed |
| Z-Function | O(n+m) | Worst-case guaranteed |
| Rabin-Karp | O(n+m) expected | Probabilistic (collision risk) |

---

## 5. Advantages

- Rolling Hash generalizes far beyond simple pattern matching — substring equality comparison, duplicate detection, and plagiarism-style matching all reuse the identical O(1)-per-slide-update mechanism.
- Recognizing the *shape* of a string problem (single-pattern exact match vs. multi-pattern vs. prefix-structure vs. hash-comparison) is a transferable skill that generalizes to novel problems you haven't seen before, unlike memorizing individual algorithms in isolation.
- The connection between rolling hash and prefix sum (both are "precompute cumulative information, derive any range via subtraction") reinforces a pattern that recurs constantly throughout this entire guide.

## 6. Limitations

- Rolling hash is fundamentally probabilistic — a hash collision (two different substrings hashing identically) is possible, if rare with a well-chosen large prime modulus; applications requiring airtight correctness (security-sensitive matching) should prefer KMP/Z-Function or verify hash matches with a direct character comparison (as the Data Structures guide's Rabin-Karp implementation already does).
- Aho-Corasick (multi-pattern matching) is mentioned here only at the overview level — implementing it fully requires combining a Trie's structure with KMP-style failure links, a genuinely more advanced undertaking beyond this chapter's scope.
- Manacher's algorithm (O(n) palindrome detection) is similarly mentioned only at the overview level — the DP-based or expand-around-center approaches are more commonly expected in standard interviews, with Manacher's reserved for specifically palindrome-heavy competitive programming contexts.

---

## 7. Real-World Applications

*(Already covered in depth in the Data Structures guide's String chapter for KMP/Z/Rabin-Karp specifically — text editors, search engines, bioinformatics, network security, plagiarism detection. Rolling Hash's applications extend further:)*

- **Plagiarism/Duplicate Detection Systems:** comparing large documents via rolling-hash fingerprints of substrings (shingling techniques) rather than raw text comparison — this is how many real plagiarism detectors and "similar document" search features work at scale.
- **Version Control / Deduplication:** systems like rsync and git use rolling-hash-based techniques (specifically, a form related to Rabin fingerprinting) to detect which parts of a file have changed without re-transmitting/re-storing unchanged content.
- **Distributed Systems:** content-addressable storage and chunk-based deduplication (e.g., in backup systems) commonly use rolling hashes to find chunk boundaries.

---

## 8. C++ Implementation

```cpp
#include <iostream>
#include <vector>
#include <string>
#include <unordered_set>

// Rolling Hash utility class: precompute prefix hashes, then answer O(1) substring hash queries.
// This generalizes the Rabin-Karp rolling hash (Data Structures guide, Ch.2) into a reusable tool.
class RollingHash {
private:
    std::vector<long long> prefixHash;
    std::vector<long long> powers;
    static const long long BASE = 131;
    static const long long MOD = 1000000007LL;

public:
    explicit RollingHash(const std::string& s) {
        int n = s.size();
        prefixHash.assign(n + 1, 0);
        powers.assign(n + 1, 1);

        for (int i = 0; i < n; ++i) {
            prefixHash[i + 1] = (prefixHash[i] * BASE + s[i]) % MOD;
            powers[i + 1] = (powers[i] * BASE) % MOD;
        }
    }

    // Hash of substring s[l..r] (inclusive, 0-indexed). O(1) — the same subtraction
    // trick as Prefix Sum (Chapter 9), just in modular arithmetic over a different base.
    long long substringHash(int l, int r) const {
        long long result = (prefixHash[r + 1] - prefixHash[l] * powers[r - l + 1]) % MOD;
        return (result + MOD) % MOD;   // ensure non-negative result under modular arithmetic
    }
};

// Find the longest duplicated substring using Binary Search (Ch.1) + Rolling Hash.
// O(n log n) expected — binary search over length, O(n) hash-collision check per length.
std::string longestDuplicateSubstring(const std::string& s) {
    RollingHash rh(s);
    int n = s.size();
    int lo = 1, hi = n - 1, bestLen = 0, bestStart = -1;

    while (lo <= hi) {
        int mid = lo + (hi - lo) / 2;   // candidate LENGTH to check (binary search on the answer — Ch.1)
        std::unordered_set<long long> seen;
        int foundStart = -1;

        for (int i = 0; i + mid <= n; ++i) {
            long long h = rh.substringHash(i, i + mid - 1);
            if (seen.count(h)) { foundStart = i; break; }   // hash collision candidate — a probable duplicate
            seen.insert(h);
        }

        if (foundStart != -1) {
            bestLen = mid; bestStart = foundStart;
            lo = mid + 1;     // try for an even longer duplicate
        } else {
            hi = mid - 1;      // no duplicate of this length — try shorter
        }
    }
    return bestStart == -1 ? "" : s.substr(bestStart, bestLen);
}

// Example usage
int main() {
    RollingHash rh("abcabc");
    std::cout << "hash(0,2) == hash(3,5)? "
              << (rh.substringHash(0, 2) == rh.substringHash(3, 5)) << "\n";   // 1 (true) — both are "abc"

    std::cout << "Longest duplicate substring in \"banana\": \""
              << longestDuplicateSubstring("banana") << "\"\n";   // "ana"

    return 0;
}
```

---

## 9. Code Walkthrough

- **`RollingHash`'s constructor precomputing BOTH `prefixHash` and `powers`:** `powers[k]` stores `BASE^k mod MOD`, needed because `substringHash`'s subtraction trick must "shift" the left boundary's contribution by the correct power of the base before subtracting — precomputing these powers once avoids recomputing `BASE^k` from scratch (which would cost O(k) via naive exponentiation) on every query.
- **`substringHash`'s formula, directly mirroring Prefix Sum's `sum(L,R) = prefix[R] - prefix[L-1]`:** here it's `prefixHash[r+1] - prefixHash[l] * powers[r-l+1]`, with the extra multiplication by `powers[...]` needed because, unlike simple addition (where every position contributes equally), each character's contribution to a polynomial hash depends on its *position*, so removing the correct number of leading characters' worth of "positional weight" requires this extra scaling factor.
- **The `+ MOD) % MOD` at the end:** modular subtraction in C++ can produce a negative intermediate result (since `%` can return negative values for negative operands) — adding `MOD` before the final modulo ensures a correctly non-negative result, the exact same defensive pattern used in the Data Structures guide's Rabin-Karp implementation.
- **`longestDuplicateSubstring`'s binary-search-on-the-answer structure:** This is a direct, concrete reuse of Chapter 1's technique — "is there a duplicate substring of length `mid`?" is a monotonic yes/no predicate (if a duplicate of length L exists, one of length L-1 trivially also exists, by just truncating it), making binary search over the candidate length valid and correct.
- **Why a hash COLLISION here is only a "candidate," not proof:** strictly speaking, a full implementation should verify a hash match with a direct substring comparison (as the Data Structures guide's Rabin-Karp does) before accepting it as a genuine duplicate — omitted here for clarity, but essential in production code to eliminate the (rare) false-positive risk.

**Common mistakes to watch for here:**
- Forgetting the positional-weight scaling factor (`powers[...]`) in the substring hash subtraction — a very easy detail to miss when adapting the simple Prefix Sum formula to this modular, positionally-weighted context.
- Not verifying a hash "match" with a direct character comparison before treating it as a confirmed duplicate — risks a (rare but real) false positive from a hash collision.
- Using a small modulus or predictable base, increasing collision risk — always prefer a large prime modulus, as shown.

---

## 10. Dry Run

**`RollingHash("abcabc").substringHash(0,2)` vs. `substringHash(3,5)`** — both should equal the hash of "abc":

```
prefixHash computed incrementally as: a, ab, abc, abca, abcab, abcabc (each step: prev*BASE + char, mod MOD)

substringHash(0,2) = prefixHash[3] - prefixHash[0]*powers[3]
                    = hash("abc") - 0*powers[3]
                    = hash("abc")

substringHash(3,5) = prefixHash[6] - prefixHash[3]*powers[3]
                    = hash("abcabc") - hash("abc")*BASE³
                    = [removes the "abc" prefix's positional contribution from the full "abcabc" hash,
                       leaving exactly the hash equivalent of the trailing "abc"]

Both evaluate to the same numeric value (modulo the astronomically unlikely event of an
unrelated hash collision) — confirming both substrings are "abc". ✓
```

---

## 11. Complexity Table

| Technique | Time | Space | Guarantee |
|---|---|---|---|
| KMP / Z-Function (recap) | O(n+m) | O(m) / O(n+m) | Worst-case exact |
| Rabin-Karp (recap) | O(n+m) expected | O(1) | Probabilistic |
| Rolling Hash (build + query) | O(n) build, O(1) query | O(n) | Probabilistic |
| Longest Duplicate Substring (binary search + rolling hash) | O(n log n) expected | O(n) | Probabilistic |
| Trie (recap, Data Structures guide Ch.9) | O(L) per op | O(total chars) | Exact |

**Every entry explained:** Rolling Hash's O(1) query cost is identical in structure to Prefix Sum's O(1) query cost (Chapter 9) — both trade O(n) upfront preprocessing for O(1) answers to a large number of subsequent range-style queries, differing only in what's being aggregated (sums vs. positional hash values) and the resulting correctness guarantee (exact for sums, probabilistic for hashes).

---

## 12. Common Mistakes

- **Forgetting hash verification** — treating a rolling-hash match as proof rather than a strong candidate needing confirmation.
- **Misapplying the positional-weight scaling factor** when adapting the Prefix Sum subtraction pattern to rolling hash's modular, position-sensitive context.
- **Choosing a poor base/modulus combination**, increasing real-world collision risk — always use a large prime modulus and a base larger than the alphabet size.
- **Not recognizing when a problem is secretly Trie-shaped, KMP-shaped, or Rolling-Hash-shaped** — the biggest practical risk in this entire chapter is pattern-recognition failure, not implementation error; always ask "am I dealing with single exact matching, multi-pattern matching, prefix structure, or repeated substring comparison?" before choosing a tool.
- **Reaching for Dynamic Programming (Edit Distance, palindrome subsequence) when a simpler, faster string-specific technique would do**, or vice versa — always check whether the problem's core need is genuinely "compare/align two sequences with flexible operations" (DP's territory) versus "match/search within one sequence" (KMP/Z/Rabin-Karp/Trie's territory).

---

## 13. Interview Questions

**Conceptual:**
1. Explain why a polynomial rolling hash is mathematically a prefix sum in a different number base.
2. When would you choose Rolling Hash over KMP/Z-Function for a pattern-matching task, given Rolling Hash's probabilistic nature?
3. How does binary-search-on-the-answer (Chapter 1) combine with Rolling Hash to solve Longest Duplicate Substring?
4. What is Aho-Corasick, conceptually, and what two techniques does it combine?
5. Given a new, unfamiliar string problem, walk through your process for identifying which technique applies.

**Coding:**
1. Implement a reusable Rolling Hash class supporting O(1) substring comparison.
2. Longest Duplicate Substring (LeetCode 1044) — binary search + rolling hash.
3. Repeated DNA Sequences (LeetCode 187) — direct rolling-hash application.
4. Shortest Palindrome (LeetCode 214) — KMP-based approach (recap from Data Structures guide Ch.2).
5. Implement strStr() using each of KMP, Z-Function, and Rabin-Karp — compare all three side by side.

**Follow-ups / interviewer traps:**
- "Your rolling hash found a match — are you certain it's a real match?" (tests whether the candidate remembers to verify with direct comparison, guarding against collision-based false positives)
- "Can you extend Rolling Hash to 2D (matching a small grid pattern within a larger grid)?" (tests generalizing the 1D technique — yes, via a 2D polynomial hash, analogous to the Data Structures guide's 2D Prefix Sum)
- "Why might an interviewer prefer you use KMP over Rabin-Karp for a security-sensitive string-matching feature?" (tests understanding of the exact-vs-probabilistic guarantee distinction and its real-world stakes)

---

## 14. Practice Problems

**Easy**
- Implement strStr() (LeetCode 28) — solve with all three techniques for comparison

**Medium**
- Repeated DNA Sequences (LeetCode 187)
- Longest Happy Prefix (LeetCode 1392) — recap from Data Structures guide Ch.2
- Find All Anagrams in a String (LeetCode 438) — Sliding Window + frequency map (Ch.8), not string-matching-specific

**Hard**
- Longest Duplicate Substring (LeetCode 1044)
- Shortest Palindrome (LeetCode 214)
- Distinct Echo Substrings (LeetCode 1316) — rolling hash + set-based duplicate detection

Also recommended: revisit the Data Structures guide's Chapter 2 practice problems (KMP/Z/Rabin-Karp) alongside this chapter's rolling-hash-specific problems to build a complete, tested string-algorithms toolkit.

---

## 15. Summary

**Key takeaways:**
- Every efficient string algorithm's core value is "not forgetting information a naive approach would discard" — KMP/Z remember prefix-overlap structure; Rabin-Karp/Rolling Hash remember a numeric fingerprint updatable in O(1); Trie remembers shared prefixes structurally.
- Rolling Hash is mathematically a prefix sum in a different number base — recognizing this connection (rather than treating it as an unrelated new technique) reinforces the "precompute cumulative info, derive ranges via subtraction" pattern that recurs throughout this guide.
- The hardest and most valuable skill in this entire chapter — and arguably this entire guide — is pattern recognition: correctly identifying which of these techniques (or which combination) a novel, unfamiliar problem actually calls for.

**Complexity recap:**

| | Time | Guarantee |
|---|---|---|
| KMP / Z-Function | O(n+m) | Exact, worst-case |
| Rabin-Karp / Rolling Hash | O(n+m) expected | Probabilistic |
| Trie | O(L) per operation | Exact |

**Decision guide:** Single-pattern exact matching with an airtight guarantee → KMP or Z-Function. Multi-pattern or substring-comparison-heavy problems where a small collision risk is acceptable → Rolling Hash / Rabin-Karp. Prefix-structure-heavy problems (autocomplete, dictionary matching) → Trie. Sequence-alignment problems with flexible edit operations → Dynamic Programming (Chapters 12-13). Whenever unsure, ask: "is this about finding an exact pattern, comparing many substrings, exploiting shared prefixes, or aligning two sequences with edits?" — the answer points directly at the right tool.

---

## Guide Complete — Final Reflection

This completes The Algorithms Handbook, spanning: the Complexity Analysis primer → Binary Search → Sorting (Simple, Merge, Quick, Heap, Non-Comparison) → Two Pointer / Sliding Window / Prefix Sum → Greedy → Backtracking → Dynamic Programming (Fundamentals and Classic Problems) → Graph Algorithms (extending the Data Structures guide with Floyd-Warshall and cycle detection) → Tree Algorithms → String Algorithms.

The throughline worth carrying forward, echoing the companion Data Structures guide's own closing reflection: almost every algorithm in this guide is either (a) a clever way of **not repeating work you've already done** — memoization, rolling hashes, prefix sums, the LPS array, all fundamentally the same idea applied in different contexts — or (b) a **provable argument for why a greedy local choice is globally safe**, when such an argument exists, and a fallback to systematic exhaustive search (backtracking) or careful state-tracking (DP) when it doesn't. When you meet an unfamiliar algorithm in the future, asking "what redundant work is this avoiding, and why is that avoidance provably correct?" will get you most of the way to understanding it — the same lens this entire guide has used, chapter after chapter.
