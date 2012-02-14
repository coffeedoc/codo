(function() {
  var Doc, Method, Parameter;

  Parameter = require('./parameter');

  Doc = require('./doc');

  module.exports = Method = (function() {

    function Method(node, comment) {
      var param, _i, _len, _ref;
      this.node = node;
      this.parameters = [];
      this.doc = new Doc(comment);
      _ref = this.node.value.params;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        param = _ref[_i];
        this.parameters.push(new Parameter(param));
      }
      this.getName();
    }

    Method.prototype.getType = function() {
      if (!this.type) this.type = this.clazz ? 'class' : 'instance';
      return this.type;
    };

    Method.prototype.getDoc = function() {
      return this.doc;
    };

    Method.prototype.getSignature = function() {
      var param, params, _i, _len, _ref;
      if (!this.signature) {
        this.signature = this.getName();
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
    };

    Method.prototype.getName = function() {
      var prop, _i, _len, _ref;
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
    };

    Method.prototype.getParamaters = function() {
      return this.parameters;
    };

    Method.prototype.getReturnValue = function() {};

    Method.prototype.getCoffeeScriptSource = function() {};

    Method.prototype.getJavaScriptSource = function() {};

    Method.prototype.toJSON = function() {
      var json, parameter, _i, _len, _ref;
      json = {
        doc: this.getDoc().toJSON(),
        type: this.getType(),
        signature: this.getSignature(),
        name: this.getName(),
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
