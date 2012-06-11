(function() {
  var Templater, fs, hamlc, mkdirp, path, walkdir, _;

  fs = require('fs');

  path = require('path');

  mkdirp = require('mkdirp');

  _ = require('underscore');

  walkdir = require('walkdir');

  hamlc = require('haml-coffee');

  module.exports = Templater = (function() {

    function Templater(options, referencer) {
      var filename, match, _i, _len, _ref;
      this.options = options;
      this.referencer = referencer;
      this.JST = [];
      this.globalContext = {
        codoVersion: 'v' + JSON.parse(fs.readFileSync(path.join(__dirname, '..', '..', 'package.json'), 'utf-8'))['version'],
        generationDate: new Date().toString(),
        JST: this.JST,
        underscore: _,
        title: this.options.title,
        referencer: this.referencer
      };
      _ref = walkdir.sync(path.join(__dirname, '..', '..', 'theme', 'default', 'templates'));
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        filename = _ref[_i];
        if (match = /theme[/\\]default[/\\]templates[/\\](.+).hamlc$/.exec(filename)) {
          this.JST[match[1]] = hamlc.compile(fs.readFileSync(filename, 'utf-8'));
        }
      }
    }

    Templater.prototype.render = function(template, context, filename) {
      var dir, file, html;
      if (context == null) {
        context = {};
      }
      if (filename == null) {
        filename = '';
      }
      html = this.JST[template](_.extend(this.globalContext, context));
      if (!_.isEmpty(filename)) {
        file = path.join(this.options.output, filename);
        dir = path.dirname(file);
        mkdirp(dir, function(err) {
          if (err) {
            return console.error("[ERROR] Cannot create directory " + dir + ": " + err);
          } else {
            return fs.writeFile(file, html);
          }
        });
      }
      return html;
    };

    return Templater;

  })();

}).call(this);
