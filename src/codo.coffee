fs        = require('fs')
util      = require('util')
findit    = require('findit')
Parser    = require('./parser')
Generator = require('./generator')

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
      describe  : 'The readme file used.'
      default   : codoopts.readme || codoopts.r || 'README.md'
    )
    .options('q',
      alias     : 'quiet'
      describe  : 'Show no warnings.'
      boolean   : true
      default   : codoopts.quiet || false
    )
    .options('o',
      alias     : 'output-dir'
      describe  : 'The output directory.'
      default   : codoopts['output-dir'] || codoopts.o || './doc'
    )
    .options('g',
      alias     : 'github'
      describe  : 'The GitHub repository.'
      default   : codoopts['github'] || codoopts.g || ''
    )
    .options('h',
      alias     : 'help'
      describe  : 'Show the help.'
    )
    .options('private',
      boolean   : true
      default   : codoopts.private || false
      describe  : 'Show private methods'
    )
    .default('title', codoopts.title || 'CoffeeScript API Documentation')

  argv     = optimist.argv

  if argv.h
    console.log optimist.help()

  else
    options =
      inputs: []
      output: argv.o
      extras: []
      readme: argv.r
      title: argv.title
      quiet: argv.q
      private: argv.private
      github: argv.g

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
              console.log "Cannot parse file #{ filename }: #{ error.message }"

      new Generator(parser, options).generate()
      parser.showResult() unless options.quiet

    catch error
      console.log "Cannot generate documentation: #{ error.message }"
