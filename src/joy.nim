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

type
  JoyField*[T] = object
    qualifiedName*: string
    dummyValue*: T

const JoyQualifiedNameSep* = "¦"

proc joyValueDefault*[T](): T =
  result

macro joyFieldHelper[T](name: untyped, 
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
  result = quote:
    const `name`* = 
      JoyField[`typeNode`](qualifiedName: `qualifiedName`,
                           dummyValue: joyValueDefault[`typeNode`]())
  debugEcho "==== joyFieldHelper.result\n", result.treeRepr

template field*[T](name: untyped, typ: type[T]): untyped =
  let dummy = 0
  joyFieldHelper(name, typ, dummy)

macro field*(name: untyped, typ: untyped): untyped =
  error "Unsupported Joy value type: " & repr(typ)
