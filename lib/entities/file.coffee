Entity     = require '../entity'
Path       = require 'path'
Method     = require './method'
Variable   = require './variable'
Mixin      = require './mixin'
Class      = require './class'
MetaMethod = require '../meta/method'
Entities   = require '../_entities'
Winston    = require 'winston'

module.exports = class Entities.File extends Entity
  @Name: "File"

  constructor: (@environment, @path, @node) ->
    @file      = @
    @name      = Path.relative(@environment.options.basedir, @path)
    @basename  = Path.basename(@name)
    @dirname   = Path.dirname(@name)
    @methods   = []
    @variables = []
    @mixins    = []
    @classes   = []
    if @environment.options.debug
      Winston.info "Creating new File Entity"
      Winston.info " name: " + @name
      Winston.info " path: " + @path

  linkify: ->
    super

    for node in @node.expressions
      # Checking direct members
      unless entities = node.entities
        # And members prefixed with `module.exports =`
        if node.variable?.base?.value == 'module'
          if node.variable?.properties?[0]?.name?.value == 'exports'
            entities = node.value?.entities

      if entities
        for entity in entities
          if entity instanceof Method
            @methods.push(entity) if entity.name.length > 0
          if entity instanceof Variable
            @variables.push entity
          if entity instanceof Mixin
            @mixins.push entity
          if entity instanceof Class
            @classes.push entity

  effectiveMethods: ->
    @_effectiveMethods ||= @methods.map (method) -> MetaMethod.fromMethodEntity method

  inspect: ->
    {
      file:          @name
      methods:       @methods.map (x) -> x.inspect()
      variables:     @variables.map (x) -> x.inspect()
    }
