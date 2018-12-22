import macros, unittest, options
import joy

dump:
  name: string
  age: int
  parents: array[0..1, Option[string]]

const name* = (qualifiedName: "joy¦test_all¦name")
field(age, int)

data(Person, name)
data(PersonWithAge, name, age)
data(Something)

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
