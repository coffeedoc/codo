(function() {
  var Class;

  module.exports = Class = (function() {

    function Class(node) {
      this.node = node;
    }

    Class.prototype.clazz = function() {
      var clazz, property, _i, _len, _ref;
      clazz = this.node.variable.base.value;
      _ref = this.node.variable.properties;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        property = _ref[_i];
        clazz += "." + property.name.value;
      }
      return clazz;
    };

    Class.prototype.name = function() {
      return this.clazz().split('.').pop();
    };

    Class.prototype.namespace = function() {
      var namespace;
      namespace = this.clazz().split('.');
      namespace.pop();
      return namespace.join('.');
    };

    Class.prototype.parentClazz = function() {
      var clazz, property, _i, _len, _ref;
      if (this.node.parent) {
        clazz = this.node.parent.base.value;
        _ref = this.node.parent.properties;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          property = _ref[_i];
          clazz += "." + property.name.value;
        }
        return clazz;
      } else {
        return;
      }
    };

    Class.prototype.subclasses = function() {};

    Class.prototype.classMethods = function() {};

    Class.prototype.instanceMethods = function() {};

    Class.prototype.classVariables = function() {};

    Class.prototype.constants = function() {};

    return Class;

  })();

}).call(this);
