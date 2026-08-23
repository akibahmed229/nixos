# Chapter 6: Non-Comparison Sorts (Counting, Radix, Bucket)

*Study time: ~5-6 hours | Prerequisite: Arrays, basic understanding of comparison sorts (Ch. 2-5) | Difficulty: Intermediate*

---

## 1. Introduction

**Definition:** Counting Sort, Radix Sort, and Bucket Sort are sorting algorithms that **never compare two elements to each other** — instead, they exploit structural knowledge about the data (small integer range, fixed number of digits, known distribution) to place elements directly into their correct positions.

**Purpose:** To sort in **O(n + k)** time (where k relates to the data's range or digit count) — genuinely faster than the **O(n log n) lower bound** that applies to *any* comparison-based sort, by sidestepping comparisons entirely.

**Problem solved:** Sorting integers (or integer-like keys) drawn from a bounded or structured range, where that structure can be exploited for better-than-comparison-sort performance.

---

## 2. Intuition

**Comparison sorts (Chapters 2-5) are provably bounded below by Ω(n log n)** — this isn't a limitation of any particular algorithm, it's a mathematical fact about *any* algorithm that only learns information by comparing pairs of elements (there are n! possible orderings, and each comparison yields at most 1 bit of information, so you need at least log₂(n!) ≈ n log n comparisons in the worst case — the same information-theoretic argument used for Binary Search's optimality in Chapter 1).

**Non-comparison sorts escape this bound by not comparing at all.** Instead:
- **Counting Sort:** if you know values range from 0 to k, count how many times each value occurs, then directly compute where each value belongs in the output — like sorting exam scores (0-100) by literally counting how many students got each score, then listing them in order.
- **Radix Sort:** sort numbers digit by digit (least significant to most significant), using a stable sort (typically Counting Sort) at each digit position — like sorting a stack of punch cards column by column, a technique literally used by mechanical card-sorting machines in the pre-computer era.
- **Bucket Sort:** distribute elements into several "buckets" based on value ranges, sort each bucket individually (with any algorithm, often insertion sort since buckets are small), then concatenate — like presorting mail by zip code region before finer sorting within each region.

---

## 3. Step-by-Step Working

### (a) Counting Sort — array `[4, 2, 2, 8, 3, 3, 1]`, range 0-8

```
STEP 1: Count occurrences of each value (0 to 8):
Value:  0  1  2  3  4  5  6  7  8
Count:  0  1  2  2  1  0  0  0  1

STEP 2: Convert counts to PREFIX sums (cumulative count) — this gives the
        position where each value's LAST occurrence should go in the output:
Value:  0  1  2  3  4  5  6  7  8
Cumul:  0  1  3  5  6  6  6  6  7

STEP 3: Build the output by placing each input element at its cumulative-count
        position, then DECREMENTING that count (to place duplicates correctly,
        and to preserve stability by processing the input right-to-left):

Process input right-to-left: 1, 3, 3, 8, 2, 2, 4
  '1' → cumul[1]=1 → place at output index 0, decrement cumul[1] to 0
  '3' → cumul[3]=5 → place at output index 4, decrement cumul[3] to 4
  '3' → cumul[3]=4 → place at output index 3, decrement cumul[3] to 3
  '8' → cumul[8]=7 → place at output index 6, decrement cumul[8] to 6
  '2' → cumul[2]=3 → place at output index 2, decrement cumul[2] to 2
  '2' → cumul[2]=2 → place at output index 1, decrement cumul[2] to 1
  '4' → cumul[4]=6 → place at output index 5, decrement cumul[4] to 5

Output: [1, 2, 2, 3, 3, 4, 8]  ✓
```

### (b) Radix Sort — array `[170, 45, 75, 90, 802, 24, 2, 66]`

```
Sort by ONES digit first (using Counting Sort, stable):
[170, 90, 802, 2, 24, 45, 75, 66]
 (0)  (0)  (2)  (2) (4)  (5)  (5)  (6)

Sort by TENS digit next:
[802, 2, 24, 45, 66, 170, 75, 90]
 (0)  (0) (2) (4) (6)  (7)  (7)  (9)

Sort by HUNDREDS digit last:
[2, 24, 45, 66, 75, 90, 170, 802]
(0) (0) (0) (0) (0) (0)  (1)  (8)

Final: [2, 24, 45, 66, 75, 90, 170, 802]  ✓ fully sorted after 3 digit-passes
```

**Why sorting least-significant-digit first works:** because each digit pass uses a **stable** sort, elements that tie on the current digit retain their relative order from the *previous* pass — which was already correctly sorted on less significant digits. This stacking of stable sorts, digit by digit from least to most significant, is what makes the final result fully correct.

### (c) Bucket Sort — array of floats `[0.78, 0.17, 0.39, 0.26, 0.72, 0.94, 0.21, 0.12]` (uniformly distributed in [0,1))

```
Create 8 buckets, each covering a 1/8 range: [0,.125), [.125,.25), ... [.875,1)

Distribute:
Bucket 0 [0,.125):    0.12
Bucket 1 [.125,.25):  0.17, 0.21
Bucket 2 [.25,.375):  0.26
Bucket 3 [.375,.5):   0.39
Bucket 4 [.5,.625):   (empty)
Bucket 5 [.625,.75):  0.72
Bucket 6 [.75,.875):  0.78
Bucket 7 [.875,1):    0.94

Sort each bucket individually (insertion sort — buckets are small):
Bucket 1: [0.17, 0.21] (already sorted after insertion sort)

Concatenate all buckets in order:
[0.12, 0.17, 0.21, 0.26, 0.39, 0.72, 0.78, 0.94]  ✓
```

---

## 4. Complexity Analysis

**Counting Sort: O(n + k)** where k is the value range. Building the count array is O(k); the cumulative sum pass is O(k); placing every input element is O(n). Total: O(n + k) — genuinely linear when k = O(n), but **degrades badly when k >> n** (e.g., sorting 10 values that range from 0 to 10,000,000 wastes enormous time/space on mostly-empty counting buckets).

**Radix Sort: O(d · (n + k))** where d is the number of digits and k is the base (typically k=10 for base-10 digits, or k=256 for byte-wise radix on binary data). Each of the d digit-passes runs a full O(n+k) Counting Sort. For fixed-width integers (e.g., 32-bit integers, d is bounded by a small constant like 10 decimal digits or 4 bytes), this is effectively **O(n)** — linear — which is asymptotically *better* than any comparison sort's O(n log n) lower bound, precisely because Radix Sort never compares elements directly.

**Bucket Sort: O(n + k) average case, assuming roughly uniform input distribution across k buckets** — each bucket ends up with about n/k elements, and sorting each small bucket (e.g., with insertion sort) costs O((n/k)²) per bucket, times k buckets, giving O(n²/k) total for the bucket-sorting step; choosing k ≈ n makes this O(n) average. **Worst case O(n²)** if the distribution is highly skewed (e.g., all elements land in one bucket, degenerating to sorting the whole array with insertion sort).

**Why these can beat the O(n log n) comparison-sort lower bound:** that lower bound applies *specifically* to algorithms that only extract information via pairwise comparisons. Counting Sort, Radix Sort, and (average-case) Bucket Sort extract information a fundamentally different way — direct indexing/counting based on value — which isn't subject to the same information-theoretic constraint at all.

---

## 5. Advantages

- **Genuinely faster than O(n log n)** when their structural assumptions hold (bounded range for Counting Sort, fixed digit-width for Radix Sort, roughly uniform distribution for Bucket Sort).
- **Counting Sort and Radix Sort (with a stable underlying sort) are stable** — useful for multi-key sorting (e.g., sort by one field, then stably re-sort by another).
- Radix Sort scales to arbitrarily large numbers (or fixed-width strings) with cost proportional to digit/character count, not value magnitude.

## 6. Limitations

- **Only applicable to specific data types** — integers, or data that can be mapped to integers/digits (not general comparable objects with an arbitrary `<` operator).
- **Counting Sort's O(k) space/time can be disastrous** if the value range is large relative to n (e.g., sorting 100 numbers where one happens to be a billion wastes a billion-sized count array).
- **Bucket Sort's average-case guarantee assumes roughly uniform distribution** — skewed real-world data (e.g., many exact duplicates, or a heavily clustered distribution) can degrade it toward O(n²).
- Radix Sort's constant factor (d passes, each a full linear scan) can make it slower in practice than a well-tuned Quick Sort for moderate n, even when asymptotically comparable or better.

---

## 7. Real-World Applications

- **Counting Sort:** grading systems (bounded score ranges), histogram-based image processing (pixel intensity values are a small bounded range, 0-255), radix sort's own internal digit-counting step.
- **Radix Sort:** sorting large datasets of fixed-width keys — IP addresses, phone numbers, employee/student ID numbers, fixed-length strings. Historically used literally in mechanical punch-card sorting machines (the origin of the "radix" — meaning "base" or "root" — naming).
- **Bucket Sort:** sorting data known to be roughly uniformly distributed — hash-table-adjacent bucketing schemes, certain graphics/rendering pipeline sorting tasks (e.g., sorting objects by a continuous depth/coordinate value).
- **Databases:** some specialized bulk-loading/bucketing strategies for building indexes over known-range key sets.
- **Networking:** sorting/grouping packets by fixed-width header fields (e.g., port numbers) can use radix-sort-like techniques.
- **Compilers:** bucket-based symbol categorization in some optimization passes.

---

## 8. C++ Implementation

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

// Counting Sort. O(n + k), stable. Assumes non-negative integers with known max value.
std::vector<int> countingSort(const std::vector<int>& arr) {
    if (arr.empty()) return arr;
    int maxVal = *std::max_element(arr.begin(), arr.end());

    std::vector<int> count(maxVal + 1, 0);
    for (int x : arr) count[x]++;                          // STEP 1: count occurrences

    for (int i = 1; i <= maxVal; ++i) count[i] += count[i - 1];   // STEP 2: cumulative sum

    std::vector<int> output(arr.size());
    for (int i = static_cast<int>(arr.size()) - 1; i >= 0; --i) {  // STEP 3: place right-to-left for stability
        output[--count[arr[i]]] = arr[i];
    }
    return output;
}

// One digit-pass of Counting Sort, used internally by Radix Sort. Sorts by the
// digit at the given place value (1, 10, 100, ...). Stable.
void countingSortByDigit(std::vector<int>& arr, int placeValue) {
    int n = static_cast<int>(arr.size());
    std::vector<int> output(n);
    std::vector<int> count(10, 0);   // digits are always 0-9

    for (int x : arr) count[(x / placeValue) % 10]++;
    for (int i = 1; i < 10; ++i) count[i] += count[i - 1];

    for (int i = n - 1; i >= 0; --i) {
        int digit = (arr[i] / placeValue) % 10;
        output[--count[digit]] = arr[i];
    }
    arr = output;
}

// Radix Sort. O(d * (n + k)), effectively O(n) for fixed-width integers.
void radixSort(std::vector<int>& arr) {
    if (arr.empty()) return;
    int maxVal = *std::max_element(arr.begin(), arr.end());

    for (int placeValue = 1; maxVal / placeValue > 0; placeValue *= 10) {
        countingSortByDigit(arr, placeValue);   // one stable pass per digit, least significant first
    }
}

// Bucket Sort. O(n + k) average case for roughly uniform data in [0, 1).
std::vector<double> bucketSort(std::vector<double>& arr) {
    int n = static_cast<int>(arr.size());
    std::vector<std::vector<double>> buckets(n);

    for (double x : arr) {
        int bucketIndex = static_cast<int>(x * n);   // map [0,1) value to a bucket index
        if (bucketIndex == n) bucketIndex = n - 1;     // guard against x exactly == 1.0
        buckets[bucketIndex].push_back(x);
    }

    for (auto& bucket : buckets) {
        std::sort(bucket.begin(), bucket.end());   // sort each (small) bucket individually
    }

    std::vector<double> result;
    result.reserve(n);
    for (auto& bucket : buckets) {
        for (double x : bucket) result.push_back(x);   // concatenate buckets in order
    }
    return result;
}

// Example usage
int main() {
    std::vector<int> a = {4, 2, 2, 8, 3, 3, 1};
    auto sortedA = countingSort(a);
    std::cout << "Counting Sort: ";
    for (int x : sortedA) std::cout << x << " ";
    std::cout << "\n";   // 1 2 2 3 3 4 8

    std::vector<int> b = {170, 45, 75, 90, 802, 24, 2, 66};
    radixSort(b);
    std::cout << "Radix Sort: ";
    for (int x : b) std::cout << x << " ";
    std::cout << "\n";   // 2 24 45 66 75 90 170 802

    std::vector<double> c = {0.78, 0.17, 0.39, 0.26, 0.72, 0.94, 0.21, 0.12};
    auto sortedC = bucketSort(c);
    std::cout << "Bucket Sort: ";
    for (double x : sortedC) std::cout << x << " ";
    std::cout << "\n";   // 0.12 0.17 0.21 0.26 0.39 0.72 0.78 0.94

    return 0;
}
```

---

## 9. Code Walkthrough

- **`countingSort`'s cumulative-sum step:** After this step, `count[v]` no longer means "how many times v occurs" — it now means "how many elements are ≤ v," which is exactly the final output index (one past the last occurrence) that value v's elements should occupy.
- **Processing the input right-to-left in the placement step:** This specific detail is what makes Counting Sort **stable** — processing left-to-right would still produce a *correctly sorted* output, but equal elements would end up in *reversed* relative order; going right-to-left preserves their original relative order instead.
- **`countingSortByDigit`'s `(x / placeValue) % 10`:** This extracts a single decimal digit at the given place value — e.g., for `placeValue=100`, `(802/100)%10 = 8`, correctly extracting the hundreds digit. This function is literally the same Counting Sort algorithm, just keyed on one digit instead of the whole value.
- **`radixSort`'s loop condition `maxVal / placeValue > 0`:** This naturally stops once `placeValue` exceeds the largest number's digit count — no need to precompute the exact number of digits separately.
- **`bucketSort`'s `x * n` bucket mapping:** For data uniformly distributed in [0,1), multiplying by `n` and truncating maps each value to one of `n` buckets roughly evenly — this is the specific assumption that gives Bucket Sort its average-case O(n) behavior; a non-uniform distribution would need a different (often more complex) mapping function to stay balanced.

**Common mistakes to watch for here:**
- Processing Counting Sort's placement step left-to-right instead of right-to-left, silently breaking stability.
- Forgetting to reset/rebuild the count array between Radix Sort's digit passes (each `countingSortByDigit` call needs its own fresh count array, which the implementation above handles correctly by declaring it locally each call).
- Using Bucket Sort on non-uniformly-distributed data without adjusting the bucket-mapping strategy, silently degrading toward O(n²).
- Using Counting Sort on data with a huge value range relative to n, wasting enormous time/space unnecessarily.

---

## 10. Dry Run

**Radix Sort on `[170, 45, 75, 90, 802, 24, 2, 66]`, ones-digit pass:**

| Value | Ones digit | count[] before cumsum | count[] after cumsum |
|---|---|---|---|
| 170 | 0 | count[0]=2 (170,90) | — |
| 45 | 5 | count[5]=2 (45,75) | — |
| 75 | 5 | (see above) | — |
| 90 | 0 | (see above) | — |
| 802 | 2 | count[2]=1 | — |
| 24 | 4 | count[4]=1 | — |
| 2 | 2 | count[2]=1 (tied with 802's digit 2 — but 2's actual value differs, only digit matters here) | — |
| 66 | 6 | count[6]=1 | — |

Full counting-and-placement process (right-to-left over input, as in section 9) produces `[170, 90, 802, 2, 24, 45, 75, 66]` — matching section 3's trace exactly. ✓

---

## 11. Complexity Table

| Algorithm | Best | Average | Worst | Space | Stable? |
|---|---|---|---|---|---|
| Counting Sort | O(n+k) | O(n+k) | O(n+k) | O(n+k) | Yes |
| Radix Sort | O(d(n+k)) | O(d(n+k)) | O(d(n+k)) | O(n+k) | Yes |
| Bucket Sort | O(n+k) | O(n+k) | O(n²) | O(n+k) | Depends on per-bucket sort choice |

**Every entry explained:** Counting Sort and Radix Sort have **no data-dependent variation** in their complexity — every case is identical, because the algorithm's work is entirely determined by n, k (and d), never by the actual arrangement of values (unlike comparison sorts, which can have best/worst-case gaps based on how "close to sorted" the input already is). Bucket Sort's worst case O(n²) arises specifically when the distribution assumption fails and all elements cluster into one bucket, degenerating to sorting that entire cluster with whatever algorithm sorts each bucket (commonly insertion sort, hence O(n²)).

---

## 12. Common Mistakes

- **Using Counting Sort when the value range k is much larger than n** — wastes enormous time and space; always check this ratio before choosing Counting Sort.
- **Breaking stability** by processing Counting Sort's placement step in the wrong order.
- **Applying Bucket Sort to skewed/clustered data** without adjusting the bucketing strategy, silently degrading toward O(n²).
- **Forgetting Radix Sort requires non-negative integers** in its basic form — negative numbers need a modified approach (e.g., offsetting all values, or handling the sign bit separately).
- **Assuming these algorithms work for general comparable objects** — they fundamentally require integer (or integer-mappable) keys, unlike comparison sorts which work for anything with a defined `<` operator.

---

## 13. Interview Questions

**Conceptual:**
1. Why can Counting Sort and Radix Sort beat the O(n log n) comparison-sort lower bound? What does that lower bound actually apply to?
2. Explain why Radix Sort must process digits from least-significant to most-significant, and why the per-digit sort must be stable.
3. When would Counting Sort be a poor choice despite the data being integers?
4. What assumption does Bucket Sort's average-case analysis depend on, and what happens when that assumption fails?
5. Compare Radix Sort's O(d(n+k)) to a comparison sort's O(n log n) — under what conditions is Radix Sort actually faster in practice?

**Coding:**
1. Implement Counting Sort, Radix Sort, and Bucket Sort from scratch.
2. Sort an array of strings by length using Counting Sort (bounded length range).
3. Sort negative and positive integers together using Radix Sort (requires handling the sign).
4. Given an array of ages (0-120), sort it in O(n) using Counting Sort.
5. Maximum Gap (LeetCode 164) — classic Bucket-Sort-adjacent application (find max gap between sorted elements in O(n)).

**Follow-ups / interviewer traps:**
- "Your data has values up to 10^9 but only 100 elements — is Counting Sort still a good choice?" (no — k >> n makes it far worse than a comparison sort here; tests recognizing the applicability boundary)
- "Can Radix Sort sort strings, not just integers?" (yes — treat characters as digits in a larger base, e.g., base 256 for bytes; tests generalizing beyond the numeric example)
- "How would you sort negative numbers with Radix Sort?" (tests awareness that the basic algorithm assumes non-negative integers, and a real fix — e.g., offsetting or separating negative/positive partitions — is needed)

---

## 14. Practice Problems

**Easy**
- Sort an Array (LeetCode 912) — try a non-comparison approach when the value range is known/bounded
- Height Checker (LeetCode 1051) — natural Counting Sort application

**Medium**
- Sort Colors (LeetCode 75) — a 3-value special case, effectively a tiny Counting Sort
- Relative Sort Array (LeetCode 1122) — Counting-Sort-based
- Maximum Gap (LeetCode 164) — Bucket Sort application

**Hard**
- Sort an array of large fixed-width numbers efficiently using Radix Sort as a benchmark against `std::sort`

Also recommended: benchmark Counting/Radix/Bucket Sort against Quick Sort/std::sort on data specifically suited to each (small-range integers, fixed-width numbers, uniformly distributed floats) — observe the real speedup non-comparison sorts provide under their ideal conditions.

---

## 15. Summary

**Key takeaways:**
- Non-comparison sorts escape the O(n log n) comparison-sort lower bound by extracting information a fundamentally different way — direct counting/indexing rather than pairwise comparison.
- Counting Sort needs a small value range (k = O(n)); Radix Sort extends this to larger values by sorting digit-by-digit; Bucket Sort needs (roughly) uniformly distributed data.
- All three can be made stable, which matters for their common role as building blocks (Radix Sort literally *is* repeated stable Counting Sort).
- These are specialized tools — powerful when their structural assumptions hold, but inapplicable or actively worse than comparison sorts when they don't.

**Complexity recap:**

| | Time | Space | Requires |
|---|---|---|---|
| Counting Sort | O(n+k) | O(n+k) | Small integer range |
| Radix Sort | O(d(n+k)) | O(n+k) | Fixed-width integers/strings |
| Bucket Sort | O(n+k) avg | O(n+k) | Roughly uniform distribution |

**Decision guide:** Reach for Counting Sort when sorting integers with a small, known range. Reach for Radix Sort when sorting larger fixed-width integers or strings where digit-by-digit processing is natural. Reach for Bucket Sort when data is known (or can be verified) to be roughly uniformly distributed over a range. When none of these structural assumptions clearly hold, default back to a comparison sort (Quick Sort/Merge Sort/your language's built-in sort) — forcing a non-comparison sort onto unsuitable data can easily perform *worse* than the comparison-sort alternative.

---

*Next chapter: `07_two_pointer.md`*
