#include "b.h"

int main() { int argc = 0; char **argv = (char **)0;

    Module m;
    // Test that the type Module which contains a field that is a
    // template instantiation can be fully resolved.
    return 0; //% self.assertTrue(self.frame().FindVariable('m').GetChildAtIndex(0).GetChildAtIndex(0).GetChildAtIndex(0).GetName() == 'buffer', 'find template specializations in imported modules')
}
