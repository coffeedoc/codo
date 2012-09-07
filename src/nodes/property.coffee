Node = require './node'
Markdown = require '../util/markdown'

# A class property that is defined by custom property set/get methods.
#
# @example Define a class property
#   class Test
#
#    get = (props) => @::__defineGetter__ name, getter for name, getter of props
#    set = (props) => @::__defineSetter__ name, setter for name, setter of props
#
#    get name: -> @name
#    set name: (@name) ->
#
module.exports = class Property extends Node

  # Construct a new property
  #
  # @param [Class] entity the methods class
  # @param [Object] node the class node
  # @param [String] name the name of the property
  # @param [
  #
  constructor: (@entity, @node, @name, @doc) ->
    @setter  = false
    @getter  = false
    @comment = Markdown.convert(@doc?.comment, true)

  # Get a JSON representation of the object
  #
  # @return [Object] the JSON object
  #
  toJSON: ->
    {
      name: @name
      comment: @comment
      setter: @setter
      getter: @getter
    }
