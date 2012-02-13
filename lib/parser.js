(function() {
  var Class, CoffeeScript, Parser, fs;

  fs = require('fs');

  CoffeeScript = require('coffee-script');

  Class = require('./nodes/class');

  module.exports = Parser = (function() {

    function Parser() {
      this.classes = [];
    }

    Parser.prototype.parse = function(file) {
      var content, root,
        _this = this;
      content = fs.readFileSync(file, 'utf8');
      root = CoffeeScript.nodes(content);
      return root.traverseChildren(true, function(child) {
        if (child.constructor.name === 'Class') {
          return _this.classes.push(new Class(child));
        }
      });
    };

    return Parser;

  })();

}).call(this);
