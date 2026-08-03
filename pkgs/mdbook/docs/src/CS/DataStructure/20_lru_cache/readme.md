# Chapter 19: LRU Cache (Capstone)

*Study time: ~5-6 hours | Prerequisite: Hash Table (Ch. 5), Doubly Linked List (Ch. 2) | Difficulty: Advanced*
*This is the capstone project for the entire guide — it combines two data structures from opposite ends of the roadmap into one elegant, O(1)-everything design.*

---

## 1. Introduction

**Definition:** An LRU (**L**east **R**ecently **U**sed) Cache is a fixed-capacity key-value store that, when full, evicts the item that hasn't been accessed for the **longest time** to make room for a new one — both `get` and `put` must run in O(1).

**Purpose:** To keep a bounded amount of "hot" (frequently/recently used) data readily available, automatically discarding the "coldest" (least recently touched) data when space runs out — without ever scanning the whole cache to decide what to evict.

**Real-world analogy:** Your work desk has limited space. You keep the documents you're actively using right in front of you; when a new document arrives and your desk is full, you file away whichever document you haven't touched in the longest time — not necessarily the oldest one you ever put there, but the one that's gone the longest *without being looked at again*.

**Motivation:** Caches speed up systems by keeping frequently-accessed data close at hand (in fast memory) instead of re-fetching it from a slow source (disk, network, database) every time. But memory is finite — you need an eviction policy for when the cache is full, and LRU is the most widely used policy because "recently used" is usually a strong predictor of "will be used again soon" (this assumption is called **temporal locality**, and it holds remarkably well for most real workloads).

**History:** LRU caching is a foundational concept in operating systems (virtual memory page replacement) dating to the 1960s, and remains the default or near-default cache eviction policy across nearly every layer of modern computing.

---

## 2. Why Do We Need It?

**Problem it solves:** Bounded-memory caching with an eviction policy that requires **no scanning** to decide what to remove — both lookup and the recency-tracking update must be O(1), or the cache itself becomes the bottleneck it was meant to eliminate.

**Why previous structures are insufficient on their own:**
- **Hash Map alone:** O(1) lookup, but has no concept of "access order" — you'd need O(n) to scan for the least-recently-used item when eviction is needed.
- **Doubly Linked List alone (ordered by recency):** O(1) to move an item to the "most recent" end, but O(n) to *find* that item in the first place (no fast lookup by key).
- **Array (ordered by recency):** same fundamental issue — moving an item to the front/back requires knowing its position, and finding that position is O(n).

**The key insight — and the entire point of this capstone chapter:** neither structure alone can give you O(1) for *both* "find by key" and "track/update recency order." **Combining them** — a Hash Map for O(1) lookup, pointing directly at nodes in a Doubly Linked List for O(1) recency reordering — gives you both simultaneously. This is precisely why the guide placed Hash Tables (Chapter 5) and Doubly Linked Lists (Chapter 2) where it did: this capstone is their natural convergence point.

**Trade-offs:**
- You gain O(1) `get` and `put`, including eviction — genuinely as fast as a cache can be.
- You pay for it with the combined memory overhead of both structures (hash map entries *and* linked list node pointers) and meaningfully more implementation care than either structure alone (keeping both structures perfectly in sync on every operation is the whole challenge).

---

## 3. Internal Working

**The combined structure:**
```
HashMap<Key, Node*>  ──points directly into──▶  Doubly Linked List (ordered by recency)

                    MOST RECENT                      LEAST RECENT
head (dummy) ⟷ [key3:val] ⟷ [key1:val] ⟷ [key2:val] ⟷ tail (dummy)
```

The list is kept ordered by recency at all times: the **head** side holds the most-recently-used item; the **tail** side holds the least-recently-used item — the one that gets evicted first when the cache is full. Using **dummy head/tail sentinel nodes** (holding no real data) simplifies the pointer logic, since every real node then always has a genuine non-null neighbor on both sides, eliminating special-case checks for "is this the very first/last real node?"

