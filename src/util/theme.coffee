fs      = require 'fs'
path    = require 'path'
walkdir = require 'walkdir'

# The theme knows where all the templates and assets are.
#
module.exports = class Theme

  # Look up and load a theme.
  #
  # @param [String] name the theme's name
  # @param [Object] options the options
  # @return [Theme] an instance of the loaded theme, or null if the theme could
  #   not be found
  @build: (name, options) ->
    themePath = path.join(__dirname, '..', '..', 'theme', options.theme)
    if fs.existsSync themePath
      new Theme themePath, options
    else
      try
        # First try loading the theme from npm paths.
        themeClass = require "codo-theme-#{name}"
      catch requireError
        # Then try loading from the current directory's node_modules.
        try
          themeClass = require path.resolve("node_modules/codo-theme-#{name}")
        catch requireError
          console.log requireError
          return null

      new themeClass(options)

  # Construct a filesystem-based theme.
  #
  # @param [String] root the path to the theme's root directory
  # @param [Object] options the options
  #
  constructor: (@root, @options) ->
    @assetPath = path.join(@root, 'assets')
    @loadTemplates()
    @loadAssets()

  # The names of the templates in this theme.
  #
  # @return [Array<String>] the names of the templates
  #
  templates: ->
    @templateNames

  templatePath: (template) ->
    @paths[template]

  # The uncompiled source code for a template.
  #
  # Theme users should call {#compiledTemplate}.
  #
  # @param [String] template the name of the template
  # @return [String] the template's uncompiled code
  #
  templateSource: (template) ->
    @sources[template]

  # The type (file extension) for a template.
  #
  # Theme users should call {#compiledTemplate}.
  #
  # @param [String] template the name of the template
  # @return [String] the template's type (e.g. "hamlc")
  #
  templateType: (template) ->
    @types[template]

  # Helper for compiling a template.
  #
  # Theme users should call {#compiledTemplate}. This method is an extension
  # point for Theme subclasses.
  #
  # @param [String] source the template source code to be compiled
  # @param [String] type the source code type (e.g. "hamlc")
  # @return [function(Object)] the compiled template, as a function that takes
  #   in the context for variable resolution and returns a String containing
  #   the template output
  #
  compileSource: (source, type) ->
    switch type
      when 'hamlc'
        hamlc.compile(source, escapeAttributes: false)
      when 'eco'
        eco.compile(source)
      else
        throw new Error("Unimplemented template type #{type}")

  # The compiled version of a template.
  #
  # @param [String] template the name of the template
  # @return [function(Object)] the compiled template, as a function that takes
  #   in the context for variable resolution and returns a String containing
  #   the template output
  #
  compiledTemplate: (template) ->
    source = @templateSource(template)
    type = @templateType(template)
    @compileSource source, type

  # The output extension for a template.
  #
  # @param [String] template the name of the template
  # @return [String] the extension for files output using the template (e.g.
  #   "html")
  #
  templateOutput: (template) ->
    @outputs[template]

  # The names of the assets in this theme.
  #
  # @return [Array<String>] the names of the assets
  #
  assets: ->
    @assetNames

  # The contents of the JavaScript used in this theme.
  #
  # @return [String] contents of the codo.js JavaScript file
  #
  javaScript: ->
    @assetSources['codo.js']

  # The contents of the CSS stylesheet used in this theme.
  #
  # @return [String] contents of the codo.css stylesheet
  #
  styleSheet: ->
    @assetSources['codo.css']

  # @property [String] the path to the theme's directory of static assets
  assetPath: null

  # Caches the templates in this theme.
  #
  # @private
  #
  loadTemplates: ->
    @sources = {}
    @types = {}
    @paths = {}
    @outputs = {}
    @templateNames = []

    templatesPath = path.join(@root, 'templates')

    for filePath in walkdir.sync(templatesPath)
      continue unless @isThemeFile(filePath)

      template = path.relative(templatesPath, filePath)
      template = template.split(path.sep).join('/')
      templateType = 'hamlc'
      outputType = 'html'
      # Extract the template type.
      typeIndex = template.lastIndexOf('.')
      if typeIndex isnt -1
        templateType = template.substring typeIndex + 1
        template = template.substring 0, typeIndex
      # Extract the output type.
      outputIndex = template.lastIndexOf('.')
      if outputIndex isnt -1
        outputType = template.substring outputIndex + 1
        template = template.substring 0, outputIndex

      @templateNames.push(template)
      @paths[template] = filePath
      @types[template] = templateType
      @outputs[template] = outputType
      @sources[template] = fs.readFileSync(filePath, 'utf-8')

  # Caches the static assets in this theme.
  #
  # @private
  #
  loadAssets: ->
    @assetSources = {}
    @assetNames = []

    for filePath in walkdir.sync(@assetPath)
      continue unless @isThemeFile(filePath)

      asset = path.relative(@assetPath, filePath)
      @assetNames.push(asset)
      @assetSources[asset] = fs.readFileSync(filePath, 'utf-8')

  # Checks if a path represents a file that is part of the theme.
  #
  # @param [String] path the path to be checked
  # @return [Boolean] true if the path points to a theme file
  #
  isThemeFile: (filePath) ->
    !(path.basename(filePath)[0] == '.') && !fs.statSync(filePath).isDirectory()
