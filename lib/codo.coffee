FS          = require 'fs'
Path        = require 'path'
walkdir     = require 'walkdir'
Winston     = require 'winston'

Environment = require './environment'
File        = require './entities/file'
Class       = require './entities/class'
Method      = require './entities/method'
Variable    = require './entities/variable'
Property    = require './entities/property'
Mixin       = require './entities/mixin'
Extra       = require './entities/extra'


module.exports = Codo =
  Environment: Environment

  Entities:
    File: File
    Class: Class
    Method: Method
    Variable: Variable
    Property: Property
    Mixin: Mixin
    Extra: Extra

  version: ->
    JSON.parse(
      FS.readFileSync(Path.join(__dirname, '..', 'package.json'), 'utf-8')
    )['version']

  parseProject: (path, options={}) ->
    options.name    ||= @detectName(path)
    options.readme  ||= @detectReadme(path)
    options.basedir ||= path

    environment = new @Environment(options)

    for extra in (options.extras || @detectExtras(path))
      environment.readExtra(Path.join path, extra)

    for input in (options.inputs || [path])
      if FS.existsSync(input)
        if FS.lstatSync(input).isDirectory()
          for filename in walkdir.sync(input) when filename.match(/\._?coffee$/)
            environment.readCoffee(filename)
        else
          environment.readCoffee(Path.resolve input)
      else
        Winston.warn("#{input} (#{Path.join process.cwd(), input}) skipped – does not exist")

    environment.linkify()
    environment

  detectDefaults: (path) ->
    results =
      _: []

    try
      if FS.existsSync(Path.join path, '.codoopts')
        configs = FS.readFileSync Path.join(path, '.codoopts'), 'utf8'

        for config in configs.split('\n')
          # Key value configs
          if option = /^-{1,2}([\w-]+)\s+(['"])?(.*?)\2?$/.exec config
            results[option[1]] = option[3]

          # Boolean configs
          else if bool = /^-{1,2}([\w-]+)\s*$/.exec config
            results[bool[1]] = true

          # Argv configs
          else if config != ''
            results._.push(config)

      results

    catch error
      Winston.error("Cannot parse .codoopts file: #{error.message}") unless @quiet


  # Find the project name by either parse `package.json`
  # or get the current working directory name.
  #
  detectName: (path) ->
    if FS.existsSync(Path.join path, 'package.json')
      name = JSON.parse(FS.readFileSync Path.join(path, 'package.json'), 'utf-8')['name']

    else if FS.existsSync(Path.join path, '.git', 'config')
      config = fs.readFileSync(Path.join(path, '.git', 'config'), 'utf-8')
      name   = /github\.com[:/][^/]+\/(.*)\.git/.exec(config)?[1]

    else
      name = Path.basename(path)

    return name.charAt(0).toUpperCase() + name.slice(1)

  # Find the project README.
  #
  detectReadme: (path) ->
    attempts = [
      'README.markdown'
      'README.md'
      'README'
    ]

    return attempt for attempt in attempts when FS.existsSync(Path.join path, attempt)

  # Find extra project files.
  #
  detectExtras: (path) ->
    [
      'CHANGELOG'
      'CHANGELOG.markdown'
      'CHANGELOG.md'
      'AUTHORS'
      'AUTHORS.md'
      'AUTHORS.markdown'
      'LICENSE'
      'LICENSE.md'
      'LICENSE.markdown'
      'LICENSE.MIT'
      'LICENSE.GPL'
      'README.markdown'
      'README.md'
      'README'
    ].filter (attempt) -> FS.existsSync(Path.join path, attempt)
