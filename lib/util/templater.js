(function() {
  var Templater, findit, fs, hamlc, mkdirp, path, _;

  fs = require('fs');

  path = require('path');

  mkdirp = require('mkdirp');

  _ = require('underscore');

  findit = require('findit');

  hamlc = require('haml-coffee');

  module.exports = Templater = (function() {

    function Templater(options) {
      var filename, match, _i, _len, _ref;
      this.options = options;
      this.JST = [];
      this.globalContext = {
        codoVersion: 'v' + JSON.parse(fs.readFileSync("" + __dirname + "/../../package.json", 'utf-8'))['version'],
        generationDate: new Date().toString(),
        JST: this.JST,
        title: this.options.title
      };
      _ref = findit.sync("" + __dirname + "/../../theme/default/templates");
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        filename = _ref[_i];
        if (match = /theme\/default\/templates\/(.+).hamlc$/.exec(filename)) {
          this.JST[match[1]] = hamlc.compile(fs.readFileSync(filename, 'utf-8'));
        }
      }
    }

    Templater.prototype.render = function(template, context, filename) {
      var dir, file, html;
      if (context == null) context = {};
      if (filename == null) filename = '';
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
