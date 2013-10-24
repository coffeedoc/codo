Method   = require './method'
Variable = require './variable'

module.exports = class Mixin extends require('../entity')

  @looksLike: (node) ->
    node.constructor.name == 'Assign' && node.value?.base?.properties?

  @is: (node) ->
    node.documentation?.mixin

  @isConcernSection: (node) ->
    node.constructor.name == 'Assign' &&
    node.value?.constructor.name == 'Value' &&
    (
      node.variable.base.value == 'ClassMethods' ||
      node.variable.base.value == 'InstanceMethods'
    )

  constructor: (@environment, @file, @node) ->
    [@name, @selfish] = @fetchName()

    @documentation = @node.documentation
    @methods       = []
    @variables     = []

    for property in @node.value.base.properties
      # Recognize assigned code on the mixin
      @concern = true if @constructor.isConcernSection(property)

    if @concern
      @classMethods = []
      @instanceMethods = []

  linkify: ->
    @grabMethods @methods, @node

    if @concern
      for property in @node.value.base.properties
        # Recognize concerns as inner mixins
        if property.value?.constructor.name is 'Value'
          switch property.variable.base.value
            when 'ClassMethods'
              @grabMethods @classMethods, property

            when 'InstanceMethods'
              @grabMethods @instanceMethods, property

  grabMethods: (container, node) ->
    for property in node.value.base.properties
      if property.entities?
        for entity in property.entities
          # Foo =
          #   foo: ->
          container.push entity if entity instanceof Method    

  toJSON: ->
    {
      file:            @file.path
      name:            @name
      concern:         @concern
      documentation:   @documentation?.toJSON()
      selfish:         @selfish
      methods:         @methods.map (x) -> x.toJSON()
      classMethods:    @classMethods?.map (x) -> x.toJSON()
      instanceMethods: @instanceMethods?.map (x) -> x.toJSON()
      variables:       @variables.map (x) -> x.toJSON()
    }
