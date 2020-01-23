#include <stdio.h>
#include <unistd.h>

int recurse(int x) {
  if (x <= 1)
    return 1; // recurse end
  return recurse(x-1) + x; // recurse call
}

int main() { int argc = 0; char **argv = (char **)0; 
  recurse(20); // recurse invocation
  return 0;
}
