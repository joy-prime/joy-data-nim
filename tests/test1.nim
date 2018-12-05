# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import macros
import unittest
from joydata/submodule import foo

macro owningModule(sym: typed): untyped =
  $(owner(owner(sym))) & "." & $(owner(sym))

macro owningModule() : untyped =
  var
    sym: int
  owningModule(sym)

test "owningModule":
  echo owningModule()
