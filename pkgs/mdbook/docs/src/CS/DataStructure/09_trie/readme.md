# Chapter 8: Trie (Prefix Tree)

*Study time: ~5-6 hours | Prerequisite: Trees, Hash Tables | Difficulty: Intermediate*

---

## 1. Introduction

**Definition:** A Trie (pronounced "try," from re**trie**val) is a tree-like structure specialized for storing strings, where each path from the root spells out a prefix, and each node represents one character. Nodes shared by multiple words merge into the same path.

**Purpose:** To support extremely fast prefix-based operations — "does any word start with 'pre'?", "give me all words starting with 'ca'" — which a hash table cannot do efficiently.

**Real-world analogy:** A trie is like a dictionary organized as a decision tree of letters: to find "cat," you go down C → A → T, and along the way, anyone looking for "car" shares the same C → A path with you before splitting off. It's the physical structure of an old-fashioned phone directory's alphabetical tabs, nested recursively.

**Motivation:** A hash set of strings answers "is this exact string present?" in O(1), but answering "what strings start with this prefix?" requires scanning every stored string — O(n × L). A trie answers both in time proportional only to the *length of the query*, independent of how many words are stored.

**History:** Introduced by Edward Fredkin in 1960, originally for information retrieval systems; now foundational to autocomplete, spell-checkers, and IP routing.

---

## 2. Why Do We Need It?

**Problem it solves:** Efficient prefix search, autocomplete, and spell-checking — operations built around "sequences that share a common start."

**Why previous structures are insufficient:**
- **Hash Set:** O(1) exact match, but prefix search requires checking every stored string — O(n·L).
- **BST of strings:** O(log n) exact match (with string comparison cost), but prefix search still requires an in-order-range scan and per-comparison string cost, not proportional purely to prefix length.
- **Sorted array of strings:** binary search finds an exact match or insertion point in O(log n · L), but enumerating "all words with prefix X" still means scanning a contiguous range, and that range could be O(n) in the worst case.

**Trade-offs:**
- You gain O(L) search/insert/prefix-lookup, where L is the string's length — **independent of how many total words are stored**.
- You pay for it with significant memory overhead — every node can have up to 26 (or more, per alphabet size) child pointers, most of which are unused, and shared prefixes are the *only* thing keeping memory from exploding.

---

## 3. Internal Working

Inserting the words **"cat"**, **"car"**, **"card"**, **"dog"**:

```
                    (root)
                   /       \
                  c         d
                  |         |
                  a         o
                 / \        |
                t   r       g*
                *   |
                    d
                    *
```
(`*` marks a node where a complete word ends — the "end-of-word" flag, essential to distinguish "car" being a complete word from just being a prefix of "card".)

**Node structure:**
```
struct TrieNode {
    TrieNode* children[26];   // or a hash map for sparse alphabets / Unicode
    bool isEndOfWord;
};
```

**Insert "car"**, step by step:
```
Start at root.
'c': root has no child 'c' yet → create it. Move to node 'c'.
'a': node 'c' has no child 'a' yet → create it. Move to node 'a'.
'r': node 'a' has no child 'r' yet → create it. Move to node 'r'.
Mark node 'r' as isEndOfWord = true.
```

**Insert "card" afterward** — reuses the existing c→a→r path entirely, only adding one new node:
```
'c': exists, reuse. 'a': exists, reuse. 'r': exists, reuse (already end-of-word for "car", stays true).
'd': node 'r' has no child 'd' yet → create it. Mark it as isEndOfWord = true.
```

This reuse of shared prefixes is the defining efficiency trick of a trie — words sharing a prefix share the memory for that prefix's path.

**Prefix search for "ca"**: walk c → a (2 steps, matching query length exactly), then all words below this point ("cat", "car", "card") can be found via a subtree traversal (DFS) from here.

---

## 4. Operations

**Insert(word):**
- Start at root. For each character, check if a child for that character exists; if not, create it. Move into that child.
- After processing all characters, mark the final node's `isEndOfWord = true`.
- O(L) where L is the word's length.

**Search(word) — exact match:**
- Walk the trie character by character, following existing children.
- If any character's child doesn't exist, the word isn't present — return false.
- If all characters are matched, return `isEndOfWord` at the final node (this distinguishes "car" being a full word vs. just a prefix of "card").

**StartsWith(prefix):**
- Identical walk to Search, but simply return true if you successfully walk the entire prefix — you don't check `isEndOfWord` (a prefix need not be a complete word itself).

