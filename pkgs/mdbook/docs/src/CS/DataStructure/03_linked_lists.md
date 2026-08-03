# Chapter 2: Linked Lists

*Study time: ~5-7 hours | Prerequisite: Arrays, pointers/references | Difficulty: Beginner-Intermediate*

---

## 1. Introduction

**Definition:** A linked list is a linear data structure where elements ("nodes") are stored in separate memory locations, each holding its data plus a pointer (or reference) to the next node. There is no requirement that nodes sit next to each other in memory.

**Purpose:** To allow the size of a collection to grow and shrink freely, and to allow O(1) insertion/deletion once you're positioned at a node — without the "shift everything" cost that arrays pay.

**Real-world analogy:** A treasure hunt. Each clue (node) tells you where to find the next clue. You can't jump straight to clue #7 — you must follow clue #1 → #2 → ... → #7. Compare this to an array, which is like a row of numbered lockers where you can walk straight to locker #7.

**Motivation:** Arrays require contiguous memory and (for static arrays) a known size upfront. A linked list frees you from both constraints — nodes can live anywhere in memory, and the list grows one node at a time with no bulk reallocation.

**History:** Introduced in the late 1950s as part of early list-processing languages (IPL, then Lisp), specifically to support of programs that manipulate symbolic, dynamically-sized data.

---

## 2. Why Do We Need It?

**Problem it solves:** Frequent insertion/deletion — especially at the front or middle — without the O(n) shifting cost arrays impose.

**Why arrays are insufficient here:** Inserting at the front of an array means shifting every existing element one slot right — O(n). A linked list just rewires two pointers — O(1), *once you're already at the right node*.

**Trade-offs:**
- You gain O(1) structural changes (given a node reference) and no need to pre-declare a size.
- You pay for it with O(n) access/search (no random access — you must walk from the head), extra memory per node (for the pointer(s)), and poor cache locality (nodes are scattered, so traversal is slower in practice than array traversal despite both being O(n)).

This is the mirror image of the array's trade-off: arrays are fast to read, slow to restructure; linked lists are slow to read, fast to restructure (once located).

---

## 3. Internal Working

**Singly Linked List** — each node has data + one pointer to the next node:

```
head
 │
 ▼
┌────┬────┐    ┌────┬────┐    ┌────┬────┐
│ 10 │ ●──┼───▶│ 20 │ ●──┼───▶│ 30 │NULL│
└────┴────┘    └────┴────┘    └────┴────┘
```

**Doubly Linked List** — each node also has a pointer back to the previous node, enabling backward traversal:

```
        head                                    tail
         │                                        │
         ▼                                        ▼
NULL◀───┬────┬────┐    ┌────┬────┬────┐    ┌────┬────┬────┐
        │prev│ 10 │next│prev│ 20 │next│prev│ 30 │next│───▶NULL
        └────┴────┴───▶│    │    │◀───┴────┴────┴────┘
```

**Circular Linked List** — the last node points back to the first instead of NULL:

```
┌────┐    ┌────┐    ┌────┐
│ 10 │───▶│ 20 │───▶│ 30 │
└────┘    └────┘    └────┘
   ▲                   │
   └───────────────────┘
```

**Insertion at the front (singly linked list), step by step:**

```
Before:  head → [10] → [20] → NULL
Insert 5:
Step 1: new node [5] → points to current head [10]
        [5] → [10] → [20] → NULL
Step 2: head now points to [5]
head →  [5] → [10] → [20] → NULL
```

Only two pointer operations — no shifting of existing nodes.

---

## 4. Operations

**Insert**
- *At head:* Create new node, point it to current head, update head. O(1).
- *At tail (no tail pointer):* Traverse to the end, then link. O(n).
- *At tail (tail pointer maintained):* O(1).
- *At position i:* Traverse to node i-1, then relink. O(n) to find + O(1) to relink.
- Edge case: inserting into an empty list — head and tail must both be updated to the new node.

**Delete**
- *At head:* Move head to `head->next`, free old head. O(1).
- *At tail (singly linked, no prev pointer):* Must traverse to second-to-last node to update its `next` to NULL. O(n). (Doubly linked list: O(1) since `prev` is directly available.)
- *At position i:* Traverse to node i-1, relink around node i, free it. O(n).
- Edge case: deleting the only node in the list — both head and tail must become NULL.

**Update**
- Traverse to the node, then overwrite its data field. O(n) to locate + O(1) to write.

