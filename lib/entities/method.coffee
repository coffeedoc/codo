Parameter = require '../meta/parameter'

module.exports = class Method extends require('../entity')

  @looksLike: (node) ->
    node.constructor.name == 'Assign' && node.value?.constructor.name == 'Code'

  constructor: (@environment, @file, @node) ->
    @name = [node.variable.base.value]
    @name.push prop.name.value for prop in @node.variable.properties

    if @name[0] == 'this'
      @selfish = true
      @name    = @name.slice(1)

    if @name[0] == 'module' && @name[1] == 'exports'
      @name = @name.slice(2)

    if @name[0] == 'exports'
      @name = @name.slice(1)

    @name = @name.join('.')

    @documentation = @node.documentation

    @parameters = @node.value.params.map (node) ->
      Parameter.fromNode(node)

  inspect: ->
    {
      file:          @file.path
      name:          @name
      documentation: @documentation?.inspect()
      selfish:       @selfish
      type:          @type
      parameters:    @parameters.map (x) -> x.inspect()
    }