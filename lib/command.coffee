Codo     = require './codo'
Optimist = require 'optimist'
Theme    = require '../themes/default/lib/theme'

module.exports = class Command
  options: [
    {name: 'help', alias: 'h', describe: 'Show this help'}
    {name: 'version', describe: 'Show version'}
    {name: 'destination', alias: 'o', describe: 'The output directory', default: './doc'}
    {name: 'theme', describe: 'The theme to be used', default: 'default'}
    {name: 'name', alias: 'n', describe: 'The project name used'}
    {name: 'readme', alias: 'r', describe: 'The readme file used'}
    {name: 'quiet', alias: 'q', describe: 'Supress warnings', boolean: true, default: false}
    {name: 'verbose', alias: 'v', describe: 'Show parsing errors', boolean: true, default: false}
    {name: 'undocumented', alias: 'u', describe: 'List undocumented objects', boolean: true, default: false}
    {name: 'closure', describe: 'Try to parse closure-like block comments', boolean: true, default: false}
    {name: 'debug', alias: 'd', boolean: true}
  ]

  @run: ->
    new @

  extendOptimist: (optimist, defaults={}, options={}) ->
    for option in options
      optimist.options option.name,
        alias: option.alias,
        describe: option.describe,
        boolean: option.boolean,
        default: defaults[option.name] || defaults[option.alias] || option.default

  lookupTheme: (name) ->
    @theme = Theme if name == 'default'

  prepareOptions: (optimist, defaults) ->
    options = optimist.argv
    options._.push entry for entry in defaults._

    keyword = 'inputs'
    for entry in options._
      if entry == '-'
        keyword = 'extras'
      else
        options[keyword] ?= []
        options[keyword].push entry

    delete options._

    options

  constructor: ->
    defaults = Codo.detectDefaults(process.cwd())

    optimist = Optimist.usage("Usage:   $0 [options] [source_files [- extra_files]]")
    @extendOptimist(optimist, defaults, @options)

    @theme = @lookupTheme(optimist.argv.theme)
    @extendOptimist(optimist, defaults, @theme::options)

    @options = @prepareOptions(optimist, defaults)

    if @options.help
      console.log optimist.help()
    else if @options.version
      console.log Codo.version()
    else
      @generate()

  generate: ->
    @theme.compile(Codo.parseProject(process.cwd(), @options))