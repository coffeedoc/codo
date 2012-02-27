Method   = require './method'
Variable = require './variable'
Doc      = require './doc'

# A CoffeeScript class
#
module.exports = class Class

  # Construct a class
  #
  # @param [Object] node the class node
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

      for exp in @node.body.expressions
        switch exp.constructor.name

          when 'Assign'
            doc = previousExp if previousExp?.constructor.name is 'Comment'

            switch exp.value?.constructor.name
              when 'Code'
                @methods.push new Method(@, exp, @options, doc)
              when 'Value'
                @variables.push new Variable(@, exp, @options, true, doc)

            doc = null

          when 'Value'
            previousProp = null

            for prop in exp.base.properties
              doc = previousProp if previousProp?.constructor.name is 'Comment'

              switch prop.value?.constructor.name
                when 'Code'
                  @methods.push new Method(@, prop, @options, doc)
                when 'Value'
                  @variables.push new Variable(@, prop, @options, doc)

              doc = null
              previousProp = prop
        previousExp = exp

    catch error
      console.warn('Create class error:', @node, error) if @options.verbose

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
    try
      unless @className
        @className = @node.variable.base.value

        for prop in @node.variable.properties
          @className += ".#{ prop.name.value }"

      @className

    catch error
      console.warn('Get class classname error:', @node, error) if @options.verbose

  # Get the class name
  #
  # @return [String] the name
  #
  getName: ->
    try
      unless @name
        @name = @getClassName().split('.').pop()

      @name

    catch error
      console.warn('Get class name error:', @node, error) if @options.verbose

  # Get the class namespace
  #
  # @return [String] the namespace
  #
  getNamespace: ->
    try
      unless @namespace
        @namespace = @getClassName().split('.')
        @namespace.pop()

        @namespace = @namespace.join('.')

      @namespace

    catch error
      console.warn('Get class namespace error:', @node, error) if @options.verbose

  # Get the full parent class name
  #
  # @return [String] the parent class name
  #
  getParentClassName: ->
    try
      unless @parentClassName
        if @node.parent
          @parentClassName = @node.parent.base.value

          for prop in @node.parent.properties
            @parentClassName += ".#{ prop.name.value }"

      @parentClassName

    catch error
      console.warn('Get class parent classname error:', @node, error) if @options.verbose

  # Get all methods.
  #
  # @return [Array<Method>] the methods
  #
  getMethods: ->
    if @options.private
      @methods
    else
      method for method in @methods when !method.doc.private

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
