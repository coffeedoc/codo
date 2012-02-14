(function() {
  var Variable;

  module.exports = Variable = (function() {

    function Variable(node) {
      this.node = node;
    }

    Variable.prototype.type = function() {};

    Variable.prototype.description = function() {};

    Variable.prototype.value = function() {};

    return Variable;

  })();

}).call(this);
