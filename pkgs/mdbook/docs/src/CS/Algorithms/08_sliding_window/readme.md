# Chapter 8: Sliding Window

*Study time: ~4-5 hours | Prerequisite: Two Pointer (Ch. 7), Arrays | Difficulty: Beginner-Intermediate*

---

## 1. Introduction

**Definition:** The Sliding Window technique maintains a contiguous "window" (subarray or substring) defined by two pointers, and slides that window across the data — either at a **fixed size** or growing/shrinking **variably** based on a condition — updating an aggregate (sum, count, set of characters, etc.) incrementally rather than recomputing it from scratch at every position.

**Purpose:** To avoid the O(n·k) (or O(n²)) cost of recomputing a window's aggregate from scratch at every position, reducing it to O(n) by **incrementally updating** the aggregate as the window slides — add what enters, remove what leaves.

**Problem solved:** "Find the best/valid contiguous subarray/substring satisfying some condition" — maximum sum of size k, smallest window containing all required characters, longest substring without repeats, and dozens of variations on this theme.

---

## 2. Intuition

Imagine looking through a physical window at a moving train, always seeing exactly 5 cars at a time. As the train moves, you don't need to recount all 5 visible cars from scratch every second — you just note "one car left view on the left, one new car entered view on the right," and update your running total accordingly (subtract the car that left, add the car that entered). This is the **fixed window** idea exactly: maintain a running aggregate, and update it in O(1) per slide instead of recomputing in O(k) every time.

**Variable window** extends this: instead of a fixed 5-car view, you keep expanding your view (moving the right edge forward) until you've seen "enough" (satisfied some condition), then start contracting from the left to find the *smallest* view that still satisfies it, giving you the tightest possible window — this two-phase "expand until valid, then contract while still valid" dance is the core mechanic behind variable-window problems like "smallest window containing all required characters."

---

## 3. Step-by-Step Working

### (a) Fixed Window — max sum of any 3 consecutive elements in `[2, 1, 5, 1, 3, 2]`

```
Initial window [0..2]: 2+1+5 = 8. Best so far = 8.

Slide window right by 1 (window [1..3]):
  Remove leaving element (2, index 0): 8 - 2 = 6
  Add entering element (1, index 3): 6 + 1 = 7
  Window sum = 7. Best so far = 8 (unchanged, 7 < 8).

Slide to [2..4]:
  Remove arr[1]=1: 7-1=6
  Add arr[4]=3: 6+3=9
  Window sum = 9. Best so far = 9 (updated!).

Slide to [3..5]:
  Remove arr[2]=5: 9-5=4
  Add arr[5]=2: 4+2=6
  Window sum = 6. Best so far = 9 (unchanged).

Final answer: 9 (from window [2,4] = [5,1,3])
```

Each slide does exactly **2 operations** (one removal, one addition) — O(1) per slide, O(n) total — versus recomputing each window's sum from scratch, which would cost O(k) per window and O(n·k) overall.

### (b) Variable Window — smallest subarray with sum ≥ 7 in `[2, 3, 1, 2, 4, 3]`

```
left=0, right=0, windowSum=0, best=infinity

Expand right, adding elements, until windowSum >= 7:
right=0: windowSum=2
right=1: windowSum=5
right=2: windowSum=6
right=3: windowSum=8 >= 7! → window [0..3], length 4. best=4.
  Now CONTRACT from left while still >= 7:
  Remove arr[0]=2: windowSum=6 < 7 → stop contracting, left stays at 0... 

  wait — remove arr[left=0]=2 first, THEN check: windowSum=6, which is < 7, so we
  should NOT have contracted past the point where it was still valid. Let's redo
  correctly: before removing, window [0..3]=8>=7 is valid, length 4, best=4.
  Try contracting: tentatively remove arr[0]=2 → windowSum=6 < 7 → window [1..3]
  is now invalid, so we do NOT accept this contraction; left stays at 0 for now,
  and we resume EXPANDING right instead.

right=4: windowSum = 6+4 = 10 >= 7 (window [1..4], after the failed contraction
  attempt already removed arr[0]) → length 4. Try contracting again:
  Remove arr[1]=3: windowSum=7 >= 7! → window [2..4], length 3. best=3. Contract again:
  Remove arr[2]=1: windowSum=6 < 7 → stop, window [3..4] invalid.

right=5: windowSum = 6+3 = 9 >= 7 (window [3..5]) → length 3 (tied, best stays 3).
  Try contracting: remove arr[3]=2: windowSum=7 >= 7! → window [4..5], length 2. best=2.
  Contract again: remove arr[4]=4: windowSum=3 < 7 → stop.

End of array. Final answer: smallest window length = 2 (window [4,5] = [4,3], sum=7)
```

