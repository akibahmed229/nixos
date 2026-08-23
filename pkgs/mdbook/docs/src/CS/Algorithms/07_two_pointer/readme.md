# Chapter 7: Two Pointer

*Study time: ~4-5 hours | Prerequisite: Arrays, Sorting (Ch. 2-4) | Difficulty: Beginner-Intermediate*

---

## 1. Introduction

**Definition:** The Two Pointer technique uses two index variables ("pointers") that traverse an array (or string) — either moving toward each other from opposite ends, moving in the same direction at different speeds, or one fast/one slow — to solve problems in O(n) that would otherwise need O(n²) with nested loops.

**Purpose:** To eliminate a redundant nested loop by exploiting structure (usually sortedness, or a specific traversal pattern) that lets both pointers move **monotonically** — each pointer only ever advances, never backtracks — guaranteeing the total work stays linear.

**Problem solved:** A huge class of "find a pair/subarray/structural property" problems that a naive nested-loop approach solves in O(n²), but which secretly only need O(n) once you recognize the right pointer-movement pattern.

---

## 2. Intuition

**Opposite Direction (the classic "sorted array, find a pair" pattern):** if an array is sorted and you're looking for two elements summing to a target, starting one pointer at each end lets you reason: "if the current sum is too small, the *only* way to increase it is to move the left pointer right (since the array is sorted, any leftward move on the right pointer can only decrease or keep the sum). If the current sum is too large, move the right pointer left." This eliminates the need to check every pair — each comparison rules out an entire row or column of the conceptual n×n pair-grid at once.

**Same Direction (the "partition/filter in-place" pattern):** one pointer tracks "where the next valid element should go," another scans forward looking for valid elements — this is exactly how you'd sort mail into "keep" and "discard" piles while only walking through the stack once, physically moving items as you find them rather than making two separate passes.

