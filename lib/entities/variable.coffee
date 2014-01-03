Entity   = require '../entity'
Entities = require '../_entities'

module.exports = class Entities.Variable extends Entity

  @looksLike: (node) ->
    node.constructor.name == 'Assign' && node.value?.constructor.name == 'Value' && node.variable?.base?.value?

  @is: (node) ->
    !node.documentation?.property && !node.documentation?.mixin && super(node)

  constructor: (@environment, @file, @node) ->
    [@name, @selfish] = @fetchName()

    @constant = /^[A-Z_-]*$/.test @name

    try
      @value = @node.value.base.compile
        indent: ''

      # Workaround to replace CoffeeScript internal
      # representations with something reasonable
      @value = 'undefined' if @value == 'void 0'

    @documentation = @node.documentation

  inspect: ->
    {
      file:          @file.path
      name:          @name
      constant:      @constant
      value:         @value
      documentation: @documentation?.inspect()
      selfish:       @selfish
      kind:          @kind
    }
