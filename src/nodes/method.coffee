Node      = require './node'
Parameter = require './parameter'
Doc       = require './doc'

_         = require 'underscore'
_.str     = require 'underscore.string'

# A CoffeeScript method
#
module.exports = class Method extends Node

  # Construct a method
  #
  # @param [Class] entity the methods class
  # @param [Object] node the node
  # @param [Object] options the parser options
  # @param [Object] comment the comment node
  #
  constructor: (@entity, @node, @options, comment) ->
    try
      @parameters = []

      @doc = new Doc(comment, @options)

      for param in @node.value.params
        @parameters.push new Parameter(param, @options)

      @getName()

    catch error
      console.warn('Create method error:', @node, error) if @options.verbose

  # Get the method type, either `class` or `instance`
  #
  # @return [String] the method type
  #
  getType: ->
    unless @type
      switch @entity.constructor.name
        when 'Class'
          @type = 'instance'
        when 'Mixin'
          @type = 'mixin'
        when 'File'
          @type = 'file'

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
          params.push param.getSignature()

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
        @name = @node.variable.base.value

        for prop in @node.variable.properties
          @name += ".#{ prop.name.value }"

        if /^this\./.test @name
          @name = @name.substring(5)
          @type = 'class'

        if /^module.exports\./.test @name
          @name = @name.substring(15)
          @type = 'class'

        if /^exports\./.test @name
          @name = @name.substring(8)
          @type = 'class'

        # Reserved names will result in a name like { '0': 'd', '1': 'e', '2': 'l', '3': 'e', '4': 't', '5': 'e' }
        if _.isObject(@name) && @name.reserved is true
          name = @name
          delete name.reserved
          @name = ''
          @name += c for p, c of name

      @name

    catch error
      console.warn('Get method name error:', @node, error) if @options.verbose

  # Get the method parameters
  #
  # @param [Array<Parameter>] the method parameters
  #
  getParameters: -> @parameters

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
      doc: @getDoc().toJSON()
      type: @getType()
      signature: @getSignature()
      name: @getName()
      bound: @node.value.bound
      parameters: []

    for parameter in @getParameters()
      json.parameters.push parameter.toJSON()

    json
