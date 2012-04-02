(function() {
  var Doc, Node, Variable,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Node = require('./node');

  Doc = require('./doc');

  module.exports = Variable = (function(_super) {

    __extends(Variable, _super);

    function Variable(entity, node, options, classType, comment) {
      this.entity = entity;
      this.node = node;
      this.options = options;
      this.classType = classType != null ? classType : false;
      if (comment == null) comment = null;
      try {
        this.getName();
        this.doc = new Doc(comment, this.options);
      } catch (error) {
        if (this.options.verbose) {
          console.warn('Create variable error:', this.node, error);
        }
      }
    }

    Variable.prototype.getType = function() {
      if (!this.type) this.type = this.classType ? 'class' : 'instance';
      return this.type;
    };

    Variable.prototype.isConstant = function() {
      if (!this.constant) this.constant = /^[A-Z_-]*$/.test(this.getName());
      return this.constant;
    };

    Variable.prototype.getDoc = function() {
      return this.doc;
    };

    Variable.prototype.getName = function() {
      var prop, _i, _len, _ref;
      try {
        if (!this.name) {
          this.name = this.node.variable.base.value;
          _ref = this.node.variable.properties;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            prop = _ref[_i];
            this.name += "." + prop.name.value;
          }
          if (/^this\./.test(this.name)) {
            this.name = this.name.substring(5);
            this.type = 'class';
          }
        }
        return this.name;
      } catch (error) {
        if (this.options.verbose) {
          return console.warn('Get method name error:', this.node, error);
        }
      }
    };

    Variable.prototype.getValue = function() {
      try {
        if (!this.value) {
          this.value = this.node.value.base.compile({
            indent: ''
          });
        }
        return this.value;
      } catch (error) {
        if (this.options.verbose) {
          return console.warn('Get method value error:', this.node, error);
        }
      }
    };

    Variable.prototype.toJSON = function() {
      var json;
      json = {
        doc: this.doc,
        type: this.getType(),
        constant: this.isConstant(),
        name: this.getName(),
        value: this.getValue()
      };
      return json;
    };

    return Variable;

  })(Node);

}).call(this);
