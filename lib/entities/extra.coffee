FS       = require 'fs'
Path     = require 'path'
Entities = require '../_entities'
Markdown = require '../tools/markdown'

module.exports = class Entities.Extra

  constructor: (@environment, @path) ->
    @name    = Path.relative(@environment.options.basedir, @path)
    @content = FS.readFileSync @path, 'utf-8'

    @parsed = if /\.(markdown|md)$/.test @path
      Markdown.convert(@content)
    else
      "<p>"+@content.replace(/\n/g, '<br/>')+"</p>"

  linkify: ->

  inspect: ->
    {
      path: @path,
      parsed: @parsed
    }