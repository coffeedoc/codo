fs         = require 'fs'
path       = require 'path'
walkdir    = require 'walkdir'

# The theme knows where all the templates and assets are.
#
module.exports = class Theme

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
  # @param [String] template the name of the template
  # @return [String] the template's uncompiled code
  #
  templateSource: (template) ->
    @sources[template]

  # The type (file extension) for a template.
  #
  # @param [String] template the name of the template
  # @return [String] the template's type (e.g. "hamlc")
  #
  templateType: (template) ->
    @types[template]

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
    return

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
    return

  # Checks if a path represents a file that is part of the theme.
  #
  # @param [String] path the path to be checked
  # @return [Boolean] true if the path points to a theme file
  #
  isThemeFile: (filePath) ->
    return false if path.basename(filePath)[0] == '.'
    return false if fs.statSync(filePath).isDirectory()

    true
