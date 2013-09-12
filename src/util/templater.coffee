fs      = require 'fs'
os      = require 'os'
path    = require 'path'
mkdirp  = require 'mkdirp'
_       = require 'underscore'
_.str   = require 'underscore.string'
hamlc   = require 'haml-coffee'

# Haml Coffee template compiler.
#
module.exports = class Templater

  isWin = os.platform().match(/^win/)

  # Construct the templater. Reads all templates and constructs
  # the global template context.
  #
  # @param [Object] options the options
  # @param [Referencer] referencer the link type referencer
  # @param [Parser] parser the codo parser
  # @param [Theme] theme the theme
  #
  constructor: (@options, @referencer, @parser, @theme) ->
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

    for template in @theme.templates()
      source = @theme.templateSource(template)
      type = @theme.templateType(template)
      template = template.replace('\\','/') if isWin
      @JST[template] = switch type
        when 'hamlc'
          hamlc.compile(source, { escapeAttributes: false })
        else
          throw new Error("Unimplemented template type #{type}")

  # Redirect template generation to a callback.
  #
  # @param [Function] file the file callback function
  #
  redirect: (file) -> @file = file

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

      # Callback generated content
      if @file
        @file(filename, html)

      # Write to file system
      else
        file = path.join @options.output, filename
        dir  = path.dirname(file)
        mkdirp dir, (err) ->
          if err
            console.error "[ERROR] Cannot create directory #{ dir }: #{ err }"
          else
            fs.writeFile file, html

    html
