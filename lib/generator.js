(function() {
  var Generator, Templater, fs, ghm, mkdirp, path, _;

  fs = require('fs');

  path = require('path');

  ghm = require('github-flavored-markdown');

  mkdirp = require('mkdirp');

  _ = require('underscore');

  Templater = require('./util/templater');

  module.exports = Generator = (function() {

    function Generator(parser, options) {
      this.parser = parser;
      this.options = options;
      this.templater = new Templater(this.options);
    }

    Generator.prototype.generate = function() {
      this.generateReadme();
      this.generateClasses();
      this.generateExtras();
      this.generateIndex();
      this.generateClassList();
      this.generateMethodList();
      this.generateFileList();
      return this.copyAssets();
    };

    Generator.prototype.generateReadme = function() {
      var filename, readme;
      try {
        readme = fs.readFileSync(this.options.readme, 'utf-8');
        if (/\.(markdown|md)$/.test(this.options.readme)) {
          readme = ghm.parse(readme, this.options.github);
        }
        filename = 'index.html';
        return this.templater.render('file', {
          filename: this.options.readme,
          content: readme,
          breadcrumbs: [
            {
              href: '_index.html',
              name: 'Index'
            }, {
              href: filename,
              name: this.options.readme
            }
          ]
        }, filename);
      } catch (error) {
        return console.log("[ERROR] Cannot generate readme file " + this.options.readme + ": " + error);
      }
    };

    Generator.prototype.generateClasses = function() {
      var clazz, _i, _len, _ref, _results;
      _ref = this.parser.classes;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        clazz = _ref[_i];
        _results.push(this.templater.render('class', clazz.toJSON(), "classes/" + (clazz.getClassName().replace(/\./g, '/')) + ".html"));
      }
      return _results;
    };

    Generator.prototype.generateExtras = function() {
      var content, extra, filename, _i, _len, _ref, _results;
      _ref = _.union([this.options.readme], this.options.extras);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        extra = _ref[_i];
        try {
          content = fs.readFileSync(extra, 'utf-8');
          if (/\.(markdown|md)$/.test(extra)) {
            content = ghm.parse(content, this.options.github);
          }
          filename = "" + extra + ".html";
          _results.push(this.templater.render('file', {
            filename: extra,
            content: content,
            breadcrumbs: [
              {
                href: '_index.html',
                name: 'Index'
              }, {
                href: filename,
                name: extra
              }
            ]
          }, filename));
        } catch (error) {
          _results.push(console.log("[ERROR] Cannot generate extra file " + extra + ": " + error));
        }
      }
      return _results;
    };

    Generator.prototype.generateIndex = function() {
      var char, classes, code, sortedClasses;
      sortedClasses = {};
      for (code = 97; code <= 122; code++) {
        char = String.fromCharCode(code);
        classes = _.filter(this.parser.classes, function(clazz) {
          return clazz.getName().toLowerCase()[0] === char;
        });
        if (!_.isEmpty(classes)) sortedClasses[char] = classes;
      }
      return this.templater.render('index', {
        classes: sortedClasses,
        files: _.union([this.options.readme], this.options.extras),
        breadcrumbs: []
      }, '_index.html');
    };

    Generator.prototype.generateClassList = function() {
      return this.templater.render('class_list', {
        classes: this.parser.classes
      }, 'class_list.html');
    };

    Generator.prototype.generateMethodList = function() {
      var methods;
      methods = _.map(this.parser.getAllMethods(), function(method) {
        return {
          name: method.getName(),
          href: "classes/" + (method.clazz.getClassName().replace(/\./g, '/')) + ".html#" + (method.getName()),
          classname: method.clazz.getClassName()
        };
      });
      return this.templater.render('method_list', {
        methods: methods
      }, 'method_list.html');
    };

    Generator.prototype.generateFileList = function() {
      return this.templater.render('file_list', {
        files: _.union([this.options.readme], this.options.extras)
      }, 'file_list.html');
    };

    Generator.prototype.copyAssets = function() {
      this.copy('./theme/default/assets/codo.css', "" + this.options.output + "/assets/codo.css");
      return this.copy('./theme/default/assets/codo.js', "" + this.options.output + "/assets/codo.js");
    };

    Generator.prototype.copy = function(from, to) {
      var dir;
      dir = path.dirname(to);
      return mkdirp(dir, function(err) {
        if (err) {
          return console.error("[ERROR] Cannot create directory " + dir + ": " + err);
        } else {
          from = fs.createReadStream(from);
          to = fs.createWriteStream(to);
          return to.once('open', function(fd) {
            return require('util').pump(from, to);
          });
        }
      });
    };

    return Generator;

  })();

}).call(this);
