(function() {
  var Generator, Templater, fs, ghm, mkdirp, path;

  fs = require('fs');

  path = require('path');

  ghm = require('github-flavored-markdown');

  mkdirp = require('mkdirp');

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
      return this.copyAssets();
    };

    Generator.prototype.generateReadme = function() {
      var readme;
      try {
        readme = fs.readFileSync(this.options.readme, 'utf-8');
        if (/\.(markdown|md)$/.test(this.options.readme)) {
          readme = ghm.parse(readme, this.options.github);
        }
        return this.templater.render('file', {
          filename: this.options.readme,
          content: readme
        }, 'index.html');
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
      var content, extra, _i, _len, _ref, _results;
      _ref = this.options.extras;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        extra = _ref[_i];
        try {
          content = fs.readFileSync(extra, 'utf-8');
          if (/\.(markdown|md)$/.test(extra)) {
            content = ghm.parse(content, this.options.github);
          }
          _results.push(this.templater.render('file', {
            filename: extra,
            content: content
          }, "" + extra + ".html"));
        } catch (error) {
          _results.push(console.log("[ERROR] Cannot generate extra file " + extra + ": " + error));
        }
      }
      return _results;
    };

    Generator.prototype.generateIndex = function() {
      return this.templater.render('index', {
        classes: this.parser.classes
      }, '_index.html');
    };

    Generator.prototype.copyAssets = function() {
      this.copy('./theme/default/assets/codo.css', "" + this.options.output + "/style/codo.css");
      return this.copy('./theme/default/assets/codo.js', "" + this.options.output + "/script/codo.js");
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
