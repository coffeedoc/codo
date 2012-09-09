Node      = require './node'
Doc      = require './doc'

# A CoffeeScript variable
#
module.exports = class Variable extends Node

  # Construct a variable
  #
  # @param [Class] entity the variables class
  # @param [Object] node the node
  # @param [Object] options the parser options
  # @param [Boolean] classType whether its a class variable or not
  # @param [Object] comment the comment node
  #
  constructor: (@entity, @node, @options, @classType = false, comment = null) ->
    try
      @doc = new Doc(comment, @options)
      @getName()

    catch error
      console.warn('Create variable error:', @node, error) if @options.verbose

  # Get the variable type, either `class` or `constant`
  #
  # @return [String] the variable type
  #
  getType: ->
    unless @type
      @type = if @classType then 'class' else 'instance'

    @type

  # Test if the given value should be treated ad constant.
  #
  # @return [Boolean] true if a constant
  #
  isConstant: ->
    unless @constant
      @constant = /^[A-Z_-]*$/.test @getName()

    @constant

  # Get the class doc
  #
  # @return [Doc] the class doc
  #
  getDoc: -> @doc

  # Get the variable name
  #
  # @return [String] the variable name
  #
  getName: ->
    try
      unless @name
        @name = @node.variable.base.value

        for prop in @node.variable.properties
          @name += ".#{ prop.name.value }"

        if /^this\./.test @name
          @name = @name.substring(5)
          @type = 'class'

      @name

    catch error
      console.warn('Get method name error:', @node, error) if @options.verbose

  # Get the variable value.
  #
  # @return [String] the value
  #
  getValue: ->
    try
      unless @value
        @value = @node.value.base.compile({ indent: '' })

      @value

    catch error
      console.warn('Get method value error:', @node, error) if @options.verbose

  # Get a JSON representation of the object
  #
  # @return [Object] the JSON object
  #
  toJSON: ->
    json =
      doc: @doc
      type: @getType()
      constant: @isConstant()
      name: @getName()
      value: @getValue()

    json
