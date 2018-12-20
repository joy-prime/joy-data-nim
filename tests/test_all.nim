import macros
import unittest
from joy import nil

joy.field(foo, int)

# joy.field(bar, string)

test "foo":
  echo "We win!"
