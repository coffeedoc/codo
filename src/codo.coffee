fs          = require('fs')
findit      = require('findit')
Parser      = require('./parser')

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
      parser.parse filename

  for clazz in parser.classes
    console.log "------------------------------------------------------------------------------------------"
    console.log "Clazz: #{ clazz.clazz() } / #{ clazz.name() } / #{ clazz.namespace() }"
    if clazz.parentClazz()
      console.log "Parent: #{ clazz.parentClazz() }"
