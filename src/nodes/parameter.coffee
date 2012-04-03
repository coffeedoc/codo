Node      = require './node'

# A CoffeeScript method parameter
#
module.exports = class Parameter extends Node

  # Construct a parameter
  #
  # @param [Object] node the node
  # @param [Object] options the parser options
  #
  constructor: (@node, @options) ->

  # Get the full parameter signature.
  #
  # @return [String] the signature
  #
  getSignature: ->
    try
      unless @signature
        @signature = @getName()

        if @isSplat()
          @signature += '...'

        value = @getDefault()
        @signature += " = #{ value.replace(/\n\s*/g, ' ') }" if value

      @signature

    catch error
      console.warn('Get parameter signature error:', @node, error) if @options.verbose

  # Get the parameter name
  #
  # @return [String] the name
  #
  getName: ->
    try
      unless @name

        # Normal attribute `do: (it) ->`
        @name = @node.name.value

        unless @name
          if @node.name.properties
            # Assigned attributes `do: (@it) ->`
            @name = @node.name.properties[0]?.name.value

      @name

    catch error
      console.warn('Get parameter name error:', @node, error) if @options.verbose

  # Get the parameter default value
  #
  # @return [String] the default
  #
  getDefault: ->
    try
      @node.value?.compile({ indent: '' })

    catch error
      if @node?.value?.base?.value is 'this'
        "@#{ @node.value.properties[0]?.name.compile({ indent: '' }) }"
      else
        console.warn('Get parameter default error:', @node, error) if @options.verbose

  # Tests if the parameters is a splat
  #
  # @return [Boolean] true if a splat
  #
  isSplat: ->
    try
      @node.splat is true

    catch error
      console.warn('Get parameter splat type error:', @node, error) if @options.verbose

  # Get a JSON representation of the object
  #
  # @return [Object] the JSON object
  #
  toJSON: ->
    json =
      name: @getName()
      default: @getDefault()
      splat: @isSplat()

    json