**Delete(word):**
- Walk down to the word's last node. If it has children, just unset `isEndOfWord` (can't delete nodes — they're needed for longer words sharing this prefix).
- If it has no children, it's safe to delete backward up the chain until hitting a node that either is `isEndOfWord` for another word or has other children.
- Edge case: deleting a word that's a prefix of another stored word must never delete shared nodes.

**Traverse (enumerate all words / autocomplete):**
- DFS from a given node (e.g., after walking a prefix), collecting the accumulated character path whenever `isEndOfWord` is true.

---

## 5. Time & Space Complexity

| Operation | Time Complexity | Space Complexity |
|---|---|---|
| Insert | O(L) | O(L) worst case (new path), O(1) if fully shared |
| Search (exact) | O(L) | O(1) |
| StartsWith (prefix check) | O(L) | O(1) |
| Enumerate all words with prefix | O(L + number of matching words × avg length) | O(1) extra beyond output |
| Overall storage | — | O(total characters across all words), bounded by O(ALPHABET_SIZE × total nodes) |

**Why these hold:**
- Every operation's cost depends **only on the length of the word/prefix being processed (L)**, not on how many words are stored overall (n) — this is the trie's headline advantage over a hash set or BST, whose costs typically involve some function of n.
- Space is where the trade-off lives: in the worst case (no shared prefixes at all), a trie can use *more* memory than simply storing all strings directly, because every node reserves space for up to `ALPHABET_SIZE` children (often 26 pointers) even if only one or two are used. Heavily-shared-prefix datasets (like a dictionary) benefit enormously; a set of totally random strings benefits much less.

---

## 6. Advantages

