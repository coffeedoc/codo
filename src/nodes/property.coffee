Node      = require './node'
Doc       = require './doc'

_         = require 'underscore'
_.str     = require 'underscore.string'

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
  # @param [Object] options the parser options
  # @param [String] name the name of the property
  # @param [Object] comment the comment node
  #
  constructor: (@entity, @node, @options, @name, comment) ->
    @doc = new Doc(comment, @options)

    @setter  = false
    @getter  = false

  # Get the property signature.
  #
  # @return [String] the signature
  #
  getSignature: ->
    try
      unless @signature
        @signature = ''

        if @doc
          @signature += if @doc.property then "(#{ _.str.escapeHTML @doc.property }) " else "(?) "

        @signature += "<strong>#{ @name }</strong>"

      @signature

    catch error
      console.warn('Get property signature error:', @node, error) if @options.verbose

  # Get a JSON representation of the object
  #
  # @return [Object] the JSON object
  #
  toJSON: ->
    {
      name: @name
      signature: @getSignature()
      setter: @setter
      getter: @getter
      doc: @doc
    }
