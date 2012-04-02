(function() {
  var Generator, Referencer, Templater, fs, marked, mkdirp, path, _;

  fs = require('fs');

  path = require('path');

  marked = require('marked');

  mkdirp = require('mkdirp');

  _ = require('underscore');

  Templater = require('./util/templater');

  Referencer = require('./util/referencer');

  module.exports = Generator = (function() {

    function Generator(parser, options) {
      this.parser = parser;
      this.options = options;
      this.referencer = new Referencer(this.parser.classes, this.parser.mixins, this.options);
      this.templater = new Templater(this.options, this.referencer);
    }

    Generator.prototype.generate = function() {
      this.generateIndex();
      this.generateClasses();
      this.generateMixins();
      this.generateFiles();
      this.generateClassAndMixinIndex();
      this.generateClassAndMixinLists();
      this.generateMethodList();
      this.generateFileList();
      return this.copyAssets();
    };

    Generator.prototype.generateIndex = function() {
      return this.templater.render('frames', {
        index: this.options.readme,
        path: ''
      }, 'index.html');
    };

    Generator.prototype.generateClasses = function() {
      var assetPath, breadcrumbs, clazz, combined, namespace, namespaces, _i, _j, _k, _len, _len2, _len3, _ref, _results,
        _this = this;
      _ref = this.parser.classes;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        clazz = _ref[_i];
        namespaces = _.compact(clazz.getNamespace().split('.'));
        assetPath = '../';
        for (_j = 0, _len2 = namespaces.length; _j < _len2; _j++) {
          namespace = namespaces[_j];
          assetPath += '../';
        }
        breadcrumbs = [
          {
            href: "" + assetPath + "class_index.html",
            name: 'Index'
          }
        ];
        combined = [];
        for (_k = 0, _len3 = namespaces.length; _k < _len3; _k++) {
          namespace = namespaces[_k];
          combined.push(namespace);
          breadcrumbs.push({
            href: this.referencer.getLink(combined.join('.'), assetPath),
            name: namespace
          });
        }
        breadcrumbs.push({
          name: clazz.getName()
        });
        _results.push(this.templater.render('class', {
          path: assetPath,
          classData: this.referencer.resolveDoc(clazz.toJSON(), clazz, assetPath),
          classMethods: _.map(_.filter(clazz.getMethods(), function(method) {
            return method.type === 'class';
          }), function(m) {
            return _this.referencer.resolveDoc(m.toJSON(), clazz, assetPath);
          }),
          instanceMethods: _.map(_.filter(clazz.getMethods(), function(method) {
            return method.type === 'instance';
          }), function(m) {
            return _this.referencer.resolveDoc(m.toJSON(), clazz, assetPath);
          }),
          constants: _.map(_.filter(clazz.getVariables(), function(variable) {
            return variable.isConstant();
          }), function(m) {
            return _this.referencer.resolveDoc(m.toJSON(), clazz, assetPath);
          }),
          subClasses: _.map(this.referencer.getDirectSubClasses(clazz), function(c) {
            return c.getClassName();
          }),
          inheritedMethods: _.groupBy(this.referencer.getInheritedMethods(clazz), function(m) {
            return m.entity.getClassName();
          }),
          includedMethods: this.referencer.getIncludedMethods(clazz),
          extendedMethods: this.referencer.getExtendedMethods(clazz),
          concernMethods: this.referencer.getConcernMethods(clazz),
          inheritedConstants: _.groupBy(this.referencer.getInheritedConstants(clazz), function(m) {
            return m.entity.getClassName();
          }),
          breadcrumbs: breadcrumbs
        }, "classes/" + (clazz.getClassName().replace(/\./g, '/')) + ".html"));
      }
      return _results;
    };

    Generator.prototype.generateMixins = function() {
      var assetPath, breadcrumbs, combined, mixin, namespace, namespaces, _i, _j, _k, _len, _len2, _len3, _ref, _results,
        _this = this;
      _ref = this.parser.mixins;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        mixin = _ref[_i];
        namespaces = _.compact(mixin.getNamespace().split('.'));
        assetPath = '../';
        for (_j = 0, _len2 = namespaces.length; _j < _len2; _j++) {
          namespace = namespaces[_j];
          assetPath += '../';
        }
        breadcrumbs = [
          {
            href: "" + assetPath + "class_index.html",
            name: 'Index'
          }
        ];
        combined = [];
        for (_k = 0, _len3 = namespaces.length; _k < _len3; _k++) {
          namespace = namespaces[_k];
          combined.push(namespace);
          breadcrumbs.push({
            href: this.referencer.getLink(combined.join('.'), assetPath),
            name: namespace
          });
        }
        breadcrumbs.push({
          name: mixin.getName()
        });
        _results.push(this.templater.render('mixin', {
          path: assetPath,
          mixinData: mixin.toJSON(),
          includedIn: _.map(_.filter(this.parser.classes, function(clazz) {
            var _ref2;
            return _.contains((_ref2 = clazz.doc) != null ? _ref2.includeMixins : void 0, mixin.getMixinName());
          }), function(c) {
            return c.getClassName();
          }),
          extendedIn: _.map(_.filter(this.parser.classes, function(clazz) {
            var _ref2;
            return _.contains((_ref2 = clazz.doc) != null ? _ref2.extendMixins : void 0, mixin.getMixinName());
          }), function(c) {
            return c.getClassName();
          }),
          methods: _.map(mixin.getMethods(), function(m) {
            return m.toJSON();
          }),
          constants: _.map(_.filter(mixin.getVariables(), function(variable) {
            return variable.isConstant();
          }), function(m) {
            return m.toJSON();
          }),
          breadcrumbs: breadcrumbs
        }, "mixins/" + (mixin.getFullName().replace(/\./g, '/')) + ".html"));
      }
      return _results;
    };

    Generator.prototype.generateFiles = function() {
      var content, extra, filename, _i, _len, _ref, _results;
      _ref = _.union([this.options.readme], this.options.extras);
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        extra = _ref[_i];
        try {
          content = fs.readFileSync(extra, 'utf-8');
          if (/\.(markdown|md)$/.test(extra)) content = marked(content);
          filename = "" + extra + ".html";
          _results.push(this.templater.render('file', {
            path: '',
            filename: extra,
            content: content,
            breadcrumbs: [
              {
                href: 'class_index.html',
                name: 'Index'
              }, {
                href: "File: " + filename,
                name: extra
              }
            ]
          }, filename));
        } catch (error) {
          _results.push(console.log("[ERROR] Cannot generate extra file " + extra + ": " + error));
        }
      }
      return _results;
    };

    Generator.prototype.generateClassAndMixinIndex = function() {
      var char, classes, code, mixins, sortedClasses, x, _i, _j, _len, _len2;
      sortedClasses = {};
      for (code = 97; code <= 122; code++) {
        char = String.fromCharCode(code);
        classes = _.filter(this.parser.classes, function(clazz) {
          return clazz.getName().toLowerCase()[0] === char;
        });
        mixins = _.filter(this.parser.mixins, function(mixin) {
          return mixin.getName().toLowerCase()[0] === char;
        });
        if (classes.length + mixins.length > 0) {
          sortedClasses[char] = [];
          if (!_.isEmpty(classes)) {
            for (_i = 0, _len = classes.length; _i < _len; _i++) {
              x = classes[_i];
              sortedClasses[char].push(x);
            }
          }
          if (!_.isEmpty(mixins)) {
            for (_j = 0, _len2 = mixins.length; _j < _len2; _j++) {
              x = mixins[_j];
              sortedClasses[char].push(x);
            }
          }
        }
      }
      return this.templater.render('index', {
        path: '',
        classes: sortedClasses,
        files: _.union([this.options.readme], this.options.extras.sort()),
        breadcrumbs: []
      }, 'class_index.html');
    };

    Generator.prototype.generateClassAndMixinLists = function() {
      var classes, clazz, mixin, mixins, traverse, _i, _j, _len, _len2, _ref, _ref2;
      classes = [];
      mixins = [];
      traverse = function(entity, children, section) {
        var child, namespace, namespaces;
        if (entity.getNamespace()) {
          namespaces = entity.getNamespace().split('.');
          while (namespace = namespaces.shift()) {
            child = _.find(children, function(c) {
              return c.name === namespace;
            });
            if (!child) {
              child = {
                name: namespace
              };
              children.push(child);
            }
            child.children || (child.children = []);
            children = child.children;
          }
        }
        return children.push({
          name: entity.getName(),
          href: "" + section + "/" + (entity.getFullName().replace(/\./g, '/')) + ".html",
          parent: typeof entity.getParentClassName === "function" ? entity.getParentClassName() : void 0
        });
      };
      _ref = this.parser.classes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        clazz = _ref[_i];
        traverse(clazz, classes, 'classes');
      }
      _ref2 = this.parser.mixins;
      for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
        mixin = _ref2[_j];
        traverse(mixin, mixins, 'mixins');
      }
      this.templater.render('class_list', {
        path: '',
        classes: classes
      }, 'class_list.html');
      return this.templater.render('mixin_list', {
        path: '',
        mixins: mixins
      }, 'mixin_list.html');
    };

    Generator.prototype.generateMethodList = function() {
      var methods, nonconstructors;
      nonconstructors = _.filter(this.parser.getAllMethods(), function(m) {
        return m.getName() !== 'constructor';
      });
      methods = _.map(nonconstructors, function(method) {
        var _ref;
        return {
          path: '',
          name: method.getName(),
          href: "" + (method.entity.constructor.name === 'Class' ? 'classes' : 'mixins') + "/" + (method.entity.getFullName().replace(/\./g, '/')) + ".html#" + (method.getName()) + "-" + (method.getType()),
          classname: method.entity.getFullName(),
          deprecated: (_ref = method.doc) != null ? _ref.deprecated : void 0,
          type: method.type
        };
      });
      return this.templater.render('method_list', {
        methods: _.sortBy(methods, function(method) {
          return method.name;
        })
      }, 'method_list.html');
    };

    Generator.prototype.generateFileList = function() {
      return this.templater.render('file_list', {
        path: '',
        files: _.union([this.options.readme], this.options.extras.sort())
      }, 'file_list.html');
    };

    Generator.prototype.copyAssets = function() {
      this.copy("" + __dirname + "/../theme/default/assets/codo.css", "" + this.options.output + "/assets/codo.css");
      return this.copy("" + __dirname + "/../theme/default/assets/codo.js", "" + this.options.output + "/assets/codo.js");
    };

    Generator.prototype.copy = function(from, to) {
      var dir;
      dir = path.dirname(to);
      return mkdirp(dir, function(err) {
        if (err) {
          return console.error("[ERROR] Cannot create directory " + dir + ": " + err);
        } else {
          from = fs.createReadStream(from);
          to = fs.createWriteStream(to);
          return to.once('open', function(fd) {
            return require('util').pump(from, to);
          });
        }
      });
    };

    return Generator;

  })();

}).call(this);
