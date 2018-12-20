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

type
  JoyValue* = concept v
    v.isJoyValue()

  JoyField = tuple[qualifiedName: string]

const JoyQualifiedNameSep* = "¦"

macro joyFieldHelper[T: JoyValue](name: untyped, 
                                  dummyInScope: typed,
                                  tyDesc: typedesc[T]): untyped =
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
  let fieldConstructionNode = quote do: (`qualifiedName`,)
  result = quote:
    var
      `name`*: JoyField = `fieldConstructionNode`
  debugEcho "==== joyFieldHelper.result\n", result.repr

template field*[T: JoyValue](name: untyped, typ: typedesc[T]): untyped =
  let dummy = 0
  joyFieldHelper(name, dummy, typ)

macro field*(name: untyped, ty: untyped): untyped =
  error "Unsupported Joy value type: " & repr(ty)
