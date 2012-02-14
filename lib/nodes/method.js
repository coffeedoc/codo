(function() {
  var Method;

  module.exports = Method = (function() {

    function Method(node, clazz) {
      this.node = node;
      this.clazz = clazz != null ? clazz : false;
      this.getName();
    }

    Method.prototype.getType = function() {
      if (!this.type) this.type = this.clazz ? 'class' : 'instance';
      return this.type;
    };

    Method.prototype.getDescription = function() {};

    Method.prototype.getSignature = function() {};

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

    Method.prototype.getReturn = function() {};

    Method.prototype.getCoffeeScriptSource = function() {};

    Method.prototype.getJavaScriptSource = function() {};

    Method.prototype.toJSON = function() {
      var json;
      json = {
        type: this.getType(),
        name: this.getName()
      };
      return json;
    };

    return Method;

  })();

}).call(this);
