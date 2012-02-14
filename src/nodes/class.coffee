Method   = require './method'
Variable = require './variable'
Doc      = require './doc'

# A CoffeeScript class
#
module.exports = class Class

  # Construct a class
  #
  # @param [Object] node the class node
  # @param [Object] comment the comment node
  # @param [String] the filename
  #
  constructor: (@node, comment, @fileName) ->
    @methods = []
    @variables = []

    @doc = new Doc(comment)

    for exp in @node.body.expressions
      switch exp.constructor.name

        when 'Assign'
          @variables.push new Variable(exp, true)

        when 'Value'
          for prop in exp.base.properties
            switch prop.value.constructor.name
              when 'Code'
                @methods.push new Method(prop)
              when 'Value'
                @variables.push new Variable(prop)

  # Get the source file name.
  #
  # @return [String] the filename of the class
  #
  getFileName: -> @fileName

  # Get the class doc
  #
  # @return [Doc] the class doc
  #
  getDoc: -> @doc

  # Get the full class name
  #
  # @return [String] the class
  #
  getClassName: ->
    unless @className
      @className = @node.variable.base.value

      for prop in @node.variable.properties
        @className += ".#{ prop.name.value }"

    @className

  # Get the class name
  #
  # @return [String] the name
  #
  getName: ->
    unless @name
      @name = @getClassName().split('.').pop()

    @name

  # Get the class namespace
  #
  # @return [String] the namespace
  #
  getNamespace: ->
    unless @namespace
      @namespace = @getClassName().split('.')
      @namespace.pop()

      @namespace = @namespace.join('.')

    @namespace

  # Get the full parent class name
  #
  # @return [String] the parent class name
  #
  getParentClassName: ->
    unless @parentClassName
      if @node.parent
        @parentClassName = @node.parent.base.value

        for prop in @node.parent.properties
          @parentClassName += ".#{ prop.name.value }"

    @parentClassName

  # Get the direct subclasses
  #
  # @return [Array<Class>] the subclasses
  #
  getSubClasses: ->

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
      class:
        className: @getClassName()
        name: @getName()
        namespace: @getNamespace()
        parent: @getParentClassName()
      methods: []
      variables: []

    for method in @getMethods()
      json.methods.push method.toJSON()

    for variable in @getVariables()
      json.variables.push variable.toJSON()

    json
