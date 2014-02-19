strftime    = require 'strftime'
FS          = require 'fs'
Path        = require 'path'
Templater   = require './templater'
TreeBuilder = require './tree_builder'

Theme = require './_theme'
Codo  = require '../../../lib/codo'

module.exports = class Theme.Theme

  options: [
    {name: 'private', alias: 'p', describe: 'Show privates', boolean: true, default: false}
    {name: 'analytics', alias: 'a', describe: 'The Google analytics ID', default: false}
    {name: 'title', alias: 't', describe: 'HTML Title', default: 'CoffeeScript API Documentation'}
  ]

  @compile: (environment) ->
    theme = new @(environment)
    theme.compile()

  constructor: (@environment) ->
    @templater  = new Templater(@environment.options.output)
    @referencer = new Codo.Tools.Referencer(@environment)

  compile: ->
    @templater.compileAsset('javascript/application.js')
    @templater.compileAsset('stylesheets/application.css')

    @renderAlphabeticalIndex()
    @render 'method_list', 'method_list.html'

    @renderClasses()
    @renderMixins()
    @renderFiles()
    @renderExtras()
    @renderIndex()
    @renderFuzzySearchData()

  #
  # HELPERS
  #
  awareOf: (needle) ->
    @environment.references[needle]?

  reference: (needle, prefix) ->
    @pathFor(@environment.reference(needle), undefined, prefix)

  anchorFor: (entity) ->
    if entity instanceof Codo.Meta.Method
      "#{entity.name}-#{entity.kind}"
    else if entity instanceof Codo.Entities.Property
      "#{entity.name}-property"
    else if entity instanceof Codo.Entities.Variable
      "#{entity.name}-variable"

  pathFor: (kind, entity, prefix='') ->
    unless entity?
      entity = kind
      kind = 'class'  if entity instanceof Codo.Entities.Class
      kind = 'mixin'  if entity instanceof Codo.Entities.Mixin
      kind = 'file'   if entity instanceof Codo.Entities.File
      kind = 'extra'  if entity instanceof Codo.Entities.Extra
      kind = 'method' if entity.entity instanceof Codo.Meta.Method
      kind = 'variable' if entity.entity instanceof Codo.Entities.Variable
      kind = 'property' if entity.entity instanceof Codo.Entities.Property

    switch kind
      when 'file', 'extra'
        prefix + kind + '/' + entity.name + '.html'
      when 'class', 'mixin'
        prefix + kind + '/' + entity.name.replace(/\./, '/') + '.html'
      when 'method', 'variable'
        @pathFor(entity.owner, undefined, prefix) + '#' + @anchorFor(entity.entity)
      else
        entity

  activate: (text, prefix, limit=false) ->
    text = @referencer.resolve text, (link, label) =>
      "<a href='#{@pathFor link, undefined, prefix}'>#{label}</a>"

    Codo.Tools.Markdown.convert(text, limit)

  generateBreadcrumbs: (entries = []) ->
    entries     = [entries] unless Array.isArray(entries)
    breadcrumbs = []

    if @environment.options.readme
      breadcrumbs.push
        href:  @pathFor('extra', @environment.findReadme())
        title: @environment.options.name

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
      path:        @calculatePath(destination)
      strftime:    strftime
      anchorFor:   @anchorFor
      pathFor:     @pathFor
      reference:   @reference
      awareOf:     @awareOf
      activate:    => @activate(arguments...)
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
      else if @environment.allExtras().length > 0
        'extra_list.html'
      else
        'method_list.html'

    main = if @environment.options.readme
      @pathFor('extra', @environment.findReadme())
    else
      'alphabetical_index.html'

    @render 'frames', 'index.html',
      list: list
      main: main

  renderClasses: ->
    @render 'class_list', 'class_list.html',
      tree: TreeBuilder.build @environment.allClasses(), (klass) ->
        [klass.basename, klass.namespace.split('.')]

    for klass in @environment.allClasses()
      @render 'class', @pathFor('class', klass),
        entity: klass,
        breadcrumbs: @generateBreadcrumbs(klass.name.split '.')

  renderMixins: ->
    @render 'mixin_list', 'mixin_list.html',
      tree: TreeBuilder.build @environment.allMixins(), (klass) ->
        [klass.basename, klass.namespace.split('.')]

    for mixin in @environment.allMixins()
      @render 'mixin', @pathFor('mixin', mixin),
        entity: mixin
        breadcrumbs: @generateBreadcrumbs(mixin.name.split '.')

  renderFiles: ->
    @render 'file_list', 'file_list.html',
      tree: TreeBuilder.build @environment.allFiles(), (file) ->
        [file.basename, file.dirname.split('/')]

    for file in @environment.allFiles()
      @render 'file', @pathFor('file', file),
        entity: file,
        breadcrumbs: @generateBreadcrumbs(file.name.split '/')

  renderExtras: ->
    @render 'extra_list', 'extra_list.html',
      tree: TreeBuilder.build @environment.allExtras(), (extra) ->
        result = extra.name.split('/')
        [result.pop(), result]

    for extra in @environment.allExtras()
      @render 'extra', @pathFor('extra', extra),
        entity: extra
        breadcrumbs: @generateBreadcrumbs(extra.name.split '/')

  renderFuzzySearchData: ->
    search = []
    everything = [
      @environment.allClasses(),
      @environment.allMixins(),
      @environment.allFiles(),
      @environment.allExtras()
    ]

    for basics in everything
      for basic in basics
        search.push
          t: basic.name
          p: @pathFor(basic)

    for method in @environment.allMethods()
      search.push
        t: "#{method.owner.name}#{method.entity.shortSignature()}"
        p: @pathFor(method)

    content = 'window.searchData = ' + JSON.stringify(search)
    output  = Path.join(@environment.options.output, 'javascript', 'search.js')

    FS.writeFileSync output, content