**Fast & Slow (Floyd's Tortoise and Hare):** two pointers move through a sequence at different speeds (typically 1 step vs. 2 steps) — if there's a cycle, the fast pointer will eventually "lap" the slow one and they'll meet; if there's no cycle, the fast pointer simply reaches the end first. This is the same technique introduced for linked list cycle detection in the Data Structures guide, generalized here as a standalone pattern.

---

## 3. Step-by-Step Working

### (a) Opposite Direction — find a pair summing to 13 in sorted `[1, 3, 5, 7, 9, 11]`

```
left=0(1), right=5(11). Sum=1+11=12 < 13 → too small → move LEFT pointer right.
left=1(3), right=5(11). Sum=3+11=14 > 13 → too large → move RIGHT pointer left.
left=1(3), right=4(9).  Sum=3+9=12 < 13 → too small → move LEFT pointer right.
left=2(5), right=4(9).  Sum=5+9=14 > 13 → too large → move RIGHT pointer left.
left=2(5), right=3(7).  Sum=5+7=12 < 13 → too small → move LEFT pointer right.
left=3(7), right=3(7).  Pointers meet — no pair found within these bounds.

(If instead target were 12: the very first check would have found 1+11=12 → MATCH immediately.)
```

Each step eliminates exactly one row or column from consideration — n pointer moves total, giving O(n) instead of checking all O(n²) pairs.

### (b) Same Direction — remove duplicates in-place from sorted `[1, 1, 2, 2, 2, 3, 4, 4]`

```
slow=0 (points to the last confirmed-unique element written so far)
fast scans forward:
fast=1: arr[1]=1 == arr[slow]=1 → duplicate, skip (don't advance slow)
fast=2: arr[2]=2 != arr[slow]=1 → new unique value → slow=1, arr[slow]=2 → [1,2,2,2,2,3,4,4]
fast=3: arr[3]=2 == arr[slow]=2 → duplicate, skip
fast=4: arr[4]=2 == arr[slow]=2 → duplicate, skip
fast=5: arr[5]=3 != arr[slow]=2 → new unique → slow=2, arr[slow]=3 → [1,2,3,2,2,3,4,4]
fast=6: arr[6]=4 != arr[slow]=3 → new unique → slow=3, arr[slow]=4 → [1,2,3,4,2,3,4,4]
fast=7: arr[7]=4 == arr[slow]=4 → duplicate, skip

Final unique portion: arr[0..slow] = [1,2,3,4]  (everything after slow is now irrelevant leftover data)
```

### (c) Fast & Slow — detect a cycle in a sequence (conceptually, matching the Data Structures guide's linked-list treatment)

```
slow moves 1 step at a time, fast moves 2 steps at a time.
If there's a cycle, fast will eventually "lap" slow and they'll occupy the same position —
mathematically guaranteed because the GAP between them shrinks by exactly 1 each step
once both are inside the cycle, so it must eventually reach 0.
If there's no cycle, fast simply reaches the end (a null/boundary) first.
```

---

## 4. Complexity Analysis

**Time: O(n) for all three variants**, in contrast to the O(n²) a naive nested-loop approach would require for the same problems.

**Why Opposite Direction is O(n), not O(n²):** each of the n total pointer moves (left advancing or right retreating) permanently shrinks the search space by one — the two pointers can move toward each other at most n times combined before meeting, so the total work across the entire algorithm is bounded by n, not n².

**Why Same Direction is O(n):** the fast pointer makes exactly n moves (one full pass), and the slow pointer makes at most n moves (never more than fast) — both bounded by a single linear pass, with no nested iteration.

**Why Fast & Slow is O(n):** even though the fast pointer moves twice as fast, it still only traverses a bounded-length structure a constant number of times before either finding the cycle or reaching the end — the total work remains linear in the structure's size.

**Space: O(1) for all three** — this is the other headline advantage: no auxiliary data structure needed, unlike, say, a hash-set-based approach to the same "find a pair" problem (which would also be O(n) time, but O(n) space instead of O(1)).

---

## 5. Advantages

- Converts many O(n²) nested-loop problems into O(n) — often the single highest-leverage optimization pattern in coding interviews.
- O(1) extra space — genuinely in-place, no auxiliary hash sets or arrays needed (an advantage over equivalent hash-based approaches to the same problems).
- Conceptually simple once the pattern is recognized — the hard part is *recognizing* when it applies, not implementing it.

## 6. Limitations

- **Opposite Direction typically requires sorted data** — if the array isn't sorted and can't be cheaply sorted (or sorting would destroy needed information, like original indices), this variant doesn't directly apply.
- Doesn't generalize to problems needing information about *all* pairs simultaneously (e.g., counting *every* pair satisfying a condition, rather than just finding one or partitioning) — some counting variants exist but require more care.
- Recognizing which variant (opposite/same/fast-slow) applies to a novel problem is a genuine pattern-recognition skill that takes deliberate practice to build.

---

## 7. Real-World Applications

- **Databases:** merge-join operations (combining two sorted result sets) use an opposite-direction-style two-pointer merge.
- **Text Processing:** palindrome checking, string reversal in-place — natural opposite-direction applications.
- **Memory Management:** in-place array compaction/garbage collection (moving "live" objects to the front, analogous to the same-direction duplicate-removal pattern).
- **Networking:** TCP congestion control's sliding window (closely related to the Sliding Window pattern, next chapter) tracks a moving range of "in-flight" packets using pointer-like bounds.
- **Version Control:** diff algorithms use two-pointer-style techniques to find common/differing regions between two sequences.
- **Operating Systems:** cycle detection in resource-allocation graphs (deadlock detection) uses fast-slow-pointer-style techniques conceptually related to Floyd's algorithm.

---

## 8. C++ Implementation

```cpp
#include <iostream>
#include <vector>
#include <algorithm>

// Opposite Direction: find if any pair in a SORTED array sums to target. O(n).
bool twoSumSorted(const std::vector<int>& arr, int target) {
    int left = 0, right = static_cast<int>(arr.size()) - 1;

    while (left < right) {
        int sum = arr[left] + arr[right];
        if (sum == target) {
            return true;   // found a matching pair
        } else if (sum < target) {
            left++;          // sum too small — only increasing left can help (array is sorted)
        } else {
            right--;          // sum too large — only decreasing right can help
        }
    }
    return false;
}

// Same Direction: remove duplicates in-place from a SORTED array, return new length. O(n).
int removeDuplicates(std::vector<int>& arr) {
    if (arr.empty()) return 0;

    int slow = 0;   // slow tracks the last position of a confirmed-unique element
    for (int fast = 1; fast < static_cast<int>(arr.size()); ++fast) {
        if (arr[fast] != arr[slow]) {
            slow++;
            arr[slow] = arr[fast];   // write the new unique value into place
        }
        // if arr[fast] == arr[slow], it's a duplicate — fast advances, slow stays put
    }
    return slow + 1;   // number of unique elements
}

// Fast & Slow: detect whether a sequence (modeled here as a "next" function) has a cycle.
// In a real linked list this would use Node* pointers — see Data Structures guide, Ch.3.
bool hasCycle(const std::vector<int>& next, int start) {
    int slow = start, fast = start;

    while (next[fast] != -1 && next[next[fast]] != -1) {   // -1 represents "end of sequence"
        slow = next[slow];              // move 1 step
        fast = next[next[fast]];         // move 2 steps
        if (slow == fast) return true;    // they met — a cycle exists
    }
    return false;   // fast reached the end without meeting slow — no cycle
}

// Example usage
int main() {
    std::vector<int> sorted = {1, 3, 5, 7, 9, 11};
    std::cout << "twoSumSorted(target=12): " << twoSumSorted(sorted, 12) << "\n";   // 1 (true)
    std::cout << "twoSumSorted(target=13): " << twoSumSorted(sorted, 13) << "\n";   // 0 (false)

    std::vector<int> withDupes = {1, 1, 2, 2, 2, 3, 4, 4};
    int newLen = removeDuplicates(withDupes);
    std::cout << "After removeDuplicates, unique portion: ";
    for (int i = 0; i < newLen; ++i) std::cout << withDupes[i] << " ";
    std::cout << "\n";   // 1 2 3 4

    return 0;
}
```

---

## 9. Code Walkthrough

- **`twoSumSorted`'s directional logic:** The crucial insight encoded in `sum < target → left++` and `sum > target → right--` is that, because the array is sorted, moving the *other* pointer in either case could never help — e.g., if the sum is too small, decreasing `right` would only make it smaller still (worse), so `left` is the only pointer that can productively move. This is the exact reasoning that makes the algorithm correct, not just fast.
- **`removeDuplicates`'s slow/fast roles:** `slow` always points at the last position that holds a confirmed-final unique value; `fast` scans ahead looking for the *next* unique value. The write `arr[slow] = arr[fast]` only happens when a genuinely new value is found — this is what keeps the "unique so far" region at the front of the array compact, with no gaps.
- **`hasCycle`'s loop condition:** Checking both `next[fast] != -1` AND `next[next[fast]] != -1` before advancing ensures the fast pointer never tries to take two steps past the actual end of a non-cyclic sequence (which would be an invalid/out-of-bounds access) — this guard is what makes the fast-pointer's "move 2 steps" safe.
- **Why `fast` moving 2x speed guarantees meeting `slow` inside a cycle:** once both pointers are inside the cycle, the *gap* between them (measured along the cycle) decreases by exactly 1 every step (since fast gains 1 net step on slow per iteration) — a gap that shrinks by 1 each step, starting from some finite value, must eventually hit 0, guaranteeing a meeting.

**Common mistakes to watch for here:**
- Applying `twoSumSorted`'s opposite-direction logic to an *unsorted* array — this technique fundamentally depends on sortedness to guarantee correctness of the pointer-movement decisions.
- In `removeDuplicates`, forgetting to advance `slow` before writing, or writing on every iteration instead of only when a new unique value is found.
- Off-by-one errors in the fast-pointer's bounds-checking for cycle detection, risking out-of-bounds access on non-cyclic sequences.

---

## 10. Dry Run

Both (a) and (b) from section 3 are already complete, step-by-step dry runs. The key complexity insight worth re-emphasizing from run (a): across the entire `twoSumSorted` execution on `[1,3,5,7,9,11]` searching for 13, there were exactly 5 pointer-movement steps before the pointers met — compare this to a brute-force nested loop, which would check up to `6×5/2 = 15` pairs for the same 6-element array. The two-pointer technique's advantage becomes dramatically larger as n grows, since it's O(n) vs. O(n²).

---

## 11. Complexity Table

| Variant | Time | Space | Precondition |
|---|---|---|---|
| Opposite Direction | O(n) | O(1) | Sorted data (or a similarly monotonic structure) |
| Same Direction | O(n) | O(1) | Usually sorted (for dedup-style problems), though some same-direction problems work unsorted (e.g., partitioning) |
| Fast & Slow | O(n) | O(1) | A traversable sequence with a well-defined "next" step |

**Every entry explained:** All three variants achieve O(n) because each pointer's total movement across the *entire* algorithm's execution is bounded by the structure's size (n), never revisiting the same position twice in a way that would reintroduce quadratic behavior — this is the single unifying reason all Two Pointer variants are linear.

---

## 12. Common Mistakes

- **Using opposite-direction two-pointer on unsorted data** — the directional logic (`sum too small → move left`) is only valid because of sortedness; applying it blindly to unsorted data gives wrong answers.
- **Off-by-one errors in loop conditions** (`left < right` vs `left <= right`) — get this wrong and you'll either miss valid pairs or double-count/incorrectly compare an element against itself.
- **Forgetting to advance the correct pointer** — a common slip is advancing both pointers on every iteration regardless of the comparison outcome, which breaks the technique's correctness guarantee entirely.
- **Confusing same-direction (dedup/partition) with opposite-direction (pair-finding) logic** — these are genuinely different patterns solving different problem shapes; misapplying one where the other is needed is a common early-learner mistake.

---

## 13. Interview Questions

**Conceptual:**
1. Why does opposite-direction two-pointer require sorted data, and what specifically breaks without it?
2. Explain why Two Pointer techniques are O(n) rather than O(n²) — what's the core argument?
3. Compare Two Pointer to a hash-set-based approach for the "find a pair summing to target" problem — what's the trade-off?
4. How does Fast & Slow pointer relate to the linked-list cycle detection covered in the Data Structures guide?
5. Give an example of a problem where Two Pointer does NOT apply, and explain why.

**Coding:**
1. Two Sum II - Input Array Is Sorted (LeetCode 167).
2. Remove Duplicates from Sorted Array (LeetCode 26).
3. Container With Most Water (LeetCode 11) — opposite-direction with a non-obvious movement rule.
4. 3Sum (LeetCode 15) — combines sorting + fixed element + opposite-direction two-pointer.
5. Linked List Cycle II — find the cycle's starting node (fast-slow pointer, with a clever second phase).
6. Sort Colors (LeetCode 75) — same-direction, three-way partition variant.

**Follow-ups / interviewer traps:**
- "Can you solve Two Sum with Two Pointer if the array isn't sorted?" (only after sorting it first, O(n log n) — but this loses original indices unless you track them separately, a common follow-up trap)
- "3Sum — why do you skip duplicate values while iterating the fixed element?" (tests understanding of avoiding duplicate triplets in the output, a subtle but essential detail)
- "Container With Most Water — why is it always correct to move the pointer at the SHORTER wall?" (tests a genuine proof-based understanding, not just pattern memorization — moving the taller wall's pointer can never improve the area, since the shorter wall was already the binding constraint)

---

## 14. Practice Problems

**Easy**
- Two Sum II - Input Array Is Sorted (LeetCode 167)
- Remove Duplicates from Sorted Array (LeetCode 26)
- Valid Palindrome (LeetCode 125)
- Reverse String (LeetCode 344)

**Medium**
- 3Sum (LeetCode 15)
- Container With Most Water (LeetCode 11)
- Sort Colors (LeetCode 75)
- Linked List Cycle II (LeetCode 142)

**Hard**
- Trapping Rain Water (LeetCode 42) — two-pointer variant exists alongside the prefix-sum approach
- 4Sum (LeetCode 18)

Also recommended: GeeksforGeeks "Two Pointer Technique" practice set, Codeforces problems tagged `two pointers`.

---

## 15. Summary

**Key takeaways:**
- Two Pointer converts O(n²) nested-loop problems into O(n) by ensuring each pointer only ever moves forward (or the two pointers only ever move toward each other), bounding total work by n rather than n².
- Opposite Direction needs sorted (monotonic) data; Same Direction handles partition/dedup-style problems; Fast & Slow detects cycles or finds midpoints.
- The hard skill is pattern recognition — spotting that a problem fits one of these three shapes — not the implementation itself, which is usually just a handful of lines once the right variant is identified.

**Complexity recap:**

| | Time | Space |
|---|---|---|
| Any Two Pointer variant | O(n) | O(1) |

**Decision guide:** Reach for Two Pointer whenever a problem involves finding a pair/triple in sorted data, partitioning/deduplicating an array in-place, or detecting a cycle/finding a midpoint in a sequence. If the data isn't sorted and sorting would destroy needed information (like original indices), consider a hash-based approach instead — same O(n) time, but O(n) space rather than Two Pointer's O(1).

---

*Next chapter: `08_sliding_window.md`*
