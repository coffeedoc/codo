fs     = require 'fs'
path   = require 'path'
mkdirp = require 'mkdirp'
_      = require 'underscore'
findit = require('findit')
hamlc  = require('haml-coffee')

# Haml Coffee template compiler.
#
module.exports = class Templater

  # Construct the templater. Reads all templates and constructs
  # the global template context.
  #
  # @param [Object] options the options
  #
  constructor: (@options) ->
    @JST = []

    @globalContext =
      codoVersion: 'v' + JSON.parse(fs.readFileSync("#{ __dirname }/../../package.json", 'utf-8'))['version']
      generationDate: new Date().toString()
      JST: @JST
      title: @options.title

    for filename in findit.sync "#{ __dirname }/../../theme/default/templates"
      if match = /theme\/default\/templates\/(.+).hamlc$/.exec filename
        @JST[match[1]] = hamlc.compile(fs.readFileSync(filename, 'utf-8'))

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
      file = path.join @options.output, filename
      dir  = path.dirname(file)
      mkdirp dir, (err) ->
        if err
          console.error "[ERROR] Cannot create directory #{ dir }: #{ err }"
        else
          fs.writeFile file, html

    html
