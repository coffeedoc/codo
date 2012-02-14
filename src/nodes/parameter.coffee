# A CoffeeScript method parameter
#
module.exports = class Parameter

  # Construct a parameter
  #
  # @param [Object] node the node
  #
  constructor: (@node) ->

  # Get the full parameter signature.
  #
  # @return [String] the signature
  #
  getSignature: ->
    unless @signature
      @signature = @getName()

      if @isSplat()
        @signature += '...'

      value = @getDefault()
      @signature += " = #{ value.replace(/\n\s*/g, ' ') }" if value

    @signature

  # Get the parameter name
  #
  # @return [String] the name
  #
  getName: -> @node.name.value

  # Get the parameter default value
  #
  # @return [String] the default
  #
  getDefault: -> @node.value?.compile({ indent: '' })

  # Tests if the parameters is a splat
  #
  # @return [Boolean] true if a splat
  #
  isSplat: -> @node.splat is true

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
