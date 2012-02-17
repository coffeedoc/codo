(function() {
  var Referencer, _;

  _ = require('underscore');

  module.exports = Referencer = (function() {

    function Referencer(classes) {
      this.classes = classes;
    }

    Referencer.prototype.getDirectSubClasses = function(clazz) {
      return _.filter(this.classes, function(cl) {
        return cl.getParentClassName() === clazz.getClassName();
      });
    };

    Referencer.prototype.getInheritedMethods = function(clazz) {
      var parentClass;
      if (!_.isEmpty(clazz.getParentClassName())) {
        parentClass = _.find(this.classes, function(c) {
          return c.getClassName() === clazz.getParentClassName();
        });
        if (parentClass) {
          return _.union(parentClass.getMethods(), this.getInheritedMethods(parentClass));
        } else {
          return [];
        }
      } else {
        return [];
      }
    };

    Referencer.prototype.getInheritedVariables = function(clazz) {
      var parentClass;
      if (!_.isEmpty(clazz.getParentClassName())) {
        parentClass = _.find(this.classes, function(c) {
          return c.getClassName() === clazz.getParentClassName();
        });
        if (parentClass) {
          return _.union(parentClass.getVariables(), this.getInheritedVariables(parentClass));
        } else {
          return [];
        }
      } else {
        return [];
      }
    };

    Referencer.prototype.getInheritedConstants = function(clazz) {
      return _.filter(this.getInheritedVariables(clazz), function(v) {
        return v.isConstant();
      });
    };

    Referencer.prototype.linkTypes = function(text, path) {
      var clazz, _i, _len, _ref;
      _ref = this.classes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        clazz = _ref[_i];
        text = text.replace(RegExp("^(" + (clazz.getClassName()) + ")$", "g"), "<a href='" + path + "classes/" + (clazz.getClassName().replace(/\./g, '/')) + ".html'>$1</a>");
        text = text.replace(RegExp("([<])(" + (clazz.getClassName()) + ")([>,])", "g"), "$1<a href='" + path + "classes/" + (clazz.getClassName().replace(/\./g, '/')) + ".html'>$2</a>$3");
      }
      return text;
    };

    Referencer.prototype.getLink = function(classname, path) {
      var clazz, _i, _len, _ref;
      _ref = this.classes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        clazz = _ref[_i];
        if (classname === clazz.getClassName()) {
          return "" + path + "classes/" + (clazz.getClassName().replace(/\./g, '/')) + ".html";
        }
      }
      return;
    };

    Referencer.prototype.linkReferences = function(text) {};

    return Referencer;

  })();

}).call(this);