**`get(key)` — walkthrough:**
```
get("key1"):
1. HashMap lookup: "key1" → pointer to its node in the linked list. O(1).
2. Found! This access makes "key1" the MOST recently used — move its node
   to right after head (the "most recent" position). O(1), pure pointer surgery,
   no searching required since we already have a direct pointer to the node.
3. Return the value.

Before: head ⟷ [key3] ⟷ [key1] ⟷ [key2] ⟷ tail
After:  head ⟷ [key1] ⟷ [key3] ⟷ [key2] ⟷ tail
                 ▲ moved to front
```

**`put(key, value)` when the cache is FULL — walkthrough:**
```
Cache capacity 3, currently: head ⟷ [key1] ⟷ [key3] ⟷ [key2] ⟷ tail  (key2 is least recent)
put("key4", val4):
1. Cache is full (size == capacity) → must evict.
2. The LEAST recently used item is always right before tail — that's key2. Remove it:
   both from the linked list (O(1), direct pointer) AND from the hash map (O(1) key-based delete).
3. Insert the new node for key4 right after head (it's now the most recent).
4. Add "key4" -> node pointer into the hash map.

After: head ⟷ [key4] ⟷ [key1] ⟷ [key3] ⟷ tail   (key2 evicted)
```

---

## 4. Operations

**get(key):**
- Hash map lookup for the node. O(1).
- If not found, return "not present" (a cache miss).
- If found: unlink the node from its current position and relink it right after `head` (marking it most-recently-used), then return its value. Both steps are O(1) because the hash map gave us a direct pointer — no traversal needed.

**put(key, value):**
- If the key already exists: update its value, and move its node to right after `head` (same "mark as most recent" logic as `get`).
- If the key is new and the cache has room: create a new node, insert it right after `head`, and add the key→node mapping to the hash map.
- If the key is new and the cache is **full**: remove the node right before `tail` (the least-recently-used item) from both the linked list and the hash map, *then* insert the new node as above.
- All cases: O(1).

**Delete/Evict (internal, triggered by `put` when full):**
- Always targets the node adjacent to `tail` — this is guaranteed to be the least-recently-used item, precisely because the list is kept ordered by recency at every step, never needing a scan to find it.

---

## 5. Time & Space Complexity

| Operation | Time Complexity | Space Complexity |
|---|---|---|
| get | O(1) | O(1) |
| put (update existing) | O(1) | O(1) |
| put (insert, room available) | O(1) | O(1) |
| put (insert, triggers eviction) | O(1) | O(1) |
| Overall storage | — | O(capacity) — bounded, this is the entire point of a "cache" |

**Why these hold:** Every single operation is O(1) because the hash map eliminates the need to *search* for a node (direct pointer lookup), and the doubly linked list's `prev`/`next` pointers eliminate the need to *shift* anything when moving a node to the front or removing one from the back (unlike an array, where "move to front" would mean shifting everything else). This is the exact payoff promised in section 2 — combining the two structures' individual O(1) strengths (hash map's O(1) lookup, doubly linked list's O(1) insert/delete-given-a-node) into one design that has no O(n) step anywhere.

---

## 6. Advantages

- Every operation — including eviction — is O(1), making it suitable for extremely high-throughput caching layers.
- Conceptually clean once understood: "hash map for lookup, linked list for recency order, keep them in sync."
- LRU is a well-understood, broadly effective eviction policy that performs well across a very wide range of real-world access patterns (temporal locality is a near-universal property of real workloads).

## 7. Disadvantages

