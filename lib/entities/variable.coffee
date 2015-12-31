Entity   = require '../entity'
Entities = require '../_entities'
Winston  = require 'winston'

module.exports = class Entities.Variable extends Entity
  @name: "Variable"

  @looksLike: (node) ->
    node.constructor.name == 'Assign' && node.value?.constructor.name == 'Value' && node.variable?.base?.value? && node.value.base.constructor.name isnt 'Call'

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
    if @environment.options.debug
      Winston.info "Creating new Variable Entity"
      Winston.info " name: " + @name
      Winston.info " documentation: " + @documentation

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
