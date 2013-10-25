Method     = require './method'
Variable   = require './variable'
Property   = require './property'
Mixin      = require './mixin'
MetaMethod = require '../meta/method'

module.exports = class Class extends require('../entity')

  @looksLike: (node) ->
    node.constructor.name is 'Class' && node.variable?.base?.value?

  constructor: (@environment, @file, @node) ->
    [@selfish, @container] = @determineContainment(@node.variable)

    @parent        = @fetchParent(@node.parent) if @node.parent
    @documentation = @node.documentation

    @name       = @fetchName(@node.variable, @selfish, @container)
    @methods    = []
    @variables  = []
    @properties = []
    @includes   = []
    @extends    = []
    @concerns   = []

    @

  # Determines if the class definition at given node is using @assignation
  # and if in such case this class is nested into another one
  determineContainment: (node) ->
    if node.base.value == 'this'
      selfish   = true                     # class @Foo
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
    name.push source.base.value unless selfish

    # Get the rest of actual assignation path
    name.push prop.name.value for prop in source.properties

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
        entity.type = 'static'
        @methods.push entity

      # class Foo
      #   @foo = 'test'
      if entity instanceof Variable 
        entity.type = 'static'
        @variables.push entity

  linkifyValue: (node) ->
    for property in node.base.properties when property.entities?
      for entity in property.entities
        # class Foo
        #   @foo: ->
        #   foo: ->
        if entity instanceof Method
          entity.type = if entity.selfish then 'static' else 'dynamic'
          @methods.push entity

        # class Foo
        #   foo: 'test'
        if entity instanceof Variable 
          entity.type = if entity.selfish then 'static' else 'dynamic'
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

  linkifyMixins: ->
    if @documentation?.includes?
      for entry in @documentation.includes
        @includes.push(@environment.find(Mixin, entry) || entry)

    if @documentation?.extends?
      for entry in @documentation.extends
        @extends.push(@environment.find(Mixin, entry) || entry)

    if @documentation?.concerns?
      for entry in @documentation.concerns
        @concerns.push(@environment.find(Mixin, entry) || entry)

  effectiveMethods: ->
    methods = []

    for method in @methods
      methods.push(MetaMethod.fromMethodEntity method)

    if @documentation.methods
      for method in @documentation.methods
        methods.push(MetaMethod.fromDocumentationMethod method)

    for inclusion in @includes
      methods = methods.concat inclusion.effectiveInclusionMethods()

    for extension in @extends
      methods = methods.concat extension.effectiveExtensionMethods()

    for concern in @concerns
      methods = methods.concat concern.effectiveConcernMethods()

    methods

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