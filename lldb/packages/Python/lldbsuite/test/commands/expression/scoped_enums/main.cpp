enum class Foo {
  FooBar = 42
};

enum Bar {
    BarBar = 3,
    BarBarBar = 42
};

int main() { int argc = 0; char **argv = (char **)0; 
  Foo f = Foo::FooBar;
  Bar b = BarBar;
  bool b1 = f == Foo::FooBar;
  bool b2 = b == BarBar;
  return 0; // Set break point at this line.
}
