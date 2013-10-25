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

    @verbose ?= false
    @debug   ?= false
    @needles ?= []

    @needles.push require('./entities/class')
    @needles.push require('./entities/method')
    @needles.push require('./entities/variable')
    @needles.push require('./entities/property')
    @needles.push require('./entities/mixin')

    @entities = []

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