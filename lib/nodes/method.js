(function() {
  var Doc, Method, Parameter, _;

  Parameter = require('./parameter');

  Doc = require('./doc');

  _ = require('underscore');

  _.str = require('underscore.string');

  module.exports = Method = (function() {

    function Method(clazz, node, options, comment) {
      var param, _i, _len, _ref;
      this.clazz = clazz;
      this.node = node;
      this.options = options;
      try {
        this.parameters = [];
        this.doc = new Doc(comment, this.options);
        _ref = this.node.value.params;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          param = _ref[_i];
          this.parameters.push(new Parameter(param, this.options));
        }
        this.getName();
      } catch (error) {
        if (this.options.verbose) {
          console.warn('Create method error:', this.node, error);
        }
      }
    }

    Method.prototype.getType = function() {
      if (!this.type) this.type = 'instance';
      return this.type;
    };

    Method.prototype.getDoc = function() {
      return this.doc;
    };

    Method.prototype.getSignature = function() {
      var param, params, _i, _len, _ref;
      try {
        if (!this.signature) {
          this.signature = this.getType() === 'instance' ? '- ' : '+ ';
          if (this.getDoc()) {
            this.signature += this.getDoc().returnValue ? "(" + (_.str.escapeHTML(this.getDoc().returnValue.type)) + ") " : "(void) ";
          }
          this.signature += "<strong>" + (this.getName()) + "</strong>";
          this.signature += '(';
          params = [];
          _ref = this.getParamaters();
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            param = _ref[_i];
            params.push(param.getSignature());
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

    Method.prototype.getName = function() {
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
          return console.warn('Get parameter name error:', this.node, error);
        }
      }
    };

    Method.prototype.getParamaters = function() {
      return this.parameters;
    };

    Method.prototype.getCoffeeScriptSource = function() {};

    Method.prototype.getJavaScriptSource = function() {};

    Method.prototype.toJSON = function() {
      var json, parameter, _i, _len, _ref;
      json = {
        doc: this.getDoc().toJSON(),
        type: this.getType(),
        signature: this.getSignature(),
        name: this.getName(),
        bound: this.node.value.bound,
        parameters: []
      };
      _ref = this.getParamaters();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        parameter = _ref[_i];
        json.parameters.push(parameter.toJSON());
      }
      return json;
    };

    return Method;

  })();

}).call(this);
