# Chapter 5: Hash Tables (Hash Table, Hash Map, Hash Set)

*Study time: ~6-8 hours | Prerequisite: Arrays, Linked Lists | Difficulty: Intermediate*

---

## 1. Introduction

**Definition:** A hash table is a data structure that maps **keys** to **values** (or just stores keys, for a set) using a **hash function** to compute an array index from the key, giving average O(1) insert, delete, and lookup. A **Hash Map** is a hash table storing key-value pairs; a **Hash Set** is a hash table storing keys only (membership testing).

**Purpose:** To answer "is X present?" or "what value is associated with key X?" in close to constant time, regardless of how many elements are stored.

**Real-world analogy:** A library that assigns every book a shelf number computed directly from its ISBN (via some formula), rather than alphabetically sorting all books. To find a book, you compute the shelf number and walk straight there — no searching required, as long as two different books don't get mapped to the exact same shelf (a "collision," handled in section 3).

**Motivation:** Arrays give O(1) access — but only by *integer index*. Real-world keys are strings, objects, tuples — arbitrary data. A hash function is the bridge that converts an arbitrary key into an array index, letting us reuse the array's O(1) access for arbitrary key types.

**History:** The hashing concept dates to IBM researchers in the 1950s (Hans Peter Luhn is often credited with early hashing ideas); it became foundational to virtually every modern language's built-in dictionary/map type (Python `dict`, Java `HashMap`, C++ `unordered_map`, JavaScript `Object`/`Map`).

---

## 2. Why Do We Need It?

**Problem it solves:** Fast lookup/insert/delete by an arbitrary key (not necessarily a small integer), without paying the O(log n) cost of a balanced tree or the O(n) cost of linear search.

**Why previous structures are insufficient:**
- **Array (direct indexing):** only works if keys are already small, dense integers.
- **Sorted array / BST:** O(log n) lookup, which is good but not as fast as the O(1) average a hash table offers — and requires the key type to support ordering (`<`), which isn't always natural (e.g., is `{name: "Bob"}` "less than" `{name: "Alice"}`? Only if you define an ordering — a hash table needs no such definition).
- **Linked list:** O(n) — no better than brute-force search.