- More implementation complexity than either structure alone — every operation must correctly update *both* structures in lockstep; a bug that updates one but not the other silently corrupts the cache.
- LRU can perform poorly for certain access patterns (e.g., a large one-time sequential scan can evict genuinely "hot" frequently-used items, since "most recent" and "most frequent" aren't always the same thing — this is why variants like LFU (Least Frequently Used) or hybrid policies like LRU-K exist for specific workloads).
- Fixed capacity must be chosen upfront (or the underlying structures resized), and choosing it well requires understanding the actual workload's working-set size.

---

## 8. Real-World Applications

- **Operating Systems:** Virtual memory page replacement — deciding which memory pages to swap out to disk when RAM is full is a classic LRU (or LRU-approximation) problem.
- **Databases:** Buffer pool management (e.g., MySQL InnoDB's buffer pool uses an LRU-based eviction strategy for cached disk pages).
- **CDNs / Web Caching:** Deciding which cached web assets to evict when cache storage is full.
- **Browsers:** Caching recently visited pages/resources, evicting the least recently used when storage limits are hit.
- **CPU Caches:** Hardware cache replacement policies are conceptually LRU-inspired (though real hardware often uses cheaper LRU-approximations due to strict speed/area constraints).
- **API/Application-Level Caching:** In-memory caching layers (like a local cache in front of Redis or a database) very commonly default to LRU eviction.
- **Content Recommendation/Session Management:** Keeping a bounded "recently viewed items" list per user is directly an LRU-style structure.

---

## 9. Implementation (C++17)

```cpp
#include <iostream>
#include <unordered_map>

class LRUCache {
private:
    struct Node {
        int key, value;
        Node* prev;
        Node* next;
        Node(int k, int v) : key(k), value(v), prev(nullptr), next(nullptr) {}
    };

    int capacity;
    std::unordered_map<int, Node*> cache;   // key -> direct pointer to its list node
    Node* head;   // dummy sentinel: head->next is always the MOST recently used real node
    Node* tail;   // dummy sentinel: tail->prev is always the LEAST recently used real node

    // Detach a node from its current position in the list. O(1) — pure pointer relinking.
    void removeNode(Node* node) {
        node->prev->next = node->next;
        node->next->prev = node->prev;
    }

    // Insert a node right after head (marking it most-recently-used). O(1).
    void insertAtFront(Node* node) {
        node->next = head->next;
        node->prev = head;
        head->next->prev = node;
        head->next = node;
    }

public:
    LRUCache(int cap) : capacity(cap) {
        head = new Node(-1, -1);   // dummy sentinels hold no real data
        tail = new Node(-1, -1);
        head->next = tail;
        tail->prev = head;
    }

    ~LRUCache() {
        Node* current = head;
        while (current != nullptr) {
            Node* toDelete = current;
            current = current->next;
            delete toDelete;
        }
    }

    // O(1): hash map lookup + O(1) reposition to front.
    int get(int key) {
        auto it = cache.find(key);
        if (it == cache.end()) return -1;   // cache miss

        Node* node = it->second;
        removeNode(node);           // detach from current position
        insertAtFront(node);        // re-insert as most-recently-used
        return node->value;
    }

    // O(1): update-in-place, or insert-with-possible-eviction.
    void put(int key, int value) {
        auto it = cache.find(key);
        if (it != cache.end()) {
            // Key already exists: update value, mark as most recently used.
            Node* node = it->second;
            node->value = value;
            removeNode(node);
            insertAtFront(node);
            return;
        }

        if (static_cast<int>(cache.size()) == capacity) {
            // Cache full: evict the least-recently-used node (always right before tail).
            Node* lru = tail->prev;
            removeNode(lru);
            cache.erase(lru->key);
            delete lru;
        }

        // Insert the new key as most-recently-used.
        Node* newNode = new Node(key, value);
        insertAtFront(newNode);
        cache[key] = newNode;
    }
};

// Example usage
int main() {
    LRUCache lru(2);   // capacity 2

    lru.put(1, 100);
    lru.put(2, 200);
    std::cout << "get(1): " << lru.get(1) << "\n";   // 100 — also marks key 1 as most recent

    lru.put(3, 300);   // cache full (1,2) — evicts key 2 (least recently used, since 1 was just accessed)
    std::cout << "get(2): " << lru.get(2) << "\n";   // -1 — evicted, cache miss

    lru.put(4, 400);   // cache full (1,3) — evicts key 1 (least recently used now)
    std::cout << "get(1): " << lru.get(1) << "\n";   // -1 — evicted
    std::cout << "get(3): " << lru.get(3) << "\n";   // 300 — still present
    std::cout << "get(4): " << lru.get(4) << "\n";   // 400 — still present

    return 0;
}
```

---

## 10. Code Walkthrough

- **Dummy `head`/`tail` sentinels:** Neither holds real data — their entire purpose is to eliminate special-case logic. Without them, inserting into an empty list or removing the only remaining node would need extra `if` branches to handle "there is no next/prev node yet." With sentinels, `head->next` and `tail->prev` are *always* valid pointers to real nodes (or to each other, if the cache is empty) — this single design choice is what keeps `removeNode` and `insertAtFront` completely branch-free.
- **`cache` mapping key directly to a `Node*`:** This is the crucial link between the two structures — the hash map doesn't store the value itself, it stores a *pointer* directly into the linked list, so once we find a key, moving/updating its node is pure O(1) pointer surgery, with zero additional searching.
- **`removeNode` + `insertAtFront` as the two universal building blocks:** Notice that **both** `get` (on a hit) and `put` (on an update, or a fresh insert) ultimately reduce to some combination of these same two operations — "detach a node" and "place a node as most-recent." This is why the whole class stays so short despite handling several distinct scenarios.
- **Eviction logic (`tail->prev`):** Because the list is *always* kept in recency order by every single `get`/`put` operation, the least-recently-used node is *guaranteed* to be sitting right before `tail` at the exact moment we need to evict — no scan, no search, just a direct pointer dereference.
- **Order of operations in `put`'s eviction branch:** Note `removeNode(lru)` and `cache.erase(lru->key)` happen *before* `delete lru` — deleting the node first would leave a dangling pointer in the hash map and cause undefined behavior when later code tries to read `lru->key`.

**Common mistakes to watch for here:**
- Forgetting to update the hash map when evicting a node from the linked list (or vice versa) — this desynchronizes the two structures, the single most common LRU Cache bug.
- Not moving a node to the front on a `get` **hit** — this is easy to forget, but it's essential: a `get` is itself a "use" of that key, and must count toward recency exactly like a `put` does.
- Checking capacity *after* inserting the new node instead of *before* evicting — can transiently let the cache exceed capacity, or evict the just-inserted node by mistake.
- Deleting a node before removing its entry from the hash map, leaving a dangling pointer.

---

## 11. Dry Run

**Capacity 2.** Operations: `put(1,100)`, `put(2,200)`, `get(1)`, `put(3,300)`, `get(2)`

| Step | Action | List (most-recent → least-recent) | HashMap keys | Notes |
|---|---|---|---|---|
| 1 | put(1,100) | [1] | {1} | inserted, room available |
| 2 | put(2,200) | [2,1] | {1,2} | inserted at front |
| 3 | get(1) → 100 | [1,2] | {1,2} | key 1 accessed → moved to front |
| 4 | put(3,300) | cache full (size==2) → evict least-recent = 2 (at tail->prev) → then insert 3 → [3,1] | {1,3} | key 2 evicted |
| 5 | get(2) → **-1** | [3,1] (unchanged, miss doesn't reorder) | {1,3} | key 2 no longer present — cache miss |

Final state: keys {1, 3} remain, key 2 was correctly evicted as the least-recently-used item at the moment `put(3,300)` needed room. ✓

---

## 12. Interview Questions

**Conceptual:**
1. Why does an LRU Cache need *both* a hash map and a doubly linked list — why can't either alone achieve O(1) for everything?
2. Why specifically a *doubly* linked list, not a singly linked list?
3. Why do dummy head/tail sentinel nodes simplify the implementation?
4. What real-world access pattern could make LRU perform worse than a simpler policy (e.g., FIFO)? (Sequential one-time scans that don't repeat.)
5. How would you extend this design to an LFU (Least Frequently Used) Cache instead — what would need to change?

**Coding:**
1. Implement LRU Cache from scratch (this chapter's exercise, LeetCode 146).
2. Implement LFU Cache (LeetCode 460) — a strictly harder variant requiring frequency tracking alongside recency.
3. Design a thread-safe version of LRU Cache (discuss locking strategy — a common systems-interview follow-up).
4. All O(1) Data Structure (LeetCode 432) — a related "combine hash map + linked list for O(1) everything" problem.
5. Design an in-memory cache with TTL (time-to-live) expiration in addition to LRU eviction.

**Follow-ups / interviewer traps:**
- "What if two threads call get() and put() concurrently — what breaks?" (tests awareness that the naive implementation is not thread-safe; pointer relinking during a concurrent read can corrupt the list — expects discussion of locking, or a lock-free/sharded design)
- "How would you make this cache distributed across multiple machines?" (tests systems-design thinking beyond the single-machine data structure — consistent hashing, distributed invalidation, etc.)
- "Your cache needs to support very large capacities — does the hash map's memory overhead matter?" (tests awareness of real memory costs: each entry needs a hash map slot AND a linked list node with two pointers, non-trivial overhead at scale)

---

## 13. Practice Problems

**Medium**
- LRU Cache (LeetCode 146) — this chapter's direct exercise
- Design a HashMap with expiry (variants seen in real interview loops)

**Hard**
- LFU Cache (LeetCode 460)
- All O(1) Data Structure (LeetCode 432)
- Design In-Memory File System (related "combine multiple structures for O(1)/efficient operations" design pattern)

Also recommended: implement this from scratch under a strict time limit (20-30 minutes) as a mock-interview exercise — LRU Cache is one of the most frequently asked data-structure-design questions at major tech companies specifically *because* it requires correctly combining two structures rather than just implementing one in isolation.

---

## 14. Common Mistakes

- **Desynchronizing the hash map and linked list** — any operation that updates one without correspondingly updating the other corrupts the cache silently (no crash, just wrong future behavior).
- **Forgetting that a `get` hit counts as a "use"** and must reorder the list, not just return the value.
- **Off-by-one/dangling-pointer bugs during eviction** — deleting a node before removing its hash map entry, or vice versa in the wrong order.
- **Using a singly linked list** and then struggling to remove an arbitrary node in O(1) — this is exactly the tail-deletion problem from Chapter 2, and it's precisely why LRU Cache requires a *doubly* linked list.
- **Not using dummy sentinels**, then mishandling the edge cases of an empty cache or a cache with exactly one item.
- **Checking cache size at the wrong point** in `put` — must check *before* deciding whether eviction is needed, not after already inserting.

---

## 15. Summary

**Key takeaways:**
- This capstone chapter is the payoff for the entire guide's structure: neither a Hash Map nor a Doubly Linked List alone can give O(1) for both "find by key" and "reorder by recency" — combining them does, by using the hash map to store direct pointers into the linked list.
- Every operation reduces to two universal building blocks: detach a node, and re-insert it as most-recently-used.
- Dummy sentinel nodes eliminate special-case edge handling for empty/single-element states.
- LRU is the default cache eviction policy across virtually every layer of computing (OS memory, databases, CDNs, browsers) because temporal locality — recently used data tends to be used again soon — holds for most real workloads.

**Complexity recap:**

| Operation | Time | Space |
|---|---|---|
| get | O(1) | O(1) |
| put (any case, including eviction) | O(1) | O(1) |
| Overall | — | O(capacity) |

**Decision guideline:** Reach for this Hash Map + Doubly Linked List combination whenever you need O(1) lookup **and** O(1) reordering/removal by recency (or any other "most recently touched" criterion) — not just for caching, but for any "bounded working set with fast eviction" problem. If your eviction policy is frequency-based rather than recency-based, the same skeleton extends to LFU with additional bookkeeping (a frequency-bucketed structure, more involved but built on the same core idea).

---

## Guide Complete — Final Reflection

You've now covered every structure in the original roadmap: Arrays → Strings-adjacent concepts woven throughout → Linked Lists → Stack/Queue → Hash Tables → Binary Tree/BST → AVL Tree → Trie → B-Tree → Graphs (representation, BFS, DFS, Topological Sort, MST, Shortest Path) → Segment Tree → Fenwick Tree → DSU → Skip List → Bloom Filter → LRU Cache.

The throughline worth carrying forward: almost every "advanced" structure in this guide is either (a) a clever index/pointer trick layered over an array or linked list, or (b) a combination of two simpler structures used together to cancel out each other's weaknesses (exactly like this capstone). When you encounter an unfamiliar data structure in the future, asking "what simpler structures is this built from, and what specific weakness is it patching?" will get you most of the way to understanding it — that's the same lens this entire guide has used, chapter after chapter.
