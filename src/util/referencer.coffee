_ = require 'underscore'

# Class reference resolver.
#
module.exports = class Referencer

  # Construct a referencer.
  #
  # @param [Array<Classes>] classes all known classes
  # @param [Array<Classes>] mixins all known mixins
  # @param [Object] options the parser options
  #
  constructor: (@classes, @mixins, @options) ->
    @resolveParamReferences()

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

      if parentClass and parentClass isnt clazz
        _.union(parentClass.getMethods(), @getInheritedMethods(parentClass))
      else
        []

    else
      []

  # Get all included mixins in the class hierarchy.
  #
  # @param [Class] clazz the class
  # @return [Object] the mixins
  #
  getIncludedMethods: (clazz) ->
    result = {}

    for mixin in clazz.doc?.includeMixins || []
      result[mixin] = @resolveMixinMethods mixin

    unless _.isEmpty clazz.getParentClassName()
      parentClass = _.find @classes, (c) -> c.getFullName() is clazz.getParentClassName()

      if parentClass and parentClass isnt clazz
        result = _.extend {}, @getIncludedMethods(parentClass), result

    result

  # Get all extended mixins in the class hierarchy.
  #
  # @param [Class] clazz the class
  # @return [Object] the mixins
  #
  getExtendedMethods: (clazz) ->
    result = {}

    for mixin in clazz.doc?.extendMixins || []
      result[mixin] = @resolveMixinMethods mixin

    unless _.isEmpty clazz.getParentClassName()
      parentClass = _.find @classes, (c) -> c.getFullName() is clazz.getParentClassName()

      if parentClass and parentClass isnt clazz
        result = _.extend {}, @getExtendedMethods(parentClass), result

    result

  # Get all concerns
  #
  # @param [Class] clazz the class
  # @return [Object] the concerns
  #
  getConcernMethods: (clazz) ->
    result = {}

    for mixin in clazz.doc?.concerns || []
      result[mixin] = @resolveMixinMethods mixin

    unless _.isEmpty clazz.getParentClassName()
      parentClass = _.find @classes, (c) -> c.getFullName() is clazz.getParentClassName()

      if parentClass and parentClass isnt clazz
        result = _.extend {}, @getConcernMethods(parentClass), result

    result

  # Get a list of all methods from the given mixin name
  #
  # @param name [String] the full name of the mixin
  # @return [Array<Methods>] the mixin methods
  #
  resolveMixinMethods: (name) ->
    mixin = _.find @mixins, (m) -> m.getMixinName() is name

    if mixin
      mixin.getMethods()
    else
      console.log "[WARN] Cannot resolve mixin name #{ name }" unless @options.quiet
      []

  # Get all inherited variables.
  #
  # @param [Class] clazz the parent class
  # @return [Array<Variable>] the variables
  #
  getInheritedVariables: (clazz) ->
    unless _.isEmpty clazz.getParentClassName()
      parentClass = _.find @classes, (c) -> c.getFullName() is clazz.getParentClassName()

      if parentClass and parentClass isnt clazz
        _.union(parentClass.getVariables(), @getInheritedVariables(parentClass))
      else
        []

    else
      []

  # Get all inherited constants.
  #
  # @param [Class] clazz the parent class
  # @return [Array<Variable>] the constants
  #
  getInheritedConstants: (clazz) ->
    _.filter @getInheritedVariables(clazz), (v) -> v.isConstant()

  # Get all inherited properties.
  #
  # @param [Class] clazz the parent class
  # @return [Array<Properties>] the properties
  #
  getInheritedProperties: (clazz) ->
    unless _.isEmpty clazz.getParentClassName()
      parentClass = _.find @classes, (c) -> c.getFullName() is clazz.getParentClassName()

      if parentClass and parentClass isnt clazz
        _.union(parentClass.properties, @getInheritedProperties(parentClass))
      else
        []

    else
      []

  # Create browsable links for known entities.
  #
  # @see #getLink
  #
  # @param [String] text the text to parse.
  # @param [String] path the path prefix
  # @return [String] the processed text
  #
  linkTypes: (text = '', path) ->
    text = text.split ','

    text = for t in text
      @linkType(t.trim(), path)

    text.join(', ')

  # Create browsable links to a known entity.
  #
  # @see #getLink
  #
  # @param [String] text the text to parse.
  # @param [String] path the path prefix
  # @return [String] the processed text
  #
  linkType: (text = '', path) ->
    text = _.str.escapeHTML text

    for clazz in @classes
      text = text.replace ///^(#{ clazz.getFullName() })$///g, "<a href='#{ path }classes/#{ clazz.getFullName().replace(/\./g, '/') }.html'>$1</a>"
      text = text.replace ///(&lt;|[ ])(#{ clazz.getFullName() })(&gt;|[, ])///g, "$1<a href='#{ path }classes/#{ clazz.getFullName().replace(/\./g, '/') }.html'>$2</a>$3"

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

      if _.isString data.doc.summary
        data.doc.summary = @resolveTextReferences(data.doc.summary, entity, path)

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

      if data.doc.throwValue
        for throws, index in data.doc.throwValue
          data.doc.throwValue[index].desc = @resolveTextReferences(throws.desc, entity, path)

    data

  # Search a text to find see links wrapped in curly braces.
  #
  # @example Reference an object
  #   "To get a list of all customers, go to {Customers.getAll}"
  #
  # @param [String] the text to search
  # @return [String] the text with hyperlinks
  #
  resolveTextReferences: (text = '', entity, path) ->
    # Make curly braces within code blocks undetectable
    text = text.replace /<code>.+?<\/code>/mg, (match) -> match.replace(/{/mg, "\u0091").replace(/}/mg, "\u0092")

    # Search for references and replace them
    text = text.replace /\{([^\}]*)\}/gm, (match, link) =>
      # Remove the markdown generated autolinks
      link = link.replace(/<.+?>/g, '').split(' ')
      href = link.shift()
      label = link.join(' ')

      see = @resolveSee({ reference: href, label: label }, entity, path)

      if see.reference
        "<a href='#{ see.reference }'>#{ see.label }</a>"
      else
        match

    # Restore curly braces within code blocks
    text = text.replace /<code>.+?<\/code>/mg, (match) -> match.replace(/\u0091/mg, '{').replace(/\u0092/mg, '}')

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
      methods = _.map(_.filter(entity.getMethods(), (m) -> _.indexOf(['class', 'mixin'], m.getType()) >= 0), (m) -> m.getName())

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
        # Try to resolve to a property
        properties = _.map entity.properties, (p) -> p.name

        if _.include properties, ref.substring(1)
          see.reference = "#{ path }#{if entity.constructor.name == 'Class' then 'classes' else 'modules'}/#{ entity.getFullName().replace(/\./g, '/') }.html##{ ref.substring(1) }-property"
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
          otherEntity ||= _.find @mixins, (c) -> c.getFullName() is refClass

          if otherEntity
            # Link to another class
            if _.isUndefined refMethod
              if _.include(_.map(@classes, (c) -> c.getFullName()), refClass) || _.include(_.map(@mixins, (c) -> c.getFullName()), refClass)
                see.reference = "#{ path }#{ if otherEntity.constructor.name == 'Class' then 'classes' else 'modules' }/#{ refClass.replace(/\./g, '/') }.html"
                see.label = ref unless see.label
              else
                see.label = see.reference
                see.reference = undefined
                console.log "[WARN] Cannot resolve link to entity #{ refClass } in #{ entity.getFullName() }" unless @options.quiet

            # Link to other class class methods
            else if /^\./.test(refMethod)
              methods = _.map(_.filter(otherEntity.getMethods(), (m) -> _.indexOf(['class', 'mixin'], m.getType()) >= 0), (m) -> m.getName())

              if _.include methods, refMethod.substring(1)
                see.reference = "#{ path }#{ if otherEntity.constructor.name == 'Class' then 'classes' else 'modules' }/#{ otherEntity.getFullName().replace(/\./g, '/') }.html##{ refMethod.substring(1) }-class"
                see.label = ref unless see.label
              else
                see.label = see.reference
                see.reference = undefined
                console.log "[WARN] Cannot resolve link to #{ refMethod } of class #{ otherEntity.getFullName() } in class #{ entity.getFullName() }" unless @options.quiet

            # Link to other class instance methods
            else if /^\#/.test(refMethod)
              instanceMethods = _.map(_.filter(otherEntity.getMethods(), (m) -> _.indexOf(['instance', 'mixin'], m.getType()) >= 0), (m) -> m.getName())

              if _.include instanceMethods, refMethod.substring(1)
                see.reference = "#{ path }#{ if otherEntity.constructor.name == 'Class' then 'classes' else 'modules' }/#{ otherEntity.getFullName().replace(/\./g, '/') }.html##{ refMethod.substring(1) }-instance"
                see.label = ref unless see.label
              else
                # Try to resolve to a property
                properties = _.map otherEntity.properties, (p) -> p.name

                if _.include properties, ref.substring(1)
                  see.reference = "#{ path }#{ if otherEntity.constructor.name == 'Class' then 'classes' else 'modules' }/#{ otherEntity.getFullName().replace(/\./g, '/') }.html##{ refMethod.substring(1) }-property"
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

  # Resolve parameter references. This goes through all
  # method parameter and see if a param doc references another
  # method. If so, copy over the doc meta data.
  #
  resolveParamReferences: ->
    entities = _.union @classes, @mixins

    for entity in entities
      for method in entity.getMethods()
        if method.getDoc() && !_.isEmpty method.getDoc().params
          for param in method.getDoc().params
            if param.reference

              # Find referenced entity
              if ref = /([$A-Za-z_\x7f-\uffff][$\w\x7f-\uffff]*)([#.])([$A-Za-z_\x7f-\uffff][$\w\x7f-\uffff]*)/i.test param.reference
                otherEntity = _.first entities, (e) -> e.getFullName() is ref[1]
                otherMethodType = if ref[2] is '#' then ['instance'] else ['class', 'mixin']
                otherMethod = ref[3]

              # The referenced entity is on the current entity
              else
                otherEntity = entity
                otherMethodType = if param.reference.substring(0, 1) is '#' then ['instance', 'mixin'] else ['class', 'mixin']
                otherMethod = param.reference.substring(1)

              # Find the referenced method
              refMethod = _.find otherEntity.getMethods(), (m) -> m.getName() is otherMethod && _.indexOf(otherMethodType, m.getType()) >= 0

              if refMethod
                # Filter param name
                if param.name
                  copyParam = _.find refMethod.getDoc().params, (p) -> p.name is param.name

                  if copyParam
                    # Replace a single param
                    method.getDoc().params ||= []
                    method.getDoc().params = _.reject method.getDoc().params, (p) -> p.name = param.name
                    method.getDoc().params.push copyParam

                    # Replace a single option param
                    if _.isObject refMethod.getDoc().paramsOptions
                      method.getDoc().paramsOptions ||= {}
                      method.getDoc().paramsOptions[param.name] = refMethod.getDoc().paramsOptions[param.name]

                  else
                    console.log "[WARN] Parameter #{ param.name } does not exist in #{ param.reference } in class #{ entity.getFullName() }" unless @options.quiet

                else
                  # Copy all parameters that exist on the given method
                  names = _.map method.getParameters(), (p) -> p.getName()
                  method.getDoc().params = _.filter refMethod.getDoc().params, (p) -> _.contains names, p.name

                  # Copy all matching options
                  if _.isObject refMethod.getDoc().paramsOptions
                    method.getDoc().paramsOptions ||= {}
                    method.getDoc().paramsOptions[name] = refMethod.getDoc().paramsOptions[name] for name in names

              else
                console.log "[WARN] Cannot resolve reference tag #{ param.reference } in class #{ entity.getFullName() }" unless @options.quiet
