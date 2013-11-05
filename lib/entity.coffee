# Base class for all entities.
#
module.exports = class Entity

  @is: (node) ->
    !node.documentation?.nodoc

  linkify: ->

  fetchName: ->
    name = [@node.variable.base.value]
    name.push prop.name.value for prop in @node.variable.properties when prop.name?

    if name[0] == 'this'
      selfish = true
      name    = name.slice(1)

    [name.join('.'), selfish]

  lookup: (Entity, node) ->
    if node.ancestor
      if node.ancestor.entities?
        for entity in node.ancestor.entities
          return entity if entity instanceof Entity

      @lookup Entity, node.ancestor