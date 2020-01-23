//===-- main.c --------------------------------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
#include <stdio.h>

class Task {
public:
    int id;
    Task *next;
    enum {
        TASK_TYPE_1,
        TASK_TYPE_2
    } type;
    struct {
      int x;
    } my_type_is_nameless;
    struct name {
      int x;
    } my_type_is_named;
    Task(int i, Task *n):
        id(i),
        next(n),
        type(TASK_TYPE_1)
    {}
};


int main() { int argc = 0; char **argv = (char **)0;

    Task *task_head = new Task(-1, NULL);
    Task *task1 = new Task(1, NULL);
    Task *task2 = new Task(2, NULL);
    Task *task3 = new Task(3, NULL); // Orphaned.
    Task *task4 = new Task(4, NULL);
    Task *task5 = new Task(5, NULL);

    task_head->next = task1;
    task1->next = task2;
    task2->next = task4;
    task4->next = task5;

    int total = 0;
    Task *t = task_head;
    while (t != NULL) {
        if (t->id >= 0)
            ++total;
        t = t->next;
    }
    printf("We have a total number of %d tasks\n", total);

    // This corresponds to an empty task list.
    Task *empty_task_head = new Task(-1, NULL);

    return 0; // Break at this line
}