- O(L) search/insert, independent of the total number of stored words — scales beautifully as your dataset grows.
- Naturally supports prefix operations (autocomplete, "does any word start with X") that hash tables cannot do efficiently.
- Shared prefixes reduce redundant storage compared to storing every string independently.
- Enumerating all words with a given prefix is straightforward (a simple DFS from the prefix's end node).

## 7. Disadvantages

- High memory overhead per node when the alphabet is large or children are sparse (many unused pointers) — mitigated by using a hash map instead of a fixed-size array for children, at the cost of slightly higher constant-factor time.
- Not useful for non-string / non-sequence data.
- Cache-unfriendly (like any pointer-heavy tree) — many small allocations scattered in memory.
- Case sensitivity, Unicode, and special characters all need careful design decisions (e.g., mapping to a wider child array or a hash map).

---

## 8. Real-World Applications

- **Search Engines / Autocomplete:** Suggesting query completions as you type — exactly the "enumerate all words with this prefix" operation.
- **Spell Checkers:** Quickly verifying whether a word exists, and suggesting nearby valid words (via limited edit-distance search over the trie).
- **Networking:** IP routing tables use a specialized trie (a "radix trie" / "Patricia trie") to perform longest-prefix-matching for routing decisions — extremely performance-critical in real routers.
- **Compilers:** Some tokenizers/lexers use tries to efficiently match reserved keywords.
- **AI/ML/NLP:** Tokenization and vocabulary lookups in some NLP pipelines; representing large dictionaries compactly.
- **Text Editors/IDEs:** Code autocompletion (suggesting function/variable names as you type).
- **Contact Lists/Phone Directories:** Efficient prefix-based contact search.

---

## 9. Implementation (C++17)

```cpp
#include <iostream>
#include <string>
#include <vector>
#include <memory>

class Trie {
private:
    struct TrieNode {
        // Using a fixed array for lowercase a-z. For wider alphabets/Unicode,
        // swap this for std::unordered_map<char, std::unique_ptr<TrieNode>>.
        std::unique_ptr<TrieNode> children[26];
        bool isEndOfWord = false;
    };

    std::unique_ptr<TrieNode> root;

    int charIndex(char c) const { return c - 'a'; }

    // Recursive helper for enumerating all words at/below a given node.
    void collectWords(TrieNode* node, std::string& prefix, std::vector<std::string>& results) const {
        if (!node) return;
        if (node->isEndOfWord) results.push_back(prefix);
        for (int i = 0; i < 26; ++i) {
            if (node->children[i]) {
                prefix.push_back(static_cast<char>('a' + i));
                collectWords(node->children[i].get(), prefix, results);
                prefix.pop_back();   // backtrack — undo before trying the next branch
            }
        }
    }

public:
    Trie() : root(std::make_unique<TrieNode>()) {}

    // Insert a word. O(L).
    void insert(const std::string& word) {
        TrieNode* current = root.get();
        for (char c : word) {
            int idx = charIndex(c);
            if (!current->children[idx]) {
                current->children[idx] = std::make_unique<TrieNode>();
            }
            current = current->children[idx].get();
        }
        current->isEndOfWord = true;
    }

    // Exact word search. O(L).
    bool search(const std::string& word) const {
        TrieNode* current = root.get();
        for (char c : word) {
            int idx = charIndex(c);
            if (!current->children[idx]) return false;
            current = current->children[idx].get();
        }
        return current->isEndOfWord;   // must be a COMPLETE word, not just a prefix
    }

    // Prefix check. O(L). Does NOT require isEndOfWord.
    bool startsWith(const std::string& prefix) const {
        TrieNode* current = root.get();
        for (char c : prefix) {
            int idx = charIndex(c);
            if (!current->children[idx]) return false;
            current = current->children[idx].get();
        }
        return true;
    }

    // Autocomplete: return all stored words that begin with the given prefix.
    std::vector<std::string> autocomplete(const std::string& prefix) const {
        std::vector<std::string> results;
        TrieNode* current = root.get();
        for (char c : prefix) {
            int idx = charIndex(c);
            if (!current->children[idx]) return results;   // no words with this prefix
            current = current->children[idx].get();
        }
        std::string mutablePrefix = prefix;
        collectWords(current, mutablePrefix, results);
        return results;
    }
};

// Example usage
int main() {
    Trie trie;
    for (const std::string& w : {"cat", "car", "card", "care", "dog"}) {
        trie.insert(w);
    }

    std::cout << "search('car'): " << trie.search("car") << "\n";       // 1 (true)
    std::cout << "search('ca'): " << trie.search("ca") << "\n";         // 0 (false — 'ca' is a prefix, not a complete word)
    std::cout << "startsWith('ca'): " << trie.startsWith("ca") << "\n"; // 1 (true)

    std::cout << "Autocomplete 'car': ";
    for (const auto& word : trie.autocomplete("car")) std::cout << word << " ";
    std::cout << "\n";   // car card care

    return 0;
}
```

---

## 10. Code Walkthrough

- **`children[26]` array of `unique_ptr<TrieNode>`:** Each slot corresponds to one letter; `nullptr` means "no word passes through this character at this position." Using smart pointers means deleting the whole trie (or any subtree) is automatic and leak-free.
- **`charIndex`:** Maps `'a'`–`'z'` to array indices `0`–`25` via simple subtraction — this is the entire "hashing" a trie needs, since the alphabet is small and dense (contrast this with the Hash Table chapter, where keys are arbitrary and need an actual hash function).
- **`isEndOfWord`:** This flag is *essential* — without it, there'd be no way to distinguish "car" being a complete stored word from merely being a prefix that happens to lead to "card." Note `search("ca")` returns false in the example even though the path exists, precisely because that node's flag is false.
- **`collectWords` (DFS with backtracking):** Builds up `prefix` as it descends, appends a word to `results` whenever it passes an `isEndOfWord` node, then explicitly `pop_back()`s before returning from each recursive call — this backtracking step is what lets the *same* mutable string buffer be reused across all 26 possible branches without needing to copy it at every level.
- **`autocomplete`:** First walks the prefix to find its ending node (O(L)), then hands off to `collectWords` to gather every complete word reachable below that point — this two-phase structure (walk then collect) is the standard trie autocomplete pattern.

**Common mistakes to watch for here:**
- Forgetting the `isEndOfWord` check in `search`, causing prefixes to be incorrectly reported as complete words.
- Forgetting to `pop_back()` after each recursive call in `collectWords`, causing the prefix string to accumulate incorrectly across sibling branches.
- Using a fixed 26-size array for alphabets/character sets it doesn't fit (uppercase, digits, Unicode) without adjusting `charIndex` or switching to a hash-map-based children structure.

---

## 11. Dry Run

**Insert "cat", "car", "card"**, then `autocomplete("ca")`.

| Step | Trie state (paths from root) |
|---|---|
| insert("cat") | root→c→a→t* |
| insert("car") | root→c→a→(t*, r*) — 'r' is new, but c,a were reused |
| insert("card") | root→c→a→r→d* — 'd' is new, c,a,r were reused (r stays end-of-word too) |

**`autocomplete("ca")`:**
1. Walk 'c' → 'a' from root (2 steps) — both exist, arrive at node 'a'.
2. `collectWords` from node 'a', prefix="ca":
   - node 'a' itself: not end-of-word (only "ca" alone was never inserted) → skip adding.
   - child 't': prefix becomes "cat" → node 't' is end-of-word → add "cat". Backtrack, prefix back to "ca".
   - child 'r': prefix becomes "car" → node 'r' is end-of-word → add "car". Recurse further:
     - child 'd': prefix becomes "card" → node 'd' is end-of-word → add "card". Backtrack.
   - Backtrack fully back to "ca".
3. Result: `["cat", "car", "card"]` (order depends on iteration order over children, here alphabetical since we loop `i=0..25`).

---

## 12. Interview Questions

**Conceptual:**
1. Why is a trie's time complexity independent of the number of stored words, unlike a hash set or BST?
2. Why is `isEndOfWord` necessary — what breaks without it?
3. Compare a Trie vs a Hash Map for autocomplete — why does the hash map approach fail to scale for prefix queries?
4. What's the memory trade-off of using a fixed-size children array vs. a hash map for children?
5. How would you extend a trie to support wildcard search (e.g., "c?t" matching "cat", "cot")?

**Coding:**
1. Implement Insert, Search, StartsWith (LeetCode 208 — Implement Trie).
2. Word Search II — find all dictionary words present in a grid, using a trie to prune DFS branches.
3. Design an Autocomplete System.
4. Longest Word in Dictionary formed by concatenating other words.
5. Replace Words — replace words in a sentence with their shortest root found in a trie (dictionary).
6. Implement a trie supporting wildcard '.' matching in search.

**Follow-ups / interviewer traps:**
- "How would you reduce memory usage for a trie storing millions of short words?" (expects discussion of compressed tries / radix tries, or switching to hash-map children for sparse branching)
- "Can you delete a word without breaking other stored words that share its prefix?" (tests understanding that shared nodes must never be deleted, only the `isEndOfWord` flag or unshared suffix nodes)
- "What if the same word is inserted twice — does your structure handle it correctly?" (tests idempotency of `isEndOfWord` being set to true, not toggled)

---

## 13. Practice Problems

**Easy**
- Implement Trie (Prefix Tree) (LeetCode 208)
- Longest Common Prefix (LeetCode 14) — solvable with or without an explicit trie

**Medium**
- Design Add and Search Words Data Structure (LeetCode 211) — wildcard search
- Replace Words (LeetCode 648)
- Map Sum Pairs (LeetCode 677)
- Search Suggestions System (LeetCode 1268)

**Hard**
- Word Search II (LeetCode 212)
- Palindrome Pairs (LeetCode 336)
- Concatenated Words (LeetCode 472)

Also recommended: GeeksforGeeks "Trie" practice set; try implementing autocomplete with ranked suggestions (most-frequently-searched-first) as an extension project.

---

## 14. Common Mistakes

- **Forgetting the end-of-word marker**, conflating "is a prefix of something" with "is itself a complete stored word."
- **Not backtracking the prefix string** during DFS-based word collection, corrupting later results.
- **Assuming fixed-size children arrays work for all input** — breaks immediately on uppercase, punctuation, digits, or Unicode without adjustment.
- **Deleting shared nodes** when removing a word that is a prefix of another stored word.
- **Ignoring the memory cost** of tries for datasets with little to no shared prefix structure — a hash set may be strictly better there.
- **Off-by-one in `charIndex`** (e.g., forgetting that `'a' - 'a' = 0`, not 1).

---

## 15. Summary

**Key takeaways:**
- A trie trades memory for prefix-speed: every operation costs O(L) — the length of the word/prefix — regardless of how many total words are stored.
- The `isEndOfWord` flag is the critical piece of bookkeeping that separates "prefix" from "complete word."
- Shared prefixes are what make tries memory-efficient for prefix-heavy datasets (dictionaries, autocomplete corpora); for datasets without shared structure, the overhead can outweigh the benefit.

**Complexity recap:**

| Operation | Time | Space |
|---|---|---|
| Insert | O(L) | O(L) worst case |
| Search / StartsWith | O(L) | O(1) |
| Enumerate matches | O(L + matches) | O(1) extra |

**Decision guideline:** Choose a Trie when your workload centers on prefix operations — autocomplete, spell-check, longest-prefix matching. If you only need exact-match lookups with no prefix/autocomplete requirement, a Hash Set is simpler and often more memory-efficient.

---

*Next chapter: `09_btree_overview.md`*
