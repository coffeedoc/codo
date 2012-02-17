(function() {
  var Class, CoffeeScript, Parser, fs, whitespace, _;

  fs = require('fs');

  _ = require('underscore');

  _.str = require('underscore.string');

  CoffeeScript = require('coffee-script');

  Class = require('./nodes/class');

  whitespace = require('./util/text').whitespace;

  module.exports = Parser = (function() {

    function Parser(options) {
      this.options = options;
      this.files = [];
      this.classes = [];
    }

    Parser.prototype.parseFile = function(file) {
      this.parseContent(fs.readFileSync(file, 'utf8'), file);
      return this.files.push(file);
    };

    Parser.prototype.parseContent = function(content, file) {
      var tokens,
        _this = this;
      if (file == null) file = '';
      this.previousNodes = [];
      tokens = CoffeeScript.nodes(this.convertComments(content));
      tokens.traverseChildren(true, function(child) {
        var doc, node, previous;
        if (child.constructor.name === 'Class') {
          previous = _this.previousNodes[_this.previousNodes.length - 1];
          switch (previous != null ? previous.constructor.name : void 0) {
            case 'Comment':
              doc = previous;
              break;
            case 'Literal':
              if (previous.value === 'exports') {
                node = _this.previousNodes[_this.previousNodes.length - 6];
                if (node.constructor.name === 'Comment') doc = node;
              }
          }
          _this.classes.push(new Class(child, file, _this.options, doc));
        }
        _this.previousNodes.push(child);
        return true;
      });
      return tokens;
    };

    Parser.prototype.convertComments = function(content) {
      var c, comment, commentLine, inComment, indentComment, line, result, show, _i, _j, _len, _len2, _ref;
      result = [];
      comment = [];
      inComment = false;
      indentComment = 0;
      _ref = content.split('\n');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        line = _ref[_i];
        if (commentLine = /^(\s*#)\s?(\s*.*)/.exec(line)) {
          show = true;
          if (inComment) {
            comment.push(commentLine[2]);
          } else {
            inComment = true;
            indentComment = commentLine[1].length - 1;
            comment.push(whitespace(indentComment) + '###');
            comment.push(commentLine[2]);
          }
        } else {
          if (inComment) {
            inComment = false;
            comment.push(whitespace(indentComment) + '###');
            if (/(class\s*[$A-Za-z_\x7f-\uffff][$\w\x7f-\uffff]*|[$A-Za-z_\x7f-\uffff][$\w\x7f-\uffff]*\s*:\s+(\(.*\)\s+[-=]>)?|@[A-Za-z_\x7f-\uffff][$\w\x7f-\uffff]*\s*=\s+(\(.*\)\s+[-=]>)?|@[$A-Z_][A-Z_]*)/.exec(line)) {
              for (_j = 0, _len2 = comment.length; _j < _len2; _j++) {
                c = comment[_j];
                result.push(c);
              }
            }
            comment = [];
          }
          result.push(line);
        }
      }
      return result.join('\n');
    };

    Parser.prototype.getAllMethods = function() {
      var clazz, _i, _len, _ref;
      if (!this.methods) {
        this.methods = [];
        _ref = this.classes;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          clazz = _ref[_i];
          this.methods = _.union(this.methods, clazz.getMethods());
        }
      }
      return this.methods;
    };

    Parser.prototype.getAllVariables = function() {
      var clazz, _i, _len, _ref;
      if (!this.variables) this.variables = [];
      _ref = this.classes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        clazz = _ref[_i];
        this.variables = _.union(this.variables, clazz.getVariables());
      }
      return this.variables;
    };

    Parser.prototype.showResult = function() {
      var classCount, constantCount, constants, documented, fileCount, maxCountLength, maxNoDocLength, methodCount, noDocClasses, noDocConstants, noDocMethods, stats;
      fileCount = this.files.length;
      classCount = this.classes.length;
      noDocClasses = _.filter(this.classes, function(clazz) {
        return _.isUndefined(clazz.getDoc());
      }).length;
      methodCount = this.getAllMethods().length;
      noDocMethods = _.filter(this.getAllMethods(), function(method) {
        return _.isUndefined(method.getDoc());
      }).length;
      constants = _.filter(this.getAllVariables(), function(variable) {
        return variable.isConstant();
      });
      constantCount = constants.length;
      noDocConstants = _.filter(constants, function(constant) {
        return _.isUndefined(constant.getDoc());
      }).length;
      documented = 100 - 100 / (classCount + methodCount + constantCount) * (noDocClasses + noDocMethods + noDocConstants);
      maxCountLength = String(_.max([fileCount, classCount, methodCount, constantCount], function(count) {
        return String(count).length;
      })).length + 6;
      maxNoDocLength = String(_.max([noDocClasses, noDocMethods, noDocConstants], function(count) {
        return String(count).length;
      })).length;
      stats = "Files:     " + (_.str.pad(fileCount, maxCountLength)) + "\nClasses:   " + (_.str.pad(classCount, maxCountLength)) + " (" + (_.str.pad(noDocClasses, maxNoDocLength)) + " undocumented)\nMethods:   " + (_.str.pad(methodCount, maxCountLength)) + " (" + (_.str.pad(noDocMethods, maxNoDocLength)) + " undocumented)\nConstants: " + (_.str.pad(constantCount, maxCountLength)) + " (" + (_.str.pad(noDocConstants, maxNoDocLength)) + " undocumented)\n " + (_.str.sprintf('%.2f', documented)) + "% documented";
      return console.log(stats);
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
