fs         = require 'fs'
path       = require 'path'
marked     = require 'marked'
mkdirp     = require 'mkdirp'
_          = require 'underscore'

Templater  = require './util/templater'
Referencer = require './util/referencer'

# The documentation generator uses the parser JSON
# to generate the final codo documentation.
#
module.exports = class Generator

  # Construct a generator
  #
  # @param [Parser] parser the parser
  # @param [Object] options the options
  #
  constructor: (@parser, @options) ->
    @referencer = new Referencer(@parser.classes, @options)
    @templater = new Templater(@options, @referencer)

  # Generate the documentation
  #
  #
  generate: ->
    @generateFrames()
    @generateReadme()
    @generateClasses()
    @generateModules()
    @generateExtras()
    @generateIndex()
    @generateLists()
    @generateMethodList()
    @generateFileList()
    @copyAssets()

  # Generate the frame source.
  #
  generateFrames: ->
    @templater.render 'frames', { path: '' }, 'frames.html'

  # Generate the home page. This is the readme
  #
  generateReadme: ->
    try
      readme   = fs.readFileSync @options.readme, 'utf-8'
      readme   = marked readme if /\.(markdown|md)$/.test @options.readme
      filename = 'index.html'

      @templater.render 'file', {
        path: ''
        filename: @options.readme,
        content: readme
        breadcrumbs: [
          {
            href: 'class_index.html'
            name: 'Index'
          }
          {
            href: "File: #{ filename }"
            name: @options.readme
          }
        ]
      }, filename

    catch error
      console.log "[ERROR] Cannot generate readme file #{ @options.readme }: #{ error }"

  # Generates the pages for all the classes.
  #
  generateClasses: ->
    for clazz in @parser.classes
      namespaces = _.compact clazz.getNamespace().split('.')
      assetPath = '../'
      assetPath += '../' for namespace in namespaces

      breadcrumbs = [
        {
          href: "#{ assetPath }class_index.html"
          name: 'Index'
        }
      ]

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
        constants: _.map _.filter(clazz.getVariables(), (variable) => variable.isConstant()), (m) => @referencer.resolveDoc(m.toJSON(), clazz, assetPath)
        subClasses: _.map @referencer.getDirectSubClasses(clazz), (c) -> c.getClassName()
        inheritedMethods: _.groupBy @referencer.getInheritedMethods(clazz), (m) -> m.entity.getClassName()
        inheritedConstants: _.groupBy @referencer.getInheritedConstants(clazz), (m) -> m.entity.getClassName()
        breadcrumbs: breadcrumbs
      }, "classes/#{ clazz.getClassName().replace(/\./g, '/') }.html"

  # Generate the pages for all the modules
  #
  generateModules: ->
    for module in @parser.modules
      namespaces = _.compact module.getNamespace().split('.')
      assetPath = '../'
      assetPath += '../' for namespace in namespaces

      breadcrumbs = [
        {
          href: "#{ assetPath }class_index.html"
          name: 'Index'
        }
      ]

      combined = []
      for namespace in namespaces
        combined.push namespace
        breadcrumbs.push
          href: @referencer.getLink combined.join('.'), assetPath
          name: namespace

      breadcrumbs.push
        name: module.getName()

      @templater.render 'module', {
        path: assetPath
        moduleData: module.toJSON()
        methods: _.map module.getMethods(), (m) -> m.toJSON()
        constants: _.map _.filter(module.getVariables(), (variable) -> variable.isConstant()), (m) -> m.toJSON()
        breadcrumbs: breadcrumbs
      }, "modules/#{ module.getFullName().replace(/\./g, '/') }.html"

  # Generates the pages for all the extra files.
  #
  generateExtras: ->
    for extra in _.union [@options.readme], @options.extras
      try
        content = fs.readFileSync extra, 'utf-8'
        content = marked content if /\.(markdown|md)$/.test extra
        filename = "#{ extra }.html"

        @templater.render 'file', {
          path: ''
          filename: extra,
          content: content
          breadcrumbs: [
            {
              href: 'class_index.html'
              name: 'Index'
            }
            {
              href: "File: #{ filename }"
              name: extra
            }
          ]
        }, filename

      catch error
        console.log "[ERROR] Cannot generate extra file #{ extra }: #{ error }"

  # Generate the alphabetical index
  #
  generateIndex: ->
    sortedClasses = {}

    # Sort in character group
    for code in [97..122]
      char = String.fromCharCode(code)
      classes = _.filter @parser.classes, (clazz) -> clazz.getName().toLowerCase()[0] is char
      modules = _.filter @parser.modules, (module) -> module.getName().toLowerCase()[0] is char
      if classes.length + modules.length > 0
        sortedClasses[char] = []
        sortedClasses[char].push x for x in classes unless _.isEmpty classes
        sortedClasses[char].push x for x in modules unless _.isEmpty modules

    @templater.render 'index', {
      path: ''
      classes: sortedClasses
      files: _.union [@options.readme], @options.extras.sort()
      breadcrumbs: []
    }, 'class_index.html'

  # Generates the drop down class list
  #
  generateLists: ->
    classes = []
    modules = []

    traverse = (entity, children, section) ->
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

      # Create a new class
      children.push
        name: entity.getName()
        href: "#{section}/#{ entity.getName().replace(/\./g, '/') }.html"
        parent: entity.getParentClassName?()

    # Create tree structure
    for clazz in @parser.classes
      traverse clazz, classes, 'classes'

    for module in @parser.modules
      traverse module, modules, 'modules'

    @templater.render 'class_list', {
      path: ''
      classes: classes
    }, 'class_list.html'

    @templater.render 'module_list', {
      path: ''
      modules: modules
    }, 'module_list.html'

  # Generates the drop down method list
  #
  generateMethodList: ->
    nonconstructors = _.filter @parser.getAllMethods(), (m) -> m.getName() isnt 'constructor'
    methods = _.map nonconstructors, (method) ->
      {
        path: ''
        name: method.getName()
        href: "#{if method.entity.constructor.name == 'Class' then 'classes' else 'modules'}/#{ method.entity.getFullName().replace(/\./g, '/') }.html##{ method.getName() }-#{ method.getType() }"
        classname: method.entity.getFullName()
        deprecated: method.doc?.deprecated
        type: method.type
      }

    @templater.render 'method_list', {
      methods: _.sortBy methods, (method) -> method.name
    }, 'method_list.html'

  # Generates the drop down file list
  #
  generateFileList: ->
    @templater.render 'file_list', {
      path: ''
      files: _.union [@options.readme], @options.extras.sort()
    }, 'file_list.html'

  # Copy the styles and scripts.
  #
  copyAssets: ->
    @copy "#{ __dirname }/../theme/default/assets/codo.css", "#{ @options.output }/assets/codo.css"
    @copy "#{ __dirname }/../theme/default/assets/codo.js", "#{ @options.output }/assets/codo.js"

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
        to.once 'open', (fd) -> require('util').pump from, to

