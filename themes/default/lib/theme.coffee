Path        = require 'path'
Templater   = require './templater'
TreeBuilder = require './tree_builder'

File      = require '../../../lib/entities/file'
Class     = require '../../../lib/entities/class'
Method    = require '../../../lib/entities/method'
Variable  = require '../../../lib/entities/variable'
Property  = require '../../../lib/entities/property'
Mixin     = require '../../../lib/entities/mixin'

module.exports = class Theme

  @compile: (environment, options={}) ->
    theme = new @(environment, options)
    theme.compile()

  constructor: (@environment, @options) ->
    @options.title ||= 'CoffeeScript API Documentation'
    @templater = new Templater(@environment.destination)

  compile: ->
    @templater.compileAsset('javascript/application.js')
    @templater.compileAsset('stylesheets/application.css')

    @renderAlphabeticalIndex()

    @render 'class_list', 'class_list.html',
      tree: TreeBuilder.build @environment.allClasses(), (klass) ->
        [klass.basename, klass.namespace.split('.')]

    @render 'mixin_list', 'mixin_list.html',
      tree: TreeBuilder.build @environment.allMixins(), (klass) ->
        [klass.basename, klass.namespace.split('.')]

    @render 'file_list', 'file_list.html',
      tree: TreeBuilder.build @environment.allFiles(), (file) ->
        [file.basename, file.dirname.split('/')]

    @render 'extra_list', 'extra_list.html',
      tree: TreeBuilder.build @environment.allExtras(), (extra) ->
        result = extra.split('/')
        [result.pop(), result]

    for file in @environment.allFiles()
      @render 'file', @pathFor('file', file), entity: file

    for klass in @environment.allClasses()
      @render 'class', @pathFor('class', klass), entity: klass

    for mixin in @environment.allMixins()
      @render 'mixin', @pathFor('mixin', mixin), entity: mixin


    @render 'method_list', 'method_list.html'

    for extra, content of @environment.extras
      @render 'extra', @pathFor('extra', extra),
        content: content
        breadcrumbs: @generateBreadcrumbs(extra.split '/')

    @renderIndex()

  #
  # HELPERS
  #

  pathFor: (kind, entity, prefix='') ->
    unless entity?
      entity = kind
      kind = 'class' if entity instanceof Class
      kind = 'mixin' if entity instanceof Mixin
      kind = 'file'  if entity instanceof File
      kind = 'extra' unless entity

    switch kind
      when 'extra'
        prefix + kind + '/' + entity + '.html'
      when 'file'
        prefix + kind + '/' + entity.name + '.html'
      when 'class', 'mixin'
        prefix + kind + '/' + entity.name.replace(/\./, '/') + '.html'

  generateBreadcrumbs: (entries = []) ->
    entries     = [entries] unless Array.isArray(entries)
    breadcrumbs = []

    if @environment.readme
      breadcrumbs.push
        href:  @pathFor('extra', @environment.readme)
        title: @environment.name

    breadcrumbs.push(href: 'alphabetical_index.html', title: 'Index')

    for entry in entries
      if entry instanceof Object
        breadcrumbs.push entry
      else
        breadcrumbs.push {title: entry}

    breadcrumbs

  calculatePath: (filename) ->
    dirname = Path.dirname(filename)
    dirname.split('/').map(-> '..').join('/')+'/' unless dirname == '.'

  render: (source, destination, context={}) ->
    globalContext =
      environment: @environment
      options:     @options
      path:        @calculatePath(destination)
      pathFor:     @pathFor
      render:      (template, context={}) =>
        context[key] = value for key, value of globalContext
        @templater.render template, context

    context[key] = value for key, value of globalContext
    @templater.render source, context, destination

  #
  # RENDERERS
  #

  # Generate the alphabetical index of all classes and mixins.
  #
  renderAlphabeticalIndex: ->
    classes = {}
    mixins  = {}
    files   = {}

    # Sort in character group
    for code in [97..122]
      char = String.fromCharCode(code)
      map  = [
        [@environment.allClasses(), classes],
        [@environment.allMixins(), mixins],
        [@environment.allFiles(), files]
      ]

      for [list, storage] in map
        for entry in list
          if entry.basename.toLowerCase()[0] == char
            storage[char] ?= []
            storage[char].push(entry) 

    @render 'alphabetical_index', 'alphabetical_index.html',
      classes: classes
      mixins:  mixins
      files:   files

  renderIndex: ->
    list = if @environment.allClasses().length > 0
        'class_list.html'
      else if @environment.allFiles().length > 0
        'file_list.html'
      else if @environment.allMixins().length > 0
        'mixin_list.html'
      else if @environment.allMethods().length > 0
        'method_list.html'
      else
        'extra_list.html'

    main = if @environment.readme
      @pathFor('extra', @environment.readme)
    else
      'alphabetical_index.html'

    @render 'frames', 'index.html',
      list: list
      main: main