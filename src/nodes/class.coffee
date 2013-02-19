Node          = require './node'
Method        = require './method'
VirtualMethod = require './virtual_method'
Variable      = require './variable'
Property      = require './property'
Doc           = require './doc'
_             = require 'underscore'

# A CoffeeScript class
#
module.exports = class Class extends Node

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
      @properties = []

      @doc = new Doc(comment, @options)

      if @doc.methods
        @methods.push new VirtualMethod(@, method, @options) for method in @doc?.methods

      previousExp = null

      for exp in @node.body.expressions
        switch exp.constructor.name

          when 'Assign'
            doc = previousExp if previousExp?.constructor.name is 'Comment'
            doc or= swallowedDoc

            switch exp.value?.constructor.name
              when 'Code'
                @methods.push(new Method(@, exp, @options, doc)) if exp.variable.base.value is 'this'
              when 'Value'
                @variables.push new Variable(@, exp, @options, true, doc)

            doc = null

          when 'Value'
            previousProp = null

            for prop in exp.base.properties
              doc = previousProp if previousProp?.constructor.name is 'Comment'
              doc or= swallowedDoc

              switch prop.value?.constructor.name
                when 'Code'
                  @methods.push new Method(@, prop, @options, doc)
                when 'Value'
                  variable =  new Variable(@, prop, @options, false, doc)

                  if variable.doc?.property
                    property = new Property(@, prop, @options, variable.getName(), doc)
                    property.setter = true
                    property.getter = true
                    @properties.push property
                  else
                    @variables.push variable

              doc = null
              previousProp = prop

          when 'Call'
            doc = previousExp if previousExp?.constructor.name is 'Comment'
            doc or= swallowedDoc

            type = exp.variable?.base?.value
            name = exp.args?[0]?.base?.properties?[0]?.variable?.base?.value

            # This is a workaround for a strange CoffeeScript bug:
            # Given the following snippet:
            #
            # class Test
            #   # Doc a
            #   set name: ->
            #
            #   # Doc B
            #   set another: ->
            #
            # This will be converted to:
            #
            # class Test
            #   ###
            #   Doc A
            #   ###
            #   set name: ->
            #
            #   ###
            #   Doc B
            #   ###
            #   set another: ->
            #
            # BUT, Doc B is now a sibling property of the previous `set name: ->` setter!
            #
            swallowedDoc = exp.args?[0]?.base?.properties?[1]

            if name && (type is 'set' or type is 'get')
              property = _.find(@properties, (p) -> p.name is name)

              unless property
                property = new Property(@, exp, @options, name, doc)
                @properties.push property

              property.setter = true if type is 'set'
              property.getter = true if type is 'get'

              doc = null

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

  # Alias for {#getClassName}
  #
  # @return [String] the full class name
  #
  getFullName: ->
    @getClassName()

  # Get the full class name
  #
  # @return [String] the class
  #
  getClassName: ->
    try
      unless @className || !@node.variable
        @className = @node.variable.base.value

        # Inner class definition inherits
        # the namespace from the outer class
        if @className is 'this'
          outer = @findAncestor('Class')

          if outer
            @className = outer.variable.base.value
            for prop in outer.variable.properties
              @className += ".#{ prop.name.value }"

          else
            @className = ''

        for prop in @node.variable.properties
          if prop.name.value
            @className += '.' if @className.length > 0
            @className += prop.name.value

      @className

    catch error
      console.warn("Get class classname error at #{@fileName}:", @node, error) if @options.verbose

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
      console.warn("Get class name error at #{@fileName}:", @node, error) if @options.verbose

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
      console.warn("Get class namespace error at #{@fileName}:", @node, error) if @options.verbose

  # Get the full parent class name
  #
  # @return [String] the parent class name
  #
  getParentClassName: ->
    try
      unless @parentClassName
        if @node.parent
          @parentClassName = @node.parent.base.value

          # Inner class parent inherits
          # the namespace from the outer class parent
          if @parentClassName is 'this'
            outer = @findAncestor('Class')

            if outer
              @parentClassName = outer.parent.base.value
              for prop in outer.parent.properties
                @parentClassName += ".#{ prop.name.value }"

            else
              @parentClassName = ''

          for prop in @node.parent.properties
            @parentClassName += ".#{ prop.name.value }"

      @parentClassName

    catch error
      console.warn("Get class parent classname error at #{@fileName}:", @node, error) if @options.verbose

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
      properties: []

    for method in @getMethods()
      json.methods.push method.toJSON()

    for variable in @getVariables()
      json.variables.push variable.toJSON()

    for property in @properties
      json.properties.push property.toJSON()

    json
