Node     = require './node'
Method   = require './method'
Variable = require './variable'
Doc      = require './doc'

# A CoffeeScript mixins
#
module.exports = class Mixin extends Node

  # Construct a mixin
  #
  # @param [Object] node the mixin node
  # @param [String] the filename
  # @param [Object] options the parser options
  # @param [Object] comment the comment node
  #
  constructor: (@node, @fileName, @options, comment) ->
    try
      @methods = []
      @variables = []

      @doc = new Doc(comment, @options)

      previousExp = null

      for exp in @node.value.base.properties

        # Recognize assigned code on the mixin
        if exp.constructor.name is 'Assign'
          doc = previousExp if previousExp?.constructor.name is 'Comment'

          if exp.value?.constructor.name is 'Code'
            @methods.push new Method(@, exp, @options, doc)

          # Recognize concerns as inner mixins
          if exp.value?.constructor.name is 'Value'
            switch exp.variable.base.value
              when 'ClassMethods'
                @classMixin = new Mixin(exp, @filename, @options, doc)

              when 'InstanceMethods'
                @instanceMixin = new Mixin(exp, @filename, options, doc)

        doc = null
        previousExp = exp

      if @classMixin? && @instanceMixin?
        @concern = true

        for method in @classMixin.getMethods()
          method.type = 'class'
          @methods.push method

        for method in @instanceMixin.getMethods()
          method.type = 'instance'
          @methods.push method
      else
        @concern = false

    catch error
      console.warn('Create mixin error:', @node, error) if @options.verbose

  # Get the source file name.
  #
  # @return [String] the filename of the mixin
  #
  getFileName: -> @fileName

  # Get the mixin doc
  #
  # @return [Doc] the mixin doc
  #
  getDoc: -> @doc

  # Get the full mixin name
  #
  # @return [String] full mixin name
  #
  getMixinName: ->
    try
      unless @mixinName
        name = []
        name = [@node.variable.base.value] unless @node.variable.base.value == 'this'
        name.push p.name.value for p in @node.variable.properties
        @mixinName = name.join('.')

      @mixinName

    catch error
      console.warn('Get mixin full name error:', @node, error) if @options.verbose

  # Alias for {Mixin#getMixinName}
  #
  getFullName: ->
    @getMixinName()

  # Get the mixin name
  #
  # @return [String] the name
  #
  getName: ->
    try
      unless @name
        @name = @getMixinName().split('.').pop()

      @name

    catch error
      console.warn('Get mixin name error:', @node, error) if @options.verbose

  # Get the mixin namespace
  #
  # @return [String] the namespace
  #
  getNamespace: ->
    try
      unless @namespace
        @namespace = @getMixinName().split('.')
        @namespace.pop()

        @namespace = @namespace.join('.')

      @namespace

    catch error
      console.warn('Get mixin namespace error:', @node, error) if @options.verbose

  # Get all methods.
  #
  # @return [Array<Method>] the methods
  #
  getMethods: -> @methods

  # Get all variables.
  #
  # @return [Array<Variable>] the variables
  #
  getVariables: -> @variables

  # Get a JSON representation of the object
  #
  # @return [Object] the JSON object
  #
  toJSON: ->
    json =
      file: @getFileName()
      doc: @getDoc().toJSON()
      mixin:
        mixinName: @getMixinName()
        name: @getName()
        namespace: @getNamespace()
        concern: @concern
      methods: []
      variables: []

    for method in @getMethods()
      json.methods.push method.toJSON()

    for variable in @getVariables()
      json.variables.push variable.toJSON()

    json
