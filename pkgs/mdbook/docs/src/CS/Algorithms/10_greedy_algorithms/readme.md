# Chapter 10: Greedy Algorithms

*Study time: ~6-7 hours | Prerequisite: Sorting (Ch. 2-4), basic proof intuition | Difficulty: Intermediate*

---

## 1. Introduction

**Definition:** A Greedy Algorithm builds a solution step by step, at each step making the choice that looks **locally best** at that moment, and **never revisiting or reconsidering** that choice later — betting that a sequence of locally optimal choices produces a globally optimal result.

**Purpose:** To solve optimization problems dramatically faster than exhaustive search (often O(n log n) instead of exponential), but **only** for problems where local optimality provably implies global optimality — a property that must be proven, not assumed.

**Problem solved:** A specific class of optimization problems (scheduling, resource allocation, encoding) where a well-chosen greedy rule, applied consistently, is provably guaranteed to reach the best possible overall outcome.

---

## 2. Intuition

Imagine making change for $0.67 using US coins (quarters, dimes, nickels, pennies) — the natural approach is to grab the largest coin that doesn't overshoot the remaining amount, repeatedly: 25+25+10+5+1+1 = 67 cents, using 6 coins. This "always grab the biggest piece that fits" strategy is greedy, and for the standard US coin system, it's **provably optimal** — no other combination uses fewer coins. But this isn't true for *every* coin system — with coins {1, 3, 4}, greedily making 6 cents grabs a 4 first, then two 1s (4+1+1=3 coins), when 3+3=2 coins is actually better. **This is the central lesson of greedy algorithms: the strategy is only as good as the proof behind it — it can look almost identical for a problem where it works and one where it silently fails.**

