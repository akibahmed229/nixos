# Chapter 18: Bloom Filter (Overview)

*Study time: ~4-5 hours | Prerequisite: Hash Tables, basic probability | Difficulty: Intermediate-Advanced*

---

## 1. Introduction

**Definition:** A Bloom Filter is a space-efficient **probabilistic** data structure that answers "have I possibly seen this element before?" It can have **false positives** (saying "maybe present" when the element was never actually added) but **never false negatives** (if it says "definitely not present," that's always correct).

**Purpose:** To test set membership using dramatically less memory than a Hash Set, at the cost of occasional false positives — ideal when you need a fast, cheap "probably not there" filter before doing a more expensive definitive check.

**Real-world analogy:** A bouncer with a rough mental list of "troublemakers" who only remembers a blurry impression of faces, not exact identities. If the impression doesn't match anyone on the list, the person is *definitely* let in — no possible mistake there. But if the blurry impression *does* seem to match, the bouncer might occasionally flag an innocent person by mistake (a false positive) — they'd need a proper ID check (a slower, definitive lookup) to be sure. What a Bloom Filter guarantees is that it will *never* mistakenly wave through an actual troublemaker.

**Motivation:** Storing millions or billions of items in a Hash Set to check membership can require enormous memory. Many applications only need a fast *first-pass filter* — "is it worth doing the expensive check at all?" — where occasionally checking a few extra non-members is an acceptable cost, but ever missing an actual member would be unacceptable.

**History:** Invented by Burton Howard Bloom in 1970, originally to reduce the disk-access cost of hyphenation dictionaries; now foundational to databases, networking, and distributed systems.

---

## 2. Why Do We Need It?

**Problem it solves:** Space-efficient approximate set-membership testing, when you can tolerate rare false positives but require zero false negatives.

**Why previous structures are insufficient:**
- **Hash Set:** Exact, no false positives/negatives — but stores every element (or at least its hash) explicitly, costing memory proportional to the number of elements, often dozens of bytes per entry.
- **Sorted Array / BST:** Also exact, but similarly memory-proportional to element count, and slower (O(log n)) besides.

A Bloom Filter breaks the "memory proportional to elements stored" constraint entirely — its size is fixed upfront based on *expected* element count and desired false-positive rate, and stays constant regardless of how "large" the actual elements are (a Bloom Filter storing membership for million-character strings uses exactly the same memory as one storing single characters).

**Trade-offs:**
- You gain massive memory savings — often 10x or more smaller than an equivalent Hash Set — and O(1) (technically O(k), a small constant) insert/query time.
- You pay for it with an irreversible trade: false positives are possible (and their rate is tunable but never zero for a fixed-size filter), and **you cannot remove elements** from a standard Bloom Filter (a variant, the Counting Bloom Filter, adds limited deletion support at extra memory cost).

---

## 3. Internal Working

**Structure:** A bit array of size `m` (all bits initially 0), plus `k` independent hash functions.

**Insert(x):** compute `k` hash values of `x`, each mapped to an index in `[0, m)`, and set **all k** of those bit positions to 1.

```
Bit array (m=10), k=3 hash functions. Insert "cat":
hash1("cat") % 10 = 1
hash2("cat") % 10 = 4
hash3("cat") % 10 = 7

Before: [0,0,0,0,0,0,0,0,0,0]
After:  [0,1,0,0,1,0,0,1,0,0]   ← bits 1, 4, 7 set to 1
```

**Insert "dog"** (different hash values, some may overlap with existing 1-bits):
```
hash1("dog") % 10 = 2
hash2("dog") % 10 = 4   ← COLLIDES with "cat"'s bit 4, already 1
hash3("dog") % 10 = 8

Before: [0,1,0,0,1,0,0,1,0,0]
After:  [0,1,1,0,1,0,0,1,1,0]   ← bits 2 and 8 newly set; bit 4 was already 1
```

**Query("cat"):** compute the same 3 hash positions (1, 4, 7) — check if **all** are 1. Yes → "possibly present" (correctly, since we did insert it).

**Query("bird")** (never inserted): compute its 3 hash positions, say (2, 4, 9). Check: bit 2 = 1 ✓, bit 4 = 1 ✓, bit 9 = **0** ✗ → at least one bit is 0 → "definitely NOT present." Correct — "bird" was never added.

**Query("fox")** (never inserted, but a **false positive** scenario): suppose its 3 hash positions happen to be (1, 2, 8) — purely by coincidence of hashing, **all three already happen to be 1** (from "cat" and "dog"'s combined insertions) → the filter reports "possibly present" even though "fox" was never actually added. This is the false positive — an unavoidable consequence of multiple elements' hash bits overlapping in a finite bit array.

**Why no false negatives are possible:** every bit that was ever set to 1 by an actual insertion *stays* 1 forever (there's no way to "unset" a bit safely, since other elements might share it) — so if an element was truly inserted, all its k bits are guaranteed to still be 1 when queried later. A "definitely not present" answer can only occur when at least one bit is *still* 0, which can only be true if that exact combination of bits was never set — meaning the element (or an unlucky collision) genuinely was never inserted.

---

## 4. Operations

**Insert(x):**
- Compute `k` hash values of `x`, each reduced mod `m` to a bit-array index.
- Set all `k` corresponding bits to 1 (if already 1, no change — idempotent).
- O(k), effectively O(1) for fixed k.

**Query(x) — "MightContain":**
- Compute the same `k` hash values/indices.
- If **any** of the k bits is 0 → return **definitely not present**.
- If **all** k bits are 1 → return **possibly present** (could be a true positive or a false positive).
- O(k), effectively O(1).

**Delete:** **Not supported** in a standard Bloom Filter — unsetting a bit could incorrectly cause a false negative for some *other* element that happens to share that bit. (The Counting Bloom Filter variant replaces each bit with a small counter, allowing safe decrement-based deletion, at proportionally more memory.)

**Tuning m and k:** Given an expected number of elements `n` and a desired false-positive rate `p`, standard formulas give the optimal bit-array size `m ≈ -(n·ln p)/(ln 2)²` and optimal hash count `k ≈ (m/n)·ln 2`. Choosing these well is essential — too few bits or too few/many hash functions all degrade the false-positive rate.

---

## 5. Time & Space Complexity

| Operation | Time Complexity | Space Complexity |
|---|---|---|
| Insert | O(k) ≈ O(1) | — |
| Query | O(k) ≈ O(1) | — |
| Overall storage | — | O(m) bits, independent of element size, and roughly O(n) bits total for a tuned filter (a small constant number of bits per expected element, NOT per byte of the element's actual data) |

**Why these hold:**
- Both operations only ever touch exactly `k` bit positions — a small, fixed constant chosen at design time — regardless of how many elements are already in the filter or how large the target dataset is. This is the fundamental reason Bloom Filters scale so well: cost per operation never grows with `n`.
- The bit array's size `m` is chosen upfront based on *expected* capacity and tolerable false-positive rate — critically, **independent of the size of the elements themselves**. A Bloom Filter of URLs (each potentially very long strings) uses exactly the same memory as one of single integers, since only a fixed-size hash (not the original element) ever gets stored.
- The false-positive rate rises predictably as more elements are inserted beyond the filter's tuned capacity (more bits get set to 1, increasing accidental all-1 collisions) — this is a graceful, well-understood degradation, not a sudden failure.

---

## 6. Advantages

- Extremely space-efficient — often an order of magnitude (or more) smaller than a Hash Set for the same membership-testing task.
- O(1) (technically O(k)) insert and query — among the fastest possible operations.
- Memory usage is independent of element size — testing membership of huge strings/objects costs the same as testing small ones.
- Tunable false-positive rate — you can trade memory for accuracy along a well-understood mathematical curve.

## 7. Disadvantages

- False positives are possible and unavoidable for a fixed-size filter (though the rate is tunable and can be made arbitrarily small at the cost of more memory).
- No deletion support in the standard version (Counting Bloom Filter needed for that, at extra memory cost).
- Cannot enumerate the actual elements stored — it only answers membership queries, nothing else (no traversal, no "give me all elements").
- Choosing `m` and `k` well requires knowing (or estimating) the expected number of elements in advance; a badly undersized filter degrades toward "everything looks present."

---

## 8. Real-World Applications

- **Databases:** Many databases (Cassandra, HBase, Bigtable-style systems) use Bloom Filters to quickly check "might this key exist in this data file?" before doing an expensive disk read — avoiding wasted I/O for keys that definitely aren't present.
- **Networking:** Detecting duplicate packets, or checking membership in large blocklists/allowlists without storing every entry explicitly.
- **Web Browsers:** Google Chrome historically used a Bloom Filter to check URLs against a local list of known-malicious sites before making a slower, more thorough server-side check (avoiding a network round-trip for the vast majority of definitely-safe URLs).
- **Distributed Systems / Caching:** Quickly checking "is this cache key definitely absent?" before querying a slower backing store — a very common cache-miss optimization pattern.
- **Spell Checkers:** An early, memory-efficient way to check "is this word definitely not in the dictionary?" before a more expensive lookup.
- **Bioinformatics:** Efficiently checking membership of massive DNA/genome sequence sets, where memory constraints are severe.
- **Blockchain/Cryptocurrency:** Some lightweight clients use Bloom Filters to privately request "transactions that might be relevant to me" without revealing exactly which addresses they're tracking.

---

## 9. Implementation (C++17)

```cpp
#include <iostream>
#include <vector>
#include <string>
#include <functional>
#include <cmath>

class BloomFilter {
private:
    std::vector<bool> bits;
    size_t m;   // bit array size
    size_t k;   // number of hash functions

    // Generate the i-th hash value by combining a base hash with a salt (double hashing technique) —
    // a standard trick to simulate k independent hash functions from just two real ones.
    size_t hashI(const std::string& item, size_t i) const {
        std::hash<std::string> hasher;
        size_t h1 = hasher(item);
        size_t h2 = std::hash<std::string>{}(item + "_salt");   // a second, differently-seeded hash
        return (h1 + i * h2) % m;
    }

public:
    // n = expected number of elements, p = desired false-positive rate (e.g., 0.01 for 1%)
    BloomFilter(size_t n, double p) {
        m = static_cast<size_t>(std::ceil(-(static_cast<double>(n) * std::log(p)) / (std::log(2) * std::log(2))));
        k = static_cast<size_t>(std::round((static_cast<double>(m) / n) * std::log(2)));
        if (k < 1) k = 1;
        bits.assign(m, false);
    }

    // Insert an element. O(k).
    void insert(const std::string& item) {
        for (size_t i = 0; i < k; ++i) {
            bits[hashI(item, i)] = true;
        }
    }

    // Query membership. O(k). Returns false ONLY if definitely absent; true means "possibly present."
    bool mightContain(const std::string& item) const {
        for (size_t i = 0; i < k; ++i) {
            if (!bits[hashI(item, i)]) {
                return false;   // any 0 bit proves definite absence
            }
        }
        return true;   // all k bits were 1 — possibly present (or a false positive)
    }

    size_t bitArraySize() const { return m; }
    size_t numHashFunctions() const { return k; }
};

// Example usage
int main() {
    // Tuned for ~1000 expected elements, 1% false-positive rate.
    BloomFilter filter(1000, 0.01);
    std::cout << "Bit array size: " << filter.bitArraySize()
              << ", hash functions: " << filter.numHashFunctions() << "\n";

    filter.insert("cat");
    filter.insert("dog");
    filter.insert("elephant");

    std::cout << "Might contain 'cat'? " << filter.mightContain("cat") << "\n";           // 1 (true)
    std::cout << "Might contain 'dog'? " << filter.mightContain("dog") << "\n";           // 1 (true)
    std::cout << "Might contain 'giraffe'? " << filter.mightContain("giraffe") << "\n";   // 0 (false) — almost certainly correct
    std::cout << "Might contain 'zebra'? " << filter.mightContain("zebra") << "\n";       // 0 (false), OR occasionally 1 (a false positive)

    return 0;
}
```

---

## 10. Code Walkthrough

- **`hashI` via double hashing:** Rather than writing `k` genuinely independent hash functions from scratch, the standard practical trick combines just two base hashes (`h1`, `h2`) as `h1 + i*h2` for `i = 0..k-1` — this is provably "good enough" to simulate k independent hash functions for Bloom Filter purposes, and is far simpler than maintaining k separate hash implementations.
- **Constructor's `m` and `k` formulas:** These directly implement the standard tuning formulas from section 4 — given the expected element count `n` and desired false-positive rate `p`, they compute the bit-array size and hash-function count that minimize memory while hitting the target false-positive rate. Getting this tuning right upfront is the single most important design decision when using a Bloom Filter.
- **`insert`:** Simply sets all `k` computed bit positions to `true` — note there's no "check if already set" logic needed, since setting an already-1 bit to 1 again is a harmless no-op (this idempotency is part of why insert is safe to call redundantly).
- **`mightContain`:** The **short-circuit `return false`** the moment any bit is found to be 0 is the crux of the whole "no false negatives" guarantee — a single 0 bit is airtight proof of absence, so there's no need to check the remaining bits once one is found unset.

**Common mistakes to watch for here:**
- Using genuinely correlated (non-independent-enough) hash functions, which inflates the real-world false-positive rate above the theoretical tuned value.
- Under-provisioning `m` for the actual number of elements inserted (inserting far more than the `n` used to tune the filter) — this silently degrades the false-positive rate well beyond what was intended.
- Attempting to delete an element by unsetting its bits directly — this can introduce false negatives for any other element sharing those bits, breaking the structure's core guarantee.

---

## 11. Dry Run

**Setup:** m=10 bits, k=3 hash functions (matching section 3's example). **Insert "cat" (bits 1,4,7), insert "dog" (bits 2,4,8).**

| Step | Bit array (index 0-9) |
|---|---|
| init | 0000000000 |
| insert "cat" (bits 1,4,7) | 0100100100 |
| insert "dog" (bits 2,4,8) | 0110100110 |

**Query "cat"** (bits 1,4,7): check bit1=1 ✓, bit4=1 ✓, bit7=1 ✓ → all set → **"possibly present"** (correct — a true positive, since "cat" really was inserted).

**Query "bird"** (suppose its bits are 3,5,9): check bit3=0 → **immediately return "definitely NOT present"** (correct — "bird" was never inserted; the very first 0 bit found is proof enough, no need to check bits 5 and 9 at all).

**Query "fox"** (suppose, by unlucky coincidence, its bits are exactly 1,2,8): check bit1=1 ✓, bit2=1 ✓, bit8=1 ✓ → all set → **"possibly present"** — but "fox" was never actually inserted! This is a **false positive**, arising purely because "fox"'s three hash positions happened to exactly match a combination of bits already set by "cat" and "dog"'s separate insertions.

---

## 12. Interview Questions

**Conceptual:**
1. Why can a Bloom Filter never produce a false negative, but can produce false positives?
2. Walk through the formulas for choosing `m` (bit array size) and `k` (number of hash functions) given expected element count and desired false-positive rate.
3. Why can't you delete an element from a standard Bloom Filter? How does a Counting Bloom Filter solve this?
4. Compare a Bloom Filter to a Hash Set for membership testing — what's the fundamental trade-off?
5. What happens to the false-positive rate as you insert more elements than the filter was tuned for?

**Coding:**
1. Implement a Bloom Filter with configurable size and hash count.
2. Design a Counting Bloom Filter supporting deletion.
3. Design a system to check if a URL is potentially malicious using a Bloom Filter as a first-pass filter (system-design style question).
4. Given a stream of items, estimate how many *distinct* items have been seen using a Bloom-Filter-adjacent technique (related to but distinct from a plain Bloom Filter — tests awareness of the broader "probabilistic data structures" family, e.g., HyperLogLog).

**Follow-ups / interviewer traps:**
- "Your Bloom Filter's false-positive rate is too high in production — what are your options?" (expects: increase `m`, retune `k`, or create a fresh larger filter and migrate — cannot simply "fix" an existing undersized filter in place)
- "Can two Bloom Filters be merged (e.g., for a distributed system)?" (yes, if they're the same size `m` and use the same hash functions — a bitwise OR of the two bit arrays correctly represents the union of both sets, with a combined false-positive rate)
- "Why not just use a smaller Hash Set instead?" (tests understanding that a Hash Set's minimum memory is bounded by needing to store enough information to be exact — a Bloom Filter deliberately discounts a small amount of exactness for a much better memory ratio)

---

## 13. Practice Problems

Bloom Filters are primarily a systems-design/probabilistic-data-structures topic rather than a classic LeetCode-style coding target, but related practice includes:
- Implement a Bloom Filter from scratch with tunable parameters (the exercise in section 9).
- Design a URL shortener / web crawler deduplication system using a Bloom Filter as a first-pass check (system design).
- GeeksforGeeks "Bloom Filters" practice/theory set.
- Explore related probabilistic structures for contrast: HyperLogLog (cardinality estimation), Count-Min Sketch (frequency estimation) — same underlying philosophy of trading a small, tunable amount of accuracy for large memory savings.

---

## 14. Common Mistakes

- **Assuming zero false positives are possible** — they are an inherent, unavoidable property of any fixed-size Bloom Filter; only the *rate* is tunable, never eliminated entirely (barring an infinitely large filter).
- **Attempting in-place deletion** by unsetting bits — breaks the no-false-negative guarantee for other elements sharing those bits.
- **Under-provisioning capacity** — inserting far more elements than the filter was tuned for silently and severely degrades accuracy.
- **Using poorly-distributed or correlated hash functions** — undermines the mathematical guarantees the tuning formulas rely on.
- **Treating a Bloom Filter as a complete replacement for exact storage** — it should typically be paired with a slower, authoritative store for confirming actual positives, not used as the sole source of truth.

---

## 15. Summary

**Key takeaways:**
- A Bloom Filter trades a small, tunable false-positive rate for massive memory savings over an exact Hash Set — and crucially, it **never** produces false negatives.
- Insert and query are both O(k), a small fixed constant, regardless of dataset size or element size.
- No deletion support in the standard version; no ability to enumerate stored elements — it answers exactly one question ("might this be present?") extremely efficiently, and nothing else.
- Widely used as a fast "is it even worth checking further?" pre-filter in databases, networking, and browsers.

**Complexity recap:**

| Operation | Time | Space |
|---|---|---|
| Insert | O(k) | — |
| Query | O(k) | O(m) bits total, tuned via n and desired false-positive rate p |

**Decision guideline:** Reach for a Bloom Filter when you need extremely memory-efficient approximate membership testing, can tolerate a small, tunable false-positive rate, and never need exact answers or deletion. Pair it with a slower, authoritative structure to resolve "possibly present" results definitively when needed. If you need exact answers or deletion support, use a Hash Set instead.

---

*Next chapter: `19_lru_cache.md` — the capstone project, combining Hash Map + Doubly Linked List.*
