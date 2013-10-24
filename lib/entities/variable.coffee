Entity = require '../entity'

module.exports = class Variable extends Entity

  @looksLike: (node) ->
    node.constructor.name == 'Assign' && node.value?.constructor.name == 'Value'

  @is: (node) ->
    !node.documentation?.property && !node.documentation?.mixin

  constructor: (@environment, @file, @node) ->
    [@name, @selfish] = @fetchName()

    @constant = /^[A-Z_-]*$/.test @name
    @value    = @node.value.base.compile
      indent: ''

    @documentation = @node.documentation

  inspect: ->
    {
      file:          @file.path
      name:          @name
      constant:      @constant
      value:         @value
      documentation: @documentation?.inspect()
      selfish:       @selfish
      type:          @type
    }
