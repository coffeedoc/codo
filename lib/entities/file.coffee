Path       = require 'path'
Method     = require './method'
Variable   = require './variable'
Mixin      = require './mixin'
Class      = require './class'
MetaMethod = require '../meta/method'

module.exports = class File extends require('../entity')

  constructor: (@environment, @path, @node) ->
    @name      = @path
    @basename  = Path.basename(@path)
    @dirname   = Path.dirname(@path)
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
      file:          @path
      methods:       @methods.map (x) -> x.inspect()
      variables:     @variables.map (x) -> x.inspect()
    }
