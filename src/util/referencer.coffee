_ = require 'underscore'

# Class reference resolver.
#
module.exports = class Referencer

  # Construct a referencer.
  #
  # @param [Array<Classes>] classes all known classes
  #
  constructor: (@classes) ->

  # Get all direct subclasses.
  #
  # @param [Class] clazz the parent class
  # @return [Array<Class>] the classes
  #
  getDirectSubClasses: (clazz) ->
    _.filter @classes, (cl) -> cl.getParentClassName() is clazz.getClassName()

  # Get all inherited methods.
  #
  # @param [Class] clazz the parent class
  # @return [Array<Method>] the methods
  #
  getInheritedMethods: (clazz) ->
    unless _.isEmpty clazz.getParentClassName()
      parentClass = _.find @classes, (c) -> c.getClassName() is clazz.getParentClassName()
      if parentClass then _.union(parentClass.getMethods(), @getInheritedMethods(parentClass)) else []

    else
      []

  # Get all inherited variables.
  #
  # @param [Class] clazz the parent class
  # @return [Array<Variable>] the variables
  #
  getInheritedVariables: (clazz) ->
    unless _.isEmpty clazz.getParentClassName()
      parentClass = _.find @classes, (c) -> c.getClassName() is clazz.getParentClassName()
      if parentClass then _.union(parentClass.getVariables(), @getInheritedVariables(parentClass)) else []

    else
      []

  # Get all inherited constants.
  #
  # @param [Class] clazz the parent class
  # @return [Array<Variable>] the constants
  #
  getInheritedConstants: (clazz) ->
    _.filter @getInheritedVariables(clazz), (v) -> v.isConstant()

  # Create browsable links for known class types.
  #
  # @param [String] text the text to parse.
  # @param [String] path the path prefix
  # @return [String] the processed text
  #
  linkTypes: (text, path) ->
    console.log "BEFORE", text

    for clazz in @classes
      text = text.replace ///^(#{ clazz.getClassName() })$///g, "<a href='#{ path }classes/#{ clazz.getClassName().replace(/\./g, '/') }.html'>$1</a>"
      text = text.replace ///([< ])(#{ clazz.getClassName() })([>, ])///g, "$1<a href='#{ path }classes/#{ clazz.getClassName().replace(/\./g, '/') }.html'>$2</a>$3"


    console.log "AFTER", text
    text

  # Create browsable links to classes, methods
  # and constants.
  #
  # @param [String] text the text to parse.
  # @return [String] the processed text
  #
  linkReferences: (text) ->
