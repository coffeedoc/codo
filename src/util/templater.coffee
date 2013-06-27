fs      = require 'fs'
path    = require 'path'
_       = require 'underscore'
_.str   = require 'underscore.string'
walkdir = require 'walkdir'
hamlc   = require 'haml-coffee'

# Haml Coffee template compiler.
#
module.exports = class Templater

  # Construct the templater. Reads all templates and constructs
  # the global template context.
  #
  # @param [Object] options the options
  # @param [Referencer] referencer the link type referencer
  # @param [Parser] parser the codo parser
  # @param [Writer] writer the file writer
  #
  constructor: (@options, @referencer, @parser, @writer) ->
    @JST = []

    @globalContext =
      codoVersion: 'v' + JSON.parse(fs.readFileSync(path.join(__dirname, '..', '..', 'package.json'), 'utf-8'))['version']
      generationDate: new Date().toString()
      JST: @JST
      underscore: _
      str: _.str
      title: @options.title
      referencer: @referencer
      analytics: @options.analytics
      fileCount: @parser.files.length
      classCount: @parser.classes.length
      mixinCount: @parser.mixins.length
      methodCount: @parser.getAllMethods().length
      extraCount: _.union([@options.readme], @options.extras).length

    for filename in walkdir.sync path.join(__dirname, '..', '..', 'theme', 'default', 'templates')
      if match = /theme[/\\]default[/\\]templates[/\\](.+).hamlc$/.exec filename
        @JST[match[1].replace(/[\\]/g, '/')] = hamlc.compile(fs.readFileSync(filename, 'utf-8'), { escapeAttributes: false })

  # Render the given template with the context and the
  # global context object merged as template data. Writes
  # the file as the output filename.
  #
  # @param [String] template the template name
  # @param [Object] context the context object
  # @param [String] filename the output file name
  #
  render: (template, context = {}, filename = '') ->
    html = @JST[template](_.extend(@globalContext, context))

    unless _.isEmpty filename
      @writer.output html, filename

    html
