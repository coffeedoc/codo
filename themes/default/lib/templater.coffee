FS      = require 'fs'
Path    = require 'path'
mkdirp  = require 'mkdirp'
_       = require 'underscore'
_.str   = require 'underscore.string'
hamlc   = require 'haml-coffee'
walkdir = require 'walkdir'
Mincer  = require 'mincer'

module.exports = class Templater

  sourceOf: (subject) ->
    Path.join(__dirname, '..', subject)

  constructor: (@environment) ->
    @JST = []

    @globalContext =
      JST:         @JST
      environment: @environment

    templates = @sourceOf('templates')

    for template in walkdir.sync(templates)
      unless FS.lstatSync(template).isDirectory()
        @JST[Path.relative(templates, template)] = hamlc.compile FS.readFileSync(template, 'utf8'),
          escapeAttributes: false

  compileAsset: (from, to=false) ->
    mincer = new Mincer.Environment()
    mincer.appendPath @sourceOf('assets')

    asset = mincer.findAsset(from)
    file  = Path.join(@environment.destination, to || from)
    dir   = Path.dirname(file)

    mkdirp dir, (err) ->
      if err
        console.error "[ERROR] Cannot create directory #{ dir }: #{ err }"
      else
        FS.writeFileSync(file, asset.buffer)

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

    if filename.length > 0

      file = Path.join @environment.destination, filename
      dir  = Path.dirname(file)

      mkdirp dir, (err) ->
        if err
          console.error "[ERROR] Cannot create directory #{ dir }: #{ err }"
        else
          FS.writeFileSync(file, html)

    html
