Path       = require 'path'
Method     = require './method'
Variable   = require './variable'
Mixin      = require './mixin'
Class      = require './class'
MetaMethod = require '../meta/method'
Entities   = require '../_entities'

module.exports = class Entities.File extends require('../entity')

  constructor: (@environment, @path, @node) ->
    @file      = @
    @name      = Path.relative(@environment.options.basedir, @path)
    @basename  = Path.basename(@name)
    @dirname   = Path.dirname(@name)
    @methods   = []
    @variables = []
    @mixins    = []
    @classes   = []

  linkify: ->
    super

    for node in @node.expressions

      if node.entities?
        for entity in node.entities
          if entity instanceof Method
            @methods.push entity
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
