(function() {
  var Class, Doc, Method, Variable;

  Method = require('./method');

  Variable = require('./variable');

  Doc = require('./doc');

  module.exports = Class = (function() {

    function Class(node, fileName, options, comment) {
      var doc, exp, previousExp, previousProp, prop, _i, _j, _len, _len2, _ref, _ref2, _ref3, _ref4;
      this.node = node;
      this.fileName = fileName;
      this.options = options;
      try {
        this.methods = [];
        this.variables = [];
        this.doc = new Doc(comment, this.options);
        previousExp = null;
        _ref = this.node.body.expressions;
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

    Class.prototype.getClassName = function() {
      var prop, _i, _len, _ref;
      try {
        if (!this.className) {
          this.className = this.node.variable.base.value;
          _ref = this.node.variable.properties;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            prop = _ref[_i];
            this.className += "." + prop.name.value;
          }
        }
        return this.className;
      } catch (error) {
        if (this.options.verbose) {
          return console.warn('Get class classname error:', this.node, error);
        }
      }
    };

    Class.prototype.getName = function() {
      try {
        if (!this.name) this.name = this.getClassName().split('.').pop();
        return this.name;
      } catch (error) {
        if (this.options.verbose) {
          return console.warn('Get class name error:', this.node, error);
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
          return console.warn('Get class namespace error:', this.node, error);
        }
      }
    };

    Class.prototype.getParentClassName = function() {
      var prop, _i, _len, _ref;
      try {
        if (!this.parentClassName) {
          if (this.node.parent) {
            this.parentClassName = this.node.parent.base.value;
            _ref = this.node.parent.properties;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              prop = _ref[_i];
              this.parentClassName += "." + prop.name.value;
            }
          }
        }
        return this.parentClassName;
      } catch (error) {
        if (this.options.verbose) {
          return console.warn('Get class parent classname error:', this.node, error);
        }
      }
    };

    Class.prototype.getSubClasses = function() {};

    Class.prototype.getMethods = function() {
      return this.methods;
    };

    Class.prototype.getVariables = function() {
      return this.variables;
    };

    Class.prototype.toJSON = function() {
      var json, method, variable, _i, _j, _len, _len2, _ref, _ref2;
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
      _ref2 = this.getVariables();
      for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
        variable = _ref2[_j];
        json.variables.push(variable.toJSON());
      }
      return json;
    };

    return Class;

  })();

}).call(this);
