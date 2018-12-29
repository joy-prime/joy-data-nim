import macros, unittest, options
import joy

static:
  debugEcho "==== AST gen for test_all fields:"
dumpAstGen:
  const
    name* = (qualifiedName: "joy¦test_all|name")
    age* = (qualifiedName: "joy¦test_all|age")

fields:
  name: string
  age: int

#types:
# dumpTree:
#   Something = data[]
#   Person = data[name]
#   PersonWithAge = data[age] of Person 

#[
test "construct data and read fields":
  let fred = Person(name: "Fred", age: 12)
  check:
      fred./name == "Fred"
      fred?/age = some(12)

  let jack = PersonWithAge(name: "Jack", age: 15)
  check:
      jack./name == "Jack"
      jack./age == 15

  let jill = Something(name: "Jill", age: 13)
  when compiles(jill./name == "Jill"):
      checkpoint("That shouldn't have compiled because name is not a defined field of jill")
      fail()
  
  check(jill.?name == some("Jill"),
        jill.?age == none(int))
]#