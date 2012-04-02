(function() {
  var Doc, Method, Mixin, Node, Variable,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Node = require('./node');

  Method = require('./method');

  Variable = require('./variable');

  Doc = require('./doc');

  module.exports = Mixin = (function(_super) {

    __extends(Mixin, _super);

    function Mixin(node, fileName, options, comment) {
      var doc, exp, method, previousExp, _i, _j, _k, _len, _len2, _len3, _ref, _ref2, _ref3, _ref4, _ref5;
      this.node = node;
      this.fileName = fileName;
      this.options = options;
      try {
        this.methods = [];
        this.variables = [];
        this.doc = new Doc(comment, this.options);
        previousExp = null;
        _ref = this.node.value.base.properties;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          exp = _ref[_i];
          if (exp.constructor.name === 'Assign') {
            if ((previousExp != null ? previousExp.constructor.name : void 0) === 'Comment') {
              doc = previousExp;
            }
            if (((_ref2 = exp.value) != null ? _ref2.constructor.name : void 0) === 'Code') {
              this.methods.push(new Method(this, exp, this.options, doc));
            }
            if (((_ref3 = exp.value) != null ? _ref3.constructor.name : void 0) === 'Value') {
              switch (exp.variable.base.value) {
                case 'ClassMethods':
                  this.classMixin = new Mixin(exp, this.filename, this.options, doc);
                  break;
                case 'InstanceMethods':
                  this.instanceMixin = new Mixin(exp, this.filename, options, doc);
              }
            }
          }
          doc = null;
          previousExp = exp;
        }
        if ((this.classMixin != null) && (this.instanceMixin != null)) {
          this.concern = true;
          _ref4 = this.classMixin.getMethods();
          for (_j = 0, _len2 = _ref4.length; _j < _len2; _j++) {
            method = _ref4[_j];
            method.type = 'class';
            this.methods.push(method);
          }
          _ref5 = this.instanceMixin.getMethods();
          for (_k = 0, _len3 = _ref5.length; _k < _len3; _k++) {
            method = _ref5[_k];
            method.type = 'instance';
            this.methods.push(method);
          }
        } else {
          this.concern = false;
        }
      } catch (error) {
        if (this.options.verbose) {
          console.warn('Create mixin error:', this.node, error);
        }
      }
    }

    Mixin.prototype.getFileName = function() {
      return this.fileName;
    };

    Mixin.prototype.getDoc = function() {
      return this.doc;
    };

    Mixin.prototype.getMixinName = function() {
      var name, p, _i, _len, _ref;
      try {
        if (!this.mixinName) {
          name = [];
          if (this.node.variable.base.value !== 'this') {
            name = [this.node.variable.base.value];
          }
          _ref = this.node.variable.properties;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            p = _ref[_i];
            name.push(p.name.value);
          }
          this.mixinName = name.join('.');
        }
        return this.mixinName;
      } catch (error) {
        if (this.options.verbose) {
          return console.warn('Get mixin full name error:', this.node, error);
        }
      }
    };

    Mixin.prototype.getFullName = function() {
      return this.getMixinName();
    };

    Mixin.prototype.getName = function() {
      try {
        if (!this.name) this.name = this.getMixinName().split('.').pop();
        return this.name;
      } catch (error) {
        if (this.options.verbose) {
          return console.warn('Get mixin name error:', this.node, error);
        }
      }
    };

    Mixin.prototype.getNamespace = function() {
      try {
        if (!this.namespace) {
          this.namespace = this.getMixinName().split('.');
          this.namespace.pop();
          this.namespace = this.namespace.join('.');
        }
        return this.namespace;
      } catch (error) {
        if (this.options.verbose) {
          return console.warn('Get mixin namespace error:', this.node, error);
        }
      }
    };

    Mixin.prototype.getMethods = function() {
      return this.methods;
    };

    Mixin.prototype.getVariables = function() {
      return this.variables;
    };

    Mixin.prototype.toJSON = function() {
      var json, method, variable, _i, _j, _len, _len2, _ref, _ref2;
      json = {
        file: this.getFileName(),
        doc: this.getDoc().toJSON(),
        mixin: {
          mixinName: this.getMixinName(),
          name: this.getName(),
          namespace: this.getNamespace(),
          concern: this.concern
        },
        methods: [],
        variables: []
      };
      _ref = this.getMethods();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        method = _ref[_i];
        json.methods.push(method.toJSON());
      }
      _ref2 = this.getVariables();
      for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
        variable = _ref2[_j];
        json.variables.push(variable.toJSON());
      }
      return json;
    };

    return Mixin;

  })(Node);

}).call(this);