**Trade-offs:**
- You gain O(1) average-case operations for arbitrary key types.
- You pay for it with: no ordering (can't easily ask "give me keys in sorted order" or "give me the next key after X"), worst-case O(n) if hashing goes badly (many collisions), and memory overhead (unused buckets, plus collision-handling structures).

---

## 3. Internal Working

**Step 1 — Hash function:** Converts a key into an integer, then that integer is reduced to a valid array index via modulo:

```
index = hash(key) % table_size
```

Example with a simple string hash and table_size = 7:
```
hash("cat") = 312   →  312 % 7 = 4   → bucket 4
hash("dog") = 205   →  205 % 7 = 2   → bucket 2
```

**Step 2 — Collisions.** Two different keys can hash to the *same* bucket. Two standard strategies:

**(a) Chaining** — each bucket holds a linked list (or small vector) of all key-value pairs that hashed there:

```
Bucket 0: []
Bucket 1: []
Bucket 2: [("dog", 5)]
Bucket 3: []
Bucket 4: [("cat", 9)] → [("bat", 2)]   ← collision! both hashed to 4, chained together
Bucket 5: []
Bucket 6: []
```

To find `"bat"`: compute `hash("bat") % 7 = 4`, go to bucket 4, then linearly scan the short chain (`"cat"` → no match, `"bat"` → match, return 2).

**(b) Open Addressing (linear probing)** — no chains; if a bucket is occupied, probe the *next* slot until an empty one is found:

```
Insert "cat" → bucket 4 (empty) → place there.
Insert "bat" → bucket 4 (occupied by "cat") → probe bucket 5 (empty) → place there.
```
Lookup for `"bat"` must replay the same probing sequence: check bucket 4 (occupied, but not a match) → check bucket 5 (match).

**Step 3 — Resizing (rehashing).** When the table gets too full (measured by **load factor** = `n / table_size`, typically resized when it exceeds ~0.7), a bigger table is allocated and *every* existing key is re-hashed into the new table (since `% table_size` changes with the new size). This is the O(n) event that amortizes into O(1) average, exactly like a dynamic array's resize.

---

## 4. Operations

**Insert (put):**
- Compute `hash(key) % table_size`.
- Chaining: append to the bucket's list (or update if key already exists in the chain).
- Open addressing: probe forward until an empty (or matching) slot is found.
- If load factor exceeds threshold, trigger a resize + full rehash.
- Edge case: inserting a duplicate key should *update* the value, not create a second entry.

**Delete:**
- Compute the bucket, then find and remove the matching key.
- Chaining: remove the node from the linked list. O(1) average (short chain).
- Open addressing: trickier — simply clearing the slot can break the probing sequence for *other* keys that probed past it. Requires either a "tombstone" marker or shifting subsequent entries back.

**Search (get / contains):**
- Compute the bucket, then scan the chain (chaining) or probe forward (open addressing) until the key is found or an empty slot is hit (meaning "not present").

**Update:**
- Same as insert for an existing key — locate the bucket/chain entry and overwrite the value.

**Traverse:**
- Iterate all buckets and all entries within each. O(n), but in **no particular order** (unlike arrays/trees).

---

## 5. Time & Space Complexity

| Operation | Average Case | Worst Case | Space Complexity |
|---|---|---|---|
| Insert | O(1) | O(n) | O(n) |
| Delete | O(1) | O(n) | O(1) |
| Search | O(1) | O(n) | O(1) |
| Traverse all | O(n) | O(n) | O(1) extra |
| Resize (amortized per insert) | O(1) amortized | O(n) for the resize event itself | O(n) |

**Why these hold:**
- Average O(1) assumes a **good hash function** that spreads keys roughly uniformly across buckets, keeping each bucket's chain short (ideally length ~load factor, a small constant).
- **Worst case O(n)** happens when many/all keys collide into the same bucket (e.g., a poor hash function, or an adversary crafting colliding keys) — the chain degenerates into a plain linked list, and search becomes linear.
- Resizing is O(n) for that single operation (every key must be rehashed), but because resizes happen exponentially less often as the table doubles, the *amortized* cost per insert stays O(1) — the same geometric-series argument as the Dynamic Array chapter.

---

## 6. Advantages

- O(1) average time for insert/search/delete — often the fastest general-purpose lookup structure available.
- Works with any hashable key type — strings, tuples, custom objects (given a proper hash function).
- Simple mental model once you understand hash + bucket + collision handling.

## 7. Disadvantages

- No ordering — can't efficiently get "sorted keys" or "the next key after X" (a BST/sorted structure is needed for that).
- Worst-case O(n) if the hash function is poor or under adversarial input (hash-flooding attacks — a real security concern for public-facing services).
- Memory overhead: some buckets stay empty (chaining) or a resize must maintain headroom (open addressing) to keep load factor low.
- Iteration order is unspecified and can change between runs/insertions (unlike an array or linked list).

---

## 8. Real-World Applications

- **Databases:** Indexing (hash indexes) for equality lookups; in-memory caches (e.g., Redis is fundamentally a giant distributed hash map).
- **Compilers:** Symbol tables mapping variable/function names to their metadata.
- **Operating Systems:** Page tables (mapping virtual to physical memory addresses) often use hashing structures.
- **Networking:** Routing tables, DNS caching (domain name → IP address lookups).
- **Search Engines:** Deduplication of crawled URLs (hash set of visited pages).
- **Browsers:** The `Object`/`Map` types in JavaScript are hash tables under the hood.
- **Security:** Password storage (hashed, not the table structure itself, but the underlying hash function concept), rate-limiting (hash set of recent request IDs).
- **AI/ML:** Feature hashing ("the hashing trick") to map huge vocabularies into fixed-size feature vectors.

---

## 9. Implementation (C++17)

```cpp
#include <iostream>
#include <vector>
#include <list>
#include <string>
#include <stdexcept>

// A HashMap<string, int> implemented with separate chaining.
// Demonstrates: hash function, bucket array, collision handling, and resizing.
class HashMap {
private:
    struct Entry {
        std::string key;
        int value;
    };

    std::vector<std::list<Entry>> buckets;   // each bucket is a chain (linked list)
    size_t count;                             // total number of key-value pairs stored
    static constexpr double MAX_LOAD_FACTOR = 0.7;

    // A simple polynomial rolling hash (djb2-style) for strings.
    size_t hashKey(const std::string& key) const {
        size_t hash = 5381;
        for (char c : key) {
            hash = hash * 33 + static_cast<size_t>(c);
        }
        return hash;
    }

    size_t bucketIndex(const std::string& key) const {
        return hashKey(key) % buckets.size();
    }

    // Rehash everything into a table of double the size when load factor is exceeded.
    void resize() {
        std::vector<std::list<Entry>> oldBuckets = std::move(buckets);
        buckets = std::vector<std::list<Entry>>(oldBuckets.size() * 2);
        for (auto& chain : oldBuckets) {
            for (auto& entry : chain) {
                size_t idx = bucketIndex(entry.key);   // recompute index for NEW table size
                buckets[idx].push_back(entry);
            }
        }
    }

public:
    HashMap() : buckets(8), count(0) {}   // start with 8 buckets

    // Insert or update. Amortized O(1).
    void put(const std::string& key, int value) {
        double loadFactor = static_cast<double>(count + 1) / buckets.size();
        if (loadFactor > MAX_LOAD_FACTOR) {
            resize();
        }
        size_t idx = bucketIndex(key);
        for (auto& entry : buckets[idx]) {
            if (entry.key == key) {   // key already exists → update in place
                entry.value = value;
                return;
            }
        }
        buckets[idx].push_back({key, value});   // new key → append to chain
        count++;
    }

    // Search. Average O(1), worst O(n) if a chain is long.
    bool get(const std::string& key, int& outValue) const {
        size_t idx = bucketIndex(key);
        for (const auto& entry : buckets[idx]) {
            if (entry.key == key) {
                outValue = entry.value;
                return true;
            }
        }
        return false;   // key not found
    }

    // Delete. Average O(1).
    bool remove(const std::string& key) {
        size_t idx = bucketIndex(key);
        auto& chain = buckets[idx];
        for (auto it = chain.begin(); it != chain.end(); ++it) {
            if (it->key == key) {
                chain.erase(it);
                count--;
                return true;
            }
        }
        return false;
    }

    bool contains(const std::string& key) const {
        int dummy;
        return get(key, dummy);
    }

    size_t size() const { return count; }
};

// Example usage
int main() {
    HashMap map;
    map.put("apple", 3);
    map.put("banana", 7);
    map.put("cherry", 12);

    int value;
    if (map.get("banana", value)) {
        std::cout << "banana -> " << value << "\n";   // 7
    }

    map.put("banana", 20);   // update existing key
    map.get("banana", value);
    std::cout << "banana updated -> " << value << "\n";   // 20

    map.remove("apple");
    std::cout << "Contains apple? " << (map.contains("apple") ? "yes" : "no") << "\n";  // no
    std::cout << "Map size: " << map.size() << "\n";   // 2
    return 0;
}
```

---

## 10. Code Walkthrough

- **`hashKey`:** A djb2-style polynomial hash — multiply-and-add across each character. The specific constants (5381, 33) are well-known choices that empirically spread string hashes well; the important *concept* is that it deterministically turns any string into a large integer.
- **`bucketIndex`:** Reduces the (potentially huge) hash value into a valid array index via modulo. This is the step that actually connects "arbitrary key" to "array position."
- **`buckets` as `vector<list<Entry>>`:** Each bucket is a chain — this is separate chaining. Using `std::list` means O(1) removal given an iterator, and no shifting needed on delete (unlike an array-backed chain).
- **`resize()`:** Note that every entry must be **re-bucketed**, not just copied — `bucketIndex` depends on `buckets.size()`, so an entry that hashed to bucket 3 in an 8-bucket table might belong in bucket 11 in a 16-bucket table. This full rehash is the O(n) cost that amortizes.
- **`put()`:** Checks load factor *before* inserting (using `count + 1` to see if the *new* count would exceed threshold) — this ordering avoids ever exceeding the threshold even briefly.
- **`get()` / `remove()`:** Both walk the target bucket's chain linearly — this is the O(1)-*average*-but-O(n)-*worst-case* part: if the hash function is bad and everything collides into one bucket, these become full linear scans.

**Common mistakes to watch for here:**
- Forgetting to re-bucket (only copying, not rehashing) during resize — this silently corrupts lookups since old bucket indices are invalid for the new table size.
- Using a poor hash function (e.g., just the string's length) — causes massive collision clustering.
- Not handling key updates (`put` on an existing key) — accidentally creating duplicate entries instead of updating in place.

---

## 11. Dry Run

**Setup:** 8 buckets. Assume (for illustration) simplified hash values: `hash("apple")=101`, `hash("banana")=205`, `hash("cherry")=308`, all mod 8.

| Key | hash % 8 | Bucket |
|---|---|---|
| apple | 101 % 8 = 5 | 5 |
| banana | 205 % 8 = 5 | 5 (collision with apple!) |
| cherry | 308 % 8 = 4 | 4 |

**Insert sequence:** `put("apple",3)`, `put("banana",7)`, `put("cherry",12)`

| Step | Bucket 4 | Bucket 5 |
|---|---|---|
| after apple | [] | [("apple",3)] |
| after banana | [] | [("apple",3) → ("banana",7)] ← chained due to collision |
| after cherry | [("cherry",12)] | [("apple",3) → ("banana",7)] |

**`get("banana")`:** compute bucket 5 → scan chain: `"apple"` (no match) → `"banana"` (match) → return 7. Two comparisons — still fast, but this illustrates *why* worst-case degrades: if 1000 keys collided into bucket 5, this scan would be O(1000).

---

## 12. Interview Questions

**Conceptual:**
1. Explain how a hash table achieves O(1) average lookup, and when it degrades to O(n).
2. Compare chaining vs. open addressing for collision handling — trade-offs of each.
3. What makes a "good" hash function? What happens with a bad one?
4. Why does resizing (rehashing) need to touch every existing key, not just the new one?
5. Why can't a hash table efficiently support "give me the smallest key" the way a BST or heap can?

**Coding:**
1. Design a HashMap from scratch (no built-in map/dict).
2. Group Anagrams using a hash map.
3. Two Sum using a hash map (O(n) instead of O(n²)).
4. Longest Consecutive Sequence using a hash set.
5. LRU Cache (hash map + doubly linked list — full chapter later).
6. First Unique Character in a string.
7. Subarray Sum Equals K (prefix sum + hash map).

**Follow-ups / interviewer traps:**
- "What if the hash function isn't uniform — how does that affect complexity?" (tests worst-case understanding)
- "Can you design a hash table where deletion doesn't break open-addressing probing?" (expects tombstones or backward-shift deletion)
- "How would you handle hash-flooding attacks in a public API?" (tests security awareness — randomized/keyed hash functions)

---

## 13. Practice Problems

**Easy**
- Two Sum (LeetCode 1)
- Contains Duplicate (LeetCode 217)
- Valid Anagram (LeetCode 242)
- Ransom Note (LeetCode 383)

**Medium**
- Group Anagrams (LeetCode 49)
- Top K Frequent Elements (LeetCode 347) — combines hashing + heap
- Longest Consecutive Sequence (LeetCode 128)
- Subarray Sum Equals K (LeetCode 560)
- Design HashMap (LeetCode 706)

**Hard**
- LRU Cache (LeetCode 146)
- Insert Delete GetRandom O(1) (LeetCode 380)
- Substring with Concatenation of All Words (LeetCode 30)

Also recommended: GeeksforGeeks "Hashing" practice set, HackerRank "Dictionaries and Hashmaps" track.

---

## 14. Common Mistakes

- **Assuming O(1) is guaranteed, not average-case** — forgetting worst-case O(n) exists under bad hashing/collisions.
- **Using a mutable object as a key** without understanding that if its hash changes after insertion, it becomes unfindable (a subtle bug in many languages).
- **Not rehashing fully on resize** — only copying without recomputing bucket indices.
- **Iterating and expecting sorted or insertion order** — hash table iteration order is unspecified (use an ordered map/tree, or a supplementary list, if order matters).
- **Ignoring load factor** — never resizing leads to long chains and degraded performance over time.
- **Comparing hash values directly for equality** instead of comparing the actual keys (two different keys *can* share a hash — always verify with a full key comparison after narrowing to a bucket).

---

## 15. Summary

**Key takeaways:**
- A hash table converts an arbitrary key into an array index via a hash function, giving average O(1) operations at the cost of losing ordering.
- Collisions are inevitable (pigeonhole principle) and must be handled — chaining (simple, extra memory) or open addressing (compact, trickier deletion).
- Resizing/rehashing is what keeps average-case O(1) sustainable as the table grows — same amortization principle as dynamic arrays.

**Complexity recap:**

| Operation | Average | Worst |
|---|---|---|
| Insert | O(1) | O(n) |
| Search | O(1) | O(n) |
| Delete | O(1) | O(n) |

**Decision guideline:** Choose a hash table when you need the fastest possible key-based lookup and don't care about ordering. Choose a BST/ordered map instead if you need sorted iteration, range queries, or "next/previous key" operations.

---

*Next chapter: `06_binary_tree_and_bst.md`*
