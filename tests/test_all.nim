import macros
import unittest
import joy

#field(name, string)
dumpTree:
  const 
    age2* = JoyField[int](qualifiedName: "joy¦test_all¦age", 
                          dummyValue: joyValueDefault[int]())

field(age, int)

#data(Person, name, age)

test "construct a data value and read fields":
  #let fred = make(Person, name = "Fred", age = 12)
  dumpTree:
    assertEquals(fred./age, 12)
