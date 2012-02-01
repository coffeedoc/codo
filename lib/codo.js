(function() {
  var argv, findit, fs;

  fs = require('fs');

  findit = require('findit');

  argv = require('optimist').usage('Usage: $0').options('i', {
    alias: 'input',
    demand: true,
    describe: 'Set the input directory'
  }).options('o', {
    alias: 'output',
    describe: 'Set the output directory'
  }).argv;

  exports.run = function() {
    var input, output;
    input = argv.i;
    return output = argv.o;
  };

}).call(this);
