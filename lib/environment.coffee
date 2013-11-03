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
walkdir   = require 'walkdir'
Winston   = require 'winston'

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

    @name        ?= 'Unknown Project'
    @verbose     ?= false
    @debug       ?= false
    @cautios     ?= false
    @quiet       ?= false
    @destination ?= 'doc'
    @basedir     ?= process.cwd()
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
    try
      Traverser.read(file, @, !@cautios)
    catch error
      throw error if @debug
      Winston.error("Cannot parse Coffee file #{file}: #{error.message}") unless @quiet

  readExtra: (file, readme = false) ->
    try
      content = FS.readFileSync file, 'utf-8'

      content = if /\.(markdown|md)$/.test file
        Markdown.convert(content)
      else
        content.replace(/\n/g, '<br/>')

      @extras[Path.relative @basedir, file] = content
      @readme = file if readme
    catch error
      throw error if @debug
      Winston.error("Cannot parse Extra file #{file}: #{error.message}") unless @quiet

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