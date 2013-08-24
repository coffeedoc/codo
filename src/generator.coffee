fs         = require 'fs'
path       = require 'path'
mkdirp     = require 'mkdirp'
_          = require 'underscore'

Templater  = require './util/templater'
Referencer = require './util/referencer'
Markdown   = require './util/markdown'

# The documentation generator uses the parser JSON
# to generate the final codo documentation.
#
module.exports = class Generator

  # Construct a generator
  #
  # @param [Parser] parser the parser
  # @param [Theme] theme the theme
  # @param [Object] options the options
  #
  constructor: (@parser, @theme, @options) ->
    @referencer = new Referencer(@parser.classes, @parser.mixins, @options)
    @templater = new Templater(@options, @referencer, @parser, @theme)

  # Generate the documentation. Without callback, the documentation
  # is written to the file system, with callback, the file content
  # will be passed to the callback.
  #
  # With a provided file generation callback, the assets will not be copied,
  # use {Codo.script} and {Codo.style} to get them.
  #
  # @param [Function] file the optional file generation callback
  #
  generate: (file) ->
    @templater.redirect(file) if file

    @generateIndex()

    @generateClasses()
    @generateMixins()
    @generateFiles()
    @generateExtras()

    @generateClassMixinFileExtraIndex()

    @generateClassAndMixinLists()
    @generateMethodList()
    @generateFileList()
    @generateExtraList()

    @generateSearchData file
    @copyAssets() unless file

  # Generate the frame source.
  #
  generateIndex: ->
    index = @options.readme || 'class_index'

    list = if @parser.classes.length isnt 0
             'class_list'
           else if @parser.files.length isnt 0
             'file_list'
           else if @parser.mixins.length isnt 0
             'mixin_list'
           else if @parser.getAllMethods().length isnt 0
             'method_list'
           else
             'extra_list'

    @templater.render 'frames', { list: list, index: index, path: '' }, 'index'

  # Generates the pages for all the classes.
  #
  generateClasses: ->
    indexOutputType = @theme.templateOutput('index')
    fileOutputType = @theme.templateOutput('file')
    for clazz in @parser.classes
      namespaces = _.compact clazz.getNamespace().split('.')
      assetPath = '../'
      assetPath += '../' for namespace in namespaces

      breadcrumbs = [
        {
          href: "#{ assetPath }class_index.#{ indexOutputType }"
          name: 'Index'
        }
      ]

      breadcrumbs.unshift({ href: "#{ assetPath }#{ @options.readme }.#{ fileOutputType }", name: @options.name }) if @options.readme
      breadcrumbs.unshift(@options.homepage) if @options.homepage

      combined = []
      for namespace in namespaces
        combined.push namespace
        breadcrumbs.push
          href: @referencer.getLink combined.join('.'), assetPath
          name: namespace

      breadcrumbs.push
        name: clazz.getName()

      @templater.render 'class', {
        path: assetPath
        classData: @referencer.resolveDoc(clazz.toJSON(), clazz, assetPath)
        classMethods: _.map _.filter(clazz.getMethods(), (method) => method.type is 'class'), (m) => @referencer.resolveDoc(m.toJSON(), clazz, assetPath)
        instanceMethods: _.map _.filter(clazz.getMethods(), (method) => method.type is 'instance'), (m) => @referencer.resolveDoc(m.toJSON(), clazz, assetPath)
        properties: _.map clazz.properties, (p) => @referencer.resolveDoc(p.toJSON(), clazz, assetPath)
        constants: _.map _.filter(clazz.getVariables(), (variable) => variable.isConstant()), (m) => @referencer.resolveDoc(m.toJSON(), clazz, assetPath)
        subClasses: _.map @referencer.getDirectSubClasses(clazz), (c) -> c.getClassName()
        inheritedMethods: _.groupBy @referencer.getInheritedMethods(clazz), (m) -> m.entity.getClassName()
        includedMethods: @referencer.getIncludedMethods(clazz)
        extendedMethods: @referencer.getExtendedMethods(clazz)
        concernMethods: @referencer.getConcernMethods(clazz)
        inheritedConstants: _.groupBy @referencer.getInheritedConstants(clazz), (m) -> m.entity.getClassName()
        inheritedProperties: _.groupBy @referencer.getInheritedProperties(clazz), (m) -> m.entity.getClassName()
        breadcrumbs: breadcrumbs
      }, "classes/#{ clazz.getClassName().replace(/\./g, '/') }"

  # Generate the pages for all the mixins
  #
  generateMixins: ->
    indexOutputType = @theme.templateOutput('index')
    fileOutputType = @theme.templateOutput('file')
    for mixin in @parser.mixins
      namespaces = _.compact mixin.getNamespace().split('.')
      assetPath = '../'
      assetPath += '../' for namespace in namespaces

      breadcrumbs = [
        {
          href: "#{ assetPath }class_index.#{ indexOutputType }"
          name: 'Index'
        }
      ]

      breadcrumbs.unshift({ href: "#{ assetPath }#{ @options.readme }.#{ fileOutputType }", name: @options.name }) if @options.readme
      breadcrumbs.unshift(@options.homepage) if @options.homepage

      combined = []
      for namespace in namespaces
        combined.push namespace
        breadcrumbs.push
          href: @referencer.getLink combined.join('.'), assetPath
          name: namespace

      breadcrumbs.push
        name: mixin.getName()

      isIncludedIn = (clazz) =>
        if clazz?.doc?.includeMixins
          _.contains clazz.doc.includeMixins, mixin.getMixinName()

      isExtendedFrom = (clazz) =>
        if clazz?.doc?.extendMixins
          _.contains clazz.doc.extendMixins, mixin.getMixinName()

      @templater.render 'mixin', {
        path: assetPath
        mixinData: mixin.toJSON()
        includedIn: _.map(_.filter(@parser.classes, isIncludedIn), (c) => c.getClassName())
        extendedIn: _.map(_.filter(@parser.classes, isExtendedFrom), (c) => c.getClassName())
        methods: _.map mixin.getMethods(), (m) -> m.toJSON()
        constants: _.map _.filter(mixin.getVariables(), (variable) -> variable.isConstant()), (m) -> m.toJSON()
        breadcrumbs: breadcrumbs
      }, "mixins/#{ mixin.getFullName().replace(/\./g, '/') }"

  # Generate the pages for all the (non-class) files that contains methods
  #
  generateFiles: ->
    indexOutputType = @theme.templateOutput('index')
    fileOutputType = @theme.templateOutput('file')
    for file in @parser.files
      p = _.compact file.getPath().split('/')
      assetPath = '../'
      assetPath += '../' for segment in p

      breadcrumbs = [
        {
        href: "#{ assetPath }class_index.#{ indexOutputType }"
        name: 'Index'
        }
      ]

      breadcrumbs.unshift({ href: "#{ assetPath }#{ @options.readme }.#{ fileOutputType }", name: @options.name }) if @options.readme
      breadcrumbs.unshift(@options.homepage) if @options.homepage

      combined = []
      for segment in p
        combined.push segment
        breadcrumbs.push
          href: @referencer.getLink combined.join('.'), assetPath
          name: segment

      breadcrumbs.push
        name: file.getFileName()

      @templater.render 'file', {
        path: assetPath
        filename: file.getFileName()
        filepath: file.getPath()
        classname: file.getClassName()
        methods: _.map file.getMethods(), (m) => @referencer.resolveDoc(m.toJSON(), file, assetPath)
        constants: _.map _.filter(file.getVariables(), (variable) => variable.isConstant()), (m) => @referencer.resolveDoc(m.toJSON(), file, assetPath)
        breadcrumbs: breadcrumbs
      }, "files/#{ file.getFullName() }"

  #
  # Generates the pages for all the extra files.
  #
  generateExtras: ->
    indexOutputType = @theme.templateOutput('index')
    fileOutputType = @theme.templateOutput('file')
    extraOutputType = @theme.templateOutput('extra')
    for extra in _.union [@options.readme], @options.extras
      try
        if (fs.existsSync || path.existsSync)(extra)
          content = fs.readFileSync extra, 'utf-8'
          content = Markdown.convert(content) if /\.(markdown|md)$/.test extra
          numSlashes = extra.split('/').length - 1
          assetPath = ''
          assetPath += '../' for slash in [0...numSlashes]
          filename = "#{ extra }.#{ extraOutputType }"

          breadcrumbs = [
            {
              href: "#{ assetPath }class_index.#{ indexOutputType }"
              name: 'Index'
            }
            {
              href: "File: #{ filename }"
              name: extra
            }
          ]

          breadcrumbs.unshift({ href: "#{ assetPath }#{ @options.readme }.#{ fileOutputType }", name: @options.name }) if @options.readme
          breadcrumbs.unshift(@options.homepage) if @options.homepage

          @templater.render 'extra', {
            path: assetPath
            filename: extra,
            content: content
            breadcrumbs: breadcrumbs
          }, extra

      catch error
        console.log "[ERROR] Cannot generate extra file #{ extra }: #{ error }"

  # Generate the alphabetical index of all classes and mixins.
  #
  generateClassMixinFileExtraIndex: ->
    sortedClasses = {}
    sortedFiles = {}

    # Sort in character group
    for code in [97..122]
      char = String.fromCharCode(code)

      classes = _.filter @parser.classes, (clazz) -> clazz.getName().toLowerCase()[0] is char
      mixins  = _.filter @parser.mixins,  (mixin) -> mixin.getName().toLowerCase()[0] is char
      files   = _.filter @parser.files,   (file)  -> file.getFileName().toLowerCase()[0] is char

      if classes.length + mixins.length > 0
        sortedClasses[char] = []
        sortedClasses[char].push x for x in classes unless _.isEmpty classes
        sortedClasses[char].push x for x in mixins unless _.isEmpty mixins

      if files.length > 0
        sortedFiles[char] = []
        sortedFiles[char].push x for x in files

    @templater.render 'index', {
      path: ''
      classes: sortedClasses
      files: sortedFiles
      extras: _.union [@options.readme], @options.extras.sort()
      breadcrumbs: []
    }, 'class_index'

  # Generates the drop down class list
  #
  generateClassAndMixinLists: ->
    classes = []
    mixins = []
    classOutputType = @theme.templateOutput 'class'
    mixinOutputType = @theme.templateOutput 'mixin'

    traverse = (entity, children, section, outputType) ->
      if entity.getNamespace()
        namespaces = entity.getNamespace().split('.')

        # Create all namespaces
        while namespace = namespaces.shift()
          child = _.find children, (c) -> c.name is namespace

          unless child
            child =
              name: namespace
            children.push child

          child.children or= []
          children = child.children

      # Determine if we should push OR update entries
      entry = _.find children, (c) -> c.name is entity.getName()
      #If there is an existing entry update it
      if entry?
        entry.parent = entity.getParentClassName?()
        entry.namespace = entity.getNamespace()
        entry.href = "#{section}/#{ entity.getFullName().replace(/\./g, '/') }.#{ outputType }"
      else # Otherwise push our new entry onto the array
        children.push
          name: entity.getName()
          href: "#{section}/#{ entity.getFullName().replace(/\./g, '/') }.#{ outputType }"
          parent: entity.getParentClassName?()
          namespace: entity.getNamespace()

    # Create tree structure
    for clazz in @parser.classes
      traverse clazz, classes, 'classes', classOutputType

    for mixin in @parser.mixins
      traverse mixin, mixins, 'mixins', mixinOutputType

    @templater.render 'class_list', {
      path: ''
      classes: classes
    }, 'class_list'

    @templater.render 'mixin_list', {
      path: ''
      mixins: mixins
    }, 'mixin_list'

  # Generates the drop down method list
  #
  generateMethodList: ->
    classOutputType = @theme.templateOutput 'class'
    mixinOutputType = @theme.templateOutput 'mixin'
    fileOutputType = @theme.templateOutput 'file'
    nonconstructors = _.filter @parser.getAllMethods(), (m) -> m.getName() isnt 'constructor'
    methods = _.map nonconstructors, (method) ->
      href = switch method.entity.constructor.name
               when 'Class'
                 "classes/#{ method.entity.getFullName().replace(/\./g, '/') }.#{ classOutputType }##{ method.getName() }-#{ method.getType() }"
               when 'Mixin'
                 "mixins/#{ method.entity.getFullName().replace(/\./g, '/') }.#{ mixinOutputType }##{ method.getName() }-#{ method.getType() }"
               when 'File'
                 "files/#{ method.entity.getFullName() }.#{ mixinOutputType }##{ method.getName() }-#{ method.getType() }"
      {
        path: ''
        name: method.getName()
        href: href
        classname: method.entity.getFullName()
        deprecated: method.doc?.deprecated
        type: method.type
      }

    @templater.render 'method_list', {
      methods: _.sortBy methods, (method) -> method.name
    }, 'method_list'

  # Generates the drop down file list
  #
  generateFileList: ->
    files = []

    traverse = (entity, children, outputType) ->
      if entity.getPath()
        segments = entity.getPath().split('/')

        # Create all namespaces
        while segment = segments.shift()
          child = _.find children, (c) -> c.name is segment

          unless child
            child =
              name: segment
            children.push child

          child.children or= []
          children = child.children

      # Create a new class
      children.push
        name: entity.getFileName()
        href: "files/#{ entity.getFullName() }.#{ outputType }"
        path: entity.getPath()

    # Create tree structure
    for file in @parser.files
      traverse file, files, @theme.templateOutput('file')

    @templater.render 'file_list', {
      path: ''
      files: files
    }, 'file_list'

  # Generates the drop down extra list
  #
  generateExtraList: ->
    @templater.render 'extra_list', {
      path: ''
      extras: _.union [@options.readme], @options.extras.sort()
    }, 'extra_list'

  # Copy the styles and scripts.
  #
  copyAssets: ->
    for asset in @theme.assets()
      @copy path.join(@theme.assetPath, asset), path.join(@options.output, 'assets', asset)

  # Copy a file
  #
  # @param [String] from the source file name
  # @param [String] to the destination file name
  #
  copy: (from, to) ->
    dir = path.dirname(to)
    mkdirp dir, (err) ->
      if err
        console.error "[ERROR] Cannot create directory #{ dir }: #{ err }"
      else
        from = fs.createReadStream from
        to = fs.createWriteStream to
        from.pipe to

  # Write the data used in search into
  # a JSON file used by the frontend.
  #
  # @param [Function] file the file callback
  #
  generateSearchData: (file) ->
    search = []

    outputType = @theme.templateOutput 'class'
    for clazz in @parser.classes
      fileName = clazz.getClassName().replace(/\./g, '/')
      search.push
        t: clazz.getClassName()
        p: "classes/#{ fileName }.#{ outputType }"

      for method in clazz.getMethods()
        search.push
          t: method.getShortSignature()
          h: clazz.getClassName()
          p: "classes/#{ fileName }.#{ outputType }##{ method.name }-#{ method.type }"

    outputType = @theme.templateOutput 'mixin'
    for mixin in @parser.mixins
      fileName = mixin.getFullName().replace(/\./g, '/')
      search.push
        t: mixin.getMixinName()
        p: "mixins/#{ fileName }.#{ outputType }"

      for method in mixin.getMethods()
        search.push
          t: method.getShortSignature()
          p: "mixins/#{ fileName }.#{ outputType }##{ method.name }-#{ method.type }"
          h: mixin.getMixinName()

    outputType = @theme.templateOutput 'mixin'
    for f in @parser.files
      search.push
        t: f.getFileName()
        p: "files/#{ f.getFullName() }.#{ outputType }"

      for method in f.getMethods()
        search.push
          t: method.getShortSignature()
          p: "files/#{ f.getFullName() }.#{ outputType }##{ method.name }-#{ method.type }"
          h: f.getFileName()

    search.push
      t: @options.readme
      p: "#{ @options.readme }.#{ @theme.templateOutput 'file' }"

    outputType = @theme.templateOutput 'file'
    for f in @options.extras.sort()
      search.push
        t: f
        p: "#{ f }.#{ outputType }"

    # Callback the search data
    if file
      file 'assets/search_data.js', 'window.searchData = ' + JSON.stringify(search)

    # Write the content to a file
    else
      destinationFolder = path.join(@options.output, 'assets')

      mkdirp destinationFolder, (err) ->
        if err
          console.error "[ERROR] Cannot create directory #{ dir }: #{ err }"
        else
          destinationFile = path.join destinationFolder, 'search_data.js'
          fs.writeFile destinationFile, 'window.searchData = ' + JSON.stringify(search), (err) ->
            console.error "[ERROR] Cannot write search data: ", err if err
