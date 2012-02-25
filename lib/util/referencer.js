(function() {
  var Referencer, _;

  _ = require('underscore');

  module.exports = Referencer = (function() {

    function Referencer(classes, options) {
      this.classes = classes;
      this.options = options;
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

    Referencer.prototype.linkReference = function(data, clazz, path) {
      var classMethods, instanceMethods, match, otherClass, ref, refClass, refMethod, see, _i, _len, _ref, _ref2;
      if ((_ref = data.doc) != null ? _ref.see : void 0) {
        _ref2 = data.doc.see;
        for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
          see = _ref2[_i];
          ref = see.reference;
          if (/^\./.test(ref)) {
            classMethods = _.map(_.filter(clazz.getMethods(), function(m) {
              return m.getType() === 'class';
            }), function(m) {
              return m.getName();
            });
            if (_.include(classMethods, ref.substring(1))) {
              see.reference = "" + path + "classes/" + (clazz.getClassName().replace(/\./g, '/')) + ".html#" + (ref.substring(1)) + "-class";
              if (!see.label) see.label = ref;
            } else {
              see.label = see.reference;
              see.reference = void 0;
              if (!this.options.quiet) {
                console.log("[WARN] Cannot resolve link to " + ref + " in class " + (clazz.getClassName()));
              }
            }
          } else if (/^\#/.test(ref)) {
            instanceMethods = _.map(_.filter(clazz.getMethods(), function(m) {
              return m.getType() === 'instance';
            }), function(m) {
              return m.getName();
            });
            if (_.include(instanceMethods, ref.substring(1))) {
              see.reference = "" + path + "classes/" + (clazz.getClassName().replace(/\./g, '/')) + ".html#" + (ref.substring(1)) + "-instance";
              if (!see.label) see.label = ref;
            } else {
              see.label = see.reference;
              see.reference = void 0;
              if (!this.options.quiet) {
                console.log("[WARN] Cannot resolve link to " + ref + " in class " + (clazz.getClassName()));
              }
            }
          } else {
            if (!/^https?:\/\//.test(ref)) {
              if (match = /^(.*?)([.#][$a-z_\x7f-\uffff][$\w\x7f-\uffff]*)?$/.exec(ref)) {
                refClass = match[1];
                refMethod = match[2];
                otherClass = _.find(this.classes, function(c) {
                  return c.getClassName() === refClass;
                });
                if (otherClass) {
                  if (_.isUndefined(refMethod)) {
                    if (_.include(_.map(this.classes, function(c) {
                      return c.getClassName();
                    }), refClass)) {
                      see.reference = "" + path + "classes/" + (refClass.replace(/\./g, '/')) + ".html";
                      if (!see.label) see.label = ref;
                    } else {
                      see.label = see.reference;
                      see.reference = void 0;
                      if (!this.options.quiet) {
                        console.log("[WARN] Cannot resolve link to class " + refClass + " in class " + (clazz.getClassName()));
                      }
                    }
                  } else if (/^\./.test(refMethod)) {
                    classMethods = _.map(_.filter(otherClass.getMethods(), function(m) {
                      return m.getType() === 'class';
                    }), function(m) {
                      return m.getName();
                    });
                    if (_.include(classMethods, refMethod.substring(1))) {
                      see.reference = "" + path + "classes/" + (otherClass.getClassName().replace(/\./g, '/')) + ".html#" + (refMethod.substring(1)) + "-class";
                      if (!see.label) see.label = ref;
                    } else {
                      see.label = see.reference;
                      see.reference = void 0;
                      if (!this.options.quiet) {
                        console.log("[WARN] Cannot resolve link to " + refMethod + " of class " + (otherClass.getClassName()) + " in class " + (clazz.getClassName()));
                      }
                    }
                  } else if (/^\#/.test(refMethod)) {
                    instanceMethods = _.map(_.filter(otherClass.getMethods(), function(m) {
                      return m.getType() === 'instance';
                    }), function(m) {
                      return m.getName();
                    });
                    if (_.include(instanceMethods, refMethod.substring(1))) {
                      see.reference = "" + path + "classes/" + (otherClass.getClassName().replace(/\./g, '/')) + ".html#" + (refMethod.substring(1)) + "-instance";
                      if (!see.label) see.label = ref;
                    } else {
                      see.label = see.reference;
                      see.reference = void 0;
                      if (!this.options.quiet) {
                        console.log("[WARN] Cannot resolve link to " + refMethod + " of class " + (otherClass.getClassName()) + " in class " + (clazz.getClassName()));
                      }
                    }
                  }
                } else {
                  see.label = see.reference;
                  see.reference = void 0;
                  if (!this.options.quiet) {
                    console.log("[WARN] Cannot find referenced class " + refClass + " in class " + (clazz.getClassName()));
                  }
                }
              } else {
                see.label = see.reference;
                see.reference = void 0;
                if (!this.options.quiet) {
                  console.log("[WARN] Cannot resolve link to " + ref + " in class " + (clazz.getClassName()));
                }
              }
            }
          }
        }
      }
      return data;
    };

    return Referencer;

  })();

}).call(this);
