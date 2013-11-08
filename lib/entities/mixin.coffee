Method     = require './method'
Variable   = require './variable'
MetaMethod = require '../meta/method'
Entities   = require '../_entities'

module.exports = class Entities.Mixin extends require('../entity')

  @looksLike: (node) ->
    node.constructor.name == 'Assign' && node.value?.base?.properties?

  @is: (node) ->
    node.documentation?.mixin && super(node)

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
    @inclusions    = []
    @extensions    = []
    @concerns      = []

    for property in @node.value.base.properties
      # Recognize assigned code on the mixin
      @concern = true if @constructor.isConcernSection(property)

    if @concern
      @classMethods = []
      @instanceMethods = []

    name = @name.split('.')
    @basename  = name.pop()
    @namespace = name.join('.')

  linkify: ->
    super

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

  aggregateEffectiveMethods: (kind) ->
    methods   = []
    overrides = {}

    overrides.kind = kind if kind?

    for method in @methods
      methods.push(MetaMethod.fromMethodEntity method, overrides)

    if @documentation.methods
      for method in @documentation.methods
        methods.push(MetaMethod.fromDocumentationMethod method, overrides)

    methods

  effectiveMethods: ->
    return @effectiveConcernMethods() if @concern
    @_effectiveMethods ||= @aggregateEffectiveMethods()

  effectiveInclusionMethods: ->
    @_effectiveInclusionMethods ||= @aggregateEffectiveMethods('dynamic')

  effectiveExtensionMethods: ->
    @_effectiveExtensionMethods ||= @aggregateEffectiveMethods('static')

  effectiveConcernMethods: ->
    return @_effectiveConcernMethods if @_effectiveConcernMethods?

    @_effectiveConcernMethods = []

    for method in @classMethods
      @_effectiveConcernMethods.push(MetaMethod.fromMethodEntity method, kind: 'static')

    for method in @instanceMethods
      @_effectiveConcernMethods.push(MetaMethod.fromMethodEntity method, kind: 'dynamic')

    if @documentation.methods
      for method in @documentation.methods
        @_effectiveConcernMethods.push(MetaMethod.fromDocumentationMethod method)

    @_effectiveConcernMethods

  inspect: ->
    {
      file:            @file.path
      name:            @name
      concern:         @concern
      documentation:   @documentation?.inspect()
      selfish:         @selfish
      methods:         @methods.map (x) -> x.inspect()
      classMethods:    @classMethods?.map (x) -> x.inspect()
      instanceMethods: @instanceMethods?.map (x) -> x.inspect()
      variables:       @variables.map (x) -> x.inspect()
    }
