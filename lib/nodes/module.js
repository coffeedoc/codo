(function() {
  var Doc, Method, Module, Node, Variable,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Node = require('./node');

  Method = require('./method');

  Variable = require('./variable');

  Doc = require('./doc');

  module.exports = Module = (function(_super) {

    __extends(Module, _super);

    function Module(node, fileName, options, comment) {
      var doc, exp, previousExp, previousProp, prop, _i, _j, _len, _len2, _ref, _ref2, _ref3, _ref4;
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
          switch (exp.constructor.name) {
            case 'Assign':
              if ((previousExp != null ? previousExp.constructor.name : void 0) === 'Comment') {
                doc = previousExp;
              }
              switch ((_ref2 = exp.value) != null ? _ref2.constructor.name : void 0) {
                case 'Code':
                  this.methods.push(new Method(this, exp, this.options, doc));
                  break;
                case 'Value':
                  this.variables.push(new Variable(this, exp, this.options, true, doc));
              }
              doc = null;
              break;
            case 'Value':
              previousProp = null;
              _ref3 = exp.base.properties;
              for (_j = 0, _len2 = _ref3.length; _j < _len2; _j++) {
                prop = _ref3[_j];
                if ((previousProp != null ? previousProp.constructor.name : void 0) === 'Comment') {
                  doc = previousProp;
                }
                switch ((_ref4 = prop.value) != null ? _ref4.constructor.name : void 0) {
                  case 'Code':
                    this.methods.push(new Method(this, prop, this.options, doc));
                    break;
                  case 'Value':
                    this.variables.push(new Variable(this, prop, this.options, doc));
                }
                doc = null;
                previousProp = prop;
              }
          }
          previousExp = exp;
        }
      } catch (error) {
        if (this.options.verbose) {
          console.warn('Create module error:', this.node, error);
        }
      }
    }

    Module.prototype.getFileName = function() {
      return this.fileName;
    };

    Module.prototype.getDoc = function() {
      return this.doc;
    };

    Module.prototype.getModuleName = function() {
      var name, p, _i, _len, _ref;
      try {
        if (!this.moduleName) {
          name = [];
          if (this.node.variable.base.value !== 'this') {
            name = [this.node.variable.base.value];
          }
          _ref = this.node.variable.properties;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            p = _ref[_i];
            name.push(p.name.value);
          }
          this.moduleName = name.join('.');
        }
        return this.moduleName;
      } catch (error) {
        if (this.options.verbose) {
          return console.warn('Get module full name error:', this.node, error);
        }
      }
    };

    Module.prototype.getFullName = function() {
      return this.getModuleName();
    };

    Module.prototype.getName = function() {
      try {
        if (!this.name) this.name = this.getModuleName().split('.').pop();
        return this.name;
      } catch (error) {
        if (this.options.verbose) {
          return console.warn('Get module name error:', this.node, error);
        }
      }
    };

    Module.prototype.getNamespace = function() {
      try {
        if (!this.namespace) {
          this.namespace = this.getModuleName().split('.');
          this.namespace.pop();
          this.namespace = this.namespace.join('.');
        }
        return this.namespace;
      } catch (error) {
        if (this.options.verbose) {
          return console.warn('Get module namespace error:', this.node, error);
        }
      }
    };

    Module.prototype.getMethods = function() {
      return this.methods;
    };

    Module.prototype.getVariables = function() {
      return this.variables;
    };

    Module.prototype.toJSON = function() {
      var json, method, variable, _i, _j, _len, _len2, _ref, _ref2;
      json = {
        file: this.getFileName(),
        doc: this.getDoc().toJSON(),
        module: {
          moduleName: this.getModuleName(),
          name: this.getName(),
          namespace: this.getNamespace()
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

    return Module;

  })(Node);

}).call(this);
