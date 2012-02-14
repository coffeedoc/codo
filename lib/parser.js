(function() {
  var Class, CoffeeScript, Parser, fs;

  fs = require('fs');

  CoffeeScript = require('coffee-script');

  Class = require('./nodes/class');

  module.exports = Parser = (function() {

    function Parser() {
      this.classes = [];
    }

    Parser.prototype.parseFile = function(file) {
      return this.parseContent(fs.readFileSync(file, 'utf8'), file);
    };

    Parser.prototype.parseContent = function(content, file) {
      var _this = this;
      if (file == null) file = '';
      return CoffeeScript.nodes(content).traverseChildren(true, function(child) {
        if (child.constructor.name === 'Class') {
          return _this.classes.push(new Class(child, file));
        }
      });
    };

    Parser.prototype.toJSON = function() {
      var clazz, json, _i, _len, _ref;
      json = [];
      _ref = this.classes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        clazz = _ref[_i];
        json.push(clazz.toJSON());
      }
      return json;
    };

    return Parser;

  })();

}).call(this);
