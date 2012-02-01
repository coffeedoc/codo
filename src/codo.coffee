fs          = require('fs')
findit      = require('findit')

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
