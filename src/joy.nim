#
#
#            Joy Prime in Nim
#        (c) Copyright 2016 Andreas Rumpf
#
#    See the file "copying.txt", included in this
#    distribution, for details about the copyright.
#

## This module is designed to be imported in its entirety. Identifiers that
## will be pervasive in typical Joy' code are unadorned, but less common 
## identifiers have Joy in their names.

import macros

proc isJoyValue(x: int): void = discard
proc isJoyValue(x: string): void = discard

type
  JoyValue* = concept v
    v.isJoyValue()

  JoyField[T] = tuple[qualifiedName: string, dummyValue: T]

const JoyQualifiedNameSep* = "¦"

proc joyValueDefault*[T](): T =
  result

macro joyFieldHelper[T: JoyValue](name: untyped, 
                                  typ: type[T],
                                  dummyInScope: typed): untyped =
  expectKind(name, nnkIdent)
  expectKind(dummyInScope, nnkSym)

  var qualifiedName = name.repr
  var module = dummyInScope.owner
  if module.symKind != nskModule:
    error "Joy fields must be declared at the top level of a module"
  else:
    while module.kind == nnkSym:
      qualifiedName = module.repr & JoyQualifiedNameSep & qualifiedName
      module = module.owner
  let qualifiedNameNode = newStrLitNode(qualifiedName)
  let typeNode = getTypeInst(typ)[1]
  let fieldConstructionNode = quote:
    (qualifiedName: `qualifiedName`,
     dummyValue: joyValueDefault[`typeNode`]())
  result = quote:
    const `name`*: JoyField[`typeNode`] = `fieldConstructionNode`
  debugEcho "==== joyFieldHelper.result\n", result.repr

template field*[T: JoyValue](name: untyped, typ: type[T]): untyped =
  let dummy = 0
  joyFieldHelper(name, typ, dummy)

macro field*(name: untyped, typ: untyped): untyped =
  error "Unsupported Joy value type: " & repr(typ)
