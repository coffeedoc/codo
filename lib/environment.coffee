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

    @needles    = []
    @entities   = []
    @references = {}
    @parsed     = {}

    @needles.push Class
    @needles.push Method
    @needles.push Variable
    @needles.push Property
    @needles.push Mixin

  readCoffee: (file) ->
    return if @parsed[file]
    Winston.info("Parsing Codo file #{file}") if @options.verbose

    try
      Traverser.read(file, @)
    catch error
      throw error if @options.debug
      Winston.error("Cannot parse Coffee file #{file}: #{error.message}") unless @options.quiet
    finally
      @parsed[file] = true

  readExtra: (file) ->
    return if @parsed[file]
    Winston.info("Parsing Extra file #{file}") if @options.verbose

    try
      @registerEntity(new Extra @, file)
    catch error
      throw error if @options.debug
      Winston.error("Cannot parse Extra file #{file}: #{error.message}") unless @options.quiet
    finally
      @parsed[file] = true

  registerEntity: (entity) ->
    @entities.push entity

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

  allVariables: ->
    return @_allVariables if @_allVariables?

    @_allVariables = []

    for source in [@allFiles(), @allClasses(), @allMixins()]
      for entry in source
        for variable in entry.variables
          @_allVariables.push {entity: variable, owner: entry}

    @_allVariables


  find: (Entity, name) ->
    for entity in @entities
      if entity instanceof Entity && entity.name == name
        return entity

  findReadme: ->
    @find Extra, Path.relative(@options.basedir, @options.readme)

  linkify: ->
    entity.linkify() for entity in @entities

    for basics in [@allFiles(), @allClasses(), @allMixins()]
      for basic in basics
        @references[basic.name] = basic

    for variable in @allVariables()
      keyword = variable.owner.name + '.' + variable.entity.name
      @references[keyword] = variable

    for method in @allMethods()
      keyword = method.owner.name + method.entity.shortSignature()
      @references[keyword] = method

  reference: (needle, context='') ->
    needle = needle.split(' ')[0]

    if @references[needle]
      @references[needle]
    else if @references[context+needle]
      @references[context+needle]
    else
      needle

  inspect: ->
    @entities.map (entity) -> entity.inspect()