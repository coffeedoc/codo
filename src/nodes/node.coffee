# Base class for all nodes.
#
module.exports = class Node

  # Find an ancestor node by type.
  #
  # @param [String] type the class name
  # @param [Base] node the CoffeeScript node
  #
  findAncestor: (type, node = @node) ->
    if node.ancestor
      if node.ancestor.constructor.name is type
        node.ancestor
      else
        @findAncestor type, node.ancestor

    else
      undefined
