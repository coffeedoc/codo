Node      = require './node'
Parameter = require './parameter'
Doc       = require './doc'

_         = require 'underscore'
_.str     = require 'underscore.string'

# A virtual method that has been declared by the `@method` tag.
#
module.exports = class VirtualMethod extends Node

  # Construct a virtual method
  #
  # @param [Class] entity the methods class
  # @param [Doc] doc the virtual doc
  # @param [Object] options the parser options
  #
  constructor: (@entity, @doc, @options) ->

  # Get the method type, either `class`, `instance` or `mixin`.
  #
  # @return [String] the method type
  #
  getType: ->
    unless @type
      if @doc.signature.substring(0, 1) is '#'
        @type = 'instance'
      else if @doc.signature.substring(0, 1) is '.'
        @type = 'class'
      else
        @type = 'mixin'

    @type

  # Get the class doc
  #
  # @return [Doc] the class doc
  #
  getDoc: -> @doc

  # Get the full method signature.
  #
  # @return [String] the signature
  #
  getSignature: ->
    try
      unless @signature
        @signature = switch @getType()
                     when 'class'
                       '+ '
                     when 'instance'
                       '- '
                     else
                       '? '

        if @getDoc()
          @signature += if @getDoc().returnValue then "(#{ _.str.escapeHTML @getDoc().returnValue.type }) " else "(void) "

        @signature += "<strong>#{ @getName() }</strong>"
        @signature += '('

        params = []

        for param in @getParameters()
          params.push param.name

        @signature += params.join(', ')
        @signature += ')'

      @signature

    catch error
      console.warn('Get method signature error:', @node, error) if @options.verbose

  # Get the short method signature.
  #
  # @return [String] the short signature
  #
  getShortSignature: ->
    try
      unless @shortSignature
        @shortSignature = switch @getType()
                          when 'class'
                            '.'
                          when 'instance'
                            '#'
                          else
                            ''
        @shortSignature += @getName()

      @shortSignature

    catch error
      console.warn('Get method short signature error:', @node, error) if @options.verbose

  # Get the method name
  #
  # @return [String] the method name
  #
  getName: ->
    try
      unless @name
        if name = /[.#]?([$A-Za-z_\x7f-\uffff][$\w\x7f-\uffff]*)/i.exec @doc.signature
          @name = name[1]
        else
          @name = 'unknown'

      @name

    catch error
      console.warn('Get method name error:', @node, error) if @options.verbose

  # Get the method parameters
  #
  # @param [Array<Parameter>] the method parameters
  #
  getParameters: -> @doc.params or []

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
      doc: @doc
      type: @getType()
      signature: @getSignature()
      name: @getName()
      bound: false
      parameters: []

    #for parameter in @getParameters()
    #  json.parameters.push parameter.toJSON()

    json
