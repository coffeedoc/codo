(function() {
  var Class, CoffeeScript, Mixin, Parser, fs, whitespace, _;

  fs = require('fs');

  _ = require('underscore');

  _.str = require('underscore.string');

  CoffeeScript = require('coffee-script');

  Class = require('./nodes/class');

  Mixin = require('./nodes/mixin');

  whitespace = require('./util/text').whitespace;

  module.exports = Parser = (function() {

    function Parser(options) {
      this.options = options;
      this.files = [];
      this.classes = [];
      this.mixins = [];
    }

    Parser.prototype.parseFile = function(file) {
      this.parseContent(fs.readFileSync(file, 'utf8'), file);
      return this.files.push(file);
    };

    Parser.prototype.parseContent = function(content, file) {
      var entities, root,
        _this = this;
      if (file == null) {
        file = '';
      }
      this.previousNodes = [];
      entities = {
        clazz: function(node) {
          var _ref, _ref1;
          return node.constructor.name === 'Class' && (((_ref = node.variable) != null ? (_ref1 = _ref.base) != null ? _ref1.value : void 0 : void 0) != null);
        },
        mixin: function(node) {
          var _ref, _ref1;
          return node.constructor.name === 'Assign' && (((_ref = node.value) != null ? (_ref1 = _ref.base) != null ? _ref1.properties : void 0 : void 0) != null);
        }
      };
      if (!this.options.cautious) {
        content = this.convertComments(content);
      }
      try {
        root = CoffeeScript.nodes(content);
      } catch (error) {
        if (this.options.debug) {
          console.log('Parsed CoffeeScript source:\n%s', content);
        }
        throw error;
      }
      this.linkAncestors(root);
      root.traverseChildren(true, function(child) {
        var clazz, condition, doc, entity, mixin, name, node, p, previous, type, _i, _len, _ref, _ref1;
        entity = false;
        for (type in entities) {
          condition = entities[type];
          if (entities.hasOwnProperty(type)) {
            if (condition(child)) {
              entity = type;
            }
          }
        }
        if (entity) {
          previous = _this.previousNodes[_this.previousNodes.length - 1];
          switch (previous != null ? previous.constructor.name : void 0) {
            case 'Comment':
              doc = previous;
              break;
            case 'Literal':
              if (previous.value === 'exports') {
                node = _this.previousNodes[_this.previousNodes.length - 6];
                if (node.constructor.name === 'Comment') {
                  doc = node;
                }
              }
          }
          if (entity === 'mixin') {
            name = [child.variable.base.value];
            _ref = child.variable.properties;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              p = _ref[_i];
              name.push((_ref1 = p.name) != null ? _ref1.value : void 0);
            }
            if (name.indexOf(void 0) === -1) {
              mixin = new Mixin(child, file, _this.options, doc);
              if ((mixin.doc.mixin != null) && (_this.options["private"] || !mixin.doc["private"])) {
                _this.mixins.push(mixin);
              }
            }
          }
          if (entity === 'clazz') {
            clazz = new Class(child, file, _this.options, doc);
            if (_this.options["private"] || !clazz.doc["private"]) {
              _this.classes.push(clazz);
            }
          }
        }
        _this.previousNodes.push(child);
        return true;
      });
      return root;
    };

    Parser.prototype.convertComments = function(content) {
      var c, comment, commentLine, inComment, indentComment, line, result, show, _i, _j, _len, _len1, _ref;
      result = [];
      comment = [];
      inComment = false;
      indentComment = 0;
      _ref = content.split('\n');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        line = _ref[_i];
        commentLine = /^(\s*#)\s?(\s*.*)/.exec(line);
        if (commentLine && commentLine[2].substring(0, 2) !== '##') {
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
            if (/(class\s*[$A-Za-z_\x7f-\uffff][$\w\x7f-\uffff]*|^\s*[$A-Za-z_\x7f-\uffff][$\w\x7f-\uffff.]*\s+\=|[$A-Za-z_\x7f-\uffff][$\w\x7f-\uffff]*\s*:\s*(\(.+\)\s*)?[-=]>|@[A-Za-z_\x7f-\uffff][$\w\x7f-\uffff]*\s*=\s*(\(.+\)\s*)?[-=]>|@[$A-Z_][A-Z_]*)/.exec(line)) {
              for (_j = 0, _len1 = comment.length; _j < _len1; _j++) {
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

    Parser.prototype.linkAncestors = function(node) {
      var _this = this;
      return node.eachChild(function(child) {
        child.ancestor = node;
        return _this.linkAncestors(child);
      });
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
      var clazz, mixin, _i, _j, _len, _len1, _ref, _ref1;
      if (!this.variables) {
        this.variables = [];
      }
      _ref = this.classes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        clazz = _ref[_i];
        this.variables = _.union(this.variables, clazz.getVariables());
      }
      _ref1 = this.mixins;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        mixin = _ref1[_j];
        this.methods = _.union(this.methods, mixin.getMethods());
      }
      return this.variables;
    };

    Parser.prototype.showResult = function() {
      var classCount, constantCount, constants, documented, fileCount, maxCountLength, maxNoDocLength, methodCount, mixinCount, noDocClasses, noDocConstants, noDocMethods, stats;
      fileCount = this.files.length;
      classCount = this.classes.length;
      noDocClasses = _.filter(this.classes, function(clazz) {
        return _.isUndefined(clazz.getDoc());
      }).length;
      mixinCount = this.mixins.length;
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
      documented || (documented = 100);
      maxCountLength = String(_.max([fileCount, mixinCount, classCount, methodCount, constantCount], function(count) {
        return String(count).length;
      })).length + 6;
      maxNoDocLength = String(_.max([noDocClasses, noDocMethods, noDocConstants], function(count) {
        return String(count).length;
      })).length;
      stats = "Files:     " + (_.str.pad(fileCount, maxCountLength)) + "\nClasses:   " + (_.str.pad(classCount, maxCountLength)) + " (" + (_.str.pad(noDocClasses, maxNoDocLength)) + " undocumented)\nMixins:    " + (_.str.pad(mixinCount, maxCountLength)) + "\nMethods:   " + (_.str.pad(methodCount, maxCountLength)) + " (" + (_.str.pad(noDocMethods, maxNoDocLength)) + " undocumented)\nConstants: " + (_.str.pad(constantCount, maxCountLength)) + " (" + (_.str.pad(noDocConstants, maxNoDocLength)) + " undocumented)\n " + (_.str.sprintf('%.2f', documented)) + "% documented";
      return console.log(stats);
    };

    Parser.prototype.toJSON = function() {
      var clazz, json, mixin, _i, _j, _len, _len1, _ref, _ref1;
      json = [];
      _ref = this.classes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        clazz = _ref[_i];
        json.push(clazz.toJSON());
      }
      _ref1 = this.mixins;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        mixin = _ref1[_j];
        json.push(mixin.toJSON());
      }
      return json;
    };

    return Parser;

  })();

}).call(this);
