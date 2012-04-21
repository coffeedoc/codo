(function() {
  var Doc, Node, Parameter, VirtualMethod, _,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Node = require('./node');

  Parameter = require('./parameter');

  Doc = require('./doc');

  _ = require('underscore');

  _.str = require('underscore.string');

  module.exports = VirtualMethod = (function(_super) {

    __extends(VirtualMethod, _super);

    function VirtualMethod(entity, doc, options) {
      this.entity = entity;
      this.doc = doc;
      this.options = options;
    }

    VirtualMethod.prototype.getType = function() {
      if (!this.type) {
        if (this.doc.signature.substring(0, 1) === '#') {
          this.type = 'instance';
        } else if (this.doc.signature.substring(0, 1) === '.') {
          this.type = 'class';
        } else {
          this.type = 'mixin';
        }
      }
      return this.type;
    };

    VirtualMethod.prototype.getDoc = function() {
      return this.doc;
    };

    VirtualMethod.prototype.getSignature = function() {
      var param, params, _i, _len, _ref;
      try {
        if (!this.signature) {
          this.signature = (function() {
            switch (this.getType()) {
              case 'class':
                return '+ ';
              case 'instance':
                return '- ';
              default:
                return '? ';
            }
          }).call(this);
          if (this.getDoc()) {
            this.signature += this.getDoc().returnValue ? "(" + (_.str.escapeHTML(this.getDoc().returnValue.type)) + ") " : "(void) ";
          }
          this.signature += "<strong>" + (this.getName()) + "</strong>";
          this.signature += '(';
          params = [];
          _ref = this.getParameters();
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            param = _ref[_i];
            params.push(param.name);
          }
          this.signature += params.join(', ');
          this.signature += ')';
        }
        return this.signature;
      } catch (error) {
        if (this.options.verbose) {
          return console.warn('Get method signature error:', this.node, error);
        }
      }
    };

    VirtualMethod.prototype.getShortSignature = function() {
      try {
        if (!this.shortSignature) {
          this.shortSignature = (function() {
            switch (this.getType()) {
              case 'class':
                return '.';
              case 'instance':
                return '#';
              default:
                return '';
            }
          }).call(this);
          this.shortSignature += this.getName();
        }
        return this.shortSignature;
      } catch (error) {
        if (this.options.verbose) {
          return console.warn('Get method short signature error:', this.node, error);
        }
      }
    };

    VirtualMethod.prototype.getName = function() {
      var name;
      try {
        if (!this.name) {
          if (name = /[.#]?([$A-Za-z_\x7f-\uffff][$\w\x7f-\uffff]*)/i.exec(this.doc.signature)) {
            this.name = name[1];
          } else {
            this.name = 'unknown';
          }
        }
        return this.name;
      } catch (error) {
        if (this.options.verbose) {
          return console.warn('Get method name error:', this.node, error);
        }
      }
    };

    VirtualMethod.prototype.getParameters = function() {
      return this.doc.params || [];
    };

    VirtualMethod.prototype.getCoffeeScriptSource = function() {};

    VirtualMethod.prototype.getJavaScriptSource = function() {};

    VirtualMethod.prototype.toJSON = function() {
      var json;
      json = {
        doc: this.doc,
        type: this.getType(),
        signature: this.getSignature(),
        name: this.getName(),
        bound: false,
        parameters: []
      };
      return json;
    };

    return VirtualMethod;

  })(Node);

}).call(this);
