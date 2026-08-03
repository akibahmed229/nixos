# Chapter 3: Stack & Queue

*Study time: ~4-6 hours | Prerequisite: Arrays, Linked Lists | Difficulty: Beginner-Intermediate*

---

## 1. Introduction

**Definition:** A **Stack** is a linear data structure that follows **LIFO** (Last In, First Out) — the most recently added element is the first one removed. A **Queue** follows **FIFO** (First In, First Out) — the earliest added element is the first one removed. Both are *restricted* interfaces layered on top of an array or linked list: they don't allow arbitrary access, only access at defined ends.

**Purpose:** To enforce a strict order of processing — "undo the last thing" (stack) or "serve whoever arrived first" (queue) — without exposing the full flexibility (and risk of misuse) of a raw array or list.

**Real-world analogy:**
- **Stack** = a stack of plates. You can only take the top plate off, and you can only add a new plate on top.
- **Queue** = a checkout line. The first person to join is the first person served; new people join at the back.

**Motivation:** Many real problems have a natural "reverse order" (stack) or "arrival order" (queue) requirement — function calls returning in reverse order of being called, or print jobs processing in the order submitted. Building a dedicated structure with only `push/pop` or `enqueue/dequeue` prevents bugs from accidentally reading/writing the middle of the collection.

---

## 2. Why Do We Need It?

**Problem it solves:** Enforcing a specific access discipline (LIFO or FIFO) so algorithms that depend on that order (backtracking, BFS, task scheduling) behave correctly and are easy to reason about.

**Why raw arrays/lists are insufficient:** You *could* use a plain array for both, but nothing stops you from accidentally reading/writing the middle, which breaks the LIFO/FIFO invariant the algorithm depends on. A dedicated Stack/Queue interface makes misuse a compile-time or immediate runtime error.

**Trade-offs:**
- You gain guaranteed O(1) operations at the defined access point(s) and a self-documenting interface (`push`/`pop` signals LIFO intent to any reader of the code).
- You lose general-purpose access — you cannot peek at the 3rd element of a stack without popping the first two.

---

## 3. Internal Working

**Stack (array-backed)** — grows and shrinks only at one end, the "top":

```
push(30):        pop():
┌────┐           ┌────┐
│ 30 │ ← top      │ 20 │ ← top (30 removed)
├────┤           ├────┤
│ 20 │           │ 10 │
├────┤           └────┘
│ 10 │
└────┘
```

**Queue (circular-array-backed)** — enqueue at rear, dequeue at front. A *circular* buffer avoids wasting space after repeated dequeues:

```
Initial: front=0, rear=-1, empty
enqueue(10): [10, _, _, _]   front=0 rear=0
enqueue(20): [10,20, _, _]   front=0 rear=1
enqueue(30): [10,20,30, _]   front=0 rear=2
dequeue():   [ _,20,30, _]   front=1 rear=2   (10 logically removed)
enqueue(40): [ _,20,30,40]   front=1 rear=3
enqueue(50): rear wraps around to index 0 (circular!) → [50,20,30,40]  front=1 rear=0
```

Without the circular wraparound, a plain array-backed queue would "leak" the freed front slots and eventually run out of room even with elements removed.

