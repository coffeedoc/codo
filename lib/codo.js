(function() {
  var Generator, Parser, findit, fs, util;

  fs = require('fs');

  util = require('util');

  findit = require('findit');

  Parser = require('./parser');

  Generator = require('./generator');

  exports.run = function() {
    var arg, args, argv, bool, codoopts, config, configs, extra, filename, input, optimist, option, options, parser, _i, _j, _k, _l, _len, _len2, _len3, _len4, _ref, _ref2, _ref3;
    codoopts = {
      _: []
    };
    try {
      configs = fs.readFileSync('.codoopts', 'utf8');
      _ref = configs.split('\n');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        config = _ref[_i];
        if (option = /^-{1,2}([\w-]+)\s+(['"])?(.*?)\2?$/.exec(config)) {
          codoopts[option[1]] = option[3];
        } else if (bool = /^-{1,2}([\w-]+)\s*$/.exec(config)) {
          codoopts[bool[1]] = true;
        } else if (config !== '') {
          codoopts._.push(config);
        }
      }
    } catch (_error) {}
    optimist = require('optimist').usage('Usage: $0 [options] [source_files [- extra_files]]').options('r', {
      alias: 'readme',
      describe: 'The readme file used.',
      "default": codoopts.readme || codoopts.r || 'README.md'
    }).options('q', {
      alias: 'quiet',
      describe: 'Show no warnings.',
      boolean: true,
      "default": codoopts.quiet || false
    }).options('o', {
      alias: 'output-dir',
      describe: 'The output directory.',
      "default": codoopts['output-dir'] || codoopts.o || './doc'
    }).options('h', {
      alias: 'help',
      describe: 'Show the help.'
    }).options('private', {
      boolean: true,
      "default": codoopts.private || false,
      describe: 'Show private methods'
    })["default"]('title', codoopts.title || 'CoffeeScript API Documentation');
    argv = optimist.argv;
    if (argv.h) {
      return console.log(optimist.help());
    } else {
      options = {
        inputs: [],
        output: argv.o,
        extras: [],
        readme: argv.r,
        title: argv.title,
        quiet: argv.q,
        private: argv.private
      };
      extra = false;
      args = argv._.length !== 0 ? argv._ : codoopts._;
      for (_j = 0, _len2 = args.length; _j < _len2; _j++) {
        arg = args[_j];
        if (arg === '-') {
          extra = true;
        } else {
          if (extra) {
            options.extras.push(arg);
          } else {
            options.inputs.push(arg);
          }
        }
      }
      if (options.inputs.length === 0) options.inputs.push('./src');
      parser = new Parser(options);
      _ref2 = options.inputs;
      for (_k = 0, _len3 = _ref2.length; _k < _len3; _k++) {
        input = _ref2[_k];
        _ref3 = findit.sync(input);
        for (_l = 0, _len4 = _ref3.length; _l < _len4; _l++) {
          filename = _ref3[_l];
          if (filename.match(/\.coffee$/)) {
            try {
              parser.parseFile(filename);
            } catch (error) {
              console.log("Cannot parse file " + filename + ": " + error.message);
            }
          }
        }
      }
      new Generator(parser, options).generate();
      if (!options.quiet) return parser.showResult();
    }
  };

}).call(this);
