# Chapter 2: Strings (Pattern Matching — KMP, Z-Function, Rabin-Karp)

*Study time: ~7-9 hours | Prerequisite: Arrays | Difficulty: Beginner (basics) to Advanced (pattern-matching algorithms)*

---

## 1. Introduction

**Definition:** A string is an array of characters — everything from Chapter 1 (Arrays) applies directly, with one addition: strings come with a rich set of **substring/pattern-matching** problems ("does text T contain pattern P? where? how many times?") that are common and important enough to deserve dedicated, highly-optimized algorithms.

**Purpose:** To efficiently search for, compare, and manipulate sequences of characters — and specifically, to find occurrences of a smaller pattern inside a larger text in far better than the naive O(n·m) time (text length n, pattern length m) that a brute-force check-every-position approach requires.

**Real-world analogy:** Searching for a phrase in a book by brute force means, at every single page position, checking character-by-character whether the phrase starts there — extremely wasteful, since most positions fail almost immediately and tell you nothing useful about where to look next. A smart pattern-matching algorithm is like a reader who, upon a partial match failing, immediately knows — from what they'd already read — exactly how far they can safely skip ahead, never re-reading text they've effectively already ruled out.

**Motivation:** String searching is everywhere — text editors' "find" feature, DNA sequence matching in bioinformatics, detecting plagiarism, network intrusion detection (matching known attack signatures in traffic), and search engines. The naive approach becomes a real bottleneck at scale (large texts, many repeated searches), motivating algorithms that exploit the *structure* of the pattern itself to skip redundant comparisons.

**History:** The Knuth-Morris-Pratt (KMP) algorithm was published in 1977 (Knuth, Morris, and Pratt); Rabin-Karp followed in 1987 (Rabin and Karp), using a completely different hashing-based strategy; the Z-function is a more modern, versatile building block that elegantly solves pattern matching and several related problems using one unified array.

---

## 2. Why Do We Need It?

**Problem it solves:** Finding all occurrences of a pattern P (length m) within a text T (length n) faster than the naive O(n·m) brute-force approach — ideally in O(n + m).

**Why the naive approach is insufficient:** Brute force slides the pattern across every possible starting position in the text and, at each position, compares character by character until a mismatch or a full match. Its worst case (e.g., text = "aaaaaaaaaa...a", pattern = "aaaa...ab") re-does almost the same wasted comparisons at every single shifted position — O(n·m) total, which is far too slow for large texts or patterns (e.g., searching a short pattern in a multi-gigabyte genome file).

**Trade-offs:**
- You gain O(n + m) matching (KMP, Z-function) or expected O(n + m) with tiny worst-case risk (Rabin-Karp, due to hash collisions) — both dramatically better than brute force.
- You pay for it with O(m) preprocessing time/space to build an auxiliary structure (KMP's "failure function," the Z-array, or Rabin-Karp's rolling hash) *before* the actual search begins — a worthwhile one-time cost that pays for itself immediately when scanning any text of meaningful length.

---

## 3. Internal Working

### (a) KMP Algorithm — the "failure function" / "longest proper prefix-suffix" (LPS) array

**Core idea:** Precompute, for every prefix of the pattern, the length of the longest proper prefix of that prefix which is *also* a suffix of it. This tells you, upon a mismatch during matching, exactly how far you can shift the pattern *without* re-checking characters you've already confirmed match — because the LPS array already tells you the longest reusable overlap.

**LPS array for pattern "ABABAC":**
```
Pattern:  A  B  A  B  A  C
Index:    0  1  2  3  4  5
LPS:      0  0  1  2  3  0
```
Reading LPS[4]=3 means: the prefix "ABABA" (length 5, index 0-4) has its longest proper prefix-that's-also-a-suffix being "ABA" (length 3).

**Matching walkthrough** — text = "ABABABAC", pattern = "ABABAC":
```
Compare text[0..5]="ABABAB" vs pattern="ABABAC":
  A=A, B=B, A=A, B=B, A=A, B≠C → MISMATCH at pattern index 5.

Naive approach: shift by 1, restart comparison from scratch — wasteful.
KMP: consult LPS[5-1]=LPS[4]=3 → we know the last 3 matched characters ("ABA")
     are also a valid prefix of the pattern — so instead of restarting from
     pattern index 0, resume comparing from pattern index 3 (LPS value),
     without re-checking those 3 characters at all.

Continue: text[5]='B' vs pattern[3]='B' → match. text[6]='A' vs pattern[4]='A' → match.
          text[7]='C' vs pattern[5]='C' → match. FULL MATCH found at text index 2.
```

