(function() {
  var Parameter;

  module.exports = Parameter = (function() {

    function Parameter(node, options) {
      this.node = node;
      this.options = options;
    }

    Parameter.prototype.getSignature = function() {
      var value;
      try {
        if (!this.signature) {
          this.signature = this.getName();
          if (this.isSplat()) this.signature += '...';
          value = this.getDefault();
          if (value) this.signature += " = " + (value.replace(/\n\s*/g, ' '));
        }
        return this.signature;
      } catch (error) {
        if (this.options.verbose) {
          return console.warn('Get parameter signature error:', this.node, error);
        }
      }
    };

    Parameter.prototype.getName = function() {
      var _ref;
      try {
        if (!this.name) {
          this.name = this.node.name.value;
          if (!this.name) {
            if (this.node.name.properties) {
              this.name = (_ref = this.node.name.properties[0]) != null ? _ref.name.value : void 0;
            }
          }
        }
        return this.name;
      } catch (error) {
        if (this.options.verbose) {
          return console.warn('Get parameter name error:', this.node, error);
        }
      }
    };

    Parameter.prototype.getDefault = function() {
      var _ref, _ref2, _ref3;
      try {
        return (_ref = this.node.value) != null ? _ref.compile({
          indent: ''
        }) : void 0;
      } catch (error) {
        if (((_ref2 = this.node.value) != null ? _ref2.base.value : void 0) === 'this') {
          return "@" + ((_ref3 = this.node.value.properties[0]) != null ? _ref3.name.compile({
            indent: ''
          }) : void 0);
        } else {
          if (this.options.verbose) {
            return console.warn('Get parameter default error:', this.node, error);
          }
        }
      }
    };

    Parameter.prototype.isSplat = function() {
      try {
        return this.node.splat === true;
      } catch (error) {
        if (this.options.verbose) {
          return console.warn('Get parameter splat type error:', this.node, error);
        }
      }
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
