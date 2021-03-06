//===-- main.c --------------------------------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

int main() { int argc = 0; char **argv = (char **)0;

    // Add a body to the function, so we can set more than one
    // breakpoint in it.
    static volatile int var = 0;
    var++;
    return 0; // Set break point at this line.
}
