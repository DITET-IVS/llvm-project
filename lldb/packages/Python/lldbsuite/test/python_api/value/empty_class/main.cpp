//===-- main.cpp ------------------------------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

class Empty {};

int main() { int argc = 0; char **argv = (char **)0; 
  Empty e;
  Empty* ep = new Empty;
  return 0; // Break at this line
}
