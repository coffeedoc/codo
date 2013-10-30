FS        = require 'fs'
Path      = require 'path'
Traverser = require './traverser'
Markdown  = require './markdown'

File      = require './entities/file'
Class     = require './entities/class'
Method    = require './entities/method'
Variable  = require './entities/variable'
Property  = require './entities/property'
Mixin     = require './entities/mixin'

module.exports = class Environment

  @read: (files, options={}) ->
    files       = [files] unless Array.isArray(files)
    environment = new @(options)

    environment.readCoffee(file) for file in files
    environment.linkify()
    environment

  constructor: (options={}) ->
    for option, value of options
      @[option] = value if options.hasOwnProperty(option)

    @version = JSON.parse(
      FS.readFileSync(Path.join(__dirname, '..', 'package.json'), 'utf-8')
    )['version']

    @name        ?= 'Unknown Name'
    @verbose     ?= false
    @debug       ?= false
    @destination ?= 'doc'
    @extras       = {}
    @registerNeedles()

    @entities = []

  registerNeedles: ->
    @needles ?= []
    @needles.push Class
    @needles.push Method
    @needles.push Variable
    @needles.push Property
    @needles.push Mixin

  readCoffee: (file) ->
    Traverser.read(file, @)

  readExtra: (file, readme = false) ->
    content = FS.readFileSync file, 'utf-8'
    content = Markdown.convert(content) if /\.(markdown|md)$/.test file

    @extras[file] = content
    @readme = file if readme

  all: (Entity, haystack = []) ->
    for entity in @entities
      haystack.push(entity) if entity instanceof Entity
    haystack

  allFiles:   -> @_allFiles   ||= @all(File)
  allClasses: -> @_allClasses ||= @all(Class)
  allMixins:  -> @_allMixins  ||= @all(Mixin)
  allExtras:  -> @_allExtras  ||= Object.keys(@extras)
  allMethods: ->
    return @_allMethods if @_allMethods?

    @_allMethods = []

    for source in [@allFiles(), @allClasses(), @allMixins()]
      for entry in source
        for method in entry.effectiveMethods()
          @_allMethods.push {entity: method, owner: entry}

    @_allMethods.sort (a, b) ->
      return -1 if a.entity.name < b.entity.name
      return 1  if a.entity.name > b.entity.name
      return 0


  find: (Entity, name) ->
    for entity in @entities
      if entity instanceof Entity && entity.name == name
        return entity

  linkify: ->
    entity.linkify() for entity in @entities

  inspect: ->
    @entities.map (entity) -> entity.inspect()