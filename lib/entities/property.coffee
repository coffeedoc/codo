Entities = require '../_entities'

module.exports = class Entities.Property extends require('../entity')

  @looksLike: (node) ->
    (node.constructor.name == 'Assign' && node.value?.constructor.name == 'Value') ||
    (
      node.constructor.name == 'Call' &&
      node.args?[0]?.base?.properties?[0]?.variable?.base?.value &&
      (node.variable?.base?.value == 'set' || node.variable?.base?.value == 'get')
    )

  @is: (node) ->
    (node.constructor.name == 'Call' || node.documentation?.property) && super(node)

  constructor: (@environment, @file, @node) ->
    if @node.constructor.name != 'Call'
      [@name, @selfish] = @fetchVariableName()
      @setter = true
      @getter = true
    else
      @name   = @node.args[0].base.properties[0].variable.base.value
      @setter = @node.variable.base.value == 'set'
      @getter = @node.variable.base.value == 'get'

    @documentation = @node.documentation

  fetchVariableName: ->
    @fetchName()

  unite: (property) ->
    for attribute in ['documentation', 'getter', 'setter']
      property[attribute] = @[attribute] = property[attribute] || @[attribute]

  inspect: ->
    {
      file:          @file.path
      name:          @name
      getter:        @getter
      setter:        @setter
      documentation: @documentation?.inspect()
    }
