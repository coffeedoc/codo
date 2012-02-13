(function() {
  var Parser, argv, findit, fs;

  fs = require('fs');

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
    var clazz, filename, input, output, parser, _i, _j, _len, _len2, _ref, _ref2, _results;
    input = argv.i;
    output = argv.o;
    parser = new Parser();
    _ref = findit.sync(input);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      filename = _ref[_i];
      if (filename.match(/\.coffee$/)) parser.parse(filename);
    }
    _ref2 = parser.classes;
    _results = [];
    for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
      clazz = _ref2[_j];
      _results.push(console.log("Clazz: " + (clazz.clazz()) + " / " + (clazz.name()) + " / " + (clazz.namespace())));
    }
    return _results;
  };

}).call(this);
