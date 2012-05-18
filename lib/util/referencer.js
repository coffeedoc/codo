(function() {
  var Referencer, _;

  _ = require('underscore');

  module.exports = Referencer = (function() {

    function Referencer(classes, mixins, options) {
      this.classes = classes;
      this.mixins = mixins;
      this.options = options;
      this.resolveParamReferences();
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

    Referencer.prototype.getIncludedMethods = function(clazz) {
      var mixin, parentClass, result, _i, _len, _ref, _ref1;
      result = {};
      _ref1 = ((_ref = clazz.doc) != null ? _ref.includeMixins : void 0) || [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        mixin = _ref1[_i];
        result[mixin] = this.resolveMixinMethods(mixin);
      }
      if (!_.isEmpty(clazz.getParentClassName())) {
        parentClass = _.find(this.classes, function(c) {
          return c.getFullName() === clazz.getParentClassName();
        });
        if (parentClass) {
          result = _.extend({}, this.getIncludedMethods(parentClass), result);
        }
      }
      return result;
    };

    Referencer.prototype.getExtendedMethods = function(clazz) {
      var mixin, parentClass, result, _i, _len, _ref, _ref1;
      result = {};
      _ref1 = ((_ref = clazz.doc) != null ? _ref.extendMixins : void 0) || [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        mixin = _ref1[_i];
        result[mixin] = this.resolveMixinMethods(mixin);
      }
      if (!_.isEmpty(clazz.getParentClassName())) {
        parentClass = _.find(this.classes, function(c) {
          return c.getFullName() === clazz.getParentClassName();
        });
        if (parentClass) {
          result = _.extend({}, this.getExtendedMethods(parentClass), result);
        }
      }
      return result;
    };

    Referencer.prototype.getConcernMethods = function(clazz) {
      var mixin, parentClass, result, _i, _len, _ref, _ref1;
      result = {};
      _ref1 = ((_ref = clazz.doc) != null ? _ref.concerns : void 0) || [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        mixin = _ref1[_i];
        result[mixin] = this.resolveMixinMethods(mixin);
      }
      if (!_.isEmpty(clazz.getParentClassName())) {
        parentClass = _.find(this.classes, function(c) {
          return c.getFullName() === clazz.getParentClassName();
        });
        if (parentClass) {
          result = _.extend({}, this.getConcernMethods(parentClass), result);
        }
      }
      return result;
    };

    Referencer.prototype.resolveMixinMethods = function(name) {
      var mixin;
      mixin = _.find(this.mixins, function(m) {
        return m.getMixinName() === name;
      });
      if (mixin) {
        return mixin.getMethods();
      } else {
        if (!this.options.quiet) {
          console.log("[WARN] Cannot resolve mixin name " + name);
        }
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
      if (text == null) {
        text = '';
      }
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
      return void 0;
    };

    Referencer.prototype.resolveDoc = function(data, entity, path) {
      var example, index, name, note, option, options, param, see, todo, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _m, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6;
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
        if (_.isString(data.doc.summary)) {
          data.doc.summary = this.resolveTextReferences(data.doc.summary, entity, path);
        }
        _ref1 = data.doc.options;
        for (name in _ref1) {
          options = _ref1[name];
          for (index = _j = 0, _len1 = options.length; _j < _len1; index = ++_j) {
            option = options[index];
            data.doc.options[name][index].desc = this.resolveTextReferences(option.desc, entity, path);
          }
        }
        _ref2 = data.doc.params;
        for (name in _ref2) {
          param = _ref2[name];
          data.doc.params[name].desc = this.resolveTextReferences(param.desc, entity, path);
        }
        if (data.doc.notes) {
          _ref3 = data.doc.notes;
          for (index = _k = 0, _len2 = _ref3.length; _k < _len2; index = ++_k) {
            note = _ref3[index];
            data.doc.notes[index] = this.resolveTextReferences(note, entity, path);
          }
        }
        if (data.doc.todos) {
          _ref4 = data.doc.todos;
          for (index = _l = 0, _len3 = _ref4.length; _l < _len3; index = ++_l) {
            todo = _ref4[index];
            data.doc.todos[index] = this.resolveTextReferences(todo, entity, path);
          }
        }
        if (data.doc.examples) {
          _ref5 = data.doc.examples;
          for (index = _m = 0, _len4 = _ref5.length; _m < _len4; index = ++_m) {
            example = _ref5[index];
            data.doc.examples[index].title = this.resolveTextReferences(example.title, entity, path);
          }
        }
        if (_.isString(data.doc.deprecated)) {
          data.doc.deprecated = this.resolveTextReferences(data.doc.deprecated, entity, path);
        }
        if (data.doc.comment) {
          data.doc.comment = this.resolveTextReferences(data.doc.comment, entity, path);
        }
        if ((_ref6 = data.doc.returnValue) != null ? _ref6.desc : void 0) {
          data.doc.returnValue.desc = this.resolveTextReferences(data.doc.returnValue.desc, entity, path);
        }
      }
      return data;
    };

    Referencer.prototype.resolveTextReferences = function(text, entity, path) {
      var _this = this;
      if (text == null) {
        text = '';
      }
      return text.replace(/\{([^\}]*)\}/gm, function(match) {
        var reference, see;
        reference = arguments[1].split(' ');
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
      if (see.reference.substring(0, 1) === ' ') {
        return see;
      }
      ref = see.reference;
      if (/^\./.test(ref)) {
        methods = _.map(_.filter(entity.getMethods(), function(m) {
          return m.getType() === 'class';
        }), function(m) {
          return m.getName();
        });
        if (_.include(methods, ref.substring(1))) {
          see.reference = "" + path + (entity.constructor.name === 'Class' ? 'classes' : 'modules') + "/" + (entity.getFullName().replace(/\./g, '/')) + ".html#" + (ref.substring(1)) + "-class";
          if (!see.label) {
            see.label = ref;
          }
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
          if (!see.label) {
            see.label = ref;
          }
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
            otherEntity || (otherEntity = _.find(this.mixins, function(c) {
              return c.getFullName() === refClass;
            }));
            if (otherEntity) {
              if (_.isUndefined(refMethod)) {
                if (_.include(_.map(this.classes, function(c) {
                  return c.getFullName();
                }), refClass) || _.include(_.map(this.mixins, function(c) {
                  return c.getFullName();
                }), refClass)) {
                  see.reference = "" + path + (otherEntity.constructor.name === 'Class' ? 'classes' : 'modules') + "/" + (refClass.replace(/\./g, '/')) + ".html";
                  if (!see.label) {
                    see.label = ref;
                  }
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
                  if (!see.label) {
                    see.label = ref;
                  }
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
                  if (!see.label) {
                    see.label = ref;
                  }
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

    Referencer.prototype.resolveParamReferences = function() {
      var copyParam, entities, entity, method, name, names, otherEntity, otherMethod, otherMethodType, param, ref, refMethod, _i, _len, _results;
      entities = _.union(this.classes, this.mixins);
      _results = [];
      for (_i = 0, _len = entities.length; _i < _len; _i++) {
        entity = entities[_i];
        _results.push((function() {
          var _j, _len1, _ref, _results1;
          _ref = entity.getMethods();
          _results1 = [];
          for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
            method = _ref[_j];
            if (method.getDoc() && !_.isEmpty(method.getDoc().params)) {
              _results1.push((function() {
                var _base, _base1, _base2, _k, _len2, _ref1, _results2;
                _ref1 = method.getDoc().params;
                _results2 = [];
                for (_k = 0, _len2 = _ref1.length; _k < _len2; _k++) {
                  param = _ref1[_k];
                  if (param.reference) {
                    if (ref = /([$A-Za-z_\x7f-\uffff][$\w\x7f-\uffff]*)([#.])([$A-Za-z_\x7f-\uffff][$\w\x7f-\uffff]*)/i.test(param.reference)) {
                      otherEntity = _.first(entities, function(e) {
                        return e.getFullName() === ref[1];
                      });
                      otherMethodType = ref[2] === '#' ? 'instance' : 'class';
                      otherMethod = ref[3];
                    } else {
                      otherEntity = entity;
                      otherMethodType = param.reference.substring(0, 1) === '#' ? 'instance' : 'class';
                      otherMethod = param.reference.substring(1);
                    }
                    refMethod = _.find(otherEntity.getMethods(), function(m) {
                      return m.getName() === otherMethod && m.getType() === otherMethodType;
                    });
                    if (refMethod) {
                      if (param.name) {
                        copyParam = _.find(refMethod.getDoc().params, function(p) {
                          return p.name === param.name;
                        });
                        if (copyParam) {
                          (_base = method.getDoc()).params || (_base.params = []);
                          method.getDoc().params = _.reject(method.getDoc().params, function(p) {
                            return p.name = param.name;
                          });
                          method.getDoc().params.push(copyParam);
                          if (_.isObject(refMethod.getDoc().paramsOptions)) {
                            (_base1 = method.getDoc()).paramsOptions || (_base1.paramsOptions = {});
                            _results2.push(method.getDoc().paramsOptions[param.name] = refMethod.getDoc().paramsOptions[param.name]);
                          } else {
                            _results2.push(void 0);
                          }
                        } else {
                          if (!this.options.quiet) {
                            _results2.push(console.log("[WARN] Parameter " + param.name + " does not exist in " + param.reference + " in class " + (entity.getFullName())));
                          } else {
                            _results2.push(void 0);
                          }
                        }
                      } else {
                        names = _.map(method.getParameters(), function(p) {
                          return p.getName();
                        });
                        method.getDoc().params = _.filter(refMethod.getDoc().params, function(p) {
                          return _.contains(names, p.name);
                        });
                        if (_.isObject(refMethod.getDoc().paramsOptions)) {
                          (_base2 = method.getDoc()).paramsOptions || (_base2.paramsOptions = {});
                          _results2.push((function() {
                            var _l, _len3, _results3;
                            _results3 = [];
                            for (_l = 0, _len3 = names.length; _l < _len3; _l++) {
                              name = names[_l];
                              _results3.push(method.getDoc().paramsOptions[name] = refMethod.getDoc().paramsOptions[name]);
                            }
                            return _results3;
                          })());
                        } else {
                          _results2.push(void 0);
                        }
                      }
                    } else {
                      if (!this.options.quiet) {
                        _results2.push(console.log("[WARN] Cannot resolve reference tag " + param.reference + " in class " + (entity.getFullName())));
                      } else {
                        _results2.push(void 0);
                      }
                    }
                  } else {
                    _results2.push(void 0);
                  }
                }
                return _results2;
              }).call(this));
            } else {
              _results1.push(void 0);
            }
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    return Referencer;

  })();

}).call(this);