**The key invariant:** every time the window becomes valid (sum ≥ 7), we greedily shrink it from the left as much as possible while it remains valid — this greedy shrinking is always safe because a smaller valid window is always at least as good as a larger one for a "smallest window" objective, and we never need to reconsider a left boundary we've already advanced past.

---

## 4. Complexity Analysis

**Time: O(n) for both fixed and variable window**, despite variable window's seemingly more complex "expand then contract" dance.

**Why fixed window is O(n):** the window slides exactly (n - k + 1) times, each slide doing O(1) work (one removal, one addition) — total O(n).

**Why variable window is still O(n), not O(n²), despite the nested-looking expand/contract logic:** this is the subtle but crucial insight — **the `right` pointer advances at most n times total, and the `left` pointer *also* advances at most n times total, across the ENTIRE algorithm's execution**, not per outer iteration. Even though the code has what looks like a loop inside a loop, neither pointer ever moves backward or resets, so the combined total movement of both pointers is bounded by 2n, not n². This is the exact same "each pointer's total movement is bounded by n" argument used for Two Pointer in the previous chapter — Sliding Window is really Two Pointer applied to a contiguous-range problem.

**Space: O(1) extra** for numeric aggregates (sum, count); **O(k) or O(alphabet size)** for problems needing a frequency map/set of the window's contents (e.g., "longest substring with at most k distinct characters" needs a hash map tracking character counts within the window).

---

## 5. Advantages

- Converts what looks like an O(n·k) or O(n²) problem into genuine O(n) by incrementally maintaining an aggregate instead of recomputing it.
- The "expand/contract" variable-window pattern handles a surprisingly large class of "smallest/longest valid subarray/substring" problems with one consistent mental template.
- Often combines naturally with a hash map (for character/element frequency tracking within the window) without sacrificing the overall O(n) bound.

## 6. Limitations

- Only applies to **contiguous** subarrays/substrings — if a problem allows non-contiguous selection, sliding window doesn't directly apply (that's typically a Dynamic Programming or subset-selection problem instead).
- The aggregate being tracked must be **efficiently updatable** as elements enter/leave the window (O(1) or close to it) — if maintaining the aggregate itself requires expensive recomputation on every change, the technique loses its advantage.
- Variable-window problems require correctly identifying the monotonic relationship between window size and validity (e.g., "growing the window can only help/hurt in one direction") — misidentifying this can lead to incorrect contraction logic.

---

## 7. Real-World Applications

- **Networking:** TCP's sliding window protocol for flow control — tracking a moving range of "sent but not yet acknowledged" packets, conceptually identical to the fixed-window technique.
- **Data Streaming/Analytics:** computing running averages, moving maximums, or other rolling statistics over a live data stream (stock price moving averages, sensor data smoothing).
- **Text Processing:** substring search problems, longest-substring-without-repeats style text analysis (e.g., detecting the longest unique-character run in a log file).
- **Video/Audio Processing:** frame-based analysis using a sliding temporal window (e.g., detecting motion across a fixed number of consecutive video frames).
- **Load Balancing/Rate Limiting:** "no more than N requests in any rolling T-second window" is a direct sliding-window application in API rate limiters.
- **Bioinformatics:** scanning DNA sequences with a fixed-size window to detect patterns or compute local statistics (GC content, etc.).

---

## 8. C++ Implementation

