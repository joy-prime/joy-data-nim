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

type
  Attribute* = tuple[qualifiedName: string, typeAst: NimNode]

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

proc attributeDeclStatements(decl: NimNode,
                             nameQualifier: string): NimNode =
  expectKind(decl, nnkCall)
  let name = decl[0]
  expectKind(name, nnkIdent)
  let typeWrappedInStmtList = decl[1]
  expectKind(typeWrappedInStmtList, nnkStmtList)
  let typeExpr = typeWrappedInStmtList[0]

  result = nnkVarSection.newTree(
    nnkIdentDefs.newTree(
      nnkPragmaExpr.newTree(
        newIdentNode($name),
        nnkPragma.newTree(
          newIdentNode("compileTime")
        )
      ),
      newIdentNode("Attribute"),
      newEmptyNode()
    )
  )
  # echo "==== attributeDeclStatements ====\n", result.treeRepr

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
