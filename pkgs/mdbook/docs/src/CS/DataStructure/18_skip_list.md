# Chapter 17: Skip List

*Study time: ~5-6 hours | Prerequisite: Linked Lists, probability basics | Difficulty: Advanced*

---

## 1. Introduction

**Definition:** A Skip List is a linked-list-based structure augmented with multiple "levels" of shortcut pointers, where higher levels skip over more elements. Each element is randomly assigned a "height" (how many levels it appears in), and this randomness statistically guarantees O(log n) search, insert, and delete — without the explicit rotation logic an AVL Tree needs.

**Purpose:** To achieve BST-like O(log n) average performance using a much simpler, linked-list-based implementation, with the added benefit of being naturally suited to **concurrent** (multi-threaded) implementations, where balancing rotations in a tree are notoriously hard to make thread-safe.

**Real-world analogy:** Think of an express-and-local subway system layered over a single street. The "local track" (bottom level) stops at every single station — a plain linked list, O(n) to traverse. An "express track" (a higher level) skips most stations, stopping only at major hubs. A "super-express" (an even higher level) stops only at the very biggest hubs. To get from station A to station Z, you ride the super-express as far as you can, then drop to the express, then to local for the final stretch — dramatically fewer stops overall than riding local the whole way.

**Motivation:** AVL/Red-Black Trees guarantee O(log n) via careful, deterministic rebalancing (rotations) — powerful, but intricate to implement correctly, and awkward to make safely concurrent (a rotation can touch several nodes at once, complicating fine-grained locking). A Skip List achieves the *same* expected O(log n) using randomness instead of deterministic balancing — no rotations at all, and its layered structure lends itself much more naturally to lock-free/concurrent designs.

**History:** Invented by William Pugh in 1990, explicitly motivated as "a probabilistic alternative to balanced trees" — the original paper's title states this goal directly.

---

## 2. Why Do We Need It?

**Problem it solves:** O(log n) average search/insert/delete with a **much simpler implementation** than a self-balancing tree, and better suitability for concurrent access patterns.

**Why previous structures are insufficient:**
- **Plain Linked List:** O(n) for search — no shortcuts of any kind.
- **AVL/Red-Black Tree:** O(log n) guaranteed, but rotation logic is genuinely intricate (as seen in Chapter 7 — four distinct cases, careful pointer surgery) and hard to parallelize safely.
- **Array/Sorted Array:** O(log n) search via binary search, but O(n) insert/delete due to shifting.

**Trade-offs:**
- You gain O(log n) **expected** (probabilistic, not strictly guaranteed) performance with dramatically simpler code — no rotations, just randomized level assignment and standard linked-list pointer relinking.
- You lose the *guarantee* — a Skip List's O(log n) is an expected/average bound backed by probability, not an absolute worst-case guarantee like AVL's. An extremely unlucky sequence of random coin flips (astronomically rare in practice) could, in theory, produce a poorly-structured skip list. You also pay extra memory for the multiple levels of pointers per node.

---

## 3. Internal Working

**Structure — multiple linked lists stacked, each level a "sparser" version of the one below:**

```
Level 3:  HEAD -------------------------> 50 -----------------------------> NIL
Level 2:  HEAD -----------> 20 --------> 50 --------> 70 ------------------> NIL
Level 1:  HEAD -----> 10 -> 20 -> 30 --> 50 --> 60 -> 70 --------> 90 ------> NIL
Level 0:  HEAD -> 5 -> 10 -> 20 -> 30 -> 40 -> 50 -> 60 -> 70 -> 80 -> 90 -> NIL
```
Level 0 is a complete, ordinary sorted linked list containing every element. Each higher level contains a random subset of the level below — in the classic design, each element independently has (typically) a 50% chance of being "promoted" to the next level up, which is what produces the expected geometric thinning (level 1 has roughly n/2 elements, level 2 roughly n/4, and so on).

**Search for 60**, step by step (starting from the top level, moving right as far as possible without overshooting, then dropping down a level):
```
Level 3: HEAD -> 50 (50 < 60, can go further?) -> NIL is next, would overshoot -> drop to level 2 at node 50
Level 2: at 50 -> 70 (70 > 60, overshoot!) -> drop to level 1, staying at 50
Level 1: at 50 -> 60 (60 == 60, FOUND!)
```
Only 4 comparisons touched, skipping entirely over 10, 20, 30, 40 — the "express lane" effect in action.

**Randomized level assignment on insert:** when inserting a new element, flip a (virtual) coin repeatedly — heads, promote to the next level up; tails, stop. This is what gives each level roughly half the elements of the level below, in expectation, without any explicit rebalancing logic.

---

## 4. Operations

**Search(value):**
- Start at the top-left (head of the highest level).
- At each level, move right as long as the next node's value is ≤ target and doesn't overshoot; when moving right would overshoot (or hit the end), drop down one level and repeat.
- Stop when either the value is found, or level 0 is exhausted without a match.
- Expected O(log n).

