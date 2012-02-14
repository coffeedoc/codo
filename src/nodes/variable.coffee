# A CoffeeScript variable
#
module.exports = class Variable

  # Construct a variable
  #
  # @param [Object] node the node
  # @param [Boolean] clazz whether its a class variable or not
  #
  constructor: (@node, @clazz = false) ->
    @getName()

  # Get the variable type, either `class` or `constant`
  #
  # @return [String] the variable type
  #
  getType: ->
    unless @type
      @type = if @clazz then 'class' else 'instance'

    @type

  # Test if the given value should be treated ad constant.
  #
  # @return [Boolean] true if a constant
  #
  isConstant: ->
    unless @constant
      @constant = /[A-Z_-]/.test @getName()

    @constant

  # Get the variable description
  #
  # @return [String] the description
  #
  getDescription: ->

  # Get the variable name
  #
  # @return [String] the variable name
  #
  getName: ->
    unless @name
      @name = @node.variable.base.value

      for prop in @node.variable.properties
        @name += ".#{ prop.name.value }"

      if /^this\./.test @name
        @name = @name.substring(5)
        @type = 'class'

    @name

  # Get the variable value.
  #
  # @return [String] the value
  #
  getValue: ->
    unless @value
      @value = @node.value.base.compile({ indent: '' })

    @value

  # Get a JSON representation of the object
  #
  # @return [Object] the JSON object
  #
  toJSON: ->
    json =
      type: @getType()
      constant: @isConstant()
      name: @getName()
      value: @getValue()

    json
