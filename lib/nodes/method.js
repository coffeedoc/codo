(function() {
  var Method;

  module.exports = Method = (function() {

    function Method(node, clazz) {
      this.node = node;
      this.clazz = clazz != null ? clazz : false;
    }

    Method.prototype.getType = function() {
      if (!this.type) this.type = this.clazz ? 'class' : 'instance';
      return this.type;
    };

    Method.prototype.getDescription = function() {};

    Method.prototype.getSignature = function() {};

    Method.prototype.getName = function() {
      if (!this.name) this.name = this.node.variable.base.value;
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
