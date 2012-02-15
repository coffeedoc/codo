fs        = require 'fs'
path      = require 'path'
ghm       = require 'github-flavored-markdown'
mkdirp    = require 'mkdirp'
_         = require 'underscore'

Templater = require './util/templater'

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

  # Generate the documentation
  #
  #
  generate: ->
    @generateReadme()
    @generateClasses()
    @generateExtras()
    @generateIndex()
    @copyAssets()

  # Generate the home page. This is the readme
  #
  generateReadme: ->
    try
      readme   = fs.readFileSync @options.readme, 'utf-8'
      readme   = ghm.parse(readme, @options.github) if /\.(markdown|md)$/.test @options.readme
      filename = 'index.html'

      @templater.render 'file', {
        filename: @options.readme,
        content: readme
        breadcrumbs: [
          {
            href: '_index.html'
            name: 'Index'
          }
          {
            href: filename
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
      @templater.render 'class', clazz.toJSON(), "classes/#{ clazz.getClassName().replace(/\./g, '/') }.html"

  # Generates the pages for all the extra files.
  #
  generateExtras: ->
    for extra in _.union [@options.readme], @options.extras
      try
        content = fs.readFileSync extra, 'utf-8'
        content = ghm.parse(content, @options.github) if /\.(markdown|md)$/.test extra
        filename = "#{ extra }.html"

        @templater.render 'file', {
          filename: extra,
          content: content
          breadcrumbs: [
            {
              href: '_index.html'
              name: 'Index'
            }
            {
              href: filename
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

    for code in [97..122]
      char = String.fromCharCode(code)
      classes = _.filter @parser.classes, (clazz) -> clazz.getName().toLowerCase()[0] is char
      sortedClasses[char] = classes unless _.isEmpty classes

    @templater.render 'index', {
      classes: sortedClasses
      files: _.union [@options.readme], @options.extras
      breadcrumbs: []
    }, '_index.html'

  # Copy the styles and scripts.
  #
  copyAssets: ->
    @copy './theme/default/assets/codo.css', "#{ @options.output }/assets/codo.css"
    @copy './theme/default/assets/codo.js', "#{ @options.output }/assets/codo.js"

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
