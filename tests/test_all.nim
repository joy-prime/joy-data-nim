import macros, unittest, options
import joy

type Age* = object
declareJoyFieldTypeAst(Age, int)

test "wip":
  declareFieldVar(age, Age)
  age = 42
  echo "age=", age
  doAssert(age == 42)

  #[
  declareFieldVar(name, Name)
  name = "Fred"
  echo "name=", name
  doAssert(name == "Fred")
  ]#

#[ Should have a nice compile error.
type Foo = object

declareFieldVar(foo, Foo) # Error: undeclared Joy field: Foo
]#

#[
attributes:
  name: string
  age: int
]#

# types:
#   dumpTree:
#     Something = data[]
#     Person = data[name]
#     PersonWithAge = data[age] of Person 

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