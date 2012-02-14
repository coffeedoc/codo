# A CoffeeScript method
#
module.exports = class Method

  # Construct a method
  #
  # @param [Object] node the node
  # @param [Boolean] clazz whether its a class variable or not
  #
  constructor: (@node, @clazz = false) ->

  # Get the method type, either `class` or `instance`
  #
  # @return [String] the method type
  #
  getType: ->
    unless @type
      @type = if @clazz then 'class' else 'instance'

    @type

  # Get the method description
  #
  # @return [String] the description
  #
  getDescription: ->

  # Get the class signature.
  #
  # @return [String] the signature
  #
  getSignature: ->

  # Get the method name
  #
  # @return [String] the method name
  #
  getName: ->
    unless @name
      @name = @node.variable.base.value

    @name

  # Get the method return value.
  #
  # @return [String] the value
  #
  getReturn: ->

  # Get the method source in CoffeeScript
  #
  # @return [String] the CoffeeScript source
  #
  getCoffeeScriptSource: ->

  # Get the method source in JavaScript
  #
  # @return [String] the JavaScript source
  #
  getJavaScriptSource: ->

  # Get a JSON representation of the object
  #
  # @return [Object] the JSON object
  #
  toJSON: ->
    json =
      type: @getType()
      name: @getName()
    json