**Search**
- Linear traversal from head, comparing each node's data. O(n). No binary search possible — you can't jump to the middle without already having a pointer there.

**Traverse**
- Follow `next` pointers until NULL. O(n). Cache-unfriendly compared to array traversal since nodes may be scattered in memory.

**Peek**
- Head/tail data, O(1) if pointers are maintained.

---

## 5. Time & Space Complexity

| Operation | Singly Linked List | Doubly Linked List | Space Complexity |
|---|---|---|---|
| Access by index | O(n) | O(n) | O(1) |
| Search | O(n) | O(n) | O(1) |
| Insert at head | O(1) | O(1) | O(1) extra per node |
| Insert at tail (tail ptr kept) | O(1) | O(1) | O(1) |
| Insert at middle (position known) | O(1) relink, O(n) to find | O(1) relink, O(n) to find | O(1) |
| Delete at head | O(1) | O(1) | O(1) |
| Delete at tail | O(n) | O(1) | O(1) |
| Overall storage | O(n) | O(n), roughly 2x pointer overhead vs singly | — |

**Why these hold:**
- Access/search must be O(n) because there is no address formula like arrays have — the only way to reach node i is to follow i pointers from the head.
- Insert/delete at head is O(1) because it only touches a fixed number of pointers regardless of list length.
- Deleting the tail in a *singly* linked list is O(n) because, without a `prev` pointer, you must walk from the head to find the node just before the tail. This single fact is the main reason doubly linked lists exist.

---

## 6. Advantages

