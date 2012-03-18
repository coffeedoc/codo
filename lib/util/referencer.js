(function() {
  var Referencer, _;

  _ = require('underscore');

  module.exports = Referencer = (function() {

    function Referencer(classes, modules, options) {
      this.classes = classes;
      this.modules = modules;
      this.options = options;
    }

    Referencer.prototype.getDirectSubClasses = function(clazz) {
      return _.filter(this.classes, function(cl) {
        return cl.getParentClassName() === clazz.getFullName();
      });
    };

    Referencer.prototype.getInheritedMethods = function(clazz) {
      var parentClass;
      if (!_.isEmpty(clazz.getParentClassName())) {
        parentClass = _.find(this.classes, function(c) {
          return c.getFullName() === clazz.getParentClassName();
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
          return c.getFullName() === clazz.getParentClassName();
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
        text = text.replace(RegExp("^(" + (clazz.getFullName()) + ")$", "g"), "<a href='" + path + "classes/" + (clazz.getFullName().replace(/\./g, '/')) + ".html'>$1</a>");
        text = text.replace(RegExp("([<])(" + (clazz.getFullName()) + ")([>,])", "g"), "$1<a href='" + path + "classes/" + (clazz.getFullName().replace(/\./g, '/')) + ".html'>$2</a>$3");
      }
      return text;
    };

    Referencer.prototype.getLink = function(classname, path) {
      var clazz, _i, _len, _ref;
      _ref = this.classes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        clazz = _ref[_i];
        if (classname === clazz.getFullName()) {
          return "" + path + "classes/" + (clazz.getFullName().replace(/\./g, '/')) + ".html";
        }
      }
      return;
    };

    Referencer.prototype.resolveDoc = function(data, entity, path) {
      var example, index, name, note, option, options, param, see, todo, _i, _len, _len2, _len3, _len4, _len5, _ref, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7;
      if (data.doc) {
        if (data.doc.see) {
          _ref = data.doc.see;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            see = _ref[_i];
            this.resolveSee(see, entity, path);
          }
        }
        if (_.isString(data.doc.abstract)) {
          data.doc.abstract = this.resolveTextReferences(data.doc.abstract, entity, path);
        }
        _ref2 = data.doc.options;
        for (name in _ref2) {
          options = _ref2[name];
          for (index = 0, _len2 = options.length; index < _len2; index++) {
            option = options[index];
            data.doc.options[name][index].desc = this.resolveTextReferences(option.desc, entity, path);
          }
        }
        _ref3 = data.doc.params;
        for (name in _ref3) {
          param = _ref3[name];
          data.doc.params[name].desc = this.resolveTextReferences(param.desc, entity, path);
        }
        if (data.doc.notes) {
          _ref4 = data.doc.notes;
          for (index = 0, _len3 = _ref4.length; index < _len3; index++) {
            note = _ref4[index];
            data.doc.notes[index] = this.resolveTextReferences(note, entity, path);
          }
        }
        if (data.doc.todos) {
          _ref5 = data.doc.todos;
          for (index = 0, _len4 = _ref5.length; index < _len4; index++) {
            todo = _ref5[index];
            data.doc.todos[index] = this.resolveTextReferences(todo, entity, path);
          }
        }
        if (data.doc.examples) {
          _ref6 = data.doc.examples;
          for (index = 0, _len5 = _ref6.length; index < _len5; index++) {
            example = _ref6[index];
            data.doc.examples[index].title = this.resolveTextReferences(example.title, entity, path);
          }
        }
        if (_.isString(data.doc.deprecated)) {
          data.doc.deprecated = this.resolveTextReferences(data.doc.deprecated, entity, path);
        }
        if (data.doc.comment) {
          data.doc.comment = this.resolveTextReferences(data.doc.comment, entity, path);
        }
        if ((_ref7 = data.doc.returnValue) != null ? _ref7.desc : void 0) {
          data.doc.returnValue.desc = this.resolveTextReferences(data.doc.returnValue.desc, entity, path);
        }
      }
      return data;
    };

    Referencer.prototype.resolveTextReferences = function(text, entity, path) {
      var _this = this;
      return text.replace(/\{(.*)\}/gm, function(match) {
        var reference, see;
        reference = arguments[1].split();
        see = _this.resolveSee({
          reference: reference[0],
          label: reference[1]
        }, entity, path);
        if (see.reference) {
          return "<a href='" + see.reference + "'>" + see.label + "</a>";
        } else {
          return match;
        }
      });
    };

    Referencer.prototype.resolveSee = function(see, entity, path) {
      var instanceMethods, match, methods, otherEntity, ref, refClass, refMethod;
      if (see.reference.substring(0, 1) === ' ') return see;
      ref = see.reference;
      if (/^\./.test(ref)) {
        methods = _.map(_.filter(entity.getMethods(), function(m) {
          return m.getType() === 'class';
        }), function(m) {
          return m.getName();
        });
        if (_.include(methods, ref.substring(1))) {
          see.reference = "" + path + (entity.constructor.name === 'Class' ? 'classes' : 'modules') + "/" + (entity.getFullName().replace(/\./g, '/')) + ".html#" + (ref.substring(1)) + "-class";
          if (!see.label) see.label = ref;
        } else {
          see.label = see.reference;
          see.reference = void 0;
          if (!this.options.quiet) {
            console.log("[WARN] Cannot resolve link to " + ref + " in " + (entity.getFullName()));
          }
        }
      } else if (/^\#/.test(ref)) {
        instanceMethods = _.map(_.filter(entity.getMethods(), function(m) {
          return m.getType() === 'instance';
        }), function(m) {
          return m.getName();
        });
        if (_.include(instanceMethods, ref.substring(1))) {
          see.reference = "" + path + "classes/" + (entity.getFullName().replace(/\./g, '/')) + ".html#" + (ref.substring(1)) + "-instance";
          if (!see.label) see.label = ref;
        } else {
          see.label = see.reference;
          see.reference = void 0;
          if (!this.options.quiet) {
            console.log("[WARN] Cannot resolve link to " + ref + " in class " + (entity.getFullName()));
          }
        }
      } else {
        if (!/^https?:\/\//.test(ref)) {
          if (match = /^(.*?)([.#][$a-z_\x7f-\uffff][$\w\x7f-\uffff]*)?$/.exec(ref)) {
            refClass = match[1];
            refMethod = match[2];
            otherEntity = _.find(this.classes, function(c) {
              return c.getFullName() === refClass;
            });
            otherEntity || (otherEntity = _.find(this.modules, function(c) {
              return c.getFullName() === refClass;
            }));
            if (otherEntity) {
              if (_.isUndefined(refMethod)) {
                if (_.include(_.map(this.classes, function(c) {
                  return c.getFullName();
                }), refClass)) {
                  see.reference = "" + path + (otherEntity.constructor.name === 'Class' ? 'classes' : 'modules') + "/" + (refClass.replace(/\./g, '/')) + ".html";
                  if (!see.label) see.label = ref;
                } else {
                  see.label = see.reference;
                  see.reference = void 0;
                  if (!this.options.quiet) {
                    console.log("[WARN] Cannot resolve link to entity " + refClass + " in " + (entity.getFullName()));
                  }
                }
              } else if (/^\./.test(refMethod)) {
                methods = _.map(_.filter(otherEntity.getMethods(), function(m) {
                  return m.getType() === 'class';
                }), function(m) {
                  return m.getName();
                });
                if (_.include(methods, refMethod.substring(1))) {
                  see.reference = "" + path + (otherEntity.constructor.name === 'Class' ? 'classes' : 'modules') + "/" + (otherEntity.getFullName().replace(/\./g, '/')) + ".html#" + (refMethod.substring(1)) + "-class";
                  if (!see.label) see.label = ref;
                } else {
                  see.label = see.reference;
                  see.reference = void 0;
                  if (!this.options.quiet) {
                    console.log("[WARN] Cannot resolve link to " + refMethod + " of class " + (otherEntity.getFullName()) + " in class " + (entity.getFullName()));
                  }
                }
              } else if (/^\#/.test(refMethod)) {
                instanceMethods = _.map(_.filter(otherEntity.getMethods(), function(m) {
                  return m.getType() === 'instance';
                }), function(m) {
                  return m.getName();
                });
                if (_.include(instanceMethods, refMethod.substring(1))) {
                  see.reference = "" + path + (otherEntity.constructor.name === 'Class' ? 'classes' : 'modules') + "/" + (otherEntity.getFullName().replace(/\./g, '/')) + ".html#" + (refMethod.substring(1)) + "-instance";
                  if (!see.label) see.label = ref;
                } else {
                  see.label = see.reference;
                  see.reference = void 0;
                  if (!this.options.quiet) {
                    console.log("[WARN] Cannot resolve link to " + refMethod + " of class " + (otherEntity.getFullName()) + " in class " + (entity.getFullName()));
                  }
                }
              }
            } else {
              see.label = see.reference;
              see.reference = void 0;
              if (!this.options.quiet) {
                console.log("[WARN] Cannot find referenced class " + refClass + " in class " + (entity.getFullName()));
              }
            }
          } else {
            see.label = see.reference;
            see.reference = void 0;
            if (!this.options.quiet) {
              console.log("[WARN] Cannot resolve link to " + ref + " in class " + (entity.getFullName()));
            }
          }
        }
      }
      return see;
    };

    return Referencer;

  })();

}).call(this);
