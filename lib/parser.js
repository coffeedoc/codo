(function() {
  var Class, CoffeeScript, Parser, fs, whitespace;

  fs = require('fs');

  CoffeeScript = require('coffee-script');

  Class = require('./nodes/class');

  whitespace = require('./util/text').whitespace;

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
      this.previousNode = null;
      return CoffeeScript.nodes(this.convertComments(content)).traverseChildren(true, function(child) {
        var doc, _ref;
        if (child.constructor.name === 'Class') {
          if (((_ref = _this.previousNode) != null ? _ref.constructor.name : void 0) === 'Comment') {
            doc = _this.previousNode;
          }
          _this.classes.push(new Class(child, doc, file));
        }
        _this.previousNode = child;
        return true;
      });
    };

    Parser.prototype.convertComments = function(content) {
      var comment, inComment, indentComment, line, result, show, _i, _len, _ref;
      result = [];
      inComment = false;
      indentComment = 0;
      _ref = content.split('\n');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        line = _ref[_i];
        if (comment = /^(\s*#)\s?(\s*.*)/.exec(line)) {
          show = true;
          if (inComment) {
            result.push(whitespace(indentComment) + comment[2]);
          } else {
            inComment = true;
            indentComment = comment[1].length - 1;
            result.push(whitespace(indentComment) + '###');
            result.push(whitespace(indentComment) + comment[2]);
          }
        } else {
          if (inComment) {
            inComment = false;
            result.push(whitespace(indentComment) + '###');
          }
          result.push(line);
        }
      }
      return result.join('\n');
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
