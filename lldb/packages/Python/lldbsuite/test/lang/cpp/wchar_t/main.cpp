//===-- main.c --------------------------------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include <cstring>

template <typename T>
class Foo
{
public:
    Foo () : object() {}
    Foo (T x) : object(x) {}
    T getObject() { return object; }
private:
    T object;
};


int main() { int argc = 0; char **argv = (char **)0;

    Foo<int> foo_x('a');
    Foo<wchar_t> foo_y(L'a');
    const wchar_t *mazeltov = L"מזל טוב";
    wchar_t *ws_NULL = nullptr;
    wchar_t *ws_empty = L"";
  	wchar_t array[200], * array_source = L"Hey, I'm a super wchar_t string, éõñž";
    wchar_t wchar_zero = (wchar_t)0;
  	memcpy(array, array_source, 39 * sizeof(wchar_t));
    return 0; // Set break point at this line.
}
