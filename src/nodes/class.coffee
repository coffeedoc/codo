# A CoffeeScript class
#
module.exports = class Class

  # Construct a class
  #
  # @param [Object] node the node
  #
  constructor: (@node) ->

  # Get the class
  #
  # @return [String] the class
  #
  clazz: ->
    clazz = @node.variable.base.value

    for property in @node.variable.properties
      clazz += ".#{ property.name.value }"

    clazz

  # Get the class name
  #
  # @return [String] the name
  #
  name: ->
     @clazz().split('.').pop()

  # Get the class namespace
  #
  # @return [String] the namespace
  #
  namespace: ->
    namespace = @clazz().split('.')
    namespace.pop()

    namespace.join('.')

  # Get the class parent
  #
  # @return [String] the parent class
  #
  parentClazz: ->
    if @node.parent
      clazz = @node.parent.base.value

      for property in @node.parent.properties
        clazz += ".#{ property.name.value }"

      clazz

    else
      undefined

  # Get the direct subclasses
  #
  # @return [Array<Class>] the subclasses
  #
  subclasses: ->

  # Get all class methods.
  #
  # @return [Array<Method>] the methods
  #
  classMethods: ->

  # Get all instance methods.
  #
  # @return [Array<Method>] the methods
  #
  instanceMethods: ->

  # Get all class variables.
  #
  # @return [Array<Variable>] the variables
  #
  classVariables: ->

  # Get all constants (uppercase class variables).
  #
  # @return [Array<Variable>] the variables
  #
  constants: ->
