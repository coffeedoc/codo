fs      = require('fs')
util    = require('util')
findit  = require('findit')

Parser  = require('./parser')

argv = require('optimist')
  .usage('Usage: $0')
  .options('i',
    alias     : 'input'
    demand    : true
    describe  : 'Set the input directory'
  )
  .options('o',
    alias     : 'output'
    describe  : 'Set the output directory'
  )
  .argv

exports.run = ->
  input  = argv.i
  output = argv.o

  parser = new Parser()

  for filename in findit.sync input
    if filename.match /\.coffee$/
      parser.parseFile filename

  console.log "Codo is not ready yet. It has been published to reserve the name on NPM."