- O(1) insertion/deletion at the head (and tail, if a tail pointer is kept).
- No need to know size in advance; grows one node at a time with no bulk reallocation.
- No wasted pre-allocated capacity (unlike a dynamic array's spare capacity).
- Doubly linked lists allow O(1) removal of a node given only a pointer to it (no need to know its predecessor).

## 7. Disadvantages

- No random access — O(n) to reach an arbitrary index.
- Extra memory per node for pointer(s) (a doubly linked list roughly doubles the pointer overhead versus singly).
- Poor cache locality — nodes are scattered, so real-world traversal is slower than an array's despite the same Big-O.
- More complex to implement correctly (pointer bugs like memory leaks and dangling pointers are common).

---

## 8. Real-World Applications

- **Operating Systems:** Process scheduling queues (e.g., the Linux kernel's task list uses a circular doubly linked list).
- **Browsers:** Forward/back navigation history (doubly linked list — you can go both directions).
- **Text Editors:** Undo/redo stacks, and some implementations model the document itself as a linked list of lines for O(1) line insertion/deletion.
- **Databases:** Buffer pool management (LRU eviction, covered later, uses a doubly linked list).
- **Music/Media players:** "Next/previous track" playlist navigation.
- **Memory Management:** Free lists in memory allocators link together free memory blocks.
- **File Systems:** Some file systems chain disk blocks belonging to one file via a linked-list-like structure (FAT — File Allocation Table).

Linked lists are chosen wherever items are added/removed frequently and sequential access is fine (you don't need "give me item #500,000 instantly").

---

## 9. Implementation (C++17)

```cpp
#include <iostream>
#include <stdexcept>

// A generic doubly linked list — supports O(1) insert/delete at both ends,
// and O(1) deletion given a direct node pointer (a key advantage over singly linked lists).
class DoublyLinkedList {
private:
    struct Node {
        int data;
        Node* prev;
        Node* next;
        Node(int val) : data(val), prev(nullptr), next(nullptr) {}
    };

    Node* head;
    Node* tail;
    size_t sz;

public:
    DoublyLinkedList() : head(nullptr), tail(nullptr), sz(0) {}

    // Destructor: walk the list and free every node to avoid memory leaks.
    ~DoublyLinkedList() {
        Node* current = head;
        while (current != nullptr) {
            Node* toDelete = current;
            current = current->next;
            delete toDelete;
        }
    }

    // Insert at the front. O(1).
    void push_front(int value) {
        Node* newNode = new Node(value);
        if (head == nullptr) {          // empty list: new node is both head and tail
            head = tail = newNode;
        } else {
            newNode->next = head;
            head->prev = newNode;
            head = newNode;
        }
        sz++;
    }

    // Insert at the back. O(1) thanks to the maintained tail pointer.
    void push_back(int value) {
        Node* newNode = new Node(value);
        if (tail == nullptr) {
            head = tail = newNode;
        } else {
            tail->next = newNode;
            newNode->prev = tail;
            tail = newNode;
        }
        sz++;
    }

    // Remove from the front. O(1).
    void pop_front() {
        if (head == nullptr) throw std::underflow_error("pop_front on empty list");
        Node* toDelete = head;
        head = head->next;
        if (head != nullptr) head->prev = nullptr;
        else tail = nullptr;            // list is now empty
        delete toDelete;
        sz--;
    }

    // Remove from the back. O(1) — this is the operation a SINGLY linked list
    // cannot do in O(1), because it has no `prev` pointer to reattach the new tail.
    void pop_back() {
        if (tail == nullptr) throw std::underflow_error("pop_back on empty list");
        Node* toDelete = tail;
        tail = tail->prev;
        if (tail != nullptr) tail->next = nullptr;
        else head = nullptr;
        delete toDelete;
        sz--;
    }

    // Search by value. O(n).
    bool contains(int value) const {
        Node* current = head;
        while (current != nullptr) {
            if (current->data == value) return true;
            current = current->next;
        }
        return false;
    }

    // Reverse the entire list in-place. O(n) time, O(1) extra space.
    // Classic interview question: swap prev/next for every node, then swap head/tail.
    void reverse() {
        Node* current = head;
        Node* temp = nullptr;
        while (current != nullptr) {
            temp = current->prev;
            current->prev = current->next;
            current->next = temp;
            current = current->prev;   // move to what was originally the next node
        }
        temp = head;
        head = tail;
        tail = temp;
    }

    size_t size() const { return sz; }
    bool empty() const { return sz == 0; }

    void print() const {
        std::cout << "[ ";
        Node* current = head;
        while (current != nullptr) {
            std::cout << current->data << " ";
            current = current->next;
        }
        std::cout << "] (size=" << sz << ")\n";
    }
};

// Example usage
int main() {
    DoublyLinkedList list;
    list.push_back(10);
    list.push_back(20);
    list.push_back(30);
    list.print();               // [ 10 20 30 ] (size=3)

    list.push_front(5);
    list.print();               // [ 5 10 20 30 ] (size=4)

    list.pop_back();
    list.print();               // [ 5 10 20 ] (size=3)

    list.reverse();
    list.print();               // [ 20 10 5 ] (size=3)

    std::cout << "Contains 10? " << (list.contains(10) ? "yes" : "no") << "\n";
    return 0;
}
```

---

## 10. Code Walkthrough

- **`Node` struct:** Nested inside the class since it's an implementation detail users of `DoublyLinkedList` never touch directly. Holds `data`, `prev`, and `next` — the three fields that define a doubly linked node.
- **`head` / `tail` pointers:** Maintaining both is what turns "insert/delete at tail" from O(n) into O(1) — the single biggest reason to choose doubly over singly linked.
- **`push_front` / `push_back`:** Both handle the empty-list case specially (`head == nullptr`), because with zero nodes there's no existing head/tail to link against — the new node becomes both.
- **`pop_front` / `pop_back`:** Notice the symmetry — `pop_front` moves `head` forward and nulls the new head's `prev`; `pop_back` moves `tail` backward and nulls the new tail's `next`. Getting this null-ing step wrong is what causes dangling pointers.
- **`reverse()`:** The trick is swapping `prev` and `next` for *every* node, then finally swapping `head` and `tail`. Beginners often forget the final head/tail swap, leaving the list logically reversed internally but with `head` still pointing at the old first node.
- **Destructor:** Must walk and `delete` every node individually — unlike an array's single `delete[]`, freeing a linked list requires touching every node because each is a separate heap allocation.

**Common mistakes to watch for here:**
- Forgetting to update `prev`/`next` on *both* neighboring nodes when inserting/deleting in the middle.
- Losing the reference to the next node before advancing (`current = current->next` too early, causing a memory leak when you meant to delete `current` first).
- Not handling the empty-list or single-node cases separately (these are the most common source of segfaults).

---

## 11. Dry Run

**Input:** `push_back(10)`, `push_back(20)`, `push_back(30)`, `push_front(5)`, `pop_back()`, `reverse()`

| Step | Operation | State | head | tail |
|---|---|---|---|---|
| 0 | init | `[]` | NULL | NULL |
| 1 | push_back(10) | `[10]` | 10 | 10 |
| 2 | push_back(20) | `[10,20]` | 10 | 20 |
| 3 | push_back(30) | `[10,20,30]` | 10 | 30 |
| 4 | push_front(5) | `[5,10,20,30]` | 5 | 30 |
| 5 | pop_back() | `[5,10,20]` | 5 | 20 |
| 6 | reverse() | `[20,10,5]` | 20 | 5 |

**Reverse, step by step on `[5,10,20]`:**
- Node 5: prev=NULL, next=10 → after swap: prev=10, next=NULL
- Node 10: prev=5, next=20 → after swap: prev=20, next=5
- Node 20: prev=10, next=NULL → after swap: prev=NULL, next=10
- Final swap: head (was 5) and tail (was 20) swap → head=20, tail=5
- Traversal from new head: 20 → 10 → 5 ✓

---

## 12. Interview Questions

**Conceptual:**
1. Why is deleting the tail O(1) in a doubly linked list but O(n) in a singly linked list?
2. Compare memory overhead: array vs singly linked list vs doubly linked list.
3. When would you choose a linked list over a dynamic array despite both being O(n) worst case for search?
4. Explain why linked lists have poor cache performance despite O(1) insert/delete.
5. What's a circular linked list used for, and how do you detect the "end" without a NULL terminator?

**Coding:**
1. Reverse a linked list (iterative and recursive).
2. Detect a cycle in a linked list (Floyd's Tortoise and Hare).
3. Find the middle node in one pass.
4. Merge two sorted linked lists.
5. Remove the nth node from the end (one-pass, two-pointer technique).
6. Detect and remove a cycle, finding its starting node.
7. Check if a linked list is a palindrome.

**Follow-ups / interviewer traps:**
- "Can you reverse it recursively? What's the space complexity then?" (recursion uses O(n) call stack, unlike O(1) iterative)
- "Can you find the middle without knowing the length first?" (expects slow/fast pointer technique)
- "What if the list is circular — does your cycle detection still terminate?" (tests understanding of Floyd's algorithm)

---

## 13. Practice Problems

**Easy**
- Reverse Linked List (LeetCode 206)
- Merge Two Sorted Lists (LeetCode 21)
- Linked List Cycle (LeetCode 141)
- Middle of the Linked List (LeetCode 876)

**Medium**
- Add Two Numbers (LeetCode 2)
- Remove Nth Node From End of List (LeetCode 19)
- Reorder List (LeetCode 143)
- Copy List with Random Pointer (LeetCode 138)
- Rotate List (LeetCode 61)

**Hard**
- Merge k Sorted Lists (LeetCode 23)
- Reverse Nodes in k-Group (LeetCode 25)
- LRU Cache (LeetCode 146) — previewed here, full chapter later

Also recommended: GeeksforGeeks "Linked List" practice set, HackerRank "Linked Lists" track, Codeforces problems tagged `data structures` involving list-like manipulation.

---

## 14. Common Mistakes

- **Losing the head pointer** by reassigning it before saving a reference to the rest of the list.
- **Not updating both `prev` and `next`** on neighboring nodes during middle insert/delete in a doubly linked list.
- **Memory leaks** — deleting a node without first saving a pointer to its `next`, then losing access to the rest of the list.
- **Dangling pointers** — using a node after it's been freed.
- **Off-by-one in traversal** when searching for the node *before* the target (needed for singly-linked deletion).
- **Forgetting the empty-list and single-node edge cases**, which behave differently from the general case (no "previous" node exists, head and tail coincide).
- **Assuming O(n) traversal performs like an array's O(n) traversal** — pointer-chasing across scattered memory is slower in practice due to cache misses.

---

## 15. Summary

**Key takeaways:**
- Linked lists trade random access for O(1) structural changes — exactly the opposite trade-off of arrays.
- Doubly linked lists exist specifically to make tail deletion and arbitrary-node deletion O(1), at the cost of extra memory per node.
- Many classic interview problems (cycle detection, reversal, merging) are really pointer-manipulation exercises — draw the pointers on paper before coding.

**Complexity recap:**

| | Access | Search | Insert (head) | Insert (tail) | Delete (head) | Delete (tail) |
|---|---|---|---|---|---|---|
| Singly Linked | O(n) | O(n) | O(1) | O(1)* | O(1) | O(n) |
| Doubly Linked | O(n) | O(n) | O(1) | O(1) | O(1) | O(1) |

*O(1) only if a tail pointer is maintained.

**Decision guideline:** Choose a linked list (over an array) when you need frequent insertion/deletion at both ends or in the middle (given a node reference), and you don't need random access by index. Choose doubly linked specifically when you need O(1) deletion of an arbitrary node or backward traversal (e.g., LRU caches, browser history, undo/redo).

---

*Next chapter: `03_stack_and_queue.md`*
