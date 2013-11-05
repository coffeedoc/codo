Parameter = require '../meta/parameter'
Entities  = require '../_entities'

module.exports = class Entities.Method extends require('../entity')

  @looksLike: (node) ->
    node.constructor.name == 'Assign' && node.value?.constructor.name == 'Code'

  constructor: (@environment, @file, @node) ->
    @name = [node.variable.base.value]
    @name.push prop.name.value for prop in @node.variable.properties when prop.name?

    if @name[0] == 'this'
      @selfish = true
      @name    = @name.slice(1)

    if @name[0] == 'module' && @name[1] == 'exports'
      @name = @name.slice(2)

    if @name[0] == 'exports'
      @name = @name.slice(1)

    @name  = @name.join('.')
    @bound = @node.value.bound

    @documentation = @node.documentation

    @parameters = @node.value.params.map (node) ->
      Parameter.fromNode(node)

  inspect: ->
    {
      file:          @file.path
      name:          @name
      bound:         @bound
      documentation: @documentation?.inspect()
      selfish:       @selfish
      kind:          @kind
      parameters:    @parameters.map (x) -> x.inspect()
    }