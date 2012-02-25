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
      this.referencer = new Referencer(this.parser.classes);
      this.templater = new Templater(this.options, this.referencer);
    }

    Generator.prototype.generate = function() {
      this.generateFrames();
      this.generateReadme();
      this.generateClasses();
      this.generateModules();
      this.generateExtras();
      this.generateIndex();
      this.generateClassList();
      this.generateModulesList();
      this.generateMethodList();
      this.generateFileList();
      return this.copyAssets();
    };

    Generator.prototype.generateFrames = function() {
      return this.templater.render('frames', {
        path: ''
      }, 'frames.html');
    };

    Generator.prototype.generateReadme = function() {
      var filename, readme;
      try {
        readme = fs.readFileSync(this.options.readme, 'utf-8');
        if (/\.(markdown|md)$/.test(this.options.readme)) readme = marked(readme);
        filename = 'index.html';
        return this.templater.render('file', {
          path: '',
          filename: this.options.readme,
          content: readme,
          breadcrumbs: [
            {
              href: 'class_index.html',
              name: 'Index'
            }, {
              href: "File: " + filename,
              name: this.options.readme
            }
          ]
        }, filename);
      } catch (error) {
        return console.log("[ERROR] Cannot generate readme file " + this.options.readme + ": " + error);
      }
    };

    Generator.prototype.generateClasses = function() {
      var assetPath, breadcrumbs, clazz, combined, namespace, namespaces, _i, _j, _k, _len, _len2, _len3, _ref, _results;
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
          classData: clazz.toJSON(),
          classMethods: _.map(_.filter(clazz.getMethods(), function(method) {
            return method.type === 'class';
          }), function(m) {
            return m.toJSON();
          }),
          instanceMethods: _.map(_.filter(clazz.getMethods(), function(method) {
            return method.type === 'instance';
          }), function(m) {
            return m.toJSON();
          }),
          constants: _.map(_.filter(clazz.getVariables(), function(variable) {
            return variable.isConstant();
          }), function(m) {
            return m.toJSON();
          }),
          subClasses: _.map(this.referencer.getDirectSubClasses(clazz), function(c) {
            return c.getClassName();
          }),
          inheritedMethods: _.groupBy(this.referencer.getInheritedMethods(clazz), function(m) {
            return m.entity.getClassName();
          }),
          inheritedConstants: _.groupBy(this.referencer.getInheritedConstants(clazz), function(m) {
            return m.entity.getClassName();
          }),
          breadcrumbs: breadcrumbs
        }, "classes/" + (clazz.getClassName().replace(/\./g, '/')) + ".html"));
      }
      return _results;
    };

    Generator.prototype.generateModules = function() {
      var assetPath, breadcrumbs, combined, module, namespace, namespaces, _i, _j, _k, _len, _len2, _len3, _ref, _results;
      _ref = this.parser.modules;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        module = _ref[_i];
        namespaces = _.compact(module.getNamespace().split('.'));
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
          name: module.getName()
        });
        _results.push(this.templater.render('module', {
          path: assetPath,
          moduleData: module.toJSON(),
          methods: _.map(module.getMethods(), function(m) {
            return m.toJSON();
          }),
          constants: _.map(_.filter(module.getVariables(), function(variable) {
            return variable.isConstant();
          }), function(m) {
            return m.toJSON();
          }),
          breadcrumbs: breadcrumbs
        }, "modules/" + (module.getFullName().replace(/\./g, '/')) + ".html"));
      }
      return _results;
    };

    Generator.prototype.generateExtras = function() {
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

    Generator.prototype.generateIndex = function() {
      var char, classes, code, modules, sortedClasses, x, _i, _j, _len, _len2;
      sortedClasses = {};
      for (code = 97; code <= 122; code++) {
        char = String.fromCharCode(code);
        classes = _.filter(this.parser.classes, function(clazz) {
          return clazz.getName().toLowerCase()[0] === char;
        });
        modules = _.filter(this.parser.modules, function(module) {
          return module.getName().toLowerCase()[0] === char;
        });
        if (classes.length + modules.length > 0) {
          sortedClasses[char] = [];
          if (!_.isEmpty(classes)) {
            for (_i = 0, _len = classes.length; _i < _len; _i++) {
              x = classes[_i];
              sortedClasses[char].push(x);
            }
          }
          if (!_.isEmpty(modules)) {
            for (_j = 0, _len2 = modules.length; _j < _len2; _j++) {
              x = modules[_j];
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

    Generator.prototype.generateClassList = function() {
      return this.templater.render('class_list', {
        path: '',
        classes: _.sortBy(this.parser.classes, function(clazz) {
          return clazz.getName();
        })
      }, 'class_list.html');
    };

    Generator.prototype.generateModulesList = function() {
      return this.templater.render('module_list', {
        path: '',
        modules: _.sortBy(this.parser.modules, function(module) {
          return module.getName();
        })
      }, 'module_list.html');
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
          href: "" + (method.entity.constructor.name === 'Class' ? 'classes' : 'modules') + "/" + (method.entity.getFullName().replace(/\./g, '/')) + ".html#" + (method.getName()) + "-" + (method.getType()),
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
