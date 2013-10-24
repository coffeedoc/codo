Method   = require './method'
Variable = require './variable'

module.exports = class File extends require('../entity')

  constructor: (@environment, @path, @node) ->
    @methods   = []
    @variables = []

  linkify: ->
    for node in @node.expressions

      if node.constructor.name == 'Assign' && node.entities?
        for entity in node.entities    
          if entity instanceof Method
            @methods.push entity

          if entity instanceof Variable 
            @variables.push entity

  toJSON: ->
    {
      file:          @path
      methods:       @methods
      variables:     @variables
    }