**Insert(value):**
- Perform a search, tracking the last node visited at *each* level (these become the new node's predecessors).
- Randomly determine the new node's height (via repeated coin flips, or equivalently, counting trailing 1-bits of a random number).
- Splice the new node into every level up to its assigned height, using the tracked predecessors from the search.
- Expected O(log n).

**Delete(value):**
- Perform a search, tracking predecessors at each level (same as insert).
- Unlink the node from every level it appears in.
- Expected O(log n).

**Range Query / Traverse:**
- Level 0 alone is a complete sorted linked list — traversing it gives sorted output, just like a BST's in-order traversal, in O(n).

---

## 5. Time & Space Complexity

| Operation | Expected (Average) | Worst Case (extremely unlikely) | Space Complexity |
|---|---|---|---|
| Search | O(log n) | O(n) | O(1) extra |
| Insert | O(log n) | O(n) | O(1) extra per node (proportional to assigned height) |
| Delete | O(log n) | O(n) | O(1) extra |
| Overall storage | — | — | O(n) expected (roughly 2n total pointers across all levels, since each level has about half the elements of the one below) |

**Why these hold:**
- The expected O(log n) comes directly from the probabilistic level-assignment scheme: with each level expected to contain about half the elements of the level below, the number of levels needed to cover n elements is expected to be O(log n) — mirroring a balanced tree's height, but achieved through randomness rather than enforced structure.
- The **worst case is technically O(n)** — if, by sheer bad luck, every coin flip came up "promote" (or every element ended up at level 0 only), the structure could degenerate toward a plain linked list. This is why Skip Lists are described as giving *expected* / *average-case* guarantees, not the *absolute worst-case* guarantees an AVL Tree provides — a distinction worth being precise about in an interview.
- Space is O(n) expected — the geometric thinning (each level roughly halves the element count) means total pointers across all levels sum to roughly 2n, a small constant multiple of a plain linked list's memory.

---

## 6. Advantages

- Expected O(log n) search/insert/delete with **dramatically simpler code** than a self-balancing tree — no rotation logic, just randomized level assignment and standard linked-list splicing.
- Naturally suited to **concurrent/lock-free implementations** — a major reason Skip Lists are chosen in some high-performance systems over trees, since balancing rotations are hard to parallelize safely.
- Supports efficient range queries (level 0 is a full sorted linked list).

## 7. Disadvantages

- No absolute worst-case guarantee — only probabilistic/expected bounds (astronomically unlikely, but theoretically possible, degenerate cases exist).
- Extra memory for multiple levels of pointers per node, though modest in expectation (~2x a plain linked list).
- Randomness makes the structure's exact shape non-deterministic — harder to reason about or debug precisely compared to a deterministic tree structure.

---

## 8. Real-World Applications

- **Databases/Storage Engines:** Redis uses Skip Lists internally to implement its **Sorted Set** data type, specifically because of the combination of O(log n) average performance and simplicity/concurrency-friendliness.
- **Concurrent Programming:** Java's `ConcurrentSkipListMap` and `ConcurrentSkipListSet` use Skip Lists specifically because they're easier to make thread-safe (via fine-grained or lock-free techniques) than a balanced tree.
- **LevelDB / RocksDB (key-value storage engines):** Use Skip-List-based structures (`MemTable`) for the in-memory write buffer, valuing the simplicity and good average-case performance for a component that's rebuilt/flushed frequently.
- **Networking:** Some routing/lookup structures favor Skip Lists for their simplicity in probabilistic or approximate contexts.

---

## 9. Implementation (C++17)

```cpp
#include <iostream>
#include <vector>
#include <cstdlib>
#include <memory>

class SkipList {
private:
    struct Node {
        int value;
        std::vector<Node*> forward;   // forward[i] = pointer at level i
        Node(int val, int level) : value(val), forward(level + 1, nullptr) {}
    };

    static constexpr int MAX_LEVEL = 16;
    static constexpr float PROBABILITY = 0.5f;

    Node* head;
    int currentLevel;

    // Randomly determine a new node's level via repeated "coin flips."
    int randomLevel() {
        int level = 0;
        while (static_cast<float>(rand()) / RAND_MAX < PROBABILITY && level < MAX_LEVEL) {
            level++;
        }
        return level;
    }

public:
    SkipList() : currentLevel(0) {
        head = new Node(-1, MAX_LEVEL);   // sentinel head, present at every level
    }

    ~SkipList() {
        Node* current = head->forward[0];
        while (current) {
            Node* next = current->forward[0];
            delete current;
            current = next;
        }
        delete head;
    }

    // Search. Expected O(log n).
    bool search(int target) {
        Node* current = head;
        for (int i = currentLevel; i >= 0; --i) {
            while (current->forward[i] && current->forward[i]->value < target) {
                current = current->forward[i];   // move right as far as possible at this level
            }
            // about to overshoot or hit end -> drop down a level
        }
        current = current->forward[0];
        return current != nullptr && current->value == target;
    }

    // Insert. Expected O(log n).
    void insert(int value) {
        std::vector<Node*> update(MAX_LEVEL + 1, head);   // tracks the predecessor at EACH level
        Node* current = head;

        for (int i = currentLevel; i >= 0; --i) {
            while (current->forward[i] && current->forward[i]->value < value) {
                current = current->forward[i];
            }
            update[i] = current;   // remember where we dropped down from, at this level
        }

        int newLevel = randomLevel();
        if (newLevel > currentLevel) {
            for (int i = currentLevel + 1; i <= newLevel; ++i) {
                update[i] = head;   // new top levels' predecessor is simply the head
            }
            currentLevel = newLevel;
        }

        Node* newNode = new Node(value, newLevel);
        for (int i = 0; i <= newLevel; ++i) {
            newNode->forward[i] = update[i]->forward[i];   // splice in at every assigned level
            update[i]->forward[i] = newNode;
        }
    }

    // Delete. Expected O(log n).
    void remove(int value) {
        std::vector<Node*> update(MAX_LEVEL + 1, head);
        Node* current = head;

        for (int i = currentLevel; i >= 0; --i) {
            while (current->forward[i] && current->forward[i]->value < value) {
                current = current->forward[i];
            }
            update[i] = current;
        }

        current = current->forward[0];
        if (!current || current->value != value) return;   // not found

        for (int i = 0; i <= currentLevel; ++i) {
            if (update[i]->forward[i] != current) break;   // this level doesn't contain the node
            update[i]->forward[i] = current->forward[i];   // unlink at this level
        }
        delete current;

        while (currentLevel > 0 && head->forward[currentLevel] == nullptr) {
            currentLevel--;   // shrink if the top level(s) became empty
        }
    }
};

// Example usage
int main() {
    SkipList list;
    for (int v : {30, 10, 50, 20, 40}) {
        list.insert(v);
    }

    std::cout << "search(40): " << list.search(40) << "\n";   // 1 (true)
    std::cout << "search(25): " << list.search(25) << "\n";   // 0 (false)

    list.remove(30);
    std::cout << "search(30) after remove: " << list.search(30) << "\n";   // 0 (false)

    return 0;
}
```

---

## 10. Code Walkthrough

- **`Node::forward` as a `vector<Node*>`:** Each node holds one forward pointer *per level it participates in* — a node assigned level 2 has `forward.size() == 3` (levels 0, 1, 2). This variable-length-per-node structure is exactly what makes memory usage proportional to the (randomized) sum of assigned heights, not a fixed multiple per node.
- **`randomLevel`'s coin-flip loop:** Each iteration is like a coin flip with `PROBABILITY` chance of "promote" — this directly implements the geometric distribution described in section 3, capped at `MAX_LEVEL` to bound worst-case memory in pathological (extremely unlucky) cases.
- **`search`'s "move right, then drop down" double loop:** The outer loop walks levels top-down; the inner `while` greedily moves right *within* a level as far as possible without overshooting — this is the literal implementation of the "express lane, then drop to local" analogy from section 1.
- **`insert`'s `update[]` array:** Tracks, for every level, the last node visited before dropping down — these become the new node's *predecessors* at each level once its random height is determined. This is conceptually identical to how you'd track "the node just before the insertion point" in a plain linked list insert, just replicated across multiple levels.
- **`insert`'s level-growth handling (`if (newLevel > currentLevel)`):** If the new node's randomly assigned height exceeds every existing node's height, the list's `currentLevel` itself grows, and the new top levels' only "predecessor" is trivially the head (since nothing else exists at that height yet).
- **`remove`'s `if (update[i]->forward[i] != current) break;`:** This check handles the fact that a node being deleted might not appear at every level up to `currentLevel` — once we reach a level where the node under deletion isn't the very next node, we know it doesn't participate in that level (or above), so we stop unlinking.

**Common mistakes to watch for here:**
- Forgetting to track predecessors at **every** level during insert/delete, not just the level(s) the target node ultimately occupies.
- Not shrinking `currentLevel` after deletions empty out the top level(s), leaving wasted iteration in future searches.
- Using a fixed (non-random) promotion pattern, defeating the entire probabilistic balance guarantee.

---

## 11. Dry Run

**Insert 30, 10, 50, 20, 40** (assume, for a clean illustrative dry run, that random level assignment gives: 30→level1, 10→level0, 50→level2, 20→level0, 40→level1):

| After inserting | Level 2 | Level 1 | Level 0 (full sorted list) |
|---|---|---|---|
| 30 (level 1) | — | 30 | 30 |
| 10 (level 0) | — | 30 | 10, 30 |
| 50 (level 2) | 50 | 30, 50 | 10, 30, 50 |
| 20 (level 0) | 50 | 30, 50 | 10, 20, 30, 50 |
| 40 (level 1) | 50 | 30, 40, 50 | 10, 20, 30, 40, 50 |

**Search(40):**
```
Level 2 (currentLevel=2): head -> 50. 50 > 40, don't move. Drop to level 1.
Level 1: head -> 30 (30<40, move) -> 40 (40==40 stop moving, but check next)... 
  at 30, forward[1]=40, 40 < 40? No (equal, not strictly less) -> stop moving right, drop to level 0.
Level 0: at 30 -> 40. current->forward[0]=40, value 40, match!
Final check: current = current->forward[0] = node(40). value==target -> TRUE.
```
Only touched nodes 50 (level 2), 30 and 40 (level 1), 40 (level 0) — 3-4 comparisons versus 5 for a full linear scan; the advantage compounds dramatically for larger n.

---

## 12. Interview Questions

**Conceptual:**
1. Why is a Skip List's O(log n) bound "expected," not guaranteed, unlike an AVL Tree?
2. Explain how randomized level assignment substitutes for explicit tree rotations.
3. Why are Skip Lists considered easier to make thread-safe/concurrent than balanced trees?
4. What's the expected total memory overhead of a Skip List compared to a plain linked list?
5. Compare Skip List vs. AVL Tree vs. Hash Table for a sorted-set use case — trade-offs of each.

**Coding:**
1. Implement a Skip List's search, insert, and delete (LeetCode 1206 — Design Skip List).
2. Implement a sorted set backed by a Skip List supporting rank queries (what's the Kth smallest element?).
3. Design a Redis-style sorted set (Skip List + Hash Map combo, mirroring Redis's actual implementation).

**Follow-ups / interviewer traps:**
- "What happens in the theoretical worst case where every coin flip favors maximum promotion?" (tests honest acknowledgment of the O(n) worst case, and why it's astronomically unlikely rather than impossible)
- "How would you make Insert/Delete safe for concurrent access?" (tests awareness that per-level fine-grained locking, or lock-free CAS-based techniques, are much more tractable here than for a rotating tree)

---

## 13. Practice Problems

**Medium/Hard**
- Design Skip List (LeetCode 1206)
- Design a sorted data structure supporting rank/order-statistics queries (extension exercise)

Skip Lists are less common as standalone LeetCode problems (more of a "explain and implement from scratch" systems/interview topic) — the highest-value practice is implementing one fully from scratch and stress-testing it against a plain sorted array or `std::set` for correctness, plus reading Redis's actual sorted-set source for a real production example.

Also recommended: GeeksforGeeks "Skip List" practice/theory set; William Pugh's original 1990 paper ("Skip Lists: A Probabilistic Alternative to Balanced Trees") is short, readable, and a genuinely worthwhile primary source.

---

## 14. Common Mistakes

- **Confusing "expected O(log n)" with a hard guarantee** — a Skip List's worst case is technically O(n), just vanishingly unlikely with proper randomization.
- **Forgetting to track predecessors at every level** during insert/delete, corrupting the structure at levels above the immediately obvious one.
- **Using a bad or predictable random number source**, undermining the probabilistic balance the entire structure depends on.
- **Not capping `MAX_LEVEL`**, risking pathological memory usage in rare unlucky cases (or capping it too low for the expected dataset size, which increases the constant factor in practice).
- **Forgetting to shrink `currentLevel`** after deletions, leaving dead levels that add small but unnecessary overhead to every subsequent search.

---

## 15. Summary

**Key takeaways:**
- A Skip List achieves expected O(log n) search/insert/delete using randomized "express lane" levels layered over a base sorted linked list — no rotations required.
- The trade-off versus AVL/Red-Black Trees is guaranteed-worst-case (trees) vs. simpler-code-and-concurrency-friendliness (skip lists) — both achieve the same *expected* asymptotic performance.
- Redis's Sorted Set and Java's `ConcurrentSkipListMap` are the most prominent real-world validations of this design.

**Complexity recap:**

| Operation | Expected Time | Worst Case | Space |
|---|---|---|---|
| Search / Insert / Delete | O(log n) | O(n) (astronomically unlikely) | O(n) expected |

**Decision guideline:** Choose a Skip List when you want BST-like average performance with much simpler implementation than a self-balancing tree, especially in concurrent/multi-threaded contexts. Choose an AVL/Red-Black Tree instead when you need an absolute worst-case guarantee, not just a probabilistic one (e.g., real-time systems with hard latency bounds).

---

*Next chapter: `18_bloom_filter.md`, followed by the capstone `19_lru_cache.md`.*
