(function() {
  var Parser, argv, findit, fs, util;

  fs = require('fs');

  util = require('util');

  findit = require('findit');

  Parser = require('./parser');

  argv = require('optimist').usage('Usage: $0').options('i', {
    alias: 'input',
    demand: true,
    describe: 'Set the input directory'
  }).options('o', {
    alias: 'output',
    describe: 'Set the output directory'
  }).argv;

  exports.run = function() {
    var filename, input, output, parser, _i, _len, _ref;
    input = argv.i;
    output = argv.o;
    parser = new Parser();
    _ref = findit.sync(input);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      filename = _ref[_i];
      if (filename.match(/\.coffee$/)) parser.parseFile(filename);
    }
    return console.log("Codo is not ready yet. It has been published to reserve the name on NPM.");
  };

}).call(this);
