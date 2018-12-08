from joyprime import joy

joy:
  using
    firstName: string
    lastName: string
    age: int

  type
    ExportedNameAge* = map[firstName, lastName, submodule.age]
    PrivateNameAge = (map of RootObj)[firstName, age]
