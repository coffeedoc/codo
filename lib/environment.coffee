FS        = require 'fs'
Path      = require 'path'
Traverser = require './traverser'

File      = require './entities/file'
Class     = require './entities/class'
Method    = require './entities/method'
Variable  = require './entities/variable'
Property  = require './entities/property'
Mixin     = require './entities/mixin'
Extra     = require './entities/extra'
walkdir   = require 'walkdir'
Winston   = require 'winston'

module.exports = class Environment

  @read: (files, options={}) ->
    files       = [files] unless Array.isArray(files)
    environment = new @(options)

    environment.readCoffee(file) for file in files
    environment.linkify()
    environment

  constructor: (@options={}) ->
    @version = JSON.parse(
      FS.readFileSync(Path.join(__dirname, '..', 'package.json'), 'utf-8')
    )['version']

    @options.name    ?= 'Unknown Project'
    @options.verbose ?= false
    @options.debug   ?= false
    @options.cautios ?= false
    @options.quiet   ?= false
    @options.closure ?= false
    @options.output  ?= 'doc'
    @options.basedir ?= process.cwd()

    @needles  = []
    @entities = []

    @needles.push Class
    @needles.push Method
    @needles.push Variable
    @needles.push Property
    @needles.push Mixin

  readCoffee: (file) ->
    Winston.info("Parsing Codo file #{file}") if @options.verbose

    try
      Traverser.read(file, @)
    catch error
      throw error if @options.debug
      Winston.error("Cannot parse Coffee file #{file}: #{error.message}") unless @options.quiet

  readExtra: (file) ->
    Winston.info("Parsing Extra file #{file}") if @options.verbose

    try
      @entities.push(new Extra @, file)
    catch error
      throw error if @options.debug
      Winston.error("Cannot parse Extra file #{file}: #{error.message}") unless @options.quiet

  all: (Entity, haystack = []) ->
    for entity in @entities
      haystack.push(entity) if entity instanceof Entity
    haystack

  allFiles:   -> @_allFiles   ||= @all(File)
  allClasses: -> @_allClasses ||= @all(Class)
  allMixins:  -> @_allMixins  ||= @all(Mixin)
  allExtras:  -> @_allExtras  ||= @all(Extra)
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

  findReadme: ->
    @find Extra, @options.readme

  linkify: ->
    entity.linkify() for entity in @entities

  inspect: ->
    @entities.map (entity) -> entity.inspect()