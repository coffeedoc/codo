fs        = require 'fs'
util      = require 'util'
findit    = require 'findit'
Parser    = require './parser'
Generator = require './generator'

exports.run = ->

  codoopts =
    _ : []

  # Read .codoopts project defaults
  try
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

  optimist = require('optimist')
    .usage('Usage: $0 [options] [source_files [- extra_files]]')
    .options('r',
      alias     : 'readme'
      describe  : 'The readme file used'
      default   : codoopts.readme || codoopts.r || 'README.md'
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
      readme: argv.r
      title: argv.title
      quiet: argv.q
      private: argv.private
      verbose: argv.v
      debug: argv.d
      cautious: argv.cautious

    extra = false

    args = if argv._.length isnt 0 then argv._ else codoopts._

    for arg in args
      if arg is '-'
        extra = true
      else
        if extra then options.extras.push(arg) else options.inputs.push(arg)

    options.inputs.push './src' if options.inputs.length is 0

    try
      parser = new Parser(options)

      for input in options.inputs
        for filename in findit.sync input
          if filename.match /\.coffee$/
            try
              parser.parseFile filename
            catch error
              throw error if options.debug
              console.log "Cannot parse file #{ filename }: #{ error.message }"

      new Generator(parser, options).generate()
      parser.showResult() unless options.quiet

    catch error
      throw error if options.debug
      console.log "Cannot generate documentation: #{ error.message }"
