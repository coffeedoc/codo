_ = require 'underscore'

# Class reference resolver.
#
module.exports = class Referencer

  # Construct a referencer.
  #
  # @param [Array<Classes>] classes all known classes
  # @param [Object] options the parser options
  #
  constructor: (@classes, @modules, @options) ->

  # Get all direct subclasses.
  #
  # @param [Class] clazz the parent class
  # @return [Array<Class>] the classes
  #
  getDirectSubClasses: (clazz) ->
    _.filter @classes, (cl) -> cl.getParentClassName() is clazz.getFullName()

  # Get all inherited methods.
  #
  # @param [Class] clazz the parent class
  # @return [Array<Method>] the methods
  #
  getInheritedMethods: (clazz) ->
    unless _.isEmpty clazz.getParentClassName()
      parentClass = _.find @classes, (c) -> c.getFullName() is clazz.getParentClassName()
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
      parentClass = _.find @classes, (c) -> c.getFullName() is clazz.getParentClassName()
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

  # Create browsable links for known entities.
  #
  # @see #getLink
  #
  # @param [String] text the text to parse.
  # @param [String] path the path prefix
  # @return [String] the processed text
  #
  linkTypes: (text, path) ->
    for clazz in @classes
      text = text.replace ///^(#{ clazz.getFullName() })$///g, "<a href='#{ path }classes/#{ clazz.getFullName().replace(/\./g, '/') }.html'>$1</a>"
      text = text.replace ///([< ])(#{ clazz.getFullName() })([>, ])///g, "$1<a href='#{ path }classes/#{ clazz.getFullName().replace(/\./g, '/') }.html'>$2</a>$3"

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
      if classname is clazz.getFullName() then return "#{ path }classes/#{ clazz.getFullName().replace(/\./g, '/') }.html"

    undefined

  # Resolve all @see tags on class and method json output.
  #
  # @param [Object] data the json data
  # @param [Class] entity the entity context
  # @param [String] path the path to the asset root
  # @return [Object] the json data with resolved references
  #
  resolveDoc: (data, entity, path) ->
    if data.doc
      if data.doc.see
        for see in data.doc.see
          @resolveSee see, entity, path

      if _.isString data.doc.abstract
        data.doc.abstract = @resolveTextReferences(data.doc.abstract, entity, path)

      for name, options of data.doc.options
        for option, index in options
          data.doc.options[name][index].desc = @resolveTextReferences(option.desc, entity, path)

      for name, param of data.doc.params
        data.doc.params[name].desc = @resolveTextReferences(param.desc, entity, path)

      if data.doc.notes
        for note, index in data.doc.notes
          data.doc.notes[index] = @resolveTextReferences(note, entity, path)

      if data.doc.todos
        for todo, index in data.doc.todos
          data.doc.todos[index] = @resolveTextReferences(todo, entity, path)

      if data.doc.examples
        for example, index in data.doc.examples
          data.doc.examples[index].title = @resolveTextReferences(example.title, entity, path)

      if _.isString data.doc.deprecated
        data.doc.deprecated = @resolveTextReferences(data.doc.deprecated, entity, path)

      if data.doc.comment
        data.doc.comment = @resolveTextReferences(data.doc.comment, entity, path)

      if data.doc.returnValue?.desc
        data.doc.returnValue.desc = @resolveTextReferences(data.doc.returnValue.desc, entity, path)

    data

  # Search a text to find see links wrapped in curly braces.
  #
  # @example Reference an object
  #   "To get a list of all customers, go to {Customers.getAll}"
  #
  # @param [String] the text to search
  # @return [String] the text with hyperlinks
  #
  resolveTextReferences: (text, entity, path) ->
    text.replace /\{([^\}]*)\}/gm, (match) =>
      reference = arguments[1].split()
      see = @resolveSee({ reference: reference[0], label: reference[1] }, entity, path)

      if see.reference
        "<a href='#{ see.reference }'>#{ see.label }</a>"
      else
        match

  # Resolves a @see link.
  #
  # @param [Object] see the see object
  # @param [Class] entity the entity context
  # @param [String] path the path to the asset root
  # @return [Object] the resolved see
  #
  resolveSee: (see, entity, path) ->
    # If a reference starts with a space like `{ a: 1 }`, then it's not a valid reference
    return see if see.reference.substring(0, 1) is ' '

    ref = see.reference

    # Link to direct class methods
    if /^\./.test(ref)
      methods = _.map(_.filter(entity.getMethods(), (m) -> m.getType() is 'class'), (m) -> m.getName())

      if _.include methods, ref.substring(1)
        see.reference = "#{ path }#{if entity.constructor.name == 'Class' then 'classes' else 'modules'}/#{ entity.getFullName().replace(/\./g, '/') }.html##{ ref.substring(1) }-class"
        see.label = ref unless see.label
      else
        see.label = see.reference
        see.reference = undefined
        console.log "[WARN] Cannot resolve link to #{ ref } in #{ entity.getFullName() }" unless @options.quiet

    # Link to direct instance methods
    else if /^\#/.test(ref)
      instanceMethods = _.map(_.filter(entity.getMethods(), (m) -> m.getType() is 'instance'), (m) -> m.getName())

      if _.include instanceMethods, ref.substring(1)
        see.reference = "#{ path }classes/#{ entity.getFullName().replace(/\./g, '/') }.html##{ ref.substring(1) }-instance"
        see.label = ref unless see.label
      else
        see.label = see.reference
        see.reference = undefined
        console.log "[WARN] Cannot resolve link to #{ ref } in class #{ entity.getFullName() }" unless @options.quiet

    # Link to other objects
    else
      # Ignore normal links
      unless /^https?:\/\//.test ref

        # Get class and method reference
        if match = /^(.*?)([.#][$a-z_\x7f-\uffff][$\w\x7f-\uffff]*)?$/.exec ref
          refClass = match[1]
          refMethod = match[2]
          otherEntity   = _.find @classes, (c) -> c.getFullName() is refClass
          otherEntity ||= _.find @modules, (c) -> c.getFullName() is refClass

          if otherEntity
            # Link to another class
            if _.isUndefined refMethod
              if _.include(_.map(@classes, (c) -> c.getFullName()), refClass) || _.include(_.map(@modules, (c) -> c.getFullName()), refClass)
                see.reference = "#{ path }#{if otherEntity.constructor.name == 'Class' then 'classes' else 'modules'}/#{ refClass.replace(/\./g, '/') }.html"
                see.label = ref unless see.label
              else
                see.label = see.reference
                see.reference = undefined
                console.log "[WARN] Cannot resolve link to entity #{ refClass } in #{ entity.getFullName() }" unless @options.quiet

            # Link to other class class methods
            else if /^\./.test(refMethod)
              methods = _.map(_.filter(otherEntity.getMethods(), (m) -> m.getType() is 'class'), (m) -> m.getName())

              if _.include methods, refMethod.substring(1)
                see.reference = "#{ path }#{if otherEntity.constructor.name == 'Class' then 'classes' else 'modules'}/#{ otherEntity.getFullName().replace(/\./g, '/') }.html##{ refMethod.substring(1) }-class"
                see.label = ref unless see.label
              else
                see.label = see.reference
                see.reference = undefined
                console.log "[WARN] Cannot resolve link to #{ refMethod } of class #{ otherEntity.getFullName() } in class #{ entity.getFullName() }" unless @options.quiet

            # Link to other class instance methods
            else if /^\#/.test(refMethod)
              instanceMethods = _.map(_.filter(otherEntity.getMethods(), (m) -> m.getType() is 'instance'), (m) -> m.getName())

              if _.include instanceMethods, refMethod.substring(1)
                see.reference = "#{ path }#{if otherEntity.constructor.name == 'Class' then 'classes' else 'modules'}/#{ otherEntity.getFullName().replace(/\./g, '/') }.html##{ refMethod.substring(1) }-instance"
                see.label = ref unless see.label
              else
                see.label = see.reference
                see.reference = undefined
                console.log "[WARN] Cannot resolve link to #{ refMethod } of class #{ otherEntity.getFullName() } in class #{ entity.getFullName() }" unless @options.quiet

           else
             see.label = see.reference
             see.reference = undefined
             console.log "[WARN] Cannot find referenced class #{ refClass } in class #{ entity.getFullName() }" unless @options.quiet

        else
          see.label = see.reference
          see.reference = undefined
          console.log "[WARN] Cannot resolve link to #{ ref } in class #{ entity.getFullName() }" unless @options.quiet

    see
