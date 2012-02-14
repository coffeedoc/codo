(function() {
  var Method;

  module.exports = Method = (function() {

    function Method(node) {
      this.node = node;
    }

    Method.prototype.type = function() {};

    Method.prototype.description = function() {};

    Method.prototype.signature = function() {};

    Method.prototype.returns = function() {};

    Method.prototype.coffeeScriptSource = function() {};

    Method.prototype.javaScriptSource = function() {};

    return Method;

  })();

}).call(this);
