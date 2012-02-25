_ = require 'underscore'

# Class reference resolver.
#
module.exports = class Referencer

  # Construct a referencer.
  #
  # @param [Array<Classes>] classes all known classes
  # @param [Object] options the parser options
  #
  constructor: (@classes, @options) ->

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
  # @see #getLink
  #
  # @param [String] text the text to parse.
  # @param [String] path the path prefix
  # @return [String] the processed text
  #
  linkTypes: (text, path) ->
    for clazz in @classes
      text = text.replace ///^(#{ clazz.getClassName() })$///g, "<a href='#{ path }classes/#{ clazz.getClassName().replace(/\./g, '/') }.html'>$1</a>"
      text = text.replace ///([< ])(#{ clazz.getClassName() })([>, ])///g, "$1<a href='#{ path }classes/#{ clazz.getClassName().replace(/\./g, '/') }.html'>$2</a>$3"

    text

  # Get the link to classname.
  #
  # @see #linkTypes
  # @param [String] classname the class name
  # @param [String] path the path prefix
  # @return [undefined, String] the link if any
  #
  getLink: (classname, path) ->
    for clazz in @classes
      if classname is clazz.getClassName() then return "#{ path }classes/#{ clazz.getClassName().replace(/\./g, '/') }.html"

    undefined

  # Get the link to a classes, methods and constants from a @see tag.
  #
  # @param [Object] data the json data
  # @param [Class] clazz the class context
  # @param [String] path the path to the asset root
  # @return [String] the href to the class/method
  #
  linkReference: (data, clazz, path) ->
    if data.doc?.see
      for see in data.doc.see
        ref = see.reference

        # Link to direct class methods
        if /^\./.test(ref)
          classMethods = _.map(_.filter(clazz.getMethods(), (m) -> m.getType() is 'class'), (m) -> m.getName())

          if _.include classMethods, ref.substring(1)
            see.reference = "#{ path }classes/#{ clazz.getClassName().replace(/\./g, '/') }.html##{ ref.substring(1) }-class"
            see.label = ref unless see.label
          else
            see.label = see.reference
            see.reference = undefined
            console.log "[WARN] Cannot resolve link to #{ ref } in class #{ clazz.getClassName() }" unless @options.quiet

        # Link to direct instance methods
        else if /^\#/.test(ref)
          instanceMethods = _.map(_.filter(clazz.getMethods(), (m) -> m.getType() is 'instance'), (m) -> m.getName())

          if _.include instanceMethods, ref.substring(1)
            see.reference = "#{ path }classes/#{ clazz.getClassName().replace(/\./g, '/') }.html##{ ref.substring(1) }-instance"
            see.label = ref unless see.label
          else
            see.label = see.reference
            see.reference = undefined
            console.log "[WARN] Cannot resolve link to #{ ref } in class #{ clazz.getClassName() }" unless @options.quiet

        # Link to other objects
        else
          # Ignore normal links
          unless /^https?:\/\//.test ref

            # Get class and method reference
            if match = /^(.*?)([.#][$a-z_\x7f-\uffff][$\w\x7f-\uffff]*)?$/.exec ref
              refClass = match[1]
              refMethod = match[2]
              otherClass = _.find @classes, (c) -> c.getClassName() is refClass

              if otherClass
                # Link to another class
                if _.isUndefined refMethod
                  if _.include(_.map(@classes, (c) -> c.getClassName()), refClass)
                    see.reference = "#{ path }classes/#{ refClass.replace(/\./g, '/') }.html"
                    see.label = ref unless see.label
                  else
                    see.label = see.reference
                    see.reference = undefined
                    console.log "[WARN] Cannot resolve link to class #{ refClass } in class #{ clazz.getClassName() }" unless @options.quiet

                # Link to other class class methods
                else if /^\./.test(refMethod)
                  classMethods = _.map(_.filter(otherClass.getMethods(), (m) -> m.getType() is 'class'), (m) -> m.getName())

                  if _.include classMethods, refMethod.substring(1)
                    see.reference = "#{ path }classes/#{ otherClass.getClassName().replace(/\./g, '/') }.html##{ refMethod.substring(1) }-class"
                    see.label = ref unless see.label
                  else
                    see.label = see.reference
                    see.reference = undefined
                    console.log "[WARN] Cannot resolve link to #{ refMethod } of class #{ otherClass.getClassName() } in class #{ clazz.getClassName() }" unless @options.quiet

                # Link to other class instance methods
                else if /^\#/.test(refMethod)
                  instanceMethods = _.map(_.filter(otherClass.getMethods(), (m) -> m.getType() is 'instance'), (m) -> m.getName())

                  if _.include instanceMethods, refMethod.substring(1)
                    see.reference = "#{ path }classes/#{ otherClass.getClassName().replace(/\./g, '/') }.html##{ refMethod.substring(1) }-instance"
                    see.label = ref unless see.label
                  else
                    see.label = see.reference
                    see.reference = undefined
                    console.log "[WARN] Cannot resolve link to #{ refMethod } of class #{ otherClass.getClassName() } in class #{ clazz.getClassName() }" unless @options.quiet

               else
                 see.label = see.reference
                 see.reference = undefined
                 console.log "[WARN] Cannot find referenced class #{ refClass } in class #{ clazz.getClassName() }" unless @options.quiet

            else
              see.label = see.reference
              see.reference = undefined
              console.log "[WARN] Cannot resolve link to #{ ref } in class #{ clazz.getClassName() }" unless @options.quiet
    data