```cpp
#include <iostream>
#include <vector>
#include <unordered_map>
#include <climits>

// Fixed Window: maximum sum of any k consecutive elements. O(n).
int maxSumFixedWindow(const std::vector<int>& arr, int k) {
    int n = static_cast<int>(arr.size());
    if (n < k) return -1;   // not enough elements for a window of size k

    int windowSum = 0;
    for (int i = 0; i < k; ++i) windowSum += arr[i];   // build the FIRST window directly

    int best = windowSum;
    for (int i = k; i < n; ++i) {
        windowSum += arr[i] - arr[i - k];   // add entering element, remove leaving element — O(1)
        best = std::max(best, windowSum);
    }
    return best;
}

// Variable Window: smallest subarray with sum >= target. O(n).
int smallestSubarrayWithSum(const std::vector<int>& arr, int target) {
    int n = static_cast<int>(arr.size());
    int left = 0, windowSum = 0, best = INT_MAX;

    for (int right = 0; right < n; ++right) {
        windowSum += arr[right];   // EXPAND: always add the new right-boundary element

        while (windowSum >= target) {   // CONTRACT: shrink from the left while still valid
            best = std::min(best, right - left + 1);
            windowSum -= arr[left];
            left++;
        }
    }
    return best == INT_MAX ? 0 : best;   // 0 (or -1, by convention) if no valid window exists
}

// Variable Window with a hash map: longest substring with at most k distinct characters. O(n).
int longestSubstringKDistinct(const std::string& s, int k) {
    std::unordered_map<char, int> freq;
    int left = 0, best = 0;

    for (int right = 0; right < static_cast<int>(s.size()); ++right) {
        freq[s[right]]++;   // EXPAND: include the new character

        while (static_cast<int>(freq.size()) > k) {   // CONTRACT: too many distinct chars, shrink
            freq[s[left]]--;
            if (freq[s[left]] == 0) freq.erase(s[left]);   // remove entirely once count hits 0
            left++;
        }
        best = std::max(best, right - left + 1);
    }
    return best;
}

// Example usage
int main() {
    std::vector<int> arr = {2, 1, 5, 1, 3, 2};
    std::cout << "maxSumFixedWindow(k=3): " << maxSumFixedWindow(arr, 3) << "\n";   // 9

    std::vector<int> arr2 = {2, 3, 1, 2, 4, 3};
    std::cout << "smallestSubarrayWithSum(target=7): " << smallestSubarrayWithSum(arr2, 7) << "\n";   // 2

    std::cout << "longestSubstringKDistinct(\"eceba\", k=2): "
              << longestSubstringKDistinct("eceba", 2) << "\n";   // 3 ("ece")

    return 0;
}
```

---

## 9. Code Walkthrough

- **`maxSumFixedWindow`'s incremental update `windowSum += arr[i] - arr[i-k]`:** This single line is the entire point of the technique — rather than resumming k elements at every position (O(k) per window, O(nk) total), we do exactly one subtraction and one addition per slide (O(1) per window, O(n) total).
- **`smallestSubarrayWithSum`'s nested-looking `while` inside the `for`:** As explained in section 4, this is NOT O(n²) despite appearances — `left` only ever increases, and across the *whole* function call, it increases at most n times total (not n times *per* outer iteration), so the amortized total work of the inner `while` loop across all outer iterations is O(n), not O(n²).
- **The "expand first, then contract while valid" ordering:** This ordering is what correctly finds the *smallest* valid window — we only start contracting once a window becomes valid, and we contract as much as possible before the window becomes invalid again, guaranteeing we don't miss a smaller valid window at any point.
- **`longestSubstringKDistinct`'s frequency map with `erase` on zero-count:** Removing a character from the map entirely (rather than leaving a zero-count entry) is essential — `freq.size()` is used as the "distinct character count" check, and a lingering zero-count entry would incorrectly inflate that count.

**Common mistakes to watch for here:**
- Recomputing the window sum from scratch on every slide instead of using the incremental update — this technically still works but throws away the entire point of the technique (silently degrading back to O(nk)).
- In variable-window problems, contracting the window in the wrong order relative to expanding (e.g., checking validity before adding the new element, rather than after) — leads to off-by-one errors in the final answer.
- Forgetting to erase zero-count entries from a frequency map, corrupting distinct-count checks in problems like `longestSubstringKDistinct`.

---

## 10. Dry Run

