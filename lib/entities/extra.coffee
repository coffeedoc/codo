FS       = require 'fs'
Path     = require 'path'
Entities = require '../_entities'
Markdown = require '../markdown'

module.exports = class Entities.Extra

  constructor: (@environment, @path) ->
    @name    = Path.relative(@environment.options.basedir, @path)
    @content = FS.readFileSync @path, 'utf-8'

    @parsed = if /\.(markdown|md)$/.test @path
      Markdown.convert(@content)
    else
      @content.replace(/\n/g, '<br/>')

  linkify: ->

  inspect: ->
    {
      path: @path,
      parsed: @parsed
    }