**Stack via recursion / call stack** (why it's called a "stack"):

```
main() calls f(3)
  f(3) calls f(2)
    f(2) calls f(1)
      f(1) returns
    f(2) resumes and returns
  f(3) resumes and returns
main() resumes

Call stack grows:  [main] → [main,f(3)] → [main,f(3),f(2)] → [main,f(3),f(2),f(1)]
Then unwinds in exact reverse order — LIFO.
```

---

## 4. Operations

**Stack**
- **push(x):** Place x at the top. O(1).
- **pop():** Remove and return the top element. O(1). Edge case: popping an empty stack → underflow error.
- **peek()/top():** View the top element without removing. O(1).
- **isEmpty():** O(1).
- No search/traverse in the "pure" interface — if you need to search, you're arguably using the wrong structure.

**Queue**
- **enqueue(x):** Place x at the rear. O(1).
- **dequeue():** Remove and return the front element. O(1). Edge case: dequeuing an empty queue → underflow error.
- **front()/peek():** View the front element without removing. O(1).
- **isEmpty():** O(1).
- **Circular array edge case:** rear must wrap using modulo (`rear = (rear + 1) % capacity`), and you must distinguish "empty" from "full" (both can look like `front == rear` without a size counter).

**Deque (double-ended queue)** — generalizes both:
- `push_front`, `push_back`, `pop_front`, `pop_back` — all O(1). A deque can *simulate* both a stack and a queue.

---

## 5. Time & Space Complexity

| Operation | Stack | Queue | Space Complexity |
|---|---|---|---|
| push / enqueue | O(1) | O(1) | O(1) per element |
| pop / dequeue | O(1) | O(1) | O(1) |
| peek / front | O(1) | O(1) | O(1) |
| isEmpty | O(1) | O(1) | O(1) |
| Search (if needed) | O(n) | O(n) | O(1) |
| Overall storage | O(n) | O(n) | O(n) |

**Why these hold:** Every core operation touches only a fixed, known location (the top, or the front/rear) — never requiring a scan of the rest of the structure. This is true whether the backing store is an array (with a top/front/rear index) or a linked list (with a head/tail pointer) — the O(1) guarantee comes from *restricting* access to defined ends, not from any particular backing implementation.

---

## 6. Advantages

- Both guarantee O(1) for their core operations, with essentially no overhead beyond the backing structure.
- The restricted interface makes code that uses them self-documenting and harder to misuse (a stack signals "I only care about the most recent item"; a queue signals "I process things in arrival order").
- Directly mirror common real-world/algorithmic patterns (undo history, BFS traversal, task scheduling), making translation from problem statement to code very direct.

## 7. Disadvantages

- No random access — can't inspect the middle without destructively popping through it.
- Array-backed stacks/queues need resizing logic (same cost profile as dynamic arrays) unless capacity is fixed and known upfront.
- A naive (non-circular) array-backed queue wastes space at the front after repeated dequeues unless a circular buffer or periodic compaction is used.

---

## 8. Real-World Applications

**Stack**
- **Compilers:** Expression evaluation, syntax parsing (matching brackets/parentheses), the function call stack itself.
- **Browsers:** The "back" button history is a stack of visited pages.
- **Text Editors:** Undo functionality — each action pushed onto a stack, popped on undo.
- **Operating Systems:** Each thread has its own call stack for function invocation and local variables.

**Queue**
- **Operating Systems:** CPU task scheduling (round-robin), print job spooling.
- **Networking:** Packet buffering at routers — packets processed in arrival order.
- **Social Media:** Notification queues, message queues (Kafka, RabbitMQ) that process events in order.
- **Customer Service Systems:** Ticket queues — first-come-first-served support.
- **BFS traversal** in Graph and Tree algorithms (covered in the Graphs chapter) is *built entirely on a queue*.

---

## 9. Implementation (C++17)

```cpp
#include <iostream>
#include <stdexcept>

// ---------- STACK: array-backed, LIFO ----------
class Stack {
private:
    int* data;
    size_t cap;
    size_t topIdx;   // number of elements currently stored (also "next free slot")

    void resize(size_t newCap) {
        int* newData = new int[newCap];
        for (size_t i = 0; i < topIdx; ++i) newData[i] = data[i];
        delete[] data;
        data = newData;
        cap = newCap;
    }

public:
    Stack() : data(new int[1]), cap(1), topIdx(0) {}
    ~Stack() { delete[] data; }

    // Push. Amortized O(1) — same doubling strategy as dynamic array.
    void push(int value) {
        if (topIdx == cap) resize(cap * 2);
        data[topIdx++] = value;
    }

    // Pop. O(1). Throws on empty stack — never silently return garbage.
    int pop() {
        if (isEmpty()) throw std::underflow_error("pop on empty stack");
        return data[--topIdx];
    }

    // Peek at top without removing. O(1).
    int peek() const {
        if (isEmpty()) throw std::underflow_error("peek on empty stack");
        return data[topIdx - 1];
    }

    bool isEmpty() const { return topIdx == 0; }
    size_t size() const { return topIdx; }
};

// ---------- QUEUE: circular-array-backed, FIFO ----------
class Queue {
private:
    int* data;
    size_t cap;
    size_t frontIdx;
    size_t count;   // number of elements currently stored

    void resize(size_t newCap) {
        int* newData = new int[newCap];
        // Copy elements out in logical order (front to rear), re-linearizing the circular buffer.
        for (size_t i = 0; i < count; ++i) {
            newData[i] = data[(frontIdx + i) % cap];
        }
        delete[] data;
        data = newData;
        cap = newCap;
        frontIdx = 0;
    }

public:
    Queue() : data(new int[1]), cap(1), frontIdx(0), count(0) {}
    ~Queue() { delete[] data; }

    // Enqueue at the rear. Amortized O(1).
    void enqueue(int value) {
        if (count == cap) resize(cap * 2);
        size_t rearIdx = (frontIdx + count) % cap;   // circular wraparound
        data[rearIdx] = value;
        count++;
    }

    // Dequeue from the front. O(1).
    int dequeue() {
        if (isEmpty()) throw std::underflow_error("dequeue on empty queue");
        int value = data[frontIdx];
        frontIdx = (frontIdx + 1) % cap;   // circular wraparound
        count--;
        return value;
    }

    // Peek at front without removing. O(1).
    int front() const {
        if (isEmpty()) throw std::underflow_error("front on empty queue");
        return data[frontIdx];
    }

    bool isEmpty() const { return count == 0; }
    size_t size() const { return count; }
};

// Example usage
int main() {
    Stack s;
    s.push(10); s.push(20); s.push(30);
    std::cout << "Stack top: " << s.peek() << "\n";   // 30
    std::cout << "Popped: " << s.pop() << "\n";        // 30
    std::cout << "Popped: " << s.pop() << "\n";        // 20
    std::cout << "Stack size: " << s.size() << "\n";    // 1

    Queue q;
    q.enqueue(10); q.enqueue(20); q.enqueue(30);
    std::cout << "Queue front: " << q.front() << "\n";   // 10
    std::cout << "Dequeued: " << q.dequeue() << "\n";     // 10
    std::cout << "Dequeued: " << q.dequeue() << "\n";     // 20
    q.enqueue(40);
    std::cout << "Queue size: " << q.size() << "\n";      // 2
    return 0;
}
```

---

## 10. Code Walkthrough

- **Stack's `topIdx`:** Doubles as both "how many elements are stored" and "the next free slot index." `push` writes to `data[topIdx]` then increments; `pop` decrements first, then reads — this ordering matters and is a common off-by-one trap.
- **Stack `resize`:** Identical doubling strategy to the Dynamic Array chapter — stacks and dynamic arrays share the same amortized-O(1)-growth logic, since a stack *is* essentially a dynamic array restricted to one access point.
- **Queue's circular indexing (`(frontIdx + count) % cap`):** This is the crux of the whole implementation. Without the modulo, `rearIdx` would keep growing forever even as elements are dequeued from the front, eventually running past the allocated array despite there being free (dequeued) slots at the beginning.
- **Queue's `resize`:** Note it re-linearizes the circular buffer — it doesn't just copy `data[0..cap)` verbatim (that would copy stale/wrapped-around data in the wrong order). It walks `count` elements starting from the *logical* front, using modulo again, and resets `frontIdx` to 0 in the new block.
- **Why `count` instead of comparing `frontIdx == rearIdx`:** A common queue bug is trying to detect "full" vs "empty" using only front/rear indices — both states can produce `front == rear`. Tracking `count` explicitly sidesteps this ambiguity entirely.

**Common mistakes to watch for here:**
- Forgetting the modulo wraparound in a circular queue, causing an index-out-of-bounds write.
- Using `front == rear` alone to detect empty/full (ambiguous) instead of a dedicated counter.
- Off-by-one between incrementing/decrementing `topIdx` before vs. after reading/writing.

---

## 11. Dry Run

**Stack — Input:** `push(10)`, `push(20)`, `push(30)`, `pop()`, `peek()`

| Step | Operation | State (top→bottom) | Returns |
|---|---|---|---|
| 1 | push(10) | [10] | — |
| 2 | push(20) | [20,10] | — |
| 3 | push(30) | [30,20,10] | — |
| 4 | pop() | [20,10] | 30 |
| 5 | peek() | [20,10] | 20 |

**Queue (capacity 4) — Input:** `enqueue(10,20,30)`, `dequeue()`, `enqueue(40)`, `enqueue(50)`

| Step | Operation | frontIdx | count | Array (logical) | Notes |
|---|---|---|---|---|---|
| 1 | enqueue(10) | 0 | 1 | [10] | |
| 2 | enqueue(20) | 0 | 2 | [10,20] | |
| 3 | enqueue(30) | 0 | 3 | [10,20,30] | |
| 4 | dequeue() → 10 | 1 | 2 | [20,30] | front slot logically freed |
| 5 | enqueue(40) | 1 | 3 | [20,30,40] | rear = (1+2)%4 = 3 |
| 6 | enqueue(50) | 1 | 4 | [20,30,40,50] | rear = (1+3)%4 = 0 → wraps to index 0! |

At step 6, `50` physically lands at array index 0 (wrapping around), even though logically it's the newest, rear-most element — this is exactly why circular indexing works without wasting the freed front slots.

---

## 12. Interview Questions

**Conceptual:**
1. Why does a naive array-backed queue "waste" space after repeated dequeues, and how does a circular buffer fix it?
2. How would you implement a Queue using two Stacks (and vice versa)?
3. What's the relationship between a Stack and recursion / the call stack?
4. When would you use a Deque instead of a plain Stack or Queue?
5. Why can't `front == rear` alone reliably distinguish an empty circular queue from a full one?

**Coding:**
1. Implement a Queue using two Stacks.
2. Implement a Stack using a single Queue.
3. Valid Parentheses — check balanced brackets using a stack.
4. Design a Min Stack (push/pop/getMin all O(1)).
5. Evaluate a Reverse Polish Notation (postfix) expression.
6. Implement a sliding window maximum using a Deque (monotonic deque technique).
7. Next Greater Element — using a monotonic stack.

**Follow-ups / interviewer traps:**
- "Can you get O(1) amortized for both push and pop in the two-stack Queue?" (yes — lazy transfer between stacks)
- "What if you need getMin() in O(1) on your Min Stack — can you do it without extra space per element?" (expects storing running-min alongside each value, or a secondary stack)
- After Sliding Window Maximum: "Why is a monotonic deque O(n) total instead of O(nk)?" (tests amortized analysis understanding)

---

## 13. Practice Problems

**Easy**
- Valid Parentheses (LeetCode 20)
- Implement Stack using Queues (LeetCode 225)
- Implement Queue using Stacks (LeetCode 232)
- Baseball Game (LeetCode 682)

**Medium**
- Min Stack (LeetCode 155)
- Evaluate Reverse Polish Notation (LeetCode 150)
- Daily Temperatures — monotonic stack (LeetCode 739)
- Next Greater Element II (LeetCode 503)
- Design Circular Queue (LeetCode 622)

**Hard**
- Sliding Window Maximum (LeetCode 239)
- Largest Rectangle in Histogram (LeetCode 84)
- Trapping Rain Water using Stack (LeetCode 42, stack-based approach)

Also recommended: GeeksforGeeks "Stack" and "Queue" practice sets, HackerRank "Stacks and Queues" track, Codeforces problems tagged `data structures` + `implementation` involving monotonic stacks/deques.

---

## 14. Common Mistakes

- **Popping/dequeuing without checking for empty first** — causes undefined behavior or crashes.
- **Forgetting the circular wraparound modulo** in an array-backed queue, leading to out-of-bounds access or "false full" errors.
- **Confusing Stack and Queue semantics** when translating a problem into code (e.g., using a Stack for BFS, which should use a Queue — this silently produces DFS-order results instead).
- **Not resizing** a fixed-capacity array-backed stack/queue and overflowing it.
- **Assuming a `std::stack`/`std::queue` supports iteration or random access** — by design (in the STL, these are "container adapters"), they intentionally don't expose iterators, mirroring the "restricted access" philosophy of section 2.
- **In Min Stack problems:** storing only the global minimum instead of a minimum-at-each-push-time, which breaks when the actual minimum is popped.

---

## 15. Summary

**Key takeaways:**
- Stack = LIFO, Queue = FIFO — the *only* difference between them is which end you remove from; everything else (O(1) core ops, restricted interface, array or linked-list backing) is shared.
- A circular buffer is what makes an array-backed queue efficient — without it, you either waste space or need O(n) compaction.
- Both structures are less "data structures to master deeply" and more "disciplines to recognize" — the real skill is spotting *when* a problem has LIFO or FIFO structure (undo → stack; BFS/scheduling → queue).

**Complexity recap:**

| | push/enqueue | pop/dequeue | peek | Space |
|---|---|---|---|---|
| Stack | O(1) amortized | O(1) | O(1) | O(n) |
| Queue (circular array) | O(1) amortized | O(1) | O(1) | O(n) |

**Decision guideline:** Use a Stack when the most recently seen item needs to be processed first (undo, backtracking, expression parsing, DFS via explicit stack). Use a Queue when items must be processed in arrival order (task scheduling, BFS, buffering). Use a Deque when you need both ends flexible (sliding window problems).

---

*Next chapter: `04_heaps.md` — Max-Heap & Min-Heap*
