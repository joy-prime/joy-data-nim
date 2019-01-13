#
#
#            Joy Prime in Nim
#        (c) Copyright 2018 Dean Thompson
#
#    See the file "LICENSE.txt", included in this
#    distribution, for details about the copyright.
#

## This module is designed to be imported in its entirety. Identifiers that
## will be pervasive in typical Joy' code are unadorned, but less common 
## identifiers have Joy in their names.

import macros
from typetraits import nil

const JoyQualifiedNameSep* = "¦"

proc nameQualifierFromVarNode(varNode: NimNode): string =
  result = ""
  var module = varNode.owner
  if module.symKind != nskModule:
    error "Joy Attributes must be declared at the top level of a module"
  else:
    while module.kind == nnkSym:
      result = $module & JoyQualifiedNameSep & result
      module = module.owner

type JoyFieldTypeClass[T] = object

template declareFieldVar*(name: untyped, Field: type): untyped =
  var name: joyFieldTypeAst(Field)

type Age* = object

type Name* = object

proc getTypeAst(ty: type): NimNode = getType(ty)[1]

macro joyFieldTypeAst*(Field: type): type = 
  error("undeclared Joy field: " & repr(getTypeAst(Field)))

template joyFieldTypeAst*(Field: type Age): type = int

template joyFieldTypeAst*(Field: type Name): type = string

#[
proc attributeDeclStatements(decl: NimNode,
                             nameQualifier: string): NimNode =
  expectKind(decl, nnkCall)
  let name = decl[0]
  expectKind(name, nnkIdent)
  let typeWrappedInStmtList = decl[1]
  expectKind(typeWrappedInStmtList, nnkStmtList)
  let typeExpr = typeWrappedInStmtList[0]

macro attributesHelper(dummy: typed, body: untyped): untyped =
  expectKind(dummy, nnkSym)
  expectKind(body, nnkStmtList)

  let nameQualifier = nameQualifierFromVarNode(dummy)

  result = nnkStmtList.newTree()
  for decl in body:
    result.add(attributeDeclStatements(decl, nameQualifier))

  # debugEcho "==== attributesHelper.result\n", result.astGenRepr
  
template attributes*(body: untyped): untyped =
  let dummy = 0
  attributesHelper(dummy, body)
]#

#[
macro defineAttribute(attr: static[var Attribute],
                      name, typ: untyped): untyped =
  attr = (qualifiedName: $name, typeAst: typ)
  newEmptyNode()

template attribute(name, typ: untyped): untyped =
  declareAttribute(name)
  defineAttribute(name, name, typ)

# macro data(tupleTypeName: untyped,
#              attr: static[Attribute]): typed =
#   let nameAst = newIdentNode(attr.name)
#   let typeAst = attr.typeAst
#   quote:
#     type `tupleTypeName` = tuple[`nameAst`: `typeAst`]
]#