**Why this is O(n+m):** building the LPS array is O(m) (each character processed via similar overlap logic, done once), and the main scan through the text is O(n) — crucially, the *text* pointer only ever moves forward, never backtracks, while the *pattern* pointer uses the LPS array to "smart jump" instead of restarting — giving strictly linear total work.

### (b) Z-Function — one array, many uses

**Core idea:** For a string S, the Z-array's entry `Z[i]` = the length of the longest substring starting at `i` that is also a **prefix** of S. To find pattern P in text T, form the combined string `P + "$" + T` (using a separator character `$` guaranteed not to appear in either), compute its Z-array, and any position where `Z[i] == length(P)` marks a full match of P within T.

**Example:** S = "aabxaabxcaabxaab", finding pattern "aab" via combined string `"aab$" + S`... (conceptually — the Z-array is computed once over the combined string, and every index where the Z-value equals the pattern's length is a match location).

**Why this generalizes KMP:** The Z-function directly encodes "how much of the prefix repeats starting here," which is a more general and often more intuitive tool than KMP's LPS array — the same Z-array can also solve string periodicity questions, finding all borders of a string, and computing the LPS array itself in a unified way, whereas KMP's LPS array is narrowly specialized to just the matching task.

### (c) Rabin-Karp — hashing-based matching

**Core idea:** Instead of comparing characters directly, compute a **rolling hash** of every length-m substring of the text and compare it to the pattern's hash — if the hashes match, do a (cheap, rare) direct character verification to rule out a hash collision; otherwise, skip immediately.

**Rolling hash — the key trick:** naively recomputing a hash for every new window would be O(m) per window (O(n·m) total, no better than brute force). Instead, a rolling hash lets you compute the *next* window's hash from the *current* one in O(1):
```
hash(T[i+1..i+m]) = (hash(T[i..i+m-1]) - T[i]*base^(m-1)) * base + T[i+m]
                     "remove the old leading character"   "shift and add the new trailing character"
```
This O(1) update per position is what gives Rabin-Karp its O(n+m) expected time — computing n rolling-hash updates (O(n)) plus the initial pattern hash (O(m)).

```
Text: "ABCDAB", Pattern: "CDA" (m=3). Rolling hash with base=10 (illustrative, not a real hash base):
hash("ABC") computed directly = some value H1.
hash("BCD") = (H1 - 'A'*10^2) * 10 + 'D'   ← O(1) update, not recomputed from scratch.
hash("CDA") = (H_BCD - 'B'*10^2) * 10 + 'A' ← compare this to hash("CDA") pattern hash → MATCH → verify directly → confirmed.
```

---

## 4. Operations

**KMP — Build LPS array:**
- For each position i in the pattern, extend the previous longest prefix-suffix match, falling back via the LPS array itself when a character doesn't extend the match (a clever "look up your own previous work" recursive-feeling but actually linear process).
- O(m).

**KMP — Search:**
- Walk the text with one pointer; walk the pattern with another. On a match, advance both. On a mismatch, consult the LPS array to know how far to "smart jump" the pattern pointer (never the text pointer, which always moves forward).
- O(n).

**Z-Function — Build:**
- Maintain a window `[L, R]` representing the rightmost Z-box found so far (a maximal match against the prefix); use previously computed Z-values to skip redundant comparisons when a new position falls inside that window, extending only when needed.
- O(n) for a string of length n (amortized — the window's right edge only ever moves forward).

**Rabin-Karp — Build initial hash + Search:**
- Compute the pattern's hash and the text's first window's hash directly, O(m).
- Slide the window across the text, updating the hash in O(1) each step; on a hash match, verify with a direct character comparison (O(m) worst case per verification, but rare in practice with a good hash function).
- O(n) expected total; O(n·m) worst case under adversarial input or a poor hash function causing many collisions.

**Common string operations (built on Arrays, Chapter 1):** concatenation, substring extraction, comparison — all inherit array's complexity characteristics (O(n) for most whole-string operations, O(1) for single-character access) unless a language's specific string implementation adds its own optimizations (e.g., some languages use rope structures for very large, frequently-edited strings, trading O(1) access for better edit performance).

---

## 5. Time & Space Complexity

| Algorithm | Preprocessing | Search | Space | Notes |
|---|---|---|---|---|
| Brute Force | O(1) | O(n·m) worst case | O(1) | Simple but slow on adversarial input |
| KMP | O(m) | O(n) | O(m) for LPS array | Worst-case guaranteed O(n+m) total |
| Z-Function | O(n+m) (on combined string) | (built into preprocessing) | O(n+m) for Z-array | Also solves periodicity, borders, and more |
| Rabin-Karp | O(m) | O(n) expected, O(n·m) worst case | O(1) extra (just the rolling hash) | Worst case only under hash collisions; easily randomized away |

**Why these hold:**
- KMP's O(n) search comes from the invariant that the text pointer **never moves backward** — every character in the text is examined a bounded number of times overall (the amortized argument is subtle but the practical guarantee is airtight: total comparisons across the whole search are O(n)).
- The Z-function's O(n) build relies on the same "never redo work already implied by a previous computation" principle — the window `[L,R]` tracking the rightmost known prefix-match only ever extends rightward, bounding total extension work by the string's length.
- Rabin-Karp's O(1) rolling hash update is what turns what would otherwise be O(n·m) (recomputing each window's hash from scratch) into O(n) — but this guarantee is only "expected," since a malicious or unlucky input causing many hash collisions forces the O(m) verification step to run at nearly every position, degrading to O(n·m) in the worst case (mitigated by using a large enough modulus and/or randomized hash base in practice).

---

## 6. Advantages

- All three pattern-matching algorithms achieve linear (or expected linear) total time — a dramatic, practically important improvement over brute force for any non-trivial text/pattern size.
- KMP's guarantee is worst-case airtight — no adversarial input can degrade it, unlike Rabin-Karp.
- Rabin-Karp generalizes elegantly to **multiple pattern search** (checking a window's hash against a *set* of pattern hashes) and 2D pattern matching, where KMP's character-by-character logic doesn't extend as naturally.
- The Z-function is a genuinely multi-purpose tool — beyond matching, it directly solves "find all periods of a string," "find the shortest string whose repetition forms this string," and related structural string questions.

## 7. Disadvantages

- KMP and the Z-function require O(m) or O(n) extra space for their auxiliary arrays — usually negligible, but notable compared to Rabin-Karp's O(1) extra space.
- Rabin-Karp's worst-case time bound is *not* guaranteed — it depends on hash quality and can be exploited adversarially if the hash function/modulus is predictable or poorly chosen.
- All three are more intricate to implement correctly than brute force — off-by-one errors in index bookkeeping are common, especially in KMP's LPS-array construction and the Z-function's window-tracking logic.

---

## 8. Real-World Applications

- **Text Editors / IDEs:** "Find" and "Find and Replace" features rely on fast substring search — often KMP or a close relative for guaranteed performance.
- **Search Engines:** Matching query terms against indexed documents; more advanced multi-pattern variants (Aho-Corasick, built on similar failure-function ideas) handle matching many patterns simultaneously.
- **Bioinformatics:** DNA/protein sequence matching, where texts can be enormous (entire genomes) and pattern matching needs to be extremely fast and reliable.
- **Network Security:** Intrusion detection systems match network packet contents against known attack signature patterns in real time.
- **Plagiarism Detection:** Finding overlapping substrings between documents, often built on rolling-hash techniques closely related to Rabin-Karp.
- **Compilers:** Lexical analysis (tokenizing source code) uses pattern-matching-adjacent techniques to recognize keywords, identifiers, and symbols.
- **Version Control Systems (e.g., git diff):** Finding common substrings/matching regions between file versions uses related string-matching and hashing techniques.

---

## 9. Implementation (C++17)

```cpp
#include <iostream>
#include <string>
#include <vector>

// ---------- KMP ALGORITHM ----------

// Build the LPS (Longest Proper Prefix which is also Suffix) array. O(m).
std::vector<int> buildLPS(const std::string& pattern) {
    int m = pattern.size();
    std::vector<int> lps(m, 0);
    int len = 0;   // length of the previous longest prefix-suffix match
    int i = 1;

    while (i < m) {
        if (pattern[i] == pattern[len]) {
            len++;
            lps[i] = len;
            i++;
        } else if (len != 0) {
            len = lps[len - 1];   // fall back using the LPS array itself — the key trick
        } else {
            lps[i] = 0;
            i++;
        }
    }
    return lps;
}

// KMP search: returns all starting indices where pattern occurs in text. O(n + m).
std::vector<int> kmpSearch(const std::string& text, const std::string& pattern) {
    std::vector<int> matches;
    int n = text.size(), m = pattern.size();
    if (m == 0) return matches;

    std::vector<int> lps = buildLPS(pattern);
    int i = 0, j = 0;   // i = text pointer, j = pattern pointer

    while (i < n) {
        if (text[i] == pattern[j]) {
            i++;
            j++;
            if (j == m) {
                matches.push_back(i - j);   // full match found
                j = lps[j - 1];               // continue searching for overlapping matches
            }
        } else if (j != 0) {
            j = lps[j - 1];                    // smart jump — text pointer i does NOT move
        } else {
            i++;                                 // no partial match to fall back on
        }
    }
    return matches;
}

// ---------- Z-FUNCTION ----------

// Build the Z-array. Z[i] = length of longest substring starting at i matching a prefix of s. O(n).
std::vector<int> buildZArray(const std::string& s) {
    int n = s.size();
    std::vector<int> z(n, 0);
    int L = 0, R = 0;   // the current rightmost "Z-box" window [L, R]

    for (int i = 1; i < n; ++i) {
        if (i < R) {
            z[i] = std::min(R - i, z[i - L]);   // reuse previously computed info within the window
        }
        while (i + z[i] < n && s[z[i]] == s[i + z[i]]) {
            z[i]++;                                // extend the match character by character
        }
        if (i + z[i] > R) {
            L = i;
            R = i + z[i];                          // grow the window rightward
        }
    }
    return z;
}

// Pattern matching via Z-function: pattern + separator + text, then scan for Z[i] == pattern length.
std::vector<int> zSearch(const std::string& text, const std::string& pattern) {
    std::vector<int> matches;
    std::string combined = pattern + "$" + text;   // '$' assumed not to appear in either string
    std::vector<int> z = buildZArray(combined);
    int m = pattern.size();

    for (int i = m + 1; i < static_cast<int>(combined.size()); ++i) {
        if (z[i] == m) {
            matches.push_back(i - m - 1);   // convert combined-string index back to text index
        }
    }
    return matches;
}

// ---------- RABIN-KARP ----------

std::vector<int> rabinKarpSearch(const std::string& text, const std::string& pattern) {
    std::vector<int> matches;
    int n = text.size(), m = pattern.size();
    if (m == 0 || m > n) return matches;

    const long long BASE = 256;
    const long long MOD = 1000000007LL;   // a large prime to reduce collision probability

    long long patternHash = 0, textHash = 0, power = 1;
    for (int i = 0; i < m - 1; ++i) power = (power * BASE) % MOD;   // BASE^(m-1) % MOD

    for (int i = 0; i < m; ++i) {
        patternHash = (patternHash * BASE + pattern[i]) % MOD;
        textHash = (textHash * BASE + text[i]) % MOD;
    }

    for (int i = 0; i <= n - m; ++i) {
        if (patternHash == textHash) {
            // Hashes match — verify directly to rule out a (rare) collision.
            if (text.substr(i, m) == pattern) {
                matches.push_back(i);
            }
        }
        if (i < n - m) {
            // Roll the hash forward: remove leading char, shift, add new trailing char. O(1).
            textHash = (textHash - text[i] * power % MOD + MOD * BASE) % MOD;   // avoid negative mod
            textHash = (textHash * BASE + text[i + m]) % MOD;
        }
    }
    return matches;
}

// Example usage
int main() {
    std::string text = "ABABABAC";
    std::string pattern = "ABABAC";

    std::cout << "KMP matches: ";
    for (int idx : kmpSearch(text, pattern)) std::cout << idx << " ";
    std::cout << "\n";   // 2

    std::cout << "Z-function matches: ";
    for (int idx : zSearch(text, pattern)) std::cout << idx << " ";
    std::cout << "\n";   // 2

    std::cout << "Rabin-Karp matches: ";
    for (int idx : rabinKarpSearch(text, pattern)) std::cout << idx << " ";
    std::cout << "\n";   // 2

    return 0;
}
```

---

## 10. Code Walkthrough

- **`buildLPS`'s fallback (`len = lps[len - 1]`):** This single line is the entire trick behind KMP — instead of restarting the "how much overlap do I have" computation from scratch on a mismatch, it reuses previously computed LPS values. This is structurally very similar to DSU's path compression or DP's memoization: *don't recompute what you've already figured out*.
- **`kmpSearch`'s two pointers:** `i` (text) and `j` (pattern). Crucially, **`i` never decreases** — every character in the text is looked at a bounded number of times overall, which is exactly why the total search is O(n) and not O(n·m). The "smart jump" (`j = lps[j-1]`) only ever moves the *pattern* pointer backward, never the text pointer.
- **`buildZArray`'s window `[L, R]`:** When processing index `i` that falls inside a previously-found match window, we can bound (via `std::min`) how much extension is *already known* to be valid from a symmetric earlier position (`z[i - L]`) — extending further only when genuinely necessary. This "don't redo already-implied work" pattern is the same spirit as KMP's LPS fallback, expressed differently.
- **`zSearch`'s combined string with `$` separator:** The separator prevents a match from spuriously "bleeding" across the boundary between pattern and text — without it, a long enough repeated character run near the boundary could produce an incorrect Z-value.
- **Rabin-Karp's rolling hash update:** `textHash - text[i]*power` removes the outgoing leading character's contribution; `* BASE + text[i+m]` shifts everything up one digit and adds the new trailing character — exactly the O(1) update formula from section 3. The `+ MOD * BASE` before the final `% MOD` is a defensive trick to avoid negative intermediate values, since C++'s `%` operator can return negative results for negative operands.
- **The direct-comparison verification step (`text.substr(i,m) == pattern`):** This is what makes Rabin-Karp correct despite using hashing — a hash match is only a *candidate*, never proof, so a cheap direct check confirms or rejects it (rare enough, with a good hash, to keep the amortized cost low).

**Common mistakes to watch for here:**
- Forgetting the LPS fallback loop entirely (`else if (len != 0)`) and just resetting `len = 0` on every mismatch — this degrades KMP back to brute-force-like behavior.
- Off-by-one in the Z-function's window comparison (`i < R` vs `i <= R`) — a very common source of subtle bugs.
- Forgetting to verify a Rabin-Karp hash match directly — treating a hash collision as a guaranteed match introduces false positives.
- Using a small modulus or predictable hash base in Rabin-Karp for security-sensitive matching — makes adversarial hash collisions easy to construct deliberately.

---

## 11. Dry Run

**KMP: text = "ABABABAC", pattern = "ABABAC".** LPS array (computed in section 3): `[0,0,1,2,3,0]`.

| i (text) | j (pattern) | text[i] vs pattern[j] | Action |
|---|---|---|---|
| 0 | 0 | A vs A | match → i=1,j=1 |
| 1 | 1 | B vs B | match → i=2,j=2 |
| 2 | 2 | A vs A | match → i=3,j=3 |
| 3 | 3 | B vs B | match → i=4,j=4 |
| 4 | 4 | A vs A | match → i=5,j=5 |
| 5 | 5 | B vs C | **mismatch** → j = lps[4] = 3 (i stays at 5!) |
| 5 | 3 | B vs B | match → i=6,j=4 |
| 6 | 4 | A vs A | match → i=7,j=5 |
| 7 | 5 | C vs C | match → i=8,j=6=m → **MATCH at i-j = 8-6 = 2** |

Matches at index 2 — confirmed, and notice the text pointer `i` only ever increased, never backtracked, even through the mismatch at step 6. ✓

---

## 12. Interview Questions

**Conceptual:**
1. Explain how the LPS array lets KMP avoid re-comparing characters after a mismatch.
2. Compare KMP, Z-function, and Rabin-Karp — when might you prefer each?
3. Why is Rabin-Karp's worst case O(n·m) despite its expected O(n+m) — what specifically causes the degradation?
4. How does the Z-function generalize beyond simple pattern matching?
5. Why must the text pointer in KMP never move backward, and why is that the key to its O(n) guarantee?

**Coding:**
1. Implement KMP pattern search.
2. Implement the Z-function and use it for pattern matching.
3. Implement Rabin-Karp with a rolling hash.
4. Longest Palindromic Substring (multiple valid approaches; some use Z-function-adjacent ideas).
5. Repeated String Match / find the shortest repeating unit of a string (a classic Z-function or KMP-LPS application).
6. Find all anagram substrings of a pattern in a text (sliding window + character frequency, string-specific but array-technique-driven).

**Follow-ups / interviewer traps:**
- "Can you find ALL occurrences (with overlaps) using KMP, not just the first?" (yes — the `j = lps[j-1]` continuation after a full match, shown in the code, handles this)
- "How would you search for multiple patterns simultaneously?" (tests awareness of Aho-Corasick, a trie-based generalization of KMP's failure-function idea to multiple patterns at once)
- "What if the alphabet is huge (e.g., Unicode) — does Rabin-Karp's hash choice matter more?" (tests understanding of hash collision risk scaling with alphabet size/adversarial input)

---

## 13. Practice Problems

**Easy**
- Implement strStr() (LeetCode 28) — basic substring search, the direct target for KMP/Z-function
- Longest Common Prefix (LeetCode 14)
- Valid Palindrome (LeetCode 125)

**Medium**
- Repeated Substring Pattern (LeetCode 459) — classic Z-function/KMP-LPS application
- Longest Happy Prefix (LeetCode 1392) — directly the LPS array's definition
- Find All Anagrams in a String (LeetCode 438)
- Group Anagrams (LeetCode 49) — ties back to the Hash Table chapter

**Hard**
- Shortest Palindrome (LeetCode 214) — KMP-based approach
- Distinct Subsequences (LeetCode 115)
- String Matching in an Array (LeetCode 1408) — practice applying substring search as a building block

Also recommended: Codeforces problems tagged `strings` at rating 1400-1900, GeeksforGeeks "Pattern Searching" practice set covering KMP, Z-function, and Rabin-Karp variants side by side.

---

## 14. Common Mistakes

- **Reverting to brute-force restart logic on a KMP mismatch** instead of correctly consulting the LPS array's fallback value.
- **Off-by-one errors in Z-function window bounds** — a notoriously fiddly piece of code to get exactly right on the first try.
- **Trusting a Rabin-Karp hash match without direct verification** — a hash collision, while rare, is not impossible, and treating "hashes equal" as "strings equal" introduces silent false positives.
- **Using a weak or predictable hash base/modulus** in Rabin-Karp, especially in any context where input could be adversarial (e.g., a public-facing search feature).
- **Forgetting the separator character in Z-function-based pattern matching**, allowing spurious cross-boundary matches.
- **Ignoring integer overflow** in Rabin-Karp's hash arithmetic — always use a sufficiently large modulus and take modulo at every intermediate step, not just at the end.

---

## 15. Summary

**Key takeaways:**
- Brute-force string matching is O(n·m); KMP and the Z-function achieve a *guaranteed* O(n+m) by precomputing structural self-overlap information about the pattern; Rabin-Karp achieves *expected* O(n+m) via O(1) rolling-hash updates, with a small but real worst-case collision risk.
- KMP's LPS array and the Z-function solve the same underlying problem from two different but related angles — the Z-function is more general-purpose (periodicity, borders, and more), while KMP's LPS array is narrowly tuned for matching.
- Rabin-Karp's hashing approach generalizes especially well to multi-pattern search and 2D matching, where character-by-character failure-function logic doesn't extend as naturally.

**Complexity recap:**

| Algorithm | Total Time | Space | Worst case guaranteed? |
|---|---|---|---|
| Brute Force | O(n·m) | O(1) | Yes (but slow) |
| KMP | O(n+m) | O(m) | Yes |
| Z-Function | O(n+m) | O(n+m) | Yes |
| Rabin-Karp | O(n+m) expected | O(1) | No — O(n·m) under hash collisions |

**Decision guideline:** Use KMP or the Z-function when you need an airtight worst-case guarantee — especially for security-sensitive or adversarial-input contexts. Use Rabin-Karp when you need to search for multiple patterns at once, need 2D pattern matching, or when average-case performance with a well-chosen hash is acceptable. For simple one-off searches in most application code, a language's built-in string search (often a well-tuned hybrid) is perfectly fine — reach for these algorithms specifically when performance at scale genuinely matters, or when an interviewer is asking about the underlying mechanics directly.

---

*Next chapter: `03_linked_lists.md`*
