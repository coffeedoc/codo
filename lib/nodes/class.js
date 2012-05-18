(function() {
  var Class, Doc, Method, Node, Variable, VirtualMethod,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Node = require('./node');

  Method = require('./method');

  VirtualMethod = require('./virtual_method');

  Variable = require('./variable');

  Doc = require('./doc');

  module.exports = Class = (function(_super) {

    __extends(Class, _super);

    function Class(node, fileName, options, comment) {
      var doc, exp, method, previousExp, previousProp, prop, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2, _ref3, _ref4, _ref5;
      this.node = node;
      this.fileName = fileName;
      this.options = options;
      try {
        this.methods = [];
        this.variables = [];
        this.doc = new Doc(comment, this.options);
        if (this.doc.methods) {
          _ref1 = (_ref = this.doc) != null ? _ref.methods : void 0;
          for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
            method = _ref1[_i];
            this.methods.push(new VirtualMethod(this, method, this.options));
          }
        }
        previousExp = null;
        _ref2 = this.node.body.expressions;
        for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
          exp = _ref2[_j];
          switch (exp.constructor.name) {
            case 'Assign':
              if ((previousExp != null ? previousExp.constructor.name : void 0) === 'Comment') {
                doc = previousExp;
              }
              switch ((_ref3 = exp.value) != null ? _ref3.constructor.name : void 0) {
                case 'Code':
                  if (exp.variable.base.value === 'this') {
                    this.methods.push(new Method(this, exp, this.options, doc));
                  }
                  break;
                case 'Value':
                  this.variables.push(new Variable(this, exp, this.options, true, doc));
              }
              doc = null;
              break;
            case 'Value':
              previousProp = null;
              _ref4 = exp.base.properties;
              for (_k = 0, _len2 = _ref4.length; _k < _len2; _k++) {
                prop = _ref4[_k];
                if ((previousProp != null ? previousProp.constructor.name : void 0) === 'Comment') {
                  doc = previousProp;
                }
                switch ((_ref5 = prop.value) != null ? _ref5.constructor.name : void 0) {
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
          console.warn('Create class error:', this.node, error);
        }
      }
    }

    Class.prototype.getFileName = function() {
      return this.fileName;
    };

    Class.prototype.getDoc = function() {
      return this.doc;
    };

    Class.prototype.getFullName = function() {
      return this.getClassName();
    };

    Class.prototype.getClassName = function() {
      var outer, prop, _i, _j, _len, _len1, _ref, _ref1;
      try {
        if (!this.className) {
          this.className = this.node.variable.base.value;
          if (this.className === 'this') {
            outer = this.findAncestor('Class');
            if (outer) {
              this.className = outer.variable.base.value;
              _ref = outer.variable.properties;
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                prop = _ref[_i];
                this.className += "." + prop.name.value;
              }
            } else {
              this.className = '';
            }
          }
          _ref1 = this.node.variable.properties;
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            prop = _ref1[_j];
            this.className += "." + prop.name.value;
          }
        }
        return this.className;
      } catch (error) {
        if (this.options.verbose) {
          return console.warn("Get class classname error at " + this.fileName + ":", this.node, error);
        }
      }
    };

    Class.prototype.getName = function() {
      try {
        if (!this.name) {
          this.name = this.getClassName().split('.').pop();
        }
        return this.name;
      } catch (error) {
        if (this.options.verbose) {
          return console.warn("Get class name error at " + this.fileName + ":", this.node, error);
        }
      }
    };

    Class.prototype.getNamespace = function() {
      try {
        if (!this.namespace) {
          this.namespace = this.getClassName().split('.');
          this.namespace.pop();
          this.namespace = this.namespace.join('.');
        }
        return this.namespace;
      } catch (error) {
        if (this.options.verbose) {
          return console.warn("Get class namespace error at " + this.fileName + ":", this.node, error);
        }
      }
    };

    Class.prototype.getParentClassName = function() {
      var outer, prop, _i, _j, _len, _len1, _ref, _ref1;
      try {
        if (!this.parentClassName) {
          if (this.node.parent) {
            this.parentClassName = this.node.parent.base.value;
            if (this.parentClassName === 'this') {
              outer = this.findAncestor('Class');
              if (outer) {
                this.parentClassName = outer.parent.base.value;
                _ref = outer.parent.properties;
                for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                  prop = _ref[_i];
                  this.parentClassName += "." + prop.name.value;
                }
              } else {
                this.parentClassName = '';
              }
            }
            _ref1 = this.node.parent.properties;
            for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
              prop = _ref1[_j];
              this.parentClassName += "." + prop.name.value;
            }
          }
        }
        return this.parentClassName;
      } catch (error) {
        if (this.options.verbose) {
          return console.warn("Get class parent classname error at " + this.fileName + ":", this.node, error);
        }
      }
    };

    Class.prototype.getMethods = function() {
      var method, _i, _len, _ref, _results;
      if (this.options["private"]) {
        return this.methods;
      } else {
        _ref = this.methods;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          method = _ref[_i];
          if (!method.doc["private"]) {
            _results.push(method);
          }
        }
        return _results;
      }
    };

    Class.prototype.getVariables = function() {
      return this.variables;
    };

    Class.prototype.toJSON = function() {
      var json, method, variable, _i, _j, _len, _len1, _ref, _ref1;
      json = {
        file: this.getFileName(),
        doc: this.getDoc().toJSON(),
        "class": {
          className: this.getClassName(),
          name: this.getName(),
          namespace: this.getNamespace(),
          parent: this.getParentClassName()
        },
        methods: [],
        variables: []
      };
      _ref = this.getMethods();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        method = _ref[_i];
        json.methods.push(method.toJSON());
      }
      _ref1 = this.getVariables();
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        variable = _ref1[_j];
        json.variables.push(variable.toJSON());
      }
      return json;
    };

    return Class;

  })(Node);

}).call(this);
