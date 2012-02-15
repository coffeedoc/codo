(function() {
  var Parameter;

  module.exports = Parameter = (function() {

    function Parameter(node, options) {
      this.node = node;
      this.options = options;
    }

    Parameter.prototype.getSignature = function() {
      var value;
      if (!this.signature) {
        this.signature = this.getName();
        if (this.isSplat()) this.signature += '...';
        value = this.getDefault();
        if (value) this.signature += " = " + (value.replace(/\n\s*/g, ' '));
      }
      return this.signature;
    };

    Parameter.prototype.getName = function() {
      return this.node.name.value;
    };

    Parameter.prototype.getDefault = function() {
      var _ref;
      return (_ref = this.node.value) != null ? _ref.compile({
        indent: ''
      }) : void 0;
    };

    Parameter.prototype.isSplat = function() {
      return this.node.splat === true;
    };

    Parameter.prototype.toJSON = function() {
      var json;
      json = {
        name: this.getName(),
        "default": this.getDefault(),
        splat: this.isSplat()
      };
      return json;
    };

    return Parameter;

  })();

}).call(this);
