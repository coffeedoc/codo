# A CoffeeScript variable
#
module.exports = class Variable

  # Construct a variable
  #
  # @param [Object] node the node
  #
  constructor: (@node) ->

  # Get the variable type, either `class` or `constant`
  #
  # @return [String] the variable type
  #
  type: ->

  # Get the variable description
  #
  # @return [String] the description
  #
  description: ->

  # Get the variable value.
  #
  # @return [String] the value
  #
  value: ->