The two most common proof techniques for "why does greedy work here?":
- **Exchange Argument:** show that if an optimal solution *doesn't* include the greedy choice, you can always "exchange" some other element in it for the greedy choice without making the solution worse — proving the greedy choice could always have been included safely.
- **Matroid / Cut Property structure:** certain problems have an underlying mathematical structure (a matroid, or in graph problems, the "cut property" — see the Data Structures guide's MST chapter) that *guarantees* greedy choices are safe, by theorem.

---

## 3. Step-by-Step Working

### (a) Activity Selection — maximize the number of non-overlapping activities

**Activities (start, end):** (1,4), (3,5), (0,6), (5,7), (3,9), (5,9), (6,10), (8,11), (8,12), (2,14), (12,16)

```
GREEDY RULE: sort by END TIME, always pick the next activity whose start time is
             ≥ the end time of the last picked activity.

Sorted by end time: (1,4),(3,5),(0,6),(5,7),(3,9),(5,9),(6,10),(8,11),(8,12),(2,14),(12,16)

Pick (1,4). lastEnd=4.
(3,5): start=3 < 4 → SKIP (overlaps)
(0,6): start=0 < 4 → SKIP
(5,7): start=5 >= 4 → PICK. lastEnd=7.
(3,9): start=3 < 7 → SKIP
(5,9): start=5 < 7 → SKIP
(6,10): start=6 < 7 → SKIP
(8,11): start=8 >= 7 → PICK. lastEnd=11.
(8,12): start=8 < 11 → SKIP
(2,14): start=2 < 11 → SKIP
(12,16): start=12 >= 11 → PICK. lastEnd=16.

Selected: (1,4), (5,7), (8,11), (12,16) — 4 non-overlapping activities, PROVABLY the maximum possible.
```

**Why "sort by end time" specifically works (exchange argument sketch):** picking the activity that finishes earliest always leaves the *most possible room* for future activities — if an optimal solution picked some other first activity that finishes later, you could always swap it for the earliest-finishing one without reducing the count of activities that still fit afterward. This exchange never makes things worse, which is exactly the exchange-argument proof pattern.

### (b) Huffman Coding — build an optimal prefix-free binary encoding

```
Character frequencies: A:5, B:9, C:12, D:13, E:16, F:45

Repeatedly extract the TWO smallest-frequency nodes, merge them into a new node
(frequency = sum), reinsert, until one node remains (using a Min-Heap — direct
application of the Data Structures guide's Heap chapter):

Extract 5(A), 9(B) → merge → new node 14, reinsert. Heap: {12,13,14,16,45}
Extract 12(C), 13(D) → merge → new node 25, reinsert. Heap: {14,16,25,45}
Extract 14, 16(E) → merge → new node 30, reinsert. Heap: {25,30,45}
Extract 25, 30 → merge → new node 55, reinsert. Heap: {45,55}
Extract 45(F), 55 → merge → new node 100 (root). Heap: {100} — done.

Resulting tree gives shorter codes to more frequent characters (F, frequency 45,
gets the shortest code; A, frequency 5, gets one of the longest) — minimizing
total encoded length across the whole message.
```

---

## 4. Complexity Analysis

**Activity Selection: O(n log n)** — dominated by the initial sort by end time; the greedy selection pass itself is a single O(n) linear scan afterward.

**Huffman Coding: O(n log n)** — n-1 extract-min operations from a heap of up to n elements, each O(log n) (directly reusing the Heap chapter's complexity analysis from the Data Structures guide).

**General pattern:** most greedy algorithms cost **O(n log n)**, dominated by an initial sort (to process elements in the "right" order for the greedy rule to apply correctly) plus a linear O(n) greedy pass — this is why greedy algorithms are typically *much* faster than the Dynamic Programming alternatives they sometimes compete with (which are often O(n²) or worse), when a valid greedy strategy actually exists for the problem.

---

## 5. Advantages

- Typically much faster than Dynamic Programming or exhaustive search for problems where a valid greedy strategy exists — often O(n log n) versus O(n²) or exponential.
- Simple to implement once the correct greedy rule is identified — usually just "sort, then scan."
- Elegant, provable optimality (via exchange argument or matroid structure) gives strong confidence in correctness, unlike heuristics that merely "usually work well."

## 6. Limitations

- **Only works when local optimality provably implies global optimality** — applying a greedy strategy to a problem that doesn't have this property produces a plausible-looking but genuinely wrong (suboptimal) answer, often without any obvious signal that something went wrong.
- Finding the *correct* greedy rule (and proving it correct) is itself a nontrivial skill — many candidate greedy strategies for a given problem are subtly wrong, and problems can have multiple "reasonable-looking" greedy rules where only one is actually correct.
- Cannot be "patched" the way Dynamic Programming can — DP naturally handles problems where choices interact and must be reconsidered; Greedy fundamentally cannot revisit a choice once made, so if that's genuinely required, greedy is the wrong tool entirely, not just a suboptimal one.

---

## 7. Real-World Applications

- **Operating Systems:** Shortest Job First / Shortest Remaining Time First CPU scheduling (a direct Activity-Selection-style greedy strategy).
- **Networking:** Huffman Coding is the basis of many real compression formats (DEFLATE, used in gzip/PNG, uses Huffman coding as one of its stages); Dijkstra's algorithm (Data Structures guide, Chapter 14) is itself a greedy algorithm (always expand the closest known vertex next).
- **Finance:** Fractional Knapsack-style greedy strategies for portfolio allocation under simplified (divisible-asset) assumptions.
- **Compilers:** Register allocation sometimes uses greedy graph-coloring heuristics (though this specific application is a heuristic, not a provably-optimal greedy algorithm, illustrating the important distinction covered in the limitations section).
- **Databases:** Query optimization sometimes uses greedy heuristics for join-order selection (again, typically a heuristic rather than provably optimal, since the underlying problem is NP-hard in general).
- **Data Compression:** Huffman Coding remains foundational to many modern compression schemes as a component alongside more advanced techniques.
- **Game Development:** greedy pathfinding heuristics (though full shortest-path correctness typically needs Dijkstra/A*, which are themselves greedy-with-a-heap algorithms).

---

## 8. C++ Implementation

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
#include <queue>

// ---------- ACTIVITY SELECTION ----------
struct Activity {
    int start, end;
};

// Greedy: sort by end time, pick each activity whose start >= last picked end. O(n log n).
std::vector<Activity> activitySelection(std::vector<Activity> activities) {
    std::sort(activities.begin(), activities.end(),
              [](const Activity& a, const Activity& b) { return a.end < b.end; });

    std::vector<Activity> selected;
    int lastEnd = -1;

    for (const Activity& a : activities) {
        if (a.start >= lastEnd) {   // no overlap with the last selected activity
            selected.push_back(a);
            lastEnd = a.end;
        }
    }
    return selected;
}

// ---------- HUFFMAN CODING ----------
struct HuffmanNode {
    char ch;
    int freq;
    HuffmanNode* left;
    HuffmanNode* right;
    HuffmanNode(char c, int f, HuffmanNode* l = nullptr, HuffmanNode* r = nullptr)
        : ch(c), freq(f), left(l), right(r) {}
};

struct Compare {
    bool operator()(HuffmanNode* a, HuffmanNode* b) { return a->freq > b->freq; }   // min-heap by frequency
};

// Build the Huffman tree. O(n log n) — n-1 extract-min + insert operations on a heap.
HuffmanNode* buildHuffmanTree(const std::vector<std::pair<char,int>>& freqs) {
    std::priority_queue<HuffmanNode*, std::vector<HuffmanNode*>, Compare> pq;
    for (auto& [ch, freq] : freqs) {
        pq.push(new HuffmanNode(ch, freq));
    }

    while (pq.size() > 1) {
        HuffmanNode* left = pq.top(); pq.pop();     // two smallest-frequency nodes
        HuffmanNode* right = pq.top(); pq.pop();
        HuffmanNode* merged = new HuffmanNode('\0', left->freq + right->freq, left, right);
        pq.push(merged);                              // reinsert the merged node
    }
    return pq.top();   // the root of the completed Huffman tree
}

// Traverse the tree to generate each character's binary code. O(n) over the tree's nodes.
void generateCodes(HuffmanNode* node, const std::string& code, std::vector<std::pair<char,std::string>>& result) {
    if (!node) return;
    if (!node->left && !node->right) {   // leaf node — represents an actual character
        result.push_back({node->ch, code.empty() ? "0" : code});   // handle single-character edge case
        return;
    }
    generateCodes(node->left, code + "0", result);
    generateCodes(node->right, code + "1", result);
}

// Example usage
int main() {
    std::vector<Activity> activities = {
        {1,4},{3,5},{0,6},{5,7},{3,9},{5,9},{6,10},{8,11},{8,12},{2,14},{12,16}
    };
    auto selected = activitySelection(activities);
    std::cout << "Selected activities: ";
    for (auto& a : selected) std::cout << "(" << a.start << "," << a.end << ") ";
    std::cout << "\n";   // (1,4) (5,7) (8,11) (12,16)

    std::vector<std::pair<char,int>> freqs = {{'A',5},{'B',9},{'C',12},{'D',13},{'E',16},{'F',45}};
    HuffmanNode* root = buildHuffmanTree(freqs);
    std::vector<std::pair<char,std::string>> codes;
    generateCodes(root, "", codes);

    std::cout << "Huffman codes:\n";
    for (auto& [ch, code] : codes) std::cout << "  " << ch << ": " << code << "\n";
    // More frequent characters (like F=45) get shorter codes than rare ones (like A=5)

    return 0;
}
```

---

## 9. Code Walkthrough

- **`activitySelection`'s sort-by-end-time:** This specific sort key is the entire correctness argument from section 3's exchange-argument sketch — sorting by *start* time or by *duration* instead would produce a plausible-looking but provably suboptimal greedy algorithm; end time is the one sort key that makes the greedy choice provably safe.
- **`lastEnd` tracking:** A single variable suffices to track the greedy state — no need to look back at *all* previously selected activities, only the most recent one, since activities are processed in sorted end-time order and the greedy choice only ever needs to compare against the most recently committed choice.
- **`buildHuffmanTree`'s min-heap of `HuffmanNode*`:** This is a direct, unmodified application of the Heap data structure (Data Structures guide, Chapter 5) — the greedy rule ("always merge the two least-frequent remaining nodes") is implemented entirely through repeated extract-min/insert operations, with no additional logic needed beyond what the heap itself provides.
- **`generateCodes`'s recursive traversal:** Building the code string by appending "0" for left and "1" for right as it descends is what produces a valid **prefix-free** code — no character's code is ever a prefix of another's, which is exactly the tree-structural guarantee that makes Huffman-encoded data unambiguously decodable.
- **The `code.empty() ? "0" : code` special case:** Handles the edge case of a single-character alphabet (only one node, so the tree is a single leaf with no traversal at all) — without this, that character would get an empty code, which is meaningless.

**Common mistakes to watch for here:**
- Sorting activities by start time or duration instead of end time — a very common, plausible-looking, but provably incorrect variant.
- Forgetting to handle ties in Huffman's min-heap comparator (though any consistent tie-breaking still produces a valid, optimal — if not unique — encoding).
- Not freeing the dynamically allocated `HuffmanNode` tree after use (a real memory-management concern in production code, simplified away here for clarity).

---

## 10. Dry Run

Already traced in full detail in section 3 for both algorithms — Activity Selection selecting `(1,4), (5,7), (8,11), (12,16)` (4 activities, provably maximal), and Huffman Coding progressively merging `{5,9}→14`, `{12,13}→25`, `{14,16}→30`, `{25,30}→55`, `{45,55}→100`, building a tree where frequency-45 character F ends up with a short code and frequency-5 character A ends up with a longer one.

---

## 11. Complexity Table

| Algorithm | Time | Space |
|---|---|---|
| Activity Selection | O(n log n) | O(n) or O(1) if sorting in-place |
| Huffman Coding | O(n log n) | O(n) for the tree + heap |
| Fractional Knapsack | O(n log n) | O(1) extra beyond sorting |

**Every entry explained:** All three follow the same pattern — an O(n log n) sort (or heap-based equivalent) to establish the correct processing order, followed by an O(n) (or O(n log n) for repeated heap operations, as in Huffman) linear-ish pass applying the greedy rule. The sort/heap cost dominates in every case, which is why "O(n log n), dominated by sorting" is such a common refrain across greedy algorithms generally.

---

## 12. Common Mistakes

- **Assuming greedy works without proving it** — the single most dangerous mistake in this entire chapter; a greedy strategy that "seems reasonable" can be silently wrong, producing a plausible but suboptimal answer with no obvious red flag.
- **Choosing the wrong sort key** — as shown in Activity Selection, sorting by the "obviously related" criterion (start time) instead of the actually-correct one (end time) is an extremely common error.
- **Applying greedy to a Coin-Change-style problem with a non-canonical coin system** — the classic counterexample (coins {1,3,4}, target 6) where greedy fails and Dynamic Programming is required instead.
- **Confusing "a greedy algorithm exists for this problem" with "any greedy rule works"** — many different greedy rules can be proposed for the same problem, and usually only one (or a small few) is actually correct.
- **Not considering whether choices interact** — if selecting one element changes the desirability of a *later* choice in a way the greedy rule doesn't account for, that's a signal the problem likely needs Dynamic Programming instead.

---

## 13. Interview Questions

**Conceptual:**
1. What must be true about a problem for a greedy algorithm to be provably correct?
2. Explain the exchange argument proof technique, using Activity Selection as an example.
3. Give an example of a greedy strategy that looks correct but isn't (the Coin Change counterexample is the classic one — walk through why it fails).
4. Why is Huffman Coding's result guaranteed optimal (minimum expected code length) for a given set of character frequencies?
5. Compare Greedy and Dynamic Programming — what's the key structural difference that determines which applies?

**Coding:**
1. Activity Selection Problem.
2. Fractional Knapsack Problem.
3. Huffman Coding — build the tree and generate codes.
4. Job Sequencing with Deadlines.
5. Minimum Number of Platforms Required (interval scheduling variant).
6. Gas Station (LeetCode 134) — a non-obvious greedy problem requiring a clever proof.

**Follow-ups / interviewer traps:**
- "Prove your greedy strategy is actually optimal, not just plausible." (the single most important thing an interviewer can ask in this entire chapter — always be ready to sketch an exchange argument or cite the relevant matroid/cut-property structure)
- "What if the coin denominations aren't {1,5,10,25} — does greedy still work for making change?" (tests recognizing that greedy correctness for Coin Change depends on the specific denomination system being "canonical," not a general guarantee)
- "Can you solve Fractional Knapsack with Dynamic Programming instead — would that even make sense?" (tests understanding that Fractional Knapsack's greedy correctness comes from the ability to take *partial* items, a structural property that the 0/1 Knapsack variant — which genuinely needs DP — lacks)

---

## 14. Practice Problems

**Easy**
- Assign Cookies (LeetCode 455)
- Lemonade Change (LeetCode 860)

**Medium**
- Jump Game (LeetCode 55) — greedy reachability tracking
- Gas Station (LeetCode 134)
- Task Scheduler (LeetCode 621) — connects back to the Data Structures guide's Heap chapter
- Non-overlapping Intervals (LeetCode 435) — Activity Selection in disguise
- Partition Labels (LeetCode 763)

**Hard**
- Candy (LeetCode 135) — a two-pass greedy proof
- Job Sequencing with Deadlines (GeeksforGeeks classic)
- Minimum Number of Arrows to Burst Balloons (LeetCode 452)

Also recommended: for every greedy problem you solve, explicitly write out (even informally) why the greedy choice is safe — this habit is what separates "got lucky with a plausible strategy" from genuine understanding, and it's exactly what a good interviewer is listening for.

---

## 15. Summary

**Key takeaways:**
- Greedy algorithms make irrevocable locally-optimal choices, and are only correct when that local optimality is *provably* sufficient for global optimality — via an exchange argument, matroid structure, or cut-property-style reasoning.
- The classic failure mode (Coin Change with non-canonical denominations) is not a corner case to memorize and forget — it's a permanent reminder that a greedy strategy must always be justified, never merely assumed because it "feels right."
- When greedy applies, it's typically the fastest correct approach available (O(n log n)), dramatically outperforming the Dynamic Programming alternative that would otherwise be needed for problems where choices genuinely interact.

**Complexity recap:**

| | Time | Space |
|---|---|---|
| Typical Greedy Algorithm | O(n log n) | O(n) or O(1) extra |

**Decision guide:** Reach for Greedy when you can articulate (and ideally prove) why the locally best choice at each step can never be wrong for the overall objective. The moment you find yourself unable to justify why an earlier choice couldn't be regretted given later information, that's the signal to switch to Dynamic Programming (next chapter after Backtracking) instead.

---

*Next chapter: `11_backtracking.md`*
