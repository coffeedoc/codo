# A CoffeeScript method
#
module.exports = class Method

  # Construct a method
  #
  # @param [Object] node the node
  #
  constructor: (@node) ->

  # Get the method type, either `class` or `instance`
  #
  # @return [String] the method type
  #
  type: ->

  # Get the method description
  #
  # @return [String] the description
  #
  description: ->

  # Get the class signature.
  #
  # @return [String] the signature
  #
  signature: ->

  # Get the method return value.
  #
  # @return [String] the value
  #
  returns: ->

  # Get the method source in CoffeeScript
  #
  # @return [String] the CoffeeScript source
  #
  coffeeScriptSource: ->

  # Get the method source in JavaScript
  #
  # @return [String] the JavaScript source
  #
  javaScriptSource: ->
