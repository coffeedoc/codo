FS        = require 'fs'
Path      = require 'path'
Traverser = require './traverser'

module.exports = class Environment

  @read: (files, options={}) ->
    files       = [files] unless Array.isArray(files)
    environment = new @(options)

    environment.read(file) for file in files
    environment.linkify()
    environment

  constructor: (options={}) ->
    for option, value of options
      @[option] = value if options.hasOwnProperty(option)

    @version = JSON.parse(
      FS.readFileSync(Path.join(__dirname, '..', 'package.json'), 'utf-8')
    )['version']

    @verbose     ?= false
    @debug       ?= false
    @destination ?= 'doc'
    @registerNeedles()

    @entities = []

  registerNeedles: ->
    @needles ?= []
    @needles.push require('./entities/class')
    @needles.push require('./entities/method')
    @needles.push require('./entities/variable')
    @needles.push require('./entities/property')
    @needles.push require('./entities/mixin')

  read: (file) ->
    Traverser.read(file, @)

  all: (Entity, haystack = []) ->
    for entity in @entities
      haystack.push(entity) if entity instanceof Entity
    haystack

  find: (Entity, name) ->
    for entity in @entities
      if entity instanceof Entity && entity.name == name
        return entity

  linkify: ->
    entity.linkify() for entity in @entities

  inspect: ->
    @entities.map (entity) -> entity.inspect()