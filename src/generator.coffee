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
    @templater = new Templater(@options)
    @referencer = new Referencer(@parser.classes)

  # Generate the documentation
  #
  #
  generate: ->
    @generateReadme()
    @generateClasses()
    @generateExtras()
    @generateIndex()
    @generateClassList()
    @generateMethodList()
    @generateFileList()
    @copyAssets()

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
            href: '_index.html'
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
          href: "#{ assetPath }_index.html"
          name: 'Index'
        }
      ]

      for namespace in namespaces
        breadcrumbs.push
          name: namespace

      breadcrumbs.push
        name: clazz.getName()

      @templater.render 'class', {
        path: assetPath
        classData: clazz.toJSON()
        classMethods: _.map _.filter(clazz.getMethods(), (method) -> method.type is 'class'), (m) -> m.toJSON()
        instanceMethods: _.map _.filter(clazz.getMethods(), (method) -> method.type is 'instance'), (m) -> m.toJSON()
        constants: _.map _.filter(clazz.getVariables(), (variable) -> variable.isConstant()), (m) -> m.toJSON()
        subClasses: _.map @referencer.getDirectSubClasses(clazz), (c) -> c.getClassName()
        inheritedMethods: _.groupBy @referencer.getInheritedMethods(clazz), (m) -> m.clazz.getClassName()
        inheritedConstants: _.groupBy @referencer.getInheritedConstants(clazz), (m) -> m.clazz.getClassName()
        breadcrumbs: breadcrumbs
      }, "classes/#{ clazz.getClassName().replace(/\./g, '/') }.html"

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
              href: '_index.html'
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
      sortedClasses[char] = classes unless _.isEmpty classes

    @templater.render 'index', {
      path: ''
      classes: sortedClasses
      files: _.union [@options.readme], @options.extras.sort()
      breadcrumbs: []
    }, '_index.html'

  # Generates the drop down class list
  #
  generateClassList: ->
    @templater.render 'class_list', {
      path: ''
      classes: _.sortBy @parser.classes, (clazz) -> clazz.getName()
    }, 'class_list.html'

  # Generates the drop down method list
  #
  generateMethodList: ->
    methods = _.map @parser.getAllMethods(), (method) ->
      {
        path: ''
        name: method.getName()
        href: "classes/#{ method.clazz.getClassName().replace(/\./g, '/') }.html##{ method.getName() }-#{ method.type }"
        classname: method.clazz.getClassName()
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

