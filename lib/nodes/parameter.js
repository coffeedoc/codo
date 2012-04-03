(function() {
  var Node, Parameter,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Node = require('./node');

  module.exports = Parameter = (function(_super) {

    __extends(Parameter, _super);

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
      var _ref, _ref2, _ref3, _ref4, _ref5;
      try {
        return (_ref = this.node.value) != null ? _ref.compile({
          indent: ''
        }) : void 0;
      } catch (error) {
        if (((_ref2 = this.node) != null ? (_ref3 = _ref2.value) != null ? (_ref4 = _ref3.base) != null ? _ref4.value : void 0 : void 0 : void 0) === 'this') {
          return "@" + ((_ref5 = this.node.value.properties[0]) != null ? _ref5.name.compile({
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

  })(Node);

}).call(this);
