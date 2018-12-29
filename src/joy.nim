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

proc nameQualifierFromVarNode(varNode: NimNode): string =
  result = ""
  var module = varNode.owner
  if module.symKind != nskModule:
    error "Joy fields must be declared at the top level of a module"
  else:
    while module.kind == nnkSym:
      result = $module & JoyQualifiedNameSep & result
      module = module.owner

proc fieldDeclImplementation(fieldDecl: NimNode,
                             nameQualifier: string): NimNode =
  expectKind(fieldDecl, nnkCall)

  let fieldName = fieldDecl[0]
  expectKind(fieldName, nnkIdent)

  let typeWrappedInStmtList = fieldDecl[1]
  expectKind(typeWrappedInStmtList, nnkStmtList)

  let typeExpr = typeWrappedInStmtList[0]

  result =
    nnkConstDef.newTree(
      nnkPostfix.newTree(
        newIdentNode("*"),
        newIdentNode(fieldName.repr)
      ),
      newEmptyNode(),
      nnkPar.newTree(
        nnkExprColonExpr.newTree(
          newIdentNode("qualifiedName"),
          newStrLitNode(nameQualifier & $fieldName)
        )
      )
    )

macro joyFieldHelper(dummy: typed, body: untyped): untyped =
  expectKind(dummy, nnkSym)
  expectKind(body, nnkStmtList)

  let nameQualifier = nameQualifierFromVarNode(dummy)

  result = newStmtList()
  let constSection = nnkConstSection.newTree()
  result.add(constSection)
  for fieldDecl in body:
    constSection.add(fieldDeclImplementation(fieldDecl, nameQualifier))

  debugEcho "==== joyFieldHelper.result\n", result.astGenRepr
  
template fields*(body: untyped): untyped =
  let dummy = 0
  joyFieldHelper(dummy, body)
