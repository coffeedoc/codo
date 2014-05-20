Entities = require '../_entities'

#
# Supported formats:
#
#   foo: []
#
#   get foo: ->
#   set foo: (value) ->
#
#   @property 'foo'
#   @property 'foo', ->
#   @property 'foo',
#     get: ->
#     set: (value) ->
#
module.exports = class Entities.Property extends require('../entity')

  @looksLike: (node) ->
    (node.constructor.name == 'Assign' && node.value?.constructor.name == 'Value') ||
    (node.constructor.name == 'Call' && node.variable?.base?.value == 'this') ||
    (
      node.constructor.name == 'Call' &&
      node.args?[0]?.base?.properties?[0]?.variable?.base?.value &&
      (node.variable?.base?.value == 'set' || node.variable?.base?.value == 'get')
    )

  @is: (node) ->
    super(node) && (
      node.documentation?.property || 
      (node.constructor.name == 'Call' && node.variable?.base?.value != 'this')
    )

  constructor: (@environment, @file, @node) ->
    if @node.constructor.name == 'Call' && @node.variable?.base?.value != 'this'
      @name   = @node.args[0].base.properties[0].variable.base.value
      @setter = @node.variable.base.value == 'set'
      @getter = @node.variable.base.value == 'get'
    else if @node.constructor.name == 'Call' && @node.variable?.base?.value == 'this'
      @name = @node.args[0].base.value.replace(/["']/g, '')

      if @node.args.length > 1
        if @node.args[1].constructor.name == 'Value'
          # @property 'test', {set: ->, get: ->}
          @setter = false
          @getter = false
          for property in @node.args[1].base?.properties
            @setter = true if property.variable.base.value == 'set'
            @getter = true if property.variable.base.value == 'get'
        else
          # @property 'test', ->
          @setter = false
          @getter = true
      else
        # @property 'test'
        @setter = true
        @getter = true
    else
      [@name, @selfish] = @fetchVariableName()
      @setter = true
      @getter = true

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
