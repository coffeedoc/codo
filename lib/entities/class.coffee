Method     = require './method'
Variable   = require './variable'
Property   = require './property'
Mixin      = require './mixin'
MetaMethod = require '../meta/method'
Entities   = require '../_entities'

module.exports = class Entities.Class extends require('../entity')

  @looksLike: (node) ->
    node.constructor.name is 'Class' && node.variable?.base?.value?

  constructor: (@environment, @file, @node) ->
    [@selfish, @container] = @determineContainment(@node.variable)

    @parent        = @fetchParent(@node.parent) if @node.parent
    @documentation = @node.documentation

    @name        = @fetchName(@node.variable, @selfish, @container)
    @methods     = []
    @variables   = []
    @properties  = []
    @includes    = []
    @extends     = []
    @concerns    = []
    @descendants = []

    name = @name.split('.')
    @basename  = name.pop()
    @namespace = name.join('.')

    @

  # Determines if the class definition at given node is using @assignation
  # and if in such case this class is nested into another one
  determineContainment: (node) ->
    if node.base?.value == 'this'
      selfish   = true                   # class @Foo
      container = @lookup(Class, node)   # class Foo \n class @Bar

    [selfish, container]

  fetchParent: (source) ->
    [selfish, container] = @determineContainment(source)
    @fetchName(source, selfish, container)

  fetchName: (source, selfish, container) ->
    name = []

    # Nested class definition inherits 
    # the namespace from the containing class
    name.push container.name if container

    # Take the actual name of assignation unless
    # we are prefixed with `@`
    name.push source.base.value if !selfish && source.base?

    # Get the rest of actual assignation path
    if source.properties
      name.push prop.name.value for prop in source.properties when prop.name?

    # Here comes the magic!
    name.join('.')

  linkify: ->
    super

    for node in @node.body.expressions

      if node.constructor.name == 'Assign' && node.entities?
        @linkifyAssign(node)

      if node.constructor.name == 'Value'
        @linkifyValue(node)

      if node.constructor.name == 'Call' && node.entities?
        @linkifyCall(node)

    @linkifyParent()
    @linkifyMixins()

  linkifyAssign: (node) ->
    for entity in node.entities when entity.selfish
      # class Foo
      #   @foo = ->            
      if entity instanceof Method
        entity.kind = 'static'
        @methods.push entity

      # class Foo
      #   @foo = 'test'
      if entity instanceof Variable 
        entity.kind = 'static'
        @variables.push entity

  linkifyValue: (node) ->
    for property in node.base.properties when property.entities?
      for entity in property.entities
        # class Foo
        #   @foo: ->
        #   foo: ->
        if entity instanceof Method
          entity.kind = if entity.selfish then 'static' else 'dynamic'
          @methods.push entity

        # class Foo
        #   foo: 'test'
        if entity instanceof Variable 
          entity.kind = if entity.selfish then 'static' else 'dynamic'
          @variables.push entity

        if entity instanceof Property
          @properties.push entity

  linkifyCall: (node) ->
    for entity in node.entities
      if entity instanceof Property
        found = false

        for property in @properties
          if property.name == entity.name
            entity.unite(property)
            found = true

        @properties.push(entity) unless found

  linkifyParent: ->
    if @parent
      @parent = @environment.find(Class, @parent) || @parent
      @parent.descendants?.push(@)

  linkifyMixins: ->
    if @documentation?.includes?
      for entry in @documentation.includes
        mixin = @environment.find(Mixin, entry) || entry
        @includes.push(mixin)
        mixin.inclusions?.push(@)

    if @documentation?.extends?
      for entry in @documentation.extends
        mixin = @environment.find(Mixin, entry) || entry
        @extends.push(mixin)
        mixin.extensions?.push(@)

    if @documentation?.concerns?
      for entry in @documentation.concerns
        mixin = @environment.find(Mixin, entry) || entry
        @concerns.push(mixin)
        mixin.concerns?.push(@)

  effectiveMethods: ->
    return @_effectiveMethods if @_effectiveMethods?

    @_effectiveMethods = []

    for method in @methods
      @_effectiveMethods.push(MetaMethod.fromMethodEntity method)

    if @documentation?.methods
      for method in @documentation.methods
        @_effectiveMethods.push(MetaMethod.fromDocumentationMethod method)

    @_effectiveMethods

  allMethods: ->
    methods = @effectiveMethods().map (method) =>
      {
        entity: method
        owner: @
      }

    resolvers =
      includes: 'effectiveInclusionMethods'
      extends: 'effectiveExtensionMethods'
      concerns: 'effectiveConcernMethods'

    for storage, resolver of resolvers
      for mixin in @[storage]
        for method in mixin[resolver]()
          methods.push
            entity: method
            owner: mixin

    methods

  inherited: (getter) ->
    return [] if !@parent || !@parent.name?

    found   = {}
    entries = getter()

    entries.filter (entry) ->
      found[entry.entity.name] = true unless found[entry.entity.name]

  inheritedMethods: ->
    @_inheritedMethods ||= @inherited =>
      @parent.allMethods().concat @parent.inheritedMethods()

  inheritedVariables: ->
    @_inheritedVariables ||= @inherited =>
      variables = @parent.variables.map (variable) =>
        {
          entity: variable
          owner: @parent
        }

      variables.concat @parent.inheritedVariables()

  inheritedProperties: ->
    @_inheritedProperties ||= @inherited =>
      properties = @parent.properties.map (property) =>
        {
          entity: property
          owner: @parent
        }

      properties.concat @parent.inheritedProperties()

  inspect: ->
    {
      file:          @file.path
      documentation: @documentation?.inspect()
      selfish:       @selfish
      name:          @name
      container:     @container?.inspect()
      parent:        @parent?.inspect?() || @parent
      methods:       @methods.map (x) -> x.inspect()
      variables:     @variables.map (x) -> x.inspect()
      properties:    @properties.map (x) -> x.inspect()
      includes:      @includes.map (x) -> x.inspect?() || x
      extends:       @extends.map (x) -> x.inspect?() || x
      concerns:      @concerns.map (x) -> x.inspect?() || x
    }