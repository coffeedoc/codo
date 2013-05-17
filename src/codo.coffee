fs        = require 'fs'
util      = require 'util'
path      = require 'path'
walkdir   = require 'walkdir'
Async     = require 'async'
_         = require 'underscore'

Parser    = require './parser'
Generator = require './generator'

# Codo - the CoffeeScript API documentation generator
#
module.exports = class Codo

  # Get the current Codo version
  #
  # @return [String] the Codo version
  #
  @version: ->
    'v' + JSON.parse(fs.readFileSync(path.join(__dirname, '..', 'package.json'), 'utf-8'))['version']

  # Run the documentation generator. This is usually done through
  # the command line utility `codo` that is provided by this package.
  #
  # You can also run the documentation generation without writing files
  # to the file system, by supplying a callback function.
  #
  # @example Run generation
  #   codo = require 'codo'
  #
  #   file = (filename, content) ->
  #     console.log "New file %s with content %s", filename, content
  #
  #   done = (err) ->
  #     if err
  #       console.log "Cannot generate documentation:", err
  #     else
  #       console.log "Documentation generated"
  #
  #   codo.run file, done
  #
  # @param [Function] done the documentation done callback
  # @param [Function] file the new file callback
  # @param [String] analytics the Google analytics tracking code
  # @param [String] homepage the homepage in the breadcrumbs
  #
  @run: (done, file, analytics = false, homepage = false) ->

    codoopts =
      _ : []

    # Read .codoopts project defaults
    try
      if (fs.existsSync || path.existsSync)('.codoopts')
        configs = fs.readFileSync '.codoopts', 'utf8'

        for config in configs.split('\n')
          # Key value configs
          if option = /^-{1,2}([\w-]+)\s+(['"])?(.*?)\2?$/.exec config
            codoopts[option[1]] = option[3]
          # Boolean configs
          else if bool = /^-{1,2}([\w-]+)\s*$/.exec config
            codoopts[bool[1]] = true
          # Argv configs
          else if config isnt ''
            codoopts._.push config


      Async.parallel {
        inputs:  @detectSources
        readme:  @detectReadme
        extras:  @detectExtras
        name:    @detectName
      },
      (err, defaults) ->

        extraUsage = if defaults.extras.length is 0 then '' else  "- #{ defaults.extras.join ' ' }"

        optimist = require('optimist')
          .usage("""
          Usage:   $0 [options] [source_files [- extra_files]]
          Default: $0 [options] #{ defaults.inputs.join ' ' } #{ extraUsage }
          """)
          .options('r',
            alias     : 'readme'
            describe  : 'The readme file used'
            default   : codoopts.readme || codoopts.r || defaults.readme
          )
          .options('n',
            alias     : 'name'
            describe  : 'The project name used'
            default   : codoopts.name || codoopts.n || defaults.name
          )
          .options('q',
            alias     : 'quiet'
            describe  : 'Show no warnings'
            boolean   : true
            default   : codoopts.quiet || false
          )
          .options('o',
            alias     : 'output-dir'
            describe  : 'The output directory'
            default   : codoopts['output-dir'] || codoopts.o || './doc'
          )
          .options('a',
            alias     : 'analytics'
            describe  : 'The Google analytics ID'
            default   : codoopts.analytics || codoopts.a || false
          )
          .options('v',
            alias     : 'verbose'
            describe  : 'Show parsing errors'
            boolean   : true
            default   : codoopts.verbose || codoopts.v  || false
          )
          .options('d',
            alias     : 'debug'
            describe  : 'Show stacktraces and converted CoffeeScript source'
            boolean   : true
            default   : codoopts.debug || codoopts.d  || false
          )
          .options('h',
            alias     : 'help'
            describe  : 'Show the help'
          )
          .options('cautious',
            describe  : 'Don\'t attempt to parse singleline comments'
            boolean   : true
            default   : codoopts.cautious || false
          )
          .options('s',
            alias     : 'server'
            describe  : 'Start a documentation server'
          )
          .options('private',
            boolean   : true
            default   : codoopts.private || false
            describe  : 'Show private methods'
          )
          .options('closure',
            boolean   : true
            default   : codoopts.closure || false
            describe  : 'Try to parse closure-like block comments'
          )
          .default('title', codoopts.title || 'CoffeeScript API Documentation')

        argv = optimist.argv

        if argv.h
          console.log optimist.help()

        else if argv.s
          port = if argv.s is true then 8080 else argv.s
          connect = require 'connect'
          connect.createServer(connect.static(argv.o)).listen port
          console.log 'Codo documentation from %s is available at http://localhost:%d', argv.o, port

        else
          options =
            inputs: []
            output: argv.o
            extras: []
            name: argv.n
            readme: argv.r
            title: argv.title
            quiet: argv.q
            private: argv.private
            verbose: argv.v
            debug: argv.d
            cautious: argv.cautious
            closure: argv.closure
            homepage: homepage
            analytics: analytics || argv.a

          extra = false

          # ignore params if codo has not been started directly
          args = if argv._.length isnt 0 and /.+codo$/.test(process.argv[1]) then argv._ else codoopts._


          for arg in args
            if arg is '-'
              extra = true
            else
              if extra then options.extras.push(arg) else options.inputs.push(arg)

          options.inputs = defaults.inputs if options.inputs.length is 0
          options.extras = defaults.extras if options.extras.length is 0

          parser = new Parser(options)

          for input in options.inputs
            if (fs.existsSync || path.existsSync)(input)
              stats = fs.lstatSync input

              if stats.isDirectory()
                for filename in walkdir.sync input
                  if filename.match /\._?coffee$/
                    try
                      parser.parseFile filename.substring process.cwd().length + 1
                    catch error
                      throw error if options.debug
                      console.log "Cannot parse file #{ filename }: #{ error.message }"
              else
                if input.match /\._?coffee$/
                  try
                    parser.parseFile input
                  catch error
                    throw error if options.debug
                    console.log "Cannot parse file #{ filename }: #{ error.message }"

          new Generator(parser, options).generate(file)
          parser.showResult() unless options.quiet
          done() if done

    catch error
      done(error) if done
      console.log "Cannot generate documentation: #{ error.message }"
      throw error

  # Get the Codo script content that is used in the webinterface
  #
  # @return [String] the script content
  #
  @script: ->
    @codoScript or= fs.readFileSync path.join(__dirname, '..', 'theme', 'default', 'assets', 'codo.js'), 'utf-8'

  # Get the Codo style content that is used in the webinterface
  #
  # @return [String] the style content
  #
  @style: ->
    @codoStyle or= fs.readFileSync path.join(__dirname, '..', 'theme', 'default', 'assets', 'codo.css'), 'utf-8'

  # Find the source directories.
  #
  @detectSources: (done) ->
    Async.filter [
      'src'
      'lib'
      'app'
    ], (fs.exists || path.exists), (results) ->
      results.push '.' if results.length is 0
      done null, results

  # Find the project README.
  #
  @detectReadme: (done) ->
    Async.filter [
      'README.markdown'
      'README.md'
      'README'
      'readme.markdown'
      'readme.md'
      'readme'
    ], (fs.exists || path.exists), (results) -> done null, _.first(results) || ''

  # Find extra project files.
  #
  @detectExtras: (done) ->
    Async.filter [
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
    ], (fs.exists || path.exists), (results) -> done null, results

  # Find the project name by either parse `package.json`
  # or get the current working directory name.
  #
  @detectName: (done) ->
    if (fs.exists || path.exists)('package.json')
      name = JSON.parse(fs.readFileSync(path.join(__dirname, '..', 'package.json'), 'utf-8'))['name']
    else if (fs.exists || path.exists)(path.join('.git', 'config'))
      gitconfig = fs.readFileSync(path.join(__dirname, '.git', 'config'), 'utf-8')
      name = /github\.com[:/][^/]+\/(.*)\.git/.exec(gitconfig)?[1]
    else
      name = path.basename(process.cwd())

    done null, name.charAt(0).toUpperCase() + name.slice(1)
