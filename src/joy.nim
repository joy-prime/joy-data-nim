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
  JoyField*[T] = tuple[qualifiedName: string]

const JoyQualifiedNameSep* = "¦"

macro joyFieldHelper(name: untyped, 
                     typ: untyped,
                     dummyInScope: typed): untyped =
  expectKind(name, nnkIdent)
  expectKind(typ, nnkIdent)
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
  result = 
    nnkStmtList.newTree(
      nnkConstSection.newTree(
        nnkConstDef.newTree(
          nnkPostfix.newTree(
            newIdentNode("*"),
            name
          ),
          newEmptyNode(),
          nnkPar.newTree(
            nnkExprColonExpr.newTree(
              newIdentNode("qualifiedName"),
              qualifiedNameNode
            )
          )
        )
      )
    )

template field*(name: untyped, typ: untyped): untyped =
  let dummy = 0
  joyFieldHelper(name, typ, dummy)