**`smallestSubarrayWithSum([2,3,1,2,4,3], target=7)`**, condensed trace (matching section 3's detailed walkthrough):

| right | windowSum after adding | Contract? | left after contracting | best |
|---|---|---|---|---|
| 0 | 2 | no (2<7) | 0 | ∞ |
| 1 | 5 | no (5<7) | 0 | ∞ |
| 2 | 6 | no (6<7) | 0 | ∞ |
| 3 | 8 | yes → remove arr[0]=2, sum=6<7, stop | 1 | 4 |
| 4 | 6+4=10 | yes → remove arr[1]=3, sum=7≥7, continue → remove arr[2]=1, sum=6<7, stop | 3 | 3 |
| 5 | 6+3=9 | yes → remove arr[3]=2, sum=7≥7, continue → remove arr[4]=4, sum=3<7, stop | 5 | 2 |

Final answer: 2 — matching section 3's manual trace exactly. ✓

---

## 11. Complexity Table

| Variant | Time | Space |
|---|---|---|
| Fixed Window | O(n) | O(1) (numeric aggregate) |
| Variable Window (numeric aggregate) | O(n) | O(1) |
| Variable Window (with frequency map) | O(n) | O(k) or O(alphabet size) |

**Every entry explained:** Fixed window's O(n) comes from exactly (n-k+1) O(1) slides. Variable window's O(n) comes from the amortized argument in section 4 — both pointers' *total* movement across the whole execution is bounded by 2n, never n². The space cost only grows beyond O(1) when the aggregate itself requires more than a single running number (e.g., tracking which distinct characters are present, not just how many).

---

## 12. Common Mistakes

- **Recomputing the window from scratch on every slide** instead of incrementally updating — defeats the entire purpose and silently degrades performance back to O(nk) or worse.
- **Misjudging variable-window monotonicity** — assuming "growing the window always helps" when the actual condition doesn't behave monotonically can lead to incorrect contraction logic (most classic sliding-window problems ARE monotonic in the relevant sense, but always verify this before applying the pattern).
- **Off-by-one in window boundaries** — particularly around whether `right - left + 1` (inclusive-inclusive) is the correct window length formula for your specific pointer convention.
- **Forgetting to erase zero-count map entries** in distinct-count-tracking problems.
- **Not handling the "no valid window exists" edge case** — e.g., `smallestSubarrayWithSum` must return a sentinel (0, or -1) rather than leaving `best` at `INT_MAX` if no window ever satisfies the condition.

---

## 13. Interview Questions

**Conceptual:**
1. Why is variable-window sliding window O(n) rather than O(n²), despite the code having a loop inside a loop?
2. Explain the difference between fixed and variable window, and how to recognize which a given problem needs.
3. Why must the aggregate being tracked be efficiently (O(1) or near it) updatable for this technique to pay off?
4. Compare Sliding Window to Two Pointer (Chapter 7) — how are they related?
5. When does Sliding Window NOT apply — what problem characteristics rule it out?

**Coding:**
1. Maximum Sum Subarray of Size K (fixed window).
2. Longest Substring Without Repeating Characters (variable window + set).
3. Minimum Window Substring (variable window + frequency map — a harder, classic problem).
4. Longest Substring with At Most K Distinct Characters.
5. Sliding Window Maximum (needs a monotonic deque — connects back to the Data Structures guide's Stack/Queue chapter).
6. Permutation in String (fixed window + frequency comparison).

**Follow-ups / interviewer traps:**
- "Can you find the maximum, not just the sum, of every window of size k, still in O(n)?" (expects a monotonic deque — a genuinely different technique than the simple running-sum update, tests whether the candidate over-generalizes the simple fixed-window template)
- "Minimum Window Substring — how do you know when the window is 'valid' efficiently, without rechecking all required characters every time?" (expects maintaining a "how many required characters are currently satisfied" counter, updated incrementally, rather than a full recheck)
- "What's the space complexity if the alphabet is Unicode rather than ASCII?" (tests awareness that frequency-map-based space costs scale with the actual character set encountered, not a fixed small constant)

---

## 14. Practice Problems

**Easy**
- Maximum Average Subarray I (LeetCode 643) — fixed window
- Contains Duplicate II (LeetCode 219)

**Medium**
- Longest Substring Without Repeating Characters (LeetCode 3)
- Longest Substring with At Most K Distinct Characters (LeetCode 340)
- Permutation in String (LeetCode 567)
- Fruit Into Baskets (LeetCode 904) — a disguised "at most 2 distinct" variable window

**Hard**
- Minimum Window Substring (LeetCode 76)
- Sliding Window Maximum (LeetCode 239)
- Substring with Concatenation of All Words (LeetCode 30)

Also recommended: GeeksforGeeks "Sliding Window Technique" practice set, Codeforces problems tagged `two pointers` (many sliding-window problems are tagged this way, reflecting the close relationship between the two techniques).

---

## 15. Summary

**Key takeaways:**
- Sliding Window is fundamentally Two Pointer applied to a *contiguous range* problem — incrementally maintaining an aggregate as the window slides, rather than recomputing it from scratch.
- Fixed window slides by a constant amount each step; variable window expands until valid, then contracts while still valid — both achieve O(n) via the same "each pointer's total movement is bounded by n" argument.
- The technique generalizes well beyond simple sums — frequency maps, distinct-element counts, and other efficiently-updatable aggregates all fit the same template.

**Complexity recap:**

| | Time | Space |
|---|---|---|
| Fixed/Variable Window | O(n) | O(1) to O(k), depending on aggregate complexity |

**Decision guide:** Reach for Sliding Window whenever a problem asks for a property of *contiguous* subarrays/substrings — maximum/minimum sum of fixed size, smallest/longest window satisfying a condition, or counting/frequency-based substring properties. If the problem allows non-contiguous selection, this technique doesn't apply — look toward Dynamic Programming instead.

---

*Next chapter: `09_prefix_sum.md`*
