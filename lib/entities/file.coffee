Method   = require './method'
Variable = require './variable'

module.exports = class File extends require('../entity')

  constructor: (@environment, @path, @node) ->
    @methods   = []
    @variables = []

  linkify: ->
    super

    for node in @node.expressions

      if node.constructor.name == 'Assign' && node.entities?
        for entity in node.entities    
          if entity instanceof Method
            @methods.push entity

          if entity instanceof Variable 
            @variables.push entity

  inspect: ->
    {
      file:          @path
      methods:       @methods.map (x) -> x.inspect()
      variables:     @variables.map (x) -> x.inspect()
    }
