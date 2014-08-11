FS       = require 'fs'
Path     = require 'path'
Entities = require '../_entities'
Markdown = require '../tools/markdown'

module.exports = class Entities.Extra

  constructor: (@environment, @path) ->
    @name   = Path.relative(@environment.options.basedir, @path)
    @buffer = null

    @parsed = if /\.(markdown|md)$/.test @name
      Markdown.convert(FS.readFileSync @path, 'utf-8')
    else if /(^[^.]+)$/.test @name
      "<p>"+FS.readFileSync(@path, 'utf-8').replace(/\n/g, '<br/>')+"</p>"
    else
      @buffer = FS.readFileSync(@path)
      null

  linkify: ->

  inspect: ->
    {
      path: @path,
      parsed: @parsed
      buffer: @buffer
    }
