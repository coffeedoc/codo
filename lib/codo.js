(function() {
  var Generator, Parser, findit, fs, util;

  fs = require('fs');

  util = require('util');

  findit = require('findit');

  Parser = require('./parser');

  Generator = require('./generator');

  exports.run = function() {
    var arg, args, argv, bool, codoopts, config, configs, connect, extra, filename, input, optimist, option, options, parser, port, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1, _ref2;
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
      describe: 'The readme file used',
      "default": codoopts.readme || codoopts.r || 'README.md'
    }).options('q', {
      alias: 'quiet',
      describe: 'Show no warnings',
      boolean: true,
      "default": codoopts.quiet || false
    }).options('o', {
      alias: 'output-dir',
      describe: 'The output directory',
      "default": codoopts['output-dir'] || codoopts.o || './doc'
    }).options('v', {
      alias: 'verbose',
      describe: 'Show parsing errors',
      boolean: true,
      "default": codoopts.verbose || codoopts.v || false
    }).options('h', {
      alias: 'help',
      describe: 'Show the help'
    }).options('cautious', {
      describe: 'Don\'t attempt to parse singleline comments',
      boolean: true,
      "default": codoopts.cautious || false
    }).options('s', {
      alias: 'server',
      describe: 'Start a documentation server'
    }).options('private', {
      boolean: true,
      "default": codoopts["private"] || false,
      describe: 'Show private methods'
    })["default"]('title', codoopts.title || 'CoffeeScript API Documentation');
    argv = optimist.argv;
    if (argv.h) {
      return console.log(optimist.help());
    } else if (argv.s) {
      port = argv.s === true ? 8080 : argv.s;
      connect = require('connect');
      connect.createServer(connect["static"](argv.o)).listen(port);
      return console.log('Codo documentation from %s is available at http://localhost:%d', argv.o, port);
    } else {
      options = {
        inputs: [],
        output: argv.o,
        extras: [],
        readme: argv.r,
        title: argv.title,
        quiet: argv.q,
        "private": argv["private"],
        verbose: argv.v,
        cautious: argv.cautious
      };
      extra = false;
      args = argv._.length !== 0 ? argv._ : codoopts._;
      for (_j = 0, _len1 = args.length; _j < _len1; _j++) {
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
      if (options.inputs.length === 0) {
        options.inputs.push('./src');
      }
      try {
        parser = new Parser(options);
        _ref1 = options.inputs;
        for (_k = 0, _len2 = _ref1.length; _k < _len2; _k++) {
          input = _ref1[_k];
          _ref2 = findit.sync(input);
          for (_l = 0, _len3 = _ref2.length; _l < _len3; _l++) {
            filename = _ref2[_l];
            if (filename.match(/\.coffee$/)) {
              try {
                parser.parseFile(filename);
              } catch (error) {
                if (options.verbose) {
                  throw error;
                }
                console.log("Cannot parse file " + filename + ": " + error.message);
              }
            }
          }
        }
        new Generator(parser, options).generate();
        if (!options.quiet) {
          return parser.showResult();
        }
      } catch (error) {
        if (options.verbose) {
          throw error;
        }
        return console.log("Cannot generate documentation: " + error.message);
      }
    }
  };

}).call(this);
