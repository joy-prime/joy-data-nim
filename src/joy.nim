import macros

proc isJoyValue(x: int): bool = true

type
  Value = concept v
    v.isJoyValue() is bool

macro field*[T: Value](name: untyped, ty: typedesc[T]): untyped =
  echo treeRepr(getType(ty))
  newEmptyNode()

macro field*(name: untyped, ty: untyped): untyped =
  error "Unsupported Joy value type: " & repr(ty)
