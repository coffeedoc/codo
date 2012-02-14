Parameter = require './parameter'
Doc       = require './doc'

# A CoffeeScript method
#
module.exports = class Method

  # Construct a method
  #
  # @param [Object] node the node
  # @param [Object] comment the comment node
  #
  constructor: (@node, comment) ->
    @parameters = []

    @doc = new Doc(comment)

    for param in @node.value.params
      @parameters.push new Parameter(param)

    @getName()

  # Get the method type, either `class` or `instance`
  #
  # @return [String] the method type
  #
  getType: ->
    unless @type
      @type = if @clazz then 'class' else 'instance'

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
    unless @signature
      @signature = if @getType() is 'instance' then '- ' else '+ '

      if @getDoc()
        @signature += if @getDoc().returnValue then "(#{ @getDoc().returnValue.type }) " else "(void) "

      @signature += @getName()
      @signature += '('

      params = []

      for param in @getParamaters()
        params.push param.getSignature()

      @signature += params.join(', ')
      @signature += ')'

      if @getDoc()
        @signature += if @getDoc().private then ' (private)' else ''

    @signature

  # Get the method name
  #
  # @return [String] the method name
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

  # Get the method parameters
  #
  # @param [Array<Parameter>] the method parameters
  #
  getParamaters: -> @parameters

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
      parameters: []

    for parameter in @getParamaters()
      json.parameters.push parameter.toJSON()

